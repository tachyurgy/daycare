# ComplianceKit — Feature Audit & Gap Report (CA/TX/FL MVP)

**Audit date:** 2026-04-20 · **MVP deadline:** 2026-04-23 · **Three days to ship.**

This is the master feature guide. It reconciles what `SPEC.md` and `FEATURES.md` *claim* we have against what's actually implemented in `backend/` and `frontend/`. Every row has:

- **Acceptance criteria** — the concrete "done" for that feature (CA/TX/FL-aware).
- **Backend status** — what exists in Go handlers, services, migrations.
- **Frontend status** — what exists in React pages/components.
- **Gap verdict** — 🟢 ship-ready · 🟡 functional with gaps · 🔴 missing / stubbed.
- **What to fix** — the exact work that closes the gap, in priority order.

---

## Summary table — ship-readiness by feature

| # | Feature | Backend | Frontend | Verdict | Demo-blocker? |
|---|---|---|---|---|---|
| 1 | Auth & magic-link sessions | ✅ real | ✅ real | 🟢 | — |
| 2 | Onboarding wizard (6 steps) | ✅ real | ✅ real | 🟢 | — |
| 3 | Compliance dashboard | ✅ real | ✅ real | 🟢 | — |
| 4 | Child file management | ✅ real | ✅ real | 🟢 | — |
| 5 | Staff file management | ✅ real | ✅ real | 🟢 | — |
| 6 | Document upload + OCR | ✅ real | ✅ real | 🟡 | No (requires Mistral/Gemini keys) |
| 7 | PDF e-signature | ✅ real | ✅ real | 🟡 | No (mounted conditionally) |
| 8 | Parent + staff upload portals | ✅ real | ✅ real | 🟢 | — |
| 9 | Compliance engine (rule packs CA/TX/FL) | ✅ real (10 rules × 3 states) | ✅ renders report | 🟢 | — |
| 10 | Immunization schedule engine | ✅ real (CDC ACIP) | ✅ renders | 🟢 | — |
| 11 | Document chase service | ✅ real (daily loop) | ✅ views in-app | 🟢 | — |
| **12** | **Facility & operations (drills, ratio, postings)** | **🔴 tables only** | **🔴 no UI** | **🔴** | **YES** |
| **13** | **Inspection readiness simulator** | **🔴 not built** | **🔴 not built** | **🔴** | **YES** |
| 14 | Billing & Stripe | ✅ real | 🟡 portal iframe only | 🟡 | No |
| 15 | Legal agreement flow | ✅ tables | 🟡 signup checkbox | 🟡 | No |
| 16 | Audit log | ✅ table, loose schema | ❌ no admin view | 🟡 | No |
| 17 | Data deletion & 90d purge | 🟡 helper only | ❌ | 🔴 | No (post-MVP) |
| 18 | Admin settings / data export | 🟡 basic CRUD | 🟡 settings page | 🟡 | No |
| 19 | Observability (slog, /healthz) | ✅ | n/a | 🟢 | — |
| 20 | Marketing & SEO | n/a | ✅ static HTML | 🟢 | — |

