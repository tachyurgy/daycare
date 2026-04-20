# Features — ComplianceKit

A plain-language tour of every feature in the app, organized by product pillar.
Each entry gives you: what the user sees, what the system does under the hood,
which REQ tickets cover it, and what state it's in right now.

State legend:
- **S** = scaffolded (files exist, compiles/type-checks, handlers present but not end-to-end tested)
- **B** = built (implemented with reasonable logic inside)
- **T** = TODO (open ticket, not started)

> This file is a living doc. If you add or change functionality, update the
> matching row here so `FEATURES.md` stays canonical. The source-of-truth for
> *what should exist* is [`SPEC.md`](./SPEC.md); this file is about *what
> actually works*.

---

## Table of contents

1. [Authentication & Sessions](#1-authentication--sessions)
2. [Onboarding (TurboTax-style wizard)](#2-onboarding-turbotax-style-wizard)
3. [Compliance Dashboard](#3-compliance-dashboard)
4. [Child File Management](#4-child-file-management)
5. [Staff File Management](#5-staff-file-management)
6. [Document Management & OCR](#6-document-management--ocr)
7. [PDF E-Signature (our own tech)](#7-pdf-e-signature-our-own-tech)
8. [Parent & Staff Upload Portals](#8-parent--staff-upload-portals)
9. [Compliance Engine (deterministic rules)](#9-compliance-engine-deterministic-rules)
10. [Immunization Schedule Engine](#10-immunization-schedule-engine)
11. [Document Chase Service (notifications)](#11-document-chase-service-notifications)
12. [Facility & Operations](#12-facility--operations)
13. [Inspection Readiness](#13-inspection-readiness)
14. [Billing & Subscriptions (Stripe)](#14-billing--subscriptions-stripe)
15. [Legal Agreement Flow](#15-legal-agreement-flow)
16. [Audit Log](#16-audit-log)
17. [Data Deletion & Retention](#17-data-deletion--retention)
18. [Admin / Provider Settings](#18-admin--provider-settings)
19. [Observability & Ops](#19-observability--ops)
20. [Marketing & SEO Content](#20-marketing--seo-content)

---

## 1. Authentication & Sessions

**What the user sees.** No passwords. A provider admin types their email on
`/login`, gets a one-time link by email (and optionally SMS), clicks it, and
lands in their dashboard. Parents and staff each get a *persistent* magic link
from the provider that keeps them logged into their own upload portal for
seven days at a time.

**Under the hood.** Two token kinds backed by one mechanism:

| Kind | TTL | Use |
|---|---|---|
| `provider_signup` | 15 min | First-time signup |
| `provider_signin` | 15 min | Returning login |
| `parent_upload` | 7d sliding | Parent portal session |
| `staff_upload` | 7d sliding | Staff portal session |
| `document_sign` | 72h | E-signature session |

Tokens are 32 random bytes, base62-encoded (26 chars). Only the HMAC-SHA256
hash is stored in `magic_link_tokens`; plaintext is only ever in the URL. On
consumption the server sets an HttpOnly + Secure + SameSite=Lax cookie
referencing a row in `sessions`. Rate-limited per IP+endpoint via in-memory
token bucket.

- Packages: `backend/internal/magiclink`, `backend/internal/middleware/auth.go`, `backend/internal/middleware/ratelimit.go`
- Tables: `magic_link_tokens`, `sessions`
- Frontend: `pages/MagicLinkRequest.tsx`, `pages/MagicLinkCallback.tsx`, `hooks/useSession.ts`
- Tickets: REQ009–REQ014
- **State: B** (real token gen, hashing, cookie logic; ratelimit in-memory only)

---

## 2. Onboarding (TurboTax-style wizard)

**What the user sees.** A friendly, one-question-at-a-time wizard after first
signup. Six steps:
1. **State** — CA, TX, FL only for MVP.
2. **License type** — center vs. family child care home.
3. **Facility details** — address, capacity, ages served, timezone.
4. **Staff roster** — paste a CSV or add people one at a time.
5. **Children roster** — same pattern.
6. **Review** — confirm, then land on a dashboard with a starting compliance
   score and a checklist of what to upload next.

Draft state persists to localStorage so closing the tab mid-wizard is safe.

**Under the hood.** Zustand store `wizardStore.ts` holds draft state; on
completion the client POSTs each section to the backend, which then runs the
first compliance evaluation and writes a `compliance_snapshot`. The checklist
comes from the deterministic rule packs (§9) — no LLM at this step.

- Frontend: `pages/onboarding/OnboardingWizard.tsx` plus `StepState/LicenseType/Facility/Staff/Children/Review.tsx` and `wizardStore.ts`
- Backend: `handlers/providers.go`, `handlers/children.go`, `handlers/staff.go`, `compliance/engine.go`
- Tickets: REQ015–REQ021
- **State: S**

---

## 3. Compliance Dashboard

**What the user sees.** The app's home page after onboarding:
- Big compliance score (0–100) in the brand color.
- Critical alerts list (anything overdue or blocking an inspection).
- 90-day timeline of upcoming deadlines (grouped by week).
- Quick actions: "Upload a document", "Invite a parent", "Send staff a cert request", "Start a self-inspection".
- Facility quick-flags: ratio OK, wall postings complete, most-recent fire drill date.

**Under the hood.** `GET /api/dashboard` returns a single payload built from:
- Latest `compliance_snapshot` (computed daily + on every document change)
- `documents` filtered to `expiration_date <= today + 90d`
- `drill_logs` count in trailing 90d
- `providers.ratio_ok` and `providers.postings_complete` flags

Scores are cached in `compliance_snapshots` so the dashboard is one DB
round-trip.

- Frontend: `pages/Dashboard.tsx`, `hooks/useDashboard.ts`, `api/dashboard.ts`
- Backend: `handlers/dashboard.go`, `compliance/engine.go`
- Tickets: REQ037, REQ038, REQ040
- **State: S** (the handler is real; the rule packs return hard-coded
  placeholder rules — see §9)

---

## 4. Child File Management

**What the user sees.** A table of all enrolled children. Click a child to
see their detail page: demographics, guardians, allergies + medical notes,
required documents per state (immunizations, emergency contact form,
physician health form, etc.), status chips for each (missing /
uploaded / expiring / compliant), timeline of past uploads.

**Under the hood.** Two tables: `children` (one row per kid) and
`child_documents_required` (one row per required doc type, status cached for
fast dashboard filters). When a document is uploaded against a child, the
compliance engine re-runs for just that child and updates the status row.

- Frontend: `pages/Children.tsx`, `pages/ChildDetail.tsx`, `api/children.ts`, `hooks/useChildren.ts`
- Backend: `handlers/children.go`, `models/models.go`
- Tables: `children`, `child_documents_required`
- Tickets: REQ020 (bulk roster), REQ028 (document linking)
- **State: S**

---

## 5. Staff File Management

**What the user sees.** Same shape as Children. Table, detail page, required
certifications with status chips (CPR, first aid, TB test, background check
clearance, orientation training hours, continuing ed hours). For staff the
emphasis is **expirations** — CPR lapses every two years, TB tests have a
rolling cadence, background checks need re-fingerprinting per state rules.

**Under the hood.** Mirrors Children: `staff` + `staff_certifications_required`.

- Frontend: `pages/Staff.tsx`, `pages/StaffDetail.tsx`
- Backend: `handlers/staff.go`
- Tickets: REQ019, REQ029
- **State: S**

---

## 6. Document Management & OCR

**What the user sees.** "Upload a document" opens a picker, the file goes
straight to S3, and within a few seconds the document's expiration date
appears auto-filled, with a "confirm expiration?" prompt. Docs show up in
three places: under the child/staff they're linked to, in a global Documents
table, and (when unassigned) in an "Unassigned photo inbox."

**Under the hood.** A proper pipeline:

```
client → presigned PUT → S3 (ck-files) → document row written
       ↓
   OCR worker: Mistral primary → Gemini fallback → raw_text + confidence
       ↓
   LLM expiration extraction: Gemini Flash with JSON-schema response mode
       ↓
   expiration_date + confidence persisted; user asked to confirm if confidence < 0.85
```

Uploads from parent/staff portals can also arrive *unassigned* (phone
uploads before linking to a child). They go to `document_unassigned_photos`
and wait for assignment; OCR runs even on unassigned so the photo inbox is
searchable.

- Frontend: `pages/Documents.tsx`, `pages/DocumentDetail.tsx`, `api/documents.ts`
- Backend: `handlers/documents.go`, `internal/ocr/ocr.go`, `internal/ocr/expiration.go`, `internal/storage/s3.go`
- Tables: `documents`, `document_ocr_results`, `document_unassigned_photos`
- Bucket: `ck-files` (all objects under key prefixes: `docs/`, `templates/`, `signed/`, `audit/`)
- Tickets: REQ022–REQ030
- **State: S** (presign, OCR chain, and Gemini expiration call are all
  implemented; unassigned-photo assignment UI is stub)

---

## 7. PDF E-Signature (our own tech)

**What the user sees.** Two flows.

*Provider authoring:* Templates page → upload a blank PDF → **Field
Designer** drags Signature / Date / Text / Checkbox fields anywhere on any
page → save template.

*Signer:* recipient opens `/sign/:token` on any device → sees the PDF with
overlay fields → signs with finger or mouse → taps Submit → receives a
copy of the signed PDF with an automatically appended *audit certificate*
page (signer name, IP, user agent, timestamp, SHA-256 of original +
signed).

**Under the hood.**
- Browser rendering via `react-pdf` (PDF.js).
- Signature capture via `signature_pad` (touch + mouse + stylus).
- PDF stamping via `pdf-lib` — stamps signature PNG at recorded field
  coordinates, then appends the audit page.
- Client computes SHA-256 and posts to `POST /api/pdfsign/sessions/:token/finalize`.
  The server **recomputes SHA-256** (never trusts the client hash), verifies
  the PDF is well-formed, stores the signed file in `ck-files` under
  `signed/`, writes audit JSON alongside it under `audit/`, and inserts the
  `signatures` row.
- Fields are frozen onto the *session* at invitation time, so edits to the
  template after a link is sent can't retroactively move fields.

Under federal ESIGN Act / UETA, this satisfies the requirements for a
legally binding electronic signature *if* the signer has consented to
electronic records (see §15) and the audit trail is preserved.

- Frontend: everything in `frontend/src/components/PdfSigner/`, plus
  `pages/SignDocument.tsx` and `pages/DocumentTemplates.tsx`
- Backend: `backend/internal/pdfsign/` (pdfsign.go, finalize.go, store.go, http.go, token.go)
- Spec: [`docs/pdf-signature-spec.md`](./docs/pdf-signature-spec.md)
- Audit schema: [`legal/signature-audit-trail-schema.md`](./legal/signature-audit-trail-schema.md)
- Tickets: REQ031–REQ034
- **State: B** (10 Go unit tests passing including tamper detection and
  hash mismatch rejection)

---

## 8. Parent & Staff Upload Portals

**What the user sees.** A parent gets a text message or email from the
daycare: *"Sunshine Daycare needs an updated immunization record for Lucas.
Upload here: [link]"*. They tap, skip auth (the magic link *is* their auth),
see a mobile-friendly page that shows only the docs their child is missing,
and snap a photo or pick a file. Staff get the same flow for their certs.

Fallback: if the parent doesn't have the link, the provider can print a QR
code taped to the front desk that opens a generic "find my child's
portal" page, keyed to the child's name plus guardian email.

**Under the hood.**
- Magic link kind is `parent_upload` or `staff_upload`, 7-day sliding.
- Portal page filters `child_documents_required` or
  `staff_certifications_required` to `status != compliant` and shows exactly
  those slots.
- Photo uploads preserve EXIF timestamps but strip location (privacy).
- Uploaded files go straight to `ck-files` under `docs/{provider_id}/{doc_id}.{ext}` and get a `documents` row; OCR runs against the same key.

- Frontend: `pages/PortalParent.tsx`, `pages/PortalStaff.tsx`, `api/portal.ts`
- Backend: `handlers/portal.go`, `internal/magiclink`
- Legal: `legal/parent-consent.md`, `legal/employee-consent.md` (both
  EN + ES) shown on first portal visit
- Tickets: REQ049–REQ052
- **State: S**

---

## 9. Compliance Engine (deterministic rules)

**What the user sees.** A compliance score from 0 to 100, a list of
specific violations (each citing the exact regulation), and a 90-day
timeline of upcoming deadlines. No AI-generated compliance advice — every
number is traceable to a specific rule.

**Under the hood.** A pure Go function:

```go
func Evaluate(state State, provider *ProviderFacts) *Report
```

No I/O, no LLM, fully testable. Rules are code in
`compliance/rules_ca.go` / `rules_tx.go` / `rules_fl.go`, each
returning `[]Rule`. Each rule has: id, citation (e.g., "CA Title 22
§101212"), severity (informational / warning / critical), a
pure predicate on `ProviderFacts`, and a human-readable violation
template.

Ten rules per state at launch, covering (per state): child immunizations,
staff TB tests, staff CPR, background checks, ratios, drills, wall
postings, license renewal, emergency info on file, incident/illness
reporting readiness.

Compliance score formula: `100 - Σ(severity_weight × violation_count) / max_possible`, clamped to [0, 100].

- Backend: `internal/compliance/engine.go`, `rules_ca.go`, `rules_tx.go`, `rules_fl.go`, `engine_test.go`
- Tickets: REQ035–REQ040
- **State: B** (evaluator + scoring implemented; rule packs use real state
  form references — LIC-281A, HHSC 2935, CF-FSP 5274 — but the specific
  rule predicates are stubbed to default outcomes; 5 table-driven tests
  green)

---

## 10. Immunization Schedule Engine

**What the user sees.** For each enrolled child, the system automatically
knows which immunizations are due, overdue, or up to date — based on the
child's date of birth and the CDC ACIP schedule. No manual entry of
"when should my 18-month-old's next MMR be due."

**Under the hood.** Hard-coded CDC schedule in
`internal/immunization/schedule.go`. Function:

```go
func Required(stateCode string, childAgeMonths int) []Immunization
```

Ten vaccines covered: DTaP, IPV, MMR, Varicella, HepA, HepB, Hib, PCV13,
Rotavirus, influenza. **No LLM is called for this** — regulatory
requirements for a legally-binding compliance score must be deterministic.

- Backend: `internal/immunization/schedule.go` + `schedule_test.go`
- Tickets: implicitly supports REQ035, REQ040
- **State: B**

---

## 11. Document Chase Service (notifications)

**What the user sees.** Weeks before a document expires, the right person
(parent for a child's doc, staff member for their own cert) starts getting
friendly reminders by email and SMS. Thresholds: 6w, 4w, 2w, 1w, 3d, and
overdue. If they act, reminders stop. If they don't, the provider admin
gets an escalation.

**Under the hood.**
- Cron-like loop: `chase.RunDaily(ctx)` kicks off from the Go server every
  morning.
- Scanner: find rows in `documents` where `expiration_date` falls on a
  threshold boundary for this run.
- Dedup via `document_chase_sends (document_id, threshold_days, channel)`
  primary key — we never send the same reminder twice.
- Quiet hours: no sends 9pm–8am in the recipient's timezone.
- Channel fanout: email via SES, SMS via Twilio, in-app notification row.
- Suppression honored via `notification_suppressions` (unsubscribes, hard
  bounces, complaints).

- Backend: `internal/notify/chase.go`, `email.go`, `sms.go`
- Tables: `chase_events`, `document_chase_sends`, `notification_suppressions`
- Tickets: REQ041–REQ045
- **State: B** (scheduler + dedup + quiet hours implemented; send is live
  if SES + Twilio credentials are set)

---

## 12. Facility & Operations

**What the user sees.** Module for the non-document stuff the state still
inspects you on:
- Daily safety checklists (digital replacement for the clipboard).
- Drill scheduler/logger — fire, tornado, lockdown — with automatic
  cadence enforcement.
- Wall posting tracker — did you post the license, the menu, the emergency
  plan, the mandated reporter sign?
- Ratio calculator — given staff on duty + kids present, are you inside
  the state-mandated ratio?

**Under the hood.**
- `drill_logs` table with trigger for `updated_at`; dashboard reads count
  of drills in trailing 90 days.
- Ratio calc is a pure function in Go; operationally it reads
  `providers.ratio_ok` as the cached flag (recomputed when staffing or
  roster changes).
- Wall postings tracked as a checklist with per-item confirmation plus
  photo upload; cached into `providers.postings_complete`.

- Backend: (wiring exists in `handlers/dashboard.go` that reads the
  `providers.ratio_ok` + `postings_complete` columns; full CRUD endpoints
  are TODO)
- Tables: `drill_logs`, columns on `providers`
- Tickets: covered by the "Facility & Operations" pillar in SPEC;
  individual tickets TBD post-MVP
- **State: T** for CRUD UI; **S** for the data model

---

## 13. Inspection Readiness

**What the user sees.**
- A **self-inspection simulator** that walks the admin through the same
  checklist a real state inspector uses — same questions, same order.
  Answers are scored in real time.
- A **violation risk assessment** — before the inspector arrives, the
  system predicts which items are most likely to trigger a finding given
  the provider's current state.
- One-click **inspection-ready report** — a PDF that mirrors the state's
  own inspection form, pre-populated with the provider's current data,
  shown to an inspector to speed things up.

**Under the hood.** The simulator reuses the compliance engine (§9) but
with a different presentation. The inspection-ready report is generated
server-side by rendering a predefined template from
`planning-docs/state-docs/*/`*-product-spec.html* content and stamping
values via pdf-lib (backend uses pdfcpu).

- Tickets: post-MVP (design already in [`planning-docs/`](./planning-docs/))
- **State: T**

---

## 14. Billing & Subscriptions (Stripe)

**What the user sees.** After onboarding, a 14-day free trial begins
automatically. At day 11 the admin gets reminded. They click "Upgrade" →
Stripe Checkout → $99/mo. Promo codes apply (e.g., `LAUNCH50` for 50% off
first three months). A "Manage billing" link opens Stripe's customer
portal for cancel / update card / past invoices.

**Under the hood.**
- `POST /api/billing/checkout-session` → creates a Stripe Checkout
  Session with `STRIPE_PRICE_PRO`, optionally attaches a promo code.
- `POST /api/stripe/webhook` handles `customer.subscription.created /
  updated / deleted` and `invoice.payment_failed`. All events idempotently
  logged to `stripe_events`; duplicate delivery is harmless.
- Paywall middleware (`RequireStripeCustomer`) gates premium routes; trial
  counts as paid.
- Subscription state mirrored in `subscriptions` (one row per provider).

- Backend: `internal/billing/stripe.go`, `handlers/webhook_stripe.go`, `middleware/auth.go` (`RequireStripeCustomer`)
- Frontend: `pages/SettingsBilling.tsx`, `api/billing.ts`
- Tables: `subscriptions`, `stripe_events`
- Tickets: REQ046–REQ048
- **State: B** (real Stripe SDK calls; needs real keys + price ID to test
  end-to-end)

---

## 15. Legal Agreement Flow

**What the user sees.**
- At signup: a single checkbox + click-through accepting MSA + DPA +
  Privacy Policy + ESIGN Act disclosure in one shot. Each is a link.
- First time a parent or staff member hits their portal: a short
  plain-language consent (separate from the B2B agreements).
- When we update any policy: the next time that user logs in, they see
  a diff and must re-accept.

**Under the hood.**
- `policy_versions` table stores each version of each document (kind +
  version string + effective_at + SHA-256 of the content).
- `policy_acceptances` stores one row per user-accept event, with
  timestamp + IP + user agent.
- Admin-facing CLI/UI to publish a new version: writes `policy_versions`
  row, re-prompts users on next login.

- Backend: (tables + a light-weight version check middleware are wired;
  admin publishing UI is TODO)
- Legal: `legal/privacy-policy.md`, `terms-of-service.md`,
  `master-subscription-agreement.md`, `data-processing-agreement.md`,
  `esignature-disclosure.md`, `parent-consent.md`, `employee-consent.md`
- Tables: `policy_versions`, `policy_acceptances`
- Tickets: REQ053, REQ054
- **State: S**

---

## 16. Audit Log

**What the user sees.** In Settings → Audit Log, admins can see a filterable
list of everything that happened in the account: who logged in, what
document was viewed, who signed what, what policy version was accepted, etc.
Data retained 7 years.

**Under the hood.** Every write-side handler emits a row to `audit_log`
(provider_id, actor_kind, actor_id, action, target_kind, target_id,
metadata JSONB, ip, user_agent). Heavy writes are acceptable; read paths
filter by `(provider_id, created_at DESC)` — index exists.

Importantly, `audit_log` rows use `ON DELETE SET NULL` on the provider FK:
when a provider is purged after churn (§17), audit rows survive for
legal/forensic purposes.

- Backend: (table exists; emission helper is defined but not yet wired
  into every handler — that's a post-MVP sweep)
- Table: `audit_log`
- Tickets: touches REQ055 and observability
- **State: S**

---

## 17. Data Deletion & Retention

**What the user sees.** When a provider cancels, they get a 90-day grace
window (their data is read-only). At day 90, a scheduled purge removes all
their documents, children, staff, uploads, and derivative records. They
get a one-page "your data has been deleted" confirmation with a SHA-256
hash of the deletion manifest.

Individual users (parents, staff) can request deletion through the daycare;
the daycare admin initiates it from within the app (CCPA/CPRA/TDPSA/FDBR
compliance).

**Under the hood.**
- Soft-delete flags (`deleted_at`) flipped immediately on cancellation.
- A `churn_purges` job queue (new, TODO) runs on day 90:
  - deletes all S3 objects under `docs/{provider_id}/`, `templates/{provider_id}/`, and `signed/{provider_id}/` in `ck-files`.
  - **keeps** `audit/{provider_id}/` entries (7yr legal hold — app-enforced, not bucket policy).
  - deletes rows via `ON DELETE CASCADE`.
- A deletion manifest is written to `ck-files` under `audit/{provider_id}/deletion-{ts}.json` with the list of deleted object keys and a timestamp.

- Backend: `internal/storage/s3.go` has `DeleteAllForProvider`; the cron
  wrapper and queue are TODO.
- Tickets: REQ055
- **State: T** (helper exists; scheduler and manifest writer are TODO)

---

## 18. Admin / Provider Settings

**What the user sees.** The settings area: profile, team members
(invite + role), organization details, billing link, audit log link,
policy versions signed, "Export all my data" button (ZIP of all docs +
CSV of all data, served via time-limited S3 URL), "Cancel subscription"
button (triggers §17 flow).

**Under the hood.** Standard CRUD endpoints; data export is a backgrounded
job that zips S3 objects, drops the ZIP in `ck-files` under
`exports/{provider_id}/{ts}.zip`, and emails a pre-signed GET URL.

- Frontend: `pages/Settings.tsx`, `pages/SettingsBilling.tsx`
- Backend: extends `handlers/providers.go`
- Tickets: post-MVP polish (some covered by REQ048)
- **State: S** for basics, **T** for data export

---

## 19. Observability & Ops

**What the user sees.** Nothing — this is for the operator.

**Under the hood.**
- Structured JSON logs via `log/slog` to stdout.
- Request ID middleware propagates through the stack, ends up in the
  error envelope so customer support can find a failure.
- Health endpoint `GET /healthz` (200 if DB reachable), `GET /readyz`
  (200 only after first successful DB ping).
- Uptime monitoring via UptimeRobot free tier hitting `/healthz`.
- Optional: log shipping to Grafana Cloud / Loki (config flag).
- Backups: `infra/scripts/backup-db.sh` runs nightly pg_dump to
  `ck-backups` bucket with 30-day lifecycle.

- Backend: `cmd/server/main.go` (slog setup), `httpx/errors.go` (request_id)
- Infra: `infra/scripts/backup-db.sh`, `backend/deploy/compliancekit.service`
- Tickets: REQ059, REQ060
- **State: S** (logs + healthz done; log shipping and uptime monitor
  are one-off config tasks)

---

## 20. Marketing & SEO Content

**What the user sees (not logged in).** Our content-led SEO funnel:
- Product page: `compliancekit-product-overview.html`
- Strategy/About: `compliancekit-product-strategy.html`
- SEO articles: `how-to-pass-daycare-inspection-{state}.html`,
  `how-to-start-a-daycare-{state}.html`,
  `daycare-immunization-requirements-{state}.html` (for CA, TX, FL)
- Prototype: `prototype.html`
- Expansion plan: `expansion.html`

**Under the hood.** Pre-existing static HTML deployed alongside the React
app on GitHub Pages. The CTA on each article links to `/login` or
`/signup` on the app.

- Repo root: all `*.html` files
- Tickets: none (content already written)
- **State: B**

---

## Cross-cutting properties

These aren't features per se, but are guarantees that cut across
everything above.

- **Base62 IDs everywhere.** 26-character opaque strings. No auto-incrementing
  integers, no UUIDs in user-facing URLs.
- **No passwords.** Ever. Magic links for humans, API keys for machines.
- **Tenant isolation.** Every write checks `provider_id`. Every read filters
  by `provider_id`. Middleware enforces session → provider binding.
- **Cheapest external services that do the job.** Mistral over Textract,
  Gemini Flash over GPT-4, SES over SendGrid, Twilio pay-as-you-go,
  DigitalOcean over AWS compute. See [`EXTERNAL_SERVICES.md`](./EXTERNAL_SERVICES.md).
- **Deterministic compliance, LLM-assisted data entry.** LLMs extract
  expiration dates from OCR text and power the onboarding chat
  personality. LLMs never decide if you are in compliance.
- **Drafts, not advice.** Every legal document in `legal/` carries a "have
  an attorney review before use" banner.
- **Everything audited.** Magic-link consumption, signature events,
  document uploads, policy acceptances, billing changes — all append to
  `audit_log` or a bucket with Object Lock.

---

## How the pieces fit

```
Marketing HTML (GitHub Pages)
      │
      ▼
  /signup (React)  ─┐
                    │ magic link → email (SES) / SMS (Twilio)
                    ▼
              click the link
                    │
                    ▼
         Session cookie set, redirect to:
                    │
      ┌─────────────┼─────────────┐
      ▼             ▼             ▼
 Onboarding      Dashboard     Portal
 (if new)                      (parent/staff)
                    │
      ┌─────────────┼─────────────────────────┐
      ▼             ▼                         ▼
  Children     Documents (upload + OCR)    Templates
  Staff            │                         │
                   ▼                         ▼
              Compliance engine          PDF Signer
                   │                         │
                   ▼                         ▼
              Chase service              ck-files (audit/)
              (email + SMS)
                   │
                   ▼
               Stripe ($99/mo)
```

---

## For contributors

If you add a feature, update this file in the same PR. The format of each
entry is stable: user-facing blurb → under-the-hood mechanics → file/ticket
pointers → state. Keep entries terse. The goal of this doc is navigability,
not exhaustiveness.

For anything that isn't clearly one of the 20 features above, either
extend the most-related section or propose a new one in a PR.
