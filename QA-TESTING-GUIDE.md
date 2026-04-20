# ComplianceKit — QA Testing Guide (CA / TX / FL MVP)

**Purpose.** Systematic test scenarios for every product requirement. A non-engineer should be able to walk through this guide and know whether each feature works. Every test includes: **the steps**, **the expected result**, and **where to look if it breaks**.

**How to use this guide.**
1. Run the backend locally: `cd backend && go run ./cmd/server`.
2. Run the frontend locally: `cd frontend && npm run dev`.
3. Apply migrations: `migrate -path backend/migrations -database sqlite://$PWD/ck.db up`.
4. Go through each section below. Check ✅ or ❌ per scenario.
5. Anything ❌ → file an issue or fix on the spot.

**Coverage philosophy.**
- **Smoke tests** (the ones marked ⚡) — the 25 tests you must pass before a customer demo.
- **Full QA pass** — all tests. Run before tagging a release.
- **State-specific variants** — every test section has a "CA/TX/FL variants" block when behavior differs by state.

Cross-reference: [`FEATURE-AUDIT.md`](./FEATURE-AUDIT.md) has the same 20 features with acceptance criteria; this guide tells you *how to verify* each one.

---

## Pre-flight checklist

Before running any tests, make sure you have:

- [ ] Backend compiled and running on `:8080` (check `curl localhost:8080/healthz` returns `{"status":"ok"}`).
- [ ] Frontend running on `:5173` (check browser loads).
- [ ] SQLite DB seeded with migrations `000001` through `000011` (or latest).
- [ ] Env vars set in `backend/.env`: `MAGIC_LINK_SIGNING_KEY`, `FRONTEND_BASE_URL`, `APP_BASE_URL`. (Email/SMS/OCR/Stripe keys optional for most tests — they'll no-op gracefully.)
- [ ] A mail catcher running locally (e.g., MailHog on `:1025`) OR you're prepared to grep server logs for the magic-link URL.

---

## ⚡ 1. Authentication & Magic-Link Sessions

### 1.1 ⚡ Signup sends a magic link

**Steps.**
1. Open browser → `http://localhost:5173/login`.
2. Enter email `owner+test@example.com` and submit.
3. Check server logs (or MailHog) for the magic link URL.
4. Click the link in the email.

**Expected.**
- Response: `202 Accepted` with `{"status": "sent"}`.
- `providers` row created with state_code = the value from signup.
- Email contains a URL like `http://localhost:5173/auth/callback?token=...`.
- Clicking the link lands on `/onboarding` (first-time user) or `/dashboard`.
- `sessions` row created, cookie `ck_sess` set HttpOnly + Secure + SameSite=Lax.

**If broken.** Look at `backend/internal/handlers/providers.go` `Signup` + `Callback` functions. Check `magic_link_tokens` table — is the row inserted with a `token_hash`? `sessions` table should have a new row after callback.

### 1.2 ⚡ State code rejection

**Steps.**
1. `curl -X POST http://localhost:8080/api/auth/signup -H 'Content-Type: application/json' -d '{"name":"Test","owner_email":"a@b.com","state_code":"NY"}'`

**Expected.** `400 Bad Request` with message `"state_code must be one of CA, TX, FL (MVP scope)"`.

**If broken.** Check the state validation block in `handlers/providers.go` Signup.

### 1.3 Magic link expiration

**Steps.**
1. Request a signin link.
2. Wait 16 minutes.
3. Click the link.

**Expected.** Error page "link expired."

### 1.4 Magic link single-use

**Steps.**
1. Request a signin link.
2. Click it — lands on dashboard.
3. Log out.
4. Click the same link again.

**Expected.** Second click errors with "link already used." Token's `consumed_at` is non-null in DB.

### 1.5 Rate-limit on auth endpoints

**Steps.**
1. Send 15 POST requests to `/api/auth/signin` in 5 seconds.

**Expected.** After ~10 requests, `429 Too Many Requests`. Bucket refills slowly (0.5 tok/sec).

### 1.6 Logout clears session

**Steps.**
1. While logged in, click Logout.
2. Try to fetch `/api/me`.

**Expected.** `401 Unauthorized`. `sessions.revoked_at` set for the prior session row.

**State variants:** None.

---

## ⚡ 2. Onboarding Wizard

### 2.1 ⚡ Complete the 6-step wizard (CA)

**Steps.**
1. Sign up with a fresh email and `state_code=CA`.
2. Click the magic link → land on `/onboarding`.
3. Step 1: CA state is pre-selected (grey). Click Next.
4. Step 2: click "Center" → Next.
5. Step 3: enter name "Sunshine Daycare", address, capacity 40, min age 0, max age 72 months → Next.
6. Step 4 (staff): click "Add manually", enter one teacher row → Next.
7. Step 5 (children): skip ("I'll add later") → Next.
8. Step 6 (review): click Finish.

**Expected.**
- Lands on `/dashboard`.
- Dashboard shows a non-zero compliance score (low, because almost nothing is uploaded).
- Sidebar shows Children / Staff / Documents / Settings links.

### 2.2 ⚡ Draft persists across page refresh

**Steps.**
1. Start onboarding, fill Steps 1–3.
2. Reload the page (F5).

**Expected.** Wizard resumes at Step 3 with Steps 1–2 data still present.

### 2.3 CSV import of children/staff

**Steps.**
1. In Step 4 or 5, click "Paste CSV".
2. Paste:
   ```
   first_name,last_name,email,role
   Alice,Smith,alice@x.com,teacher
   Bob,Jones,bob@x.com,aide
   ```
3. Click Import.

**Expected.** Both rows appear in the staff list inside the wizard.

### 2.4 ⚡ Re-onboarding is blocked

**Steps.**
1. After completing onboarding, manually visit `/onboarding`.

**Expected.** Redirect to `/dashboard`. `<RequireOnboarded>` guard should also redirect in the other direction (not-onboarded user visits `/dashboard` → sent to `/onboarding`).

**State variants:**
- Step 1 state button: only CA/TX/FL render as clickable; any other state option should be absent.
- Step 3 facility capacity: no state-specific validation at this step, but backend state logic kicks in after submit.

---

## ⚡ 3. Compliance Dashboard

### 3.1 ⚡ Initial dashboard loads with score

**Steps.**
1. Log in as a user who has completed onboarding but uploaded nothing.
2. Open `/dashboard`.

**Expected.**
- Big compliance score displayed (will be low — somewhere 20–50 depending on rule weights).
- At least one critical alert visible (e.g., "0 of N children have immunization records").
- 90-day deadline timeline renders (empty OK).
- No 500 errors in network tab.

### 3.2 Score updates after document upload

**Steps.**
1. From dashboard, click "Upload a document".
2. Upload an immunization PDF for the only enrolled child (assign to that child).
3. Return to dashboard.

**Expected.** Score increased. That specific violation ("child missing immunization") removed from the alerts list. A new `compliance_snapshots` row inserted.

### 3.3 Dashboard handles zero children / zero staff

**Steps.**
1. Log in as user with empty roster.

**Expected.** Dashboard renders without errors. Alerts focused on facility-level items (license, drills, postings).

### 3.4 Dashboard handles facility-level doc expiration

**Steps.**
1. Upload a facility license with `expiration_date = today + 30 days`.
2. Check 90-day timeline.

**Expected.** A card appears on the timeline labeled "License expires in 30 days" with severity = major.

**State variants:**
- CA: dashboard should cite `22 CCR §*` in violations.
- TX: dashboard should cite `26 TAC Ch. 746` or `Form 2935/7259/2937`.
- FL: dashboard should cite `F.A.C. 65C-22` or `CF-FSP 5274/5316`.

---

## ⚡ 4. Child File Management

### 4.1 ⚡ Add a child manually

**Steps.**
1. Go to `/children`.
2. Click "Add child".
3. Fill first, last, DOB (= today - 14 months), parent email.
4. Submit.

**Expected.** Child row appears in the table. `child_documents_required` rows seeded per state template.

### 4.2 Child detail page shows required docs

**Steps.**
1. Click a child in the list.

**Expected.** Detail shows: demographics, guardians, allergies (empty), required documents with status chips. Per state:
- CA: LIC 700, LIC 701/9165, LIC 702, CDPH 286 (Blue Card), TB test (required), consents.
- TX: Form 2935, 7259 immunization, 2937 health record, consents.
- FL: CF-FSP 5274 enrollment, CF-FSP 5316 health, DH 680 immunization, CF-FSP 5075 physician.

### 4.3 Child soft-delete

**Steps.** Withdraw a child from enrollment.

**Expected.** Child shows `Withdrawn` badge, but still visible. Their required-doc rows remain (legacy — see FEATURE-AUDIT for noted bug).

### 4.4 Bulk CSV import outside onboarding

**Steps.** On `/children`, click "Import CSV", paste 5 rows.

**Expected.** 5 children added; any row with bad DOB is rejected with clear error.

---

## ⚡ 5. Staff File Management

Tests identical shape to Children.

### 5.1 ⚡ Add a staff member

Same as 4.1 but on `/staff`. Fields: first/last/email/phone/role (director|teacher|aide|cook).

### 5.2 Required certs per state

Verify the per-state checklist:
- **CA:** LIC 508 background + DOJ Live Scan + TB + CPR + Pediatric First Aid + Mandated Reporter + orientation 15 hrs + CE 16 hrs (directors).
- **TX:** Form 2760 + DPS/FBI fingerprint + Form 2948 + 24 annual hrs + 8 pre-service + SBS training.
- **FL:** CF-FSP 5131 Clearinghouse + 40/45-hr Intro + 10 in-service/yr + FCCPC/DCP credential (directors).

### 5.3 CPR expiration tracking

**Steps.** Upload a CPR card for a staff member with `expiration_date = today - 1 day`.

**Expected.** Staff detail shows the cert as **Expired** (red chip). Dashboard violation for expired CPR. Score drops.

---

## ⚡ 6. Document Upload & OCR

### 6.1 ⚡ Upload an immunization PDF (happy path)

**Prereq:** `MISTRAL_API_KEY` and `GEMINI_API_KEY` set in `backend/.env`. Otherwise OCR no-ops gracefully; this test becomes "upload works, expiration must be entered manually."

**Steps.**
1. On `/documents`, click Upload.
2. Pick an immunization PDF.
3. Assign to a child.
4. Wait ≤ 60s.

**Expected.**
- `documents` row inserted with `ocr_status=pending`.
- File lands in S3 bucket (or local `./data/s3/` if using MinIO).
- After OCR completes: `ocr_status=completed`, `raw_text` populated, `expiration_date` extracted.
- UI shows the extracted date with "Confirm?" prompt if confidence < 0.85.

### 6.2 Duplicate upload deduplication

**Steps.** Upload the same file twice.

**Expected.** Second upload returns the existing document row (same ID). No dupe rows — enforced by unique `(provider_id, sha256)` index.

### 6.3 Upload OCR failure graceful fallback

**Steps.** Unset `MISTRAL_API_KEY` and `GEMINI_API_KEY`. Upload a PDF.

**Expected.** Upload succeeds. `ocr_status=skipped`. User is prompted to enter expiration date manually.

### 6.4 ⚡ File size limit

**Steps.** Try uploading a 30 MB PDF.

**Expected.** `413 Payload Too Large` (default Chi limit or explicit guard — confirm in `DocumentHandler.Presign`).

---

## ⚡ 7. PDF E-Signature

### 7.1 ⚡ Provider creates a template

**Prereq:** `pdfsign` wired in main.go (currently stubbed — see FEATURE-AUDIT Fix #8).

**Steps.**
1. Go to `/templates` (Document Templates).
2. Upload a blank PDF (e.g., a handbook).
3. Drag Signature, Date, and Text fields onto page 1.
4. Save.

**Expected.** `document_templates` row inserted with `fields_json` populated.

### 7.2 Send signature request to a staff member

**Steps.** From a template, click "Send for signature" → select staff → send.

**Expected.**
- `sign_sessions` row created with `status=pending`.
- A magic link emailed to that staff: `/sign/<token>`.

### 7.3 ⚡ Staff signs the document

**Steps.**
1. Open the sign link in a new browser (incognito).
2. PDF renders in the page.
3. Tap/click the signature field — draw with mouse/finger.
4. Submit.

**Expected.**
- Browser stamps the signature PNG onto the PDF via pdf-lib.
- Final PDF POSTed to server; server **recomputes** SHA-256 (not trusting client).
- `signatures` row inserted with both pre-sign and post-sign hashes.
- Signed PDF stored in `ck-files` under `signed/`.
- Audit JSON stored under `audit/`.

### 7.4 Tamper detection

**Steps.** Intercept the Submit POST and change a byte in the PDF bytes. Resubmit.

**Expected.** Server rejects — hash mismatch. `signatures` row NOT created. This is covered by the 10 Go unit tests in `pdfsign/pdfsign_test.go`.

---

## ⚡ 8. Parent & Staff Upload Portals

### 8.1 ⚡ Parent opens portal link (no login)

**Steps.**
1. From a child page, click "Generate parent upload link" → copy URL.
2. Open URL in incognito.

**Expected.** Mobile-friendly page loads. Shows only the docs missing for that child. Parent is never prompted to sign in.

### 8.2 Parent uploads a photo

**Steps.** In portal, tap a slot (e.g., Immunization Record). Pick a photo or "Take a photo".

**Expected.**
- File uploads direct to S3 via presigned URL.
- `documents` row created, linked to child, `uploaded_via=parent_portal`.
- EXIF timestamp preserved, EXIF location stripped.
- OCR kicks off in the background.
- Slot goes from empty to "Uploaded, pending review".

### 8.3 Consent shown on first visit only

**Steps.** Open the portal link for the first time → consent page appears. Accept. Reopen the link.

**Expected.** On second visit, no consent page. `policy_acceptances` row stored.

### 8.4 Magic link 7-day sliding TTL

**Steps.** Use the link. Wait 3 days. Use again.

**Expected.** Still works. `expires_at` slides forward. On day 8 of non-use, link dead.

**State variants:**
- Consent language is shown per state? Currently not — same EN/ES text for all states. OK for MVP.

---

## 9. Compliance Engine (Rule Packs)

### 9.1 ⚡ CA rule pack returns 10 rules

**Test.** `curl -H "Cookie: ck_sess=..." http://localhost:8080/api/dashboard | jq '.violations | length + (.passed_rules | length)'`

**Expected.** Total rules evaluated = 10.

### 9.2 ⚡ CA child immunization rule triggers

**Steps.** As a CA provider with 3 enrolled children and 0 immunization records uploaded, hit dashboard.

**Expected.** Violation `CA-CHILD-IMM` present. Title: "Child immunization records". Reference: `CA H&SC §120335; CCR tit. 17 §6025`. FormRef: `CDPH 286 (Blue Card)`. Description references "3 enrolled children."

### 9.3 CA staff background rule triggers

**Steps.** Add a staff member, don't upload any background check.

**Expected.** Violation `CA-STAFF-BACKGROUND` present. Severity critical. References LIC 508.

### 9.4 TX ratio rule triggers when `ratio_ok=false`

**Steps.** Manually (via SQL) set `providers.ratio_ok = 0`. Refresh dashboard.

**Expected.** Violation `TX-RATIOS` (or equivalent) present.

### 9.5 FL drill rule — monthly fire drill

**Steps.** As an FL provider, ensure `drill_logs` has no rows in last 90 days. Check dashboard.

**Expected.** Violation citing FL drill rule. Fixes: log a drill.

### 9.6 Unsupported state fallback

**Steps.** Manually set `providers.state_code = 'WA'`. Hit dashboard.

**Expected.** Returns a single violation `STATE-NOT-SUPPORTED` (not a score of 100 — the fallback added in hardening).

**Unit tests.** `backend/internal/compliance/engine_test.go` has CA missing-immunization + TX all-green table tests. Run: `cd backend && go test ./internal/compliance/...`.

---

## 10. Immunization Schedule Engine

### 10.1 CDC ACIP schedule

**Test.** `cd backend && go test ./internal/immunization/...`

**Expected.** All tests green. Schedule covers HepB, RV, DTaP, Hib, PCV13, IPV, Influenza, MMR, Varicella, HepA. `Required(state, ageMonths)` returns correct number of doses per vaccine at each age.

### 10.2 Child detail immunization badge

**Steps.** Enroll a 15-month-old. Open their detail page.

**Expected.** Immunization list shows expected doses for 15 months with status badges (e.g., "MMR due — 1st dose" if none recorded).

---

## 11. Document Chase Service

### 11.1 Threshold triggers

**Prereq:** SES + Twilio keys set (or swap in mock senders for tests).

**Steps.** Upload a doc with `expiration_date = today + 14 days`. Manually run `chase.ProcessOnce(ctx, now)` with `now = today`.

**Expected.**
- `chase_events` row created with `trigger='2w'`.
- Email or SMS sent (check MailHog / Twilio debug).
- `document_chase_sends` row inserted (dedup key).

### 11.2 Dedup prevents double-send

**Steps.** Run `ProcessOnce` twice with the same `now`.

**Expected.** Second run does not send — caught by `document_chase_sends` composite PK.

### 11.3 Quiet hours

**Steps.** Call `ProcessOnce` with `now = 23:00 local`.

**Expected.** No SMS sent (quiet-hours block 21:00–08:00). Email may still send (email has no quiet hours).

### 11.4 Suppression list honored

**Steps.** Add a row to `notification_suppressions` for `parent@example.com`. Run chase.

**Expected.** That parent is skipped.

---

## 12. Facility & Operations ⚠ NEW FEATURE — TEST AFTER FIX #1 MERGES

### 12.1 ⚡ Log a fire drill

**Steps.**
1. Go to `/operations` → Drills tab.
2. Click "Log a new drill".
3. Pick kind=Fire, date=today, duration=120s, notes="Practice run", no attachment.
4. Submit.

**Expected.** Drill appears in the list. Dashboard `DrillsLast90d` increments. Compliance rule that depends on drills (CA-DRILLS or similar) flips from violated to satisfied.

### 12.2 ⚡ Drill cadence warning

**Steps.** Log a fire drill with `date=today-40 days`. No other drills. Refresh Operations page.

**Expected.** UI shows warning: "No fire drill in the last 30 days. Most states require monthly."

### 12.3 ⚡ Wall posting checklist (FL)

**Steps.** As an FL provider, open Operations → Postings tab.

**Expected.** Checklist shows FL-specific items: license, ratio poster, evac map, menu, DCF hotline, mandated reporter. Check each item → upload photo → item turns green. `providers.postings_complete` = true only when all required items checked.

### 12.4 ⚡ Ratio calculator (TX)

**Steps.** As a TX provider, open Operations → Ratio tab. Add two rooms:
- Infant room: age 0–11mo, 5 children, 1 staff.
- Preschool: age 3yr, 12 children, 1 staff.

**Expected.** Infant row red (1:5 > 1:4 cap). Preschool row green (1:12 ≤ 1:15 cap). `providers.ratio_ok=false`. Dashboard ratio violation appears.

### 12.5 Ratio — CA age bands

**Steps.** CA provider. Add: Infant 0–24mo / 4 kids / 1 staff; Toddler 24–72mo / 12 kids / 1 staff.

**Expected.** Both rows green (CA: 1:4 infant / 1:12 toddler–preschool).

**State variants:** All three ratio tables live in `internal/compliance/ratios.go`. Run `go test ./internal/compliance/...` for coverage.

---

## 13. Inspection Readiness Simulator ⚠ NEW FEATURE — TEST AFTER FIX #2 MERGES

### 13.1 ⚡ Start a mock inspection (CA)

**Steps.**
1. As a CA provider, go to `/inspections`.
2. Click "Start a mock inspection".

**Expected.** Wizard opens showing Domain 1 of 9 — Personnel. Each item is plain-English. Reference line cites Title 22.

### 13.2 ⚡ Answer items and finalize

**Steps.** Walk through ~5 items marking Pass/Fail/NA. Skip the rest. Click Finalize.

**Expected.**
- Inspection run completes, `inspection_runs.completed_at` set.
- Summary screen shows: final score (weighted by severity), domain breakdown, predicted citation risks (= failed items sorted by severity).
- Score calculation uses same Critical=5/Major=3/Minor=1 weights as main engine.

### 13.3 ⚡ Export PDF report

**Steps.** From the summary screen, click "Export PDF".

**Expected.** Browser downloads a PDF (or HTML — see Fix #2 fallback). Content includes run summary, per-domain breakdown, per-item responses + evidence refs + notes.

### 13.4 Past run visible

**Steps.** Go back to `/inspections`.

**Expected.** Previous run listed with its score + date. Click → re-opens summary.

### 13.5 TX Form 2936 checklist (30+ items)

**Steps.** As TX provider, start an inspection.

**Expected.** Different item set than CA. References `Form 2936` / `7259` / `7260` / `7261`. At least 30 items.

### 13.6 FL CF-FSP 5316 (32 categories)

**Steps.** As FL provider, start an inspection.

**Expected.** 32 items matching CF-FSP 5316 Standards Classification Summary.

**State variants:** Each state ships its own checklist file: `ca_lic9099.go`, `tx_form2936.go`, `fl_cffsp5316.go`.

---

## ⚡ 14. Billing & Stripe

**Prereq:** `STRIPE_SECRET_KEY`, `STRIPE_PRICE_PRO`, `STRIPE_WEBHOOK_SECRET` set. Use test-mode keys.

### 14.1 ⚡ Start 14-day trial on signup

**Steps.** Sign up as new provider.

**Expected.** `subscriptions` row created with `status=trialing`, `current_period_end = now + 14 days`. Paywalled routes allow access (trial counts as paid).

### 14.2 Upgrade to Pro via Stripe Checkout

**Steps.** Visit `/settings/billing` → "Upgrade".

**Expected.** Redirect to Stripe Checkout. Complete with test card `4242 4242 4242 4242`. Stripe fires `customer.subscription.updated` webhook. `subscriptions.status` → `active`. `stripe_events` row logged.

### 14.3 Webhook idempotency

**Steps.** Replay the same webhook delivery twice.

**Expected.** Second delivery no-ops. `stripe_events.stripe_event_id` UNIQUE enforces.

### 14.4 Paywall blocks premium routes on cancellation

**Steps.** Cancel subscription (Stripe fires `customer.subscription.deleted`). Try to access `/api/sign/request`.

**Expected.** `402 Payment Required` or equivalent; frontend redirects to billing page.

### 14.5 Trial-ending email

**Steps.** Advance trial to day 11 in Stripe test clock; fire `customer.subscription.trial_will_end`.

**Expected.** `chase_events` row (or similar) written and email sent.

---

## 15. Legal Agreement Flow

### 15.1 ⚡ Signup checkbox gates submit

**Steps.** Try to submit signup without checking MSA + DPA + Privacy + ESIGN.

**Expected.** Submit disabled OR server rejects. On success: `policy_acceptances` row inserted for each policy kind.

### 15.2 Parent consent at first portal visit

See Test 8.3.

### 15.3 Policy re-prompt on version bump

**Steps.** Manually insert a new `policy_versions` row with `effective_at=now` and a higher version. Log in.

**Expected.** User prompted to re-accept. On accept: new `policy_acceptances` row.

---

## 16. Audit Log

### 16.1 Writes emit audit rows

**Steps.** Create a child, upload a document, delete a staff.

**Expected.** Three rows in `audit_log` table: `action=create_child`, `action=upload_document`, `action=delete_staff` (or similar). Each row has `provider_id`, `actor_id`, `ip`, `user_agent`.

### 16.2 Audit survives provider deletion

**Steps.** Delete a provider. Check `audit_log` for that `provider_id`.

**Expected.** Rows survive (`ON DELETE SET NULL`). `provider_id` is now null but rows remain for 7-year legal hold.

---

## 17. Data Deletion & Retention ⚠ NOT IMPLEMENTED IN MVP

*Tests deferred — see FEATURE-AUDIT.md post-MVP roadmap.*

---

## 18. Admin Settings

### 18.1 Profile update

**Steps.** `/settings` → edit name + email → save.

**Expected.** `users` row updated. `audit_log` captures the change.

### 18.2 Cancel subscription

**Steps.** `/settings/billing` → "Cancel".

**Expected.** Redirects to Stripe Customer Portal. Canceling there fires webhook.

### 18.3 Data export ⚠ NOT IN MVP

---

## ⚡ 19. Observability & Ops

### 19.1 ⚡ Healthz

**Steps.** `curl localhost:8080/healthz`.

**Expected.** `{"status":"ok"}` with `200`.

### 19.2 ⚡ Readyz after DB ready

**Steps.** `curl localhost:8080/readyz`.

**Expected.** `200 {"status":"ready"}`.

### 19.3 Structured logs

**Steps.** Do any authed action. Check stdout.

**Expected.** JSON log lines with `time`, `level`, `msg`, `component`, `request_id`, etc.

### 19.4 Error envelope carries request ID

**Steps.** Hit an endpoint with a bad body (e.g., malformed JSON on POST /api/children).

**Expected.** JSON error body includes `request_id` that matches the log line.

---

## 20. Marketing & SEO

### 20.1 ⚡ Landing pages render

**Steps.** Browse `compliancekit-product-overview.html`, `how-to-pass-daycare-inspection-california.html`, etc.

**Expected.** All render. All CTAs point to `/signup` or `/login`.

### 20.2 State guide index

**Steps.** Open `state-guides/README.md` on GitHub.

**Expected.** Links to all 50 state guides. Each link opens a valid `how-to-pass-{state}.md`.

---

## The ⚡ Smoke Test Matrix (run before every demo)

Tick these 25 and the product is demo-ready:

| # | Test | Status |
|---|---|---|
| S1 | 1.1 Signup sends magic link | [ ] |
| S2 | 1.2 State code rejection (non-CA/TX/FL) | [ ] |
| S3 | 2.1 Complete 6-step wizard for CA | [ ] |
| S4 | 2.2 Wizard draft persists | [ ] |
| S5 | 2.4 Re-onboarding blocked | [ ] |
| S6 | 3.1 Dashboard loads with score | [ ] |
| S7 | 4.1 Add a child manually | [ ] |
| S8 | 5.1 Add a staff manually | [ ] |
| S9 | 6.1 Upload immunization PDF (OCR happy path) | [ ] |
| S10 | 6.4 File size limit | [ ] |
| S11 | 7.1 Create PDF template | [ ] |
| S12 | 7.3 Staff signs document | [ ] |
| S13 | 8.1 Parent opens portal link (no login) | [ ] |
| S14 | 9.1 CA rule pack returns 10 rules | [ ] |
| S15 | 9.2 CA child immunization rule triggers | [ ] |
| S16 | 12.1 Log a fire drill | [ ] |
| S17 | 12.2 Drill cadence warning | [ ] |
| S18 | 12.3 Wall posting checklist (FL) | [ ] |
| S19 | 12.4 Ratio calculator (TX) | [ ] |
| S20 | 13.1 Start a mock inspection (CA) | [ ] |
| S21 | 13.2 Finalize + score | [ ] |
| S22 | 13.3 Export PDF report | [ ] |
| S23 | 14.1 Trial starts on signup | [ ] |
| S24 | 15.1 Signup checkbox gates submit | [ ] |
| S25 | 19.1 Healthz returns OK | [ ] |

---

## Test data fixtures

Use these canned inputs in manual QA so every tester sees the same thing.

**CA demo provider.**
- Owner email: `demo-ca@compliancekit.local`
- Name: `Sunshine Daycare CA`
- State: CA
- License: LIC-000001-CA
- Address: 100 Mission St, San Francisco, CA 94105
- Capacity: 40

**TX demo provider.** Same shape, state TX, address in Austin.

**FL demo provider.** Same shape, state FL, address in Orlando.

Per state, seed 3 children (ages 4mo, 18mo, 4yr) and 3 staff (1 director, 2 teachers). Run seeding with `backend/scripts/seed_demo.sh` (TODO — create as part of Fix #4).

---

## If it's broken — where to look

| Symptom | Where to look first |
|---|---|
| 500 on dashboard | `handlers/dashboard.go` + `compliance/engine.go` + server stdout |
| Score always 100 | Rule pack for that state; check `facts.RatioOK` / `PostingsComplete` |
| OCR never runs | `MISTRAL_API_KEY` / `GEMINI_API_KEY` env vars; `docs/*.go` pipeline |
| Magic link expired too fast | `magiclink/magiclink.go` TTL constants |
| Stripe webhook 500 | Signing secret mismatch; `handlers/webhook_stripe.go` |
| Frontend "undefined" | Zod validation failure — check browser console + server response shape |
| Portal page blank | Magic link expired; check `magic_link_tokens.expires_at` |
| Drill not counted | `drill_logs` row present? `DashboardHandler.loadFacts()` reads trailing 90d |

---

## What's not covered here (known gaps)

- Load/performance testing (not needed at MVP scale).
- Penetration testing (deferred, see DECISIONS.md).
- Cross-browser testing (target: Chrome + Safari + Firefox, last 2 versions).
- Accessibility audit (WCAG 2.1 AA — post-MVP).
- Data import from competitor products (Brightwheel, Procare) — not in scope.
- Multi-language UI — post-MVP.

Every gap here maps to a line item in `ROADMAP.md` or is explicitly post-MVP in `SPEC.md §8`.