**Bottom line:** 17 of 20 features are demo-ready. Three demo-blockers (#12 facility ops, #13 inspection sim, #17 purge) — two of them gate the core sales pitch (*"Be inspection-ready every single day"*).

---

## 1. Authentication & Magic-Link Sessions 🟢

**Acceptance criteria.**
- [x] Provider can request a signup link by email; receives email via SES within 30s; clicking logs them in.
- [x] Provider can request a signin link by email; 15-min TTL; rate-limited per IP.
- [x] Parent + staff get 7-day sliding magic links scoped to their upload portal only.
- [x] Document-sign links have 72h TTL.
- [x] Tokens are 32 random bytes, base62-encoded (26 chars). Only HMAC-SHA256 hash stored.
- [x] Consumption sets HttpOnly + Secure + SameSite=Lax session cookie.
- [x] Sessions table tracks `(provider_id, user_id, ip, user_agent, expires_at, revoked_at)`.

**Backend:** `internal/magiclink/`, `internal/middleware/auth.go`, `internal/middleware/ratelimit.go`. Token hashing + session cookie logic real. Rate limit is in-memory token bucket (10 burst, 0.5/sec) — fine at MVP scale.

**Frontend:** `pages/MagicLinkRequest.tsx`, `pages/MagicLinkCallback.tsx`, `hooks/useSession.ts`. `<RequireAuth>` + `<RequireOnboarded>` route guards.

**Gaps:** No session cleanup job — `sessions` table grows unbounded. Not a demo blocker but will bite in production at month 2. → See Fix #6.

---

## 2. Onboarding Wizard (TurboTax-style 6 steps) 🟢

**Acceptance criteria.**
- [x] Step 1: choose state from CA / TX / FL buttons.
- [x] Step 2: choose license type (center vs. family home).
- [x] Step 3: facility name, address, capacity, age range in months, timezone.
- [x] Step 4: staff roster — CSV paste or one-by-one.
- [x] Step 5: children roster — CSV paste or one-by-one.
- [x] Step 6: review → submit.
- [x] Draft persists to localStorage so closing the tab mid-wizard is safe.
- [x] On completion, the compliance engine runs and writes the first `compliance_snapshot`.

**Backend:** `handlers/providers.go` — signup + onboarding completion; `compliance/engine.go` runs on completion.

**Frontend:** `pages/onboarding/OnboardingWizard.tsx` + Step{State,LicenseType,Facility,Staff,Children,Review}.tsx + `wizardStore.ts` (Zustand + persist).

**Gaps:** CSV parser is simplistic (line-by-line split, no error handling). State-code validation missing on backend — junk value could write bad `providers.state` and break the engine. → See Fix #7.

---

## 3. Compliance Dashboard 🟢

**Acceptance criteria.**
- [x] `GET /api/dashboard` returns single payload: score 0–100, violation list, 90-day deadline timeline, module roll-ups, ratio/postings/drills flags.
- [x] Score cached in `compliance_snapshots` → one DB round-trip.
- [x] Recomputes on document finalize.
- [ ] **Nightly recompute cron** — not scheduled.

**Backend:** `handlers/dashboard.go` assembles report from latest snapshot + live document/drill counts.

**Frontend:** `pages/Dashboard.tsx` + `hooks/useDashboard.ts`. Score circle, alert list, 90-day timeline, module roll-ups all render.

**Gaps:** Missing nightly recompute → if a staff CPR card expires at midnight nothing marks it until the next doc upload triggers a recompute. → See Fix #5.

---

## 4. Child File Management 🟢

**Acceptance criteria.**
- [x] Enroll a child with name, DOB, guardians (JSON), allergies, medical notes.
- [x] Per-state required-document list seeded on enrollment.
- [x] Status chips per required doc: missing / uploaded / expiring / compliant.
- [x] Click child → detail page with timeline of uploads.
- [x] Bulk roster import via CSV.

**Backend:** `handlers/children.go`, tables `children` + `child_documents_required`.

**Frontend:** `pages/Children.tsx` + `pages/ChildDetail.tsx` + `api/children.ts`.

**Gaps:** Soft-deleted children leave orphaned `child_documents_required` rows — compliance engine may still evaluate them. Low priority cosmetic for MVP.

---

## 5. Staff File Management 🟢

**Acceptance criteria.**
- [x] Add staff with first/last/email/phone/role/hire date.
- [x] Per-state required-certification list (CPR, First Aid, TB, background check, orientation hours, CE hours).
- [x] Status chips + expiration tracking.
- [x] Bulk import via CSV.

**Backend:** `handlers/staff.go`, tables `staff` + `staff_certifications_required`.

**Frontend:** `pages/Staff.tsx` + `pages/StaffDetail.tsx`.

**Gaps:** Same soft-delete dangling rows issue as Children.

---

## 6. Document Upload + OCR 🟡

**Acceptance criteria.**
- [x] Client POSTs to `/api/documents/presign`, gets an S3 presigned PUT URL; uploads file direct to `ck-files`.
- [x] OCR runs: Mistral primary → Gemini fallback if confidence < 0.6.
- [x] Gemini extracts expiration date; written to `documents.expiration_date`.
- [x] User asked to confirm if confidence < 0.85.
- [x] Unassigned photos go to `document_unassigned_photos` and wait for admin assignment.
- [ ] **Gemini/Mistral keys must be set** — otherwise OCR silently no-ops.

**Backend:** `internal/ocr/*` — Mistral + Gemini HTTP clients with confidence-based chain. `internal/storage/s3.go` — PUT/GET/Presign. Unique SHA256 per provider prevents dupes.

**Frontend:** `pages/Documents.tsx` + `pages/DocumentDetail.tsx`. Unassigned-photo assignment UI is stub.

**Gaps:** Unassigned-photo assignment UI → low priority. OCR nil-check → production issue only (dev/test handles gracefully). For demo: set Mistral + Gemini keys, upload works.

---

## 7. PDF E-Signature 🟡

**Acceptance criteria.**
- [x] Provider uploads blank PDF template, drags signature/date/text/checkbox fields onto pages.
- [x] Signer opens `/sign/:token`, draws signature with finger/mouse, submits.
- [x] Server recomputes SHA-256 (never trusts client), writes signed PDF + audit JSON to `ck-files`.
- [x] Fields frozen at invitation time — edits to template don't retroactively move fields.
- [x] 10 Go unit tests passing, including tamper detection + hash mismatch rejection.

**Backend:** `internal/pdfsign/` with 10 unit tests.

**Frontend:** `components/PdfSigner/` + `pages/SignDocument.tsx` + `pages/DocumentTemplates.tsx`.

**Gaps:** `main.go` has `PDFSign: nil, // pdfsign package wires in here` — routes only mount if non-nil. **This must be wired before demo.** → See Fix #8.

---

## 8. Parent & Staff Upload Portals 🟢

**Acceptance criteria.**
- [x] Parent receives SMS/email link → opens mobile-friendly page → no login required (magic link is auth).
- [x] Parent sees only the docs their child is missing.
- [x] Staff has identical flow for their certs.
- [x] Photos preserve EXIF timestamps, strip location.
- [x] First-visit parent/staff consent (EN + ES) shown once.

**Backend:** `handlers/portal.go` + `internal/magiclink/`. Legal consents in `legal/parent-consent.md` + `employee-consent.md`.

**Frontend:** `pages/PortalParent.tsx` + `pages/PortalStaff.tsx`.

**Gaps:** None blocking.

---

## 9. Compliance Engine (Deterministic Rule Packs) 🟢

**Acceptance criteria.**
- [x] Pure function `Evaluate(state, facts)` — no I/O.
- [x] 10 rules per state covering: child immunizations, emergency info, physician report, staff TB, CPR/First Aid, background check, facility license, drills, ratios, wall postings.
- [x] Severity weights: Critical=5, Major=3, Minor=1.
- [x] Score = `100 × (Σweight of satisfied rules / Σ total weight)`.
- [x] Each rule has `Reference` (e.g., `"22 CCR §101216"`) and `FormRef` (e.g., `"LIC 508"`).

**Backend:** `internal/compliance/engine.go` + `rules_ca.go` + `rules_tx.go` + `rules_fl.go`. `engine_test.go` has CA + TX happy-path coverage.

**CA rules (real, not stubs):**
1. CA-CHILD-IMM — CDPH 286 (Blue Card) per enrolled child.
2. CA-CHILD-ADMISSION — LIC 627 + LIC 700.
3. CA-CHILD-PHYSICIAN-REPORT — LIC 701 / LIC 9165.
4. CA-STAFF-TB — LIC 503 within 1 year of hire.
5. CA-STAFF-CPR-FIRSTAID — CPR + Pediatric First Aid for every teacher/director.
6. CA-STAFF-BACKGROUND — LIC 508 + DOJ clearance before contact.
7. CA-FACILITY-LICENSE — LIC 203 displayed.
8. CA-DRILLS — monthly fire/earthquake/lockdown (≥3 in trailing 90d).
9. CA-RATIOS — `f.RatioOK` (1:4 infant, 1:12 preschool, 1:15 school-age).
10. CA-POSTINGS — `f.PostingsComplete` (LIC 995 Parents' Rights, evac map, license).

**TX rules (real):** 10 rules covering Chapter 746 — Form 2935, 7259, 2937, 2760, 2948, Form 2936 inspector checklist, drills, ratios (age-banded 1:4 to 1:22), postings.

**FL rules (real):** 10 rules covering 65C-22 — CF-FSP 5274/5316/5131, DH 680/681, Level 2 background, 40/45-hr Intro Training, 10 in-service hours, ratios (1:4 infant, 1:25 5+).

**Gaps:**
- OR/WA are `StateCode` enum values but have no rule packs. Not a 3-state-MVP blocker; rules return `[]Rule{}` for unknown states so score defaults to 100 (wrong but non-crashing).
- State code validation on signup is missing — junk code → empty rule pack → false 100 score. → See Fix #7.

---

## 10. Immunization Schedule Engine 🟢

**Acceptance criteria.**
- [x] `Required(stateCode, childAgeMonths)` returns the CDC ACIP schedule for 10 vaccines.
- [x] Pure function — deterministic.
- [x] `immunization/schedule_test.go` exists.

**Backend:** `internal/immunization/schedule.go`. Covers HepB, RV, DTaP, Hib, PCV13, IPV, Influenza, MMR, Varicella, HepA per CDC ACIP 2024.

**Frontend:** Child detail renders vaccine list + status badges (up_to_date / due_soon / overdue / exempt) from backend.

**Gaps:** State code is a reserved parameter — no per-state overrides yet. CA's SB 277 personal-belief-exemption removal isn't enforced in the engine (only medical exemptions valid). Add state-specific rules when we see real divergence. Low priority.

---

## 11. Document Chase Service 🟢

**Acceptance criteria.**
- [x] 24-hour loop started as goroutine on boot.
- [x] Scanner finds documents with `expiration_date` at threshold boundaries: 42d / 28d / 14d / 7d / 3d / overdue.
- [x] Dedup via `document_chase_sends` (composite PK) — no duplicate sends.
- [x] Channels: email (SES), SMS (Twilio), in-app notification row.
- [x] Suppression honored via `notification_suppressions`.
- [x] Quiet hours 21:00–08:00 recipient's TZ.

**Backend:** `internal/notify/chase.go`, `email.go`, `sms.go`. `main.go` kicks `go chase.RunDaily(ctx)`.

**Frontend:** Notifications visible in-app (count badge on dashboard). No separate "chase feed" page; fine for MVP.

**Gaps:** If SES/Twilio keys not set, chase silently no-ops. Production only.

---

## 12. Facility & Operations 🔴 **DEMO BLOCKER**

**Acceptance criteria (per SPEC §4.4 + FEATURES §12).**
- [ ] Daily safety checklist (state-configurable) — owner can check items off once a day; last-completed timestamp shown.
- [ ] Drill scheduler/logger (fire, tornado, lockdown, earthquake) with cadence enforcement.
  - CA: monthly fire + biannual earthquake.
  - TX: monthly fire + quarterly severe-weather.
  - FL: monthly fire + quarterly lockdown + annual reunification.
- [ ] Wall-posting tracker: per-item checklist with photo evidence. States require: license, ratio chart, menu, emergency plan, mandated-reporter sign (+ state-specific: CA LIC 995, TX 2936 summary, FL DCF hotline poster).
- [ ] Ratio calculator: given staff on duty + kids present per age band, compute if in ratio. Per-state age bands.
- [ ] Incident log (already covered by document upload flow with `doc_type=incident_report`).

**Backend status:** 🔴
- `drill_logs` table **exists** (migration 000009), but **no CRUD handlers**. Nobody can log a drill.
- `providers.ratio_ok` + `postings_complete` columns **exist** but **nothing writes to them**.
- No daily-checklist table at all.

**Frontend status:** 🔴 No Facility / Operations page exists. Dashboard reads the ratio/postings flags but there's no UI to set them.

**This is the biggest MVP gap.** Five of our 10 compliance rules per state reference `DrillsLast90d` / `RatioOK` / `PostingsComplete` — they're effectively dead checks without the CRUD.

**Fix plan (Fix #1):**
1. Add `POST /api/drills` + `GET /api/drills` + `DELETE /api/drills/:id` handlers.
2. Add `PATCH /api/facility/postings` that toggles individual posting items (JSON column `facility_postings` on `providers`) and recomputes `postings_complete` = all required posted.
3. Add `POST /api/facility/ratio-check` that takes current staff + children rosters + state code, computes in-ratio, writes `ratio_ok`.
4. Frontend: new `/operations` page with three tabs: Drills / Postings / Ratio. Tablet-first so owners can use it at the door.

---

## 13. Inspection Readiness Simulator 🔴 **DEMO BLOCKER — THE KILLER FEATURE**

**Acceptance criteria (per SPEC §4.5 + FEATURES §13).**
- [ ] Self-inspection simulator walks the owner through their state's actual inspector checklist, same order, same words as the state.
  - CA: LIC-9099 pre-licensing checklist (9 domains).
  - TX: Form 2936 annual licensing inspection checklist.
  - FL: CF-FSP 5316 Standards Classification Summary (32 categories).
- [ ] Each item is yes/no/NA with evidence photo upload.
- [ ] Violation risk assessment: predicts most-likely citations from current compliance gaps.
- [ ] One-click inspection-ready PDF report: renders state's inspector form pre-populated with provider data.
- [ ] Past inspection log: track inspection history + citations + corrective action plans.

**Backend status:** 🔴 Zero code.

**Frontend status:** 🔴 Zero code.

**Strategic importance:** this is the feature that makes *"Be inspection-ready every single day"* a real product, not a slogan. Without it we're selling a glorified file cabinet.

**Fix plan (Fix #2):**
1. Define `internal/inspection/` package with one checklist file per state: `ca_lic9099.go`, `tx_form2936.go`, `fl_cffsp5316.go`. Each exports `Checklist()` → `[]Item{Domain, Question, EvidenceKind, Source}`.
2. Add tables `inspection_runs` (id, provider_id, state, started_at, completed_at, score) and `inspection_responses` (run_id, item_id, answer, evidence_document_id, note).
3. Add `POST /api/inspections` (start a run) → `PATCH /api/inspections/:id/items/:item_id` (answer) → `POST /api/inspections/:id/finalize` (compute score + summary).
4. Add `GET /api/inspections/:id/report.pdf` that renders the state's form pre-populated.
5. Frontend: new `/inspections` page + `/inspections/:id` wizard + detail + "Export PDF" button.

---

## 14. Billing & Stripe 🟡

**Acceptance criteria.**
- [x] 14-day free trial auto-starts on signup.
- [x] Day-11 reminder email (chase worker covers this).
- [x] "Upgrade" → Stripe Checkout → $99/mo Pro.
- [x] Promo codes supported.
- [x] "Manage billing" opens Stripe Customer Portal.
- [x] Webhook handlers: `customer.subscription.{created,updated,deleted}`, `invoice.payment_failed`, `trial_will_end`.
- [x] Paywall middleware `RequireStripeCustomer` gates premium routes.

**Backend:** `internal/billing/stripe.go` + `handlers/webhook_stripe.go`. All real. Tables `subscriptions` + `stripe_events` with idempotency key.

**Frontend:** `pages/SettingsBilling.tsx` is stubby — opens an iframe to Stripe portal. Works but unpolished.

**Gaps:** Needs real `STRIPE_PRICE_PRO` and `STRIPE_WEBHOOK_SECRET` to test E2E. Not a code gap.

---

## 15. Legal Agreement Flow 🟡

**Acceptance criteria.**
- [x] Single checkbox at signup for MSA + DPA + Privacy + ESIGN.
- [x] Parent/staff consent shown at first portal visit (EN + ES).
- [ ] Admin UI to publish a new policy version.
- [ ] Re-prompt on policy update.

**Backend:** Tables `policy_versions` + `policy_acceptances` exist. Light middleware check wired; admin publisher CLI/UI missing.

**Frontend:** Signup has the checkbox; portal has the consent page. No admin publisher UI.

**Gaps:** Admin publisher is post-MVP.

---

## 16. Audit Log 🟡

**Acceptance criteria.**
- [x] Every write handler emits `audit_log` row: provider_id, actor_kind, actor_id, action, target_kind, target_id, metadata, ip, user_agent.
- [x] FK `ON DELETE SET NULL` so rows survive provider purge (7yr legal hold).
- [ ] Admin-facing filterable view.
- [ ] Emission helper wired into *every* write handler (currently partial).

**Backend:** Table + emission helper exist. Not every handler calls it.

**Frontend:** No admin-facing log viewer.

**Gaps:** Full emission sweep + admin viewer are post-MVP. Keep the table writing where it writes today; ship.

---

## 17. Data Deletion & 90-Day Retention 🔴

**Acceptance criteria.**
- [ ] Soft-delete on cancellation.
- [ ] 90-day grace window (read-only data).
- [ ] Day-90 scheduled purge of S3 `docs/` + `templates/` + `signed/` for that provider.
- [ ] Keep `audit/` (7yr legal hold).
- [ ] Deletion manifest written to `ck-files` `audit/{provider_id}/deletion-{ts}.json`.

**Backend:** `internal/storage/s3.go` has `DeleteAllForProvider`. Cron wrapper + manifest writer TODO.

**Gaps:** Not a demo blocker. Ship as post-MVP week-5 item.

---

## 18. Admin Settings & Data Export 🟡

**Acceptance criteria.**
- [x] Profile + org details.
- [x] Billing link.
- [ ] Audit log link.
- [ ] Policy versions signed view.
- [ ] "Export all my data" — backgrounded ZIP job → email signed URL.
- [x] "Cancel subscription" → Stripe portal + triggers §17 flow.

**Backend/Frontend:** Basics exist; export + audit view TODO.

**Gaps:** Export is nice-to-have. Ship without.

---

## 19. Observability & Ops 🟢

**Acceptance criteria.**
- [x] Structured slog JSON → stdout.
- [x] Request ID middleware.
- [x] `/healthz` + `/readyz`.
- [x] Nightly `pg_dump` backup (actually `sqlite backup` per ADR-017) → `ck-backups` bucket with 30-day lifecycle.
- [ ] Log shipping to Grafana Cloud (config flag, not required at MVP).

---

## 20. Marketing & SEO Content 🟢

**Acceptance criteria.**
- [x] Product page, strategy page, three per-state articles (CA/TX/FL × 3 topics), prototype, expansion plan.
- [x] Deployed on GitHub Pages alongside React app.
- [x] **All 50 state guides now live** in `state-guides/` (plain-English, cite-linked).
- [x] **Master product vision doc** `PRODUCT-TURBOTAX.md` with 50 cartridges.

---

## What to fix — priority order for the final 3 days

### Must-ship before 2026-04-23

**Fix #1 — Facility & Operations CRUD (12)** · *backend + frontend* · ~1 day
- Drill log endpoint + UI.
- Wall-posting tracker endpoint + UI.
- Ratio calculator endpoint + UI.
- Backs compliance rules that are otherwise dead.

**Fix #2 — Inspection Readiness simulator (13)** · *backend + frontend* · ~1 day
- Checklist data for CA LIC-9099, TX Form 2936, FL CF-FSP 5316.
- Run/response schema + endpoints.
- Wizard UI + PDF export.
- This is the feature that justifies "inspection-ready every day."

**Fix #3 — QA-TESTING-GUIDE.md** · *docs* · ~2 hours
- Per-feature test scenarios with plain-English steps.
- Covers all 20 features × 3 states where state-specific.

**Fix #4 — Integration tests** · *backend + frontend* · ~4 hours
- Backend Go tests for every handler (table-driven).
- Frontend Playwright tests for critical flows: signup → onboarding → dashboard → upload doc → inspection sim → PDF sign.

**Fix #8 — Wire pdfsign into main.go** · ~30 min
- `main.go` still has `PDFSign: nil,`. Needs `pdfsign.New(...)` wired so the signing routes mount.

### Harden for production (post-demo, before first paying customer)

**Fix #5 — Nightly compliance snapshot recompute** · ~1 hour
- Add `go snapshotworker.RunDaily(ctx)` in main.go alongside chase worker.
- Iterates every non-deleted provider, runs `Evaluate`, writes snapshot.

**Fix #6 — Session cleanup job** · ~30 min
- DELETE expired sessions nightly.

**Fix #7 — State code validation** · ~15 min
- `handlers/providers.go` Signup: reject any state not in `{CA,TX,FL}` with 400.

**Fix #9 — Explicit OR/WA 501 Not Implemented** · ~15 min
- `Evaluate(unknown state)` currently returns score=100. Change to return `error: "state not supported at MVP"`.

**Fix #10 — Add handler + chase tests** · ~3 hours
- Backend integration tests covering end-to-end: POST presign → OCR → compliance recompute.

### Post-MVP (week 5+)

- Feature #17 90-day purge cron.
- Feature #18 data export.
- Feature #15 admin policy publisher.
- Feature #16 admin audit log viewer.
- RBAC enforcement.

---

## Appendix A — Acceptance criteria cross-reference by state

### California (Title 22, CCLD)
- Child files: `LIC 700` + `LIC 701` + `LIC 702` + `CDPH 286 (Blue Card)` + TB clearance + consents — enforced by CA-CHILD-{IMM,ADMISSION,PHYSICIAN-REPORT}.
- Staff files: `LIC 508` + Live Scan + CACI + TB + CPR + First Aid + mandated reporter training — enforced by CA-STAFF-{TB,CPR-FIRSTAID,BACKGROUND}.
- Facility: `LIC 203` license posted + LIC 995 Parents' Rights + evac map — enforced by CA-{FACILITY-LICENSE,POSTINGS}.
- Drills: monthly fire/earthquake/lockdown ≥3 in 90d — enforced by CA-DRILLS.
- Ratios: 1:4 infant (0–2), 1:12 preschool (2–6), 1:15 school-age (6–14) — enforced by CA-RATIOS.
- Inspector checklist: LIC-9099 — **NOT IMPLEMENTED** (Fix #2).

### Texas (Chapter 746, HHSC)
- Child files: `Form 2935` + `Form 7259` immunization + `Form 2937` health — enforced by TX rules.
- Staff files: `Form 2760` + DPS/FBI fingerprint + `Form 2948` + 24 annual + 8 pre-service + SBS training.
- Ratios (strictest-by-age): 0–11mo 1:4 (max 10) / 12–17mo 1:5 / 18–23mo 1:9 / 2yo 1:11 / 3yo 1:15 / 4yo 1:18 / 5yo 1:22 / 6–12yo 1:26.
- Drills: monthly fire + quarterly severe-weather.
- Inspector checklist: `Form 2936` — **NOT IMPLEMENTED** (Fix #2).

### Florida (F.A.C. 65C-22, DCF)
- Child files: `CF-FSP 5274` + `CF-FSP 5316` + `DH 680` / `DH 681` + Student Health Record.
- Staff files: `CF-FSP 5131` + Level 2 Clearinghouse + 40/45-hr Intro Training + 10 hr/yr in-service + FCCPC/DCP credential.
- Ratios: <12mo 1:4, 1yr 1:6, 2yr 1:11, 3yr 1:15, 4yr 1:20, 5+yr 1:25.
- Drills: monthly fire + quarterly lockdown + annual reunification.
- Inspector visits: **2 unannounced per year** (most aggressive in the country).
- Inspector checklist: `CF-FSP 5316` 32 categories — **NOT IMPLEMENTED** (Fix #2).

---

## Appendix B — Where each feature is sourced from

| FEATURES.md ref | SPEC.md ref | Cartridge ref | State-guide ref |
|---|---|---|---|
| §1 Auth | §7.1 Security | — | — |
| §2 Onboarding | §5.1 User Flow | PRODUCT-TURBOTAX §2 (Screen 1) | — |
| §3 Dashboard | §4.1, §9.1 Metrics | PRODUCT-TURBOTAX §2 (Screen 3) | — |
| §4 Child files | §4.2, §8A | PRODUCT-TURBOTAX §4 (records_checklist.child) | how-to-pass-{ca,tx,fl}.md "Every child must have…" |
| §5 Staff files | §4.3, §8A | PRODUCT-TURBOTAX §4 (records_checklist.staff) | how-to-pass-{ca,tx,fl}.md "Every staff member…" |
| §6 Documents + OCR | §5.2 Upload flow | — | — |
| §7 PDF sign | §5.6 Signing flow | — | — |
| §8 Portals | §5.2–5.3 | PRODUCT-TURBOTAX §4 (Screen 1 portal branch) | — |
| §9 Compliance engine | §4.1, §8A | PRODUCT-TURBOTAX §4 (top_violation_nags) | how-to-pass-*.md "The 5 things that fail" |
| §10 Immunization | §8A state-by-state | — | how-to-pass-*.md immunization bullets |
| §11 Chase | §4.6, §5.4 | — | — |
| §12 Facility & ops | §4.4 | PRODUCT-TURBOTAX §4 (inspection-day pack ratios/drills) | how-to-pass-*.md "Drills and daily logs" |
| §13 Inspection simulator | §4.5, §5.5 | PRODUCT-TURBOTAX §2 (Screen 5 killer feature) | how-to-pass-*.md "What the inspector actually does" |
| §14 Billing | §7.2 | — | — |
| §15 Legal | §7.4 | — | — |
| §16 Audit log | §7.1 | — | — |
| §17 Purge | §7.4, §8 Out-of-scope nuance | — | — |
| §18 Settings | — | — | — |
| §19 Ops | §7.2, §7.3 | — | — |
| §20 SEO | GTM section of CLAUDE.md | — | All 50 state-guides |
