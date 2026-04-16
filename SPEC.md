# ComplianceKit — Master Product & Technical Specification

**Version:** 0.1 (MVP)
**Last updated:** 2026-04-16
**Owner:** Magnus (solo founder)
**MVP target:** 2026-04-23

---

## 1. Executive Summary

ComplianceKit is a compliance management SaaS for licensed child care providers. It replaces the paper binders, spreadsheets, and pre-inspection panic that currently define the operational reality of most daycare centers and family child care homes. The product tracks every state-specific regulatory requirement, deadline, and document against a deterministic rules engine, surfaces violations before an inspector does, and automates the work of chasing parents and staff for missing paperwork.

The tagline — "Be inspection-ready every single day" — is the product promise. The compliance dashboard is the front door. Every other module (child files, staff files, facility operations, inspection readiness, notifications) feeds signals into the same scoring engine.

MVP launches in California, Texas, and Florida. Combined these three states contain approximately 80,000 licensed facilities. The product targets the single-site owner/director who is both the buyer and the user — the same person who wakes up at 4 a.m. worried about an expired immunization record.

Stack is locked: Go backend on a DigitalOcean droplet, React (Vite + TypeScript) frontend on GitHub Pages, managed PostgreSQL, AWS S3 for document storage, Stripe for billing, SES for email, Twilio for SMS, Mistral OCR for document extraction, Gemini Flash as the LLM for narrow tasks (expiration date extraction, TurboTax-style onboarding).

See [ARCHITECTURE.md](ARCHITECTURE.md) for technical detail, [ROADMAP.md](ROADMAP.md) for the week-by-week plan, [DECISIONS.md](DECISIONS.md) for ADR log.

---

## 2. Target User

### 2.1 Primary Persona — The Owner/Director

- **Role:** Owner-operator of a single-site child care center (10–80 children, 2–12 staff) or family child care home (6–12 children, 1–4 staff)
- **Geography:** Florida, Texas, California at MVP
- **Age:** 38–62
- **Tech literacy:** Moderate. Uses Gmail, QuickBooks Online, Brightwheel or Procare, Facebook. Comfortable on a phone, less so on a laptop.
- **Pain points (from discovery interviews and inspector checklists):**
  - Cannot produce a single document on demand during an inspection; it lives in a filing cabinet, a binder, a shared Google Drive, and two staff members' personal phones
  - Misses staff certification expirations (CPR, First Aid, food handler) because the expiration is tracked in a spreadsheet that nobody opens
  - Chases parents for immunization records, physicals, enrollment forms by text message, one at a time, for weeks
  - Fails a routine inspection over a missing posting, a lapsed drill log, or a staff background check that expired 11 days ago
- **Budget authority:** Full. No procurement cycle. Pays with a personal credit card.
- **Decision window:** 24–72 hours. If the product works in a 15-minute demo, they sign up.

### 2.2 Secondary Personas

- **Parents (REQ015):** Upload immunization records, physicals, enrollment forms via a per-child magic link. Zero login friction. Phone camera upload.
- **Staff (REQ016):** Upload certifications, training certificates, background check results via a per-staff magic link. Same zero-friction flow.
- **Inspector (out of scope for MVP):** Read-only portal is roadmap, not MVP. MVP exports PDF reports inspectors can review on-site.

---

## 3. Core Jobs to Be Done

The user hires ComplianceKit to:

1. **Tell me what I'm missing right now.** A single score (0–100) and a ranked list of violations.
2. **Tell me what expires in the next 90 days.** A timeline, not a dump.
3. **Chase my parents and staff for me.** I should not be sending reminder texts at 9 p.m.
4. **Turn a pile of PDFs and phone photos into a structured file.** Extract expiration dates, child names, vaccine types automatically.
5. **Let me walk an inspector through my compliance in under 10 minutes.** Produce a report on demand.
6. **Stop surprising me.** I should know about a problem 60 days before it becomes a violation.

Everything else is scope creep.

---

## 4. Product Pillars

### 4.1 Compliance Dashboard (REQ001–REQ008)

The default landing view after login. Contents:

- **Compliance score** (0–100). Deterministic calculation. See [ARCHITECTURE.md §5](ARCHITECTURE.md#5-compliance-engine).
- **Critical alerts** — violations that would cause an inspector to cite on contact (expired background check, missing immunization, expired license).
- **90-day deadline timeline** — stacked by week, color-coded by severity.
- **Module roll-ups** — per-pillar score (Child Files 92, Staff Files 78, Facility 100, Inspection Readiness 85).
- **Quick actions** — "Send chase message to 4 parents", "Upload pending document", "Run self-inspection".

### 4.2 Child File Management (REQ010–REQ020)

State-specific document checklists. Florida requires CF-FSP 5274 (enrollment) and CF-FSP 5316 (health). Texas requires Form 2935 (admission) and Form 7259 (immunization). California requires LIC-281A (child identification) and LIC-627 (physician's report). The rules engine loads the correct checklist per `facility.state`.

Features:
- Per-child document folder with state-specific required-document list
- Immunization tracking with age-appropriate due-date calculation (REQ018 — age-based rules engine; e.g., DTaP doses 1–5 vary by child age)
- Parent upload portal (magic link, no password) — REQ015
- OCR-extracted metadata review queue — REQ019
- Bulk enrollment import (CSV) — REQ020

### 4.3 Staff File Management (REQ021–REQ030)

Analogous to child files but keyed on staff.

Features:
- Per-staff certification tracker with expiration-driven alerts (CPR, First Aid, food handler, state-specific director credentials — e.g., Florida DCF Director's Credential, Texas Director's Certificate)
- Training hour tracker — state-specific annual hour requirements (Florida: 10 in-service hours; Texas: 24 annual clock hours; California: 16 hours continuing education for directors)
- Background check expiration tracker — LiveScan (CA), FBI/DPS fingerprint (TX), Level 2 screening (FL)
- Staff upload portal (per-staff magic link) — REQ024
- Bulk staff import (CSV) — REQ029

### 4.4 Facility & Operations (REQ031–REQ040)

The module that replaces the paper clipboard by the front door.

Features:
- Digital daily safety checklist (state-configurable) — REQ031
- Drill scheduler and logger (fire, lockdown, severe weather) — REQ032. Texas requires monthly fire drills; Florida requires monthly fire plus quarterly lockdown; California requires monthly fire plus biannual earthquake.
- Wall posting tracker — REQ033. Which required postings (license, ratio chart, menu, emergency contact, disaster plan) are currently posted; photo evidence.
- Staff-to-child ratio calculator — REQ034. State-specific rules; e.g., Florida 1:4 for infants, Texas 1:4 for under-11-months, California 1:4 for under-18-months.
- Incident log — REQ035.

### 4.5 Inspection Readiness (REQ041–REQ050)

The highest-value module. Converts the scattered state into a single inspection artifact.

Features:
- **Self-inspection simulator** — REQ041. Mirrors the actual state inspector checklist (Florida's CF-FSP 5316 Environmental Health, Texas Form 2936 Annual Inspection Checklist, California LIC-9099 pre-licensing checklist). User walks through it, answers yes/no/NA, uploads evidence photos.
- **Violation risk assessment** — REQ042. Predicts the most likely citations based on current compliance gaps.
- **Inspection-ready PDF report** — REQ043. Single export the owner can hand to the inspector.
- **Past inspection log** — REQ044. Track state inspection history, citations, corrective action plans.

### 4.6 Notifications / Chase Service (REQ051–REQ060)

The automation layer. Multi-channel (email via SES, SMS via Twilio, in-app).

- Document expiration alerts at 90/60/30/7-day thresholds — REQ051
- Parent chase messages (REQ052) — batched daily, owner-approved before send
- Staff chase messages (REQ053) — same
- Inspection-date reminders (REQ054)
- Daily digest email (REQ055) — one email at 6 a.m. summarizing yesterday's changes and today's critical items
- Notification quiet hours (REQ056) — no SMS before 8 a.m. or after 8 p.m. local

---

## 5. User Flows

### 5.1 Signup → Onboarding → First Dashboard View

1. Owner lands on marketing page, clicks "Start free trial"
2. Enters email → magic link sent via SES
3. Clicks magic link → lands in onboarding wizard (TurboTax-style, Gemini Flash backs the chat)
4. Onboarding collects: facility name, state, license number, license expiration, facility type (center vs. family home), approximate staff count, approximate child count
5. On submit, backend provisions `facility` row, seeds state-specific checklist, redirects to dashboard
6. Dashboard shows a low initial score (everything is "unknown"), with a ranked list of next actions
7. User is prompted: "Import staff roster" → CSV upload OR manual add, "Import child roster" → CSV upload OR manual add
8. Each staff/child gets a magic-link upload URL that the owner can copy-paste or have ComplianceKit send directly

### 5.2 Parent Upload Portal Flow

1. Parent receives SMS or email: "Lil' Sprouts Academy needs three documents for Ava: immunization record, physical exam, enrollment form. Tap here to upload."
2. Link opens a mobile-first page, no login. Link is a per-child magic link with a 30-day expiration.
3. Parent sees three empty slots. Taps each, takes photo with phone camera or picks from files.
4. Upload lands in S3 bucket `ck-raw-uploads`, mirrored event to backend, OCR job enqueued.
5. OCR extracts: vaccine type, date administered, next-dose-due date (immunizations); child name, physician name, exam date, cleared-for-care date (physicals).
6. Document moves to `ck-documents` (originals) and metadata lands in Postgres.
7. Owner gets an in-app review queue: "3 documents ready to approve. Verify the extracted data is correct."
8. On approval, document is locked, included in compliance score.

### 5.3 Staff Upload Portal Flow

Identical to parent flow, keyed on staff instead of child. Accepts: CPR card, First Aid card, food handler, background check clearance letter, training certificates.

### 5.4 Document Expiration Chase Flow

1. Nightly job runs at 02:00 UTC
2. Compliance engine evaluates every document with an `expires_at` in (today, today + 90 days)
3. For each expiring document, determines owner (parent, staff, facility), channel preference, and threshold (90/60/30/7)
4. Writes to `notification_queue` table
5. Owner gets morning digest at 06:00 local: "12 items expire in the next 30 days. 4 need parent action, 6 need staff action, 2 need your action. Approve chase messages?"
6. Owner taps "Approve all" or reviews individually
7. Approved messages send via SES/Twilio
8. Bounce/failure handling — if SMS fails twice, auto-downgrade to email; if email bounces, flag owner to update contact

### 5.5 Inspection Prep Flow

1. Owner clicks "Run self-inspection" on dashboard
2. App loads state-specific checklist (Florida CF-FSP 5316, Texas 2936, California LIC-9099)
3. Owner walks through each section — yes/no/NA — with photo upload for evidence
4. On completion, app renders a report: current compliance score, items passed, items failed, items unknown, predicted citation risk
5. Owner can export as PDF for internal record or share with a consultant

### 5.6 Document Signing Flow (REQ046)

1. Owner uploads a document that requires staff signature (handbook acknowledgment, confidentiality agreement)
2. Selects staff recipients → signing session created → magic link sent to each
3. Staff clicks link, views PDF in browser (pdf-lib render)
4. Staff draws signature on canvas, hits "Sign"
5. Signature PNG is stamped onto PDF in browser via pdf-lib
6. Signed PDF + signature PNG + page coordinates + timestamp + staff magic-link token + request IP + user agent POST'd to backend
7. Backend hashes signed PDF (SHA-256), stores hash in `signatures` table, stores PDF in `ck-signed-pdfs`, stores audit blob (JSON of all metadata + IP + UA + magic-link-token) in `ck-audit-trail`
8. Owner sees signing status; completed signed PDFs available for download and attached to staff file

---

## 6. Functional Requirements

Functional requirements are tracked as REQ tickets in `tickets/`. Abbreviated list:

| Range | Pillar |
|-------|--------|
| REQ001–REQ008 | Compliance Dashboard |
| REQ010–REQ020 | Child File Management |
| REQ021–REQ030 | Staff File Management |
| REQ031–REQ040 | Facility & Operations |
| REQ041–REQ050 | Inspection Readiness |
| REQ051–REQ060 | Notifications / Chase |

Each ticket specifies: user story, acceptance criteria, state-specific variants, dependencies, estimated effort.

---

## 7. Non-Functional Requirements

### 7.1 Security

- **Data in transit:** TLS 1.3 on all endpoints. HSTS. No HTTP fallback.
- **Data at rest:** Postgres encrypted at rest (managed DO default). S3 buckets encrypted with SSE-S3. Signature audit bucket uses SSE-KMS with a dedicated key.
- **Authentication:** Magic links only. No passwords. Token = base62(32 random bytes). TTL = 15 minutes for owner login, 30 days for parent/staff upload links.
- **Authorization:** Row-level scoping on every query by `facility_id`. Every handler asserts the authenticated principal's facility matches the resource's facility.
- **Audit log:** Every mutation writes to `audit_log` table with `actor_id`, `action`, `resource_id`, `ip`, `user_agent`, `ts`. Retained forever for MVP.
- **PII handling:** Child names, DOBs, immunization records are PII. Documented subprocessors: see [EXTERNAL_SERVICES.md](EXTERNAL_SERVICES.md).
- **Secrets:** Stored in systemd `EnvironmentFile` on the droplet, 600 perms, root-owned.

### 7.2 Performance

- **p50 dashboard load:** < 800ms (cold), < 200ms (warm cache)
- **OCR turnaround:** < 60s per document (Mistral) at p95
- **Magic link email delivery:** < 30s end-to-end
- **API p95:** < 300ms for read endpoints, < 800ms for writes (excluding OCR-backed endpoints)

### 7.3 Availability

- **Target:** 99.5% uptime at MVP. ~3.6 hours/month allowed downtime.
- **Deployment:** Zero-downtime not required at MVP. Systemd restart is acceptable.
- **Backup:** Managed Postgres daily snapshot, 7-day retention. S3 versioning enabled on `ck-documents` and `ck-signed-pdfs`.
- **DR:** Acceptable RTO = 4 hours, RPO = 24 hours at MVP.

### 7.4 Compliance Posture

- COPPA-relevant (data on children under 13). Parent is the consenting party; no direct child-to-service interaction.
- Not HIPAA. Immunization records are handled as PII but not as PHI (no covered-entity relationship).
- SOC 2 and cyber insurance deferred (see [DECISIONS.md](DECISIONS.md) ADR-013, ADR-014).

---

## 8. Out of Scope for MVP

Explicitly not shipping by 2026-04-23:

- Mobile native apps (iOS/Android). PWA only. See [DECISIONS.md](DECISIONS.md) ADR-012.
- Inspector read-only portal
- Multi-site / franchise organization hierarchy (Enterprise tier exists for pricing but serves the same single-site UI)
- Accounting / billing-of-parents features (Brightwheel, Procare territory)
- Attendance tracking
- Curriculum / lesson planning
- Communication-with-parents as a product surface (beyond compliance chase messages)
- Food program (CACFP) tracking
- Expansion states beyond CA/TX/FL
- SOC 2 Type I audit
- White-labeling
- Public API
- Zapier / Make integrations
- Advanced RBAC (owner is the only role at MVP; staff have upload-portal-only access)
- Multi-language UI (English only at MVP)

---

## 8A. State-Specific Implementation Notes

The generic product is useless; the state-specific details are the product. A non-exhaustive map of what the compliance engine, document taxonomy, and chase flows must encode at MVP:

### California (Title 22, Community Care Licensing Division)

- **Child files required:** LIC-281A (Identification and Emergency Information), LIC-702 (Physician's Report), LIC-627 (Consent for Emergency Medical Treatment), LIC-995 (Personal Rights), LIC-9188 (Caregiver Background Check Process Disclosure).
- **Staff files required:** LIC-508 (Criminal Record Statement), LIC-501 (Staff Health Screening), LIC-503 (Personnel Report), tuberculosis clearance current within 1 year of hire, 15 hours health and safety training, 16 hours continuing education for directors.
- **Immunization:** SB 277 removed personal belief exemptions; medical exemptions require a CDPH-approved provider via CAIR-ME. Required vaccines by entry age per Shots for School schedule.
- **Ratios:** Infant 1:4 (group of 12 max), Toddler 1:6, Preschool 1:12.
- **Inspector checklist:** LIC-9099 (pre-licensing), routine unannounced visits, complaint investigations.

### Texas (HHSC Chapter 746 Minimum Standards for Child-Care Centers)

- **Child files required:** Form 2935 (Admission Information), Form 7259 (Immunization Record review), Form 2937 (Child Health Record), emergency contact, allergy list.
- **Staff files required:** Form 2760 (Criminal History Check Form), FBI/DPS fingerprint check, Form 2948 (Pre-employment Affidavit), 24 annual clock hours of training post-orientation, 8 hours pre-service plus director's certificate for directors.
- **Immunization:** Form 7259 structured record. DSHS school/child-care schedule. Affidavit of conscience allowed via Form 7259-A.
- **Ratios:** 0–11 months 1:4 (group max 10), 12–17 months 1:5, 18–23 months 1:9, 2-year-olds 1:11, 3-year-olds 1:15, 4-year-olds 1:18, 5-year-olds 1:22.
- **Drills:** Monthly fire drill, quarterly severe-weather drill, documented.
- **Inspector checklist:** Form 2936 annual licensing inspection tool.

### Florida (DCF, Child Care Facility Handbook / CFOP 170-20)

- **Child files required:** CF-FSP 5274 (Application for Enrollment), CF-FSP 5316 (Health Exam and Immunization), DH 680 (Immunization) or DH 681 (religious exemption), Student Health Record.
- **Staff files required:** CF-FSP 5131 (Background Screening Attestation), Level 2 background screening via Clearinghouse, 40/45-hour Introductory Child Care Training completed within 90 days of hire, 10 in-service hours annually, FCCPC or DCP (Director Credential) for directors.
- **Immunization:** DH 680 required; DH 681 accepted for religious exemption.
- **Ratios:** Under 12 months 1:4, 1 year 1:6, 2 years 1:11, 3 years 1:15, 4 years 1:20, 5+ years 1:25.
- **Drills:** Monthly fire drill logged, quarterly lockdown drill, annual reunification drill.
- **Inspector checklist:** CF-FSP 5316 environmental/health form plus the quarterly routine inspection checklist.

These details drive the required-document lists, the chase message templates, the self-inspection simulator questions, and the scoring rules. Getting them exact is the product's moat; getting them generic is commodity.

---

## 8B. Assumptions

Explicit assumptions made in shaping this spec:

- Facility has exactly one owner account at MVP. Multi-owner is deferred (see [QUESTIONS.md](QUESTIONS.md) Q10).
- Parents and staff have mobile phones with cameras. Family child care homes without parent phone access (rare in 2026) fall back to manual owner entry.
- OCR confidence is high enough that owner review is still required but correction load is not a primary burden. If accuracy falls below 70%, this assumption breaks and an earlier human-in-the-loop design is needed.
- Regulatory forms referenced (LIC-*, CF-FSP *, Form 2935 etc.) remain stable within MVP window. Form version tracking is NOT in the MVP schema; if a state reissues a form, we treat it as a code change.
- English proficiency is assumed at MVP for the owner user. Spanish UI for parent/staff upload portals is Week 4.
- Stripe and our payment rail hold. No alternate payment path at MVP.
- A single droplet provides sufficient availability for 99.5% at the scale envisioned through first 3 months.

---

## 9. Success Metrics

### 9.1 Product metrics

- **Time to first "compliant enough" score** (score > 80) from signup: < 7 days
- **Document chase resolution rate** at 14 days post-send: > 60%
- **Inspection readiness report exports per active facility per quarter:** > 1
- **OCR extraction accuracy** (human-approved without correction): > 85%

### 9.2 Business metrics

- **MRR at Day 30 post-launch:** $2,000
- **MRR at Day 90:** $10,000
- **Trial → paid conversion:** > 25%
- **Monthly logo churn:** < 7% (benchmark: SMB SaaS)
- **CAC:** ~$0 via SEO-led content strategy

### 9.3 Operational metrics

- **p95 API latency:** < 300ms read, < 800ms write
- **p95 OCR turnaround:** < 60s
- **Production incidents/month:** < 2 (Sev-2+)
- **Magic link delivery success:** > 99%

---

**End of SPEC.md.** Next: [ARCHITECTURE.md](ARCHITECTURE.md).
