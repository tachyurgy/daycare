# ComplianceKit — Roadmap

**Version:** 0.1
**Last updated:** 2026-04-16
**MVP target:** 2026-04-23 (Thursday)

Companion to [SPEC.md](SPEC.md) and [ARCHITECTURE.md](ARCHITECTURE.md). Day-by-day plan for MVP, then post-MVP weeks 2–8.

The working principle: every day ends with something deployable. No multi-day PRs. Commits land on `main` hourly. See global CLAUDE.md for commit discipline.

---

## Week 1 — MVP (2026-04-16 through 2026-04-23)

### Day 1 — Thursday 2026-04-16 — Scaffolding

**Goal:** Dev environment, deployable skeleton, auth.

- [ ] Provision DigitalOcean droplet + managed Postgres (tickets: REQ-INFRA-001, INFRA-002)
- [ ] Create S3 bucket `ck-files` with IAM user `ck-deploy` — REQ-INFRA-003
- [ ] Register domains, point `api.compliancekit.app` A-record to droplet, `app.compliancekit.app` CNAME to GitHub Pages
- [ ] Go repo scaffold: `backend/` with `cmd/api`, `cmd/worker`, `cmd/migrate`, `internal/{config,db,httpx,auth,middleware,handlers,models,base62,compliance,magiclink,storage,notify,billing,ocr,pdfsign,immunization}` — REQ-INFRA-004
- [ ] React repo scaffold: Vite + TS + Tailwind + Zustand, deployed to GitHub Pages via GitHub Actions — REQ-INFRA-005
- [ ] Caddy + systemd units installed — REQ-INFRA-006
- [ ] Magic link auth end-to-end (owner flow) — REQ002
- [ ] `/healthz` endpoint returning `{"ok":true}` and scrape-ready Prometheus at `/metrics`

**EOD deliverable:** Owner can visit `app.compliancekit.app`, enter email, click magic link from SES, land on an empty `/app` screen.

### Day 2 — Friday 2026-04-17 — Onboarding + Facility model

- [ ] Postgres schema: `facility`, `account`, `session`, `magic_link`, `audit_log` — REQ003
- [ ] Onboarding wizard frontend (facility name, state, license #, license expiry, facility type) — REQ004
- [ ] Gemini Flash-backed TurboTax-style chat for "help me figure out my facility type" — REQ005
- [ ] State-specific checklist seeding on facility creation (CA / TX / FL) — REQ006
- [ ] Dashboard skeleton with placeholder score — REQ007

**EOD deliverable:** Fresh signup → onboarding → dashboard loads with hardcoded score + state-appropriate checklist visible.

### Day 3 — Saturday 2026-04-18 — Children + Staff models + upload portals

- [ ] Postgres schema: `child`, `staff`, `document` — REQ010, REQ021
- [ ] CRUD handlers for children and staff — REQ011, REQ022
- [ ] CSV bulk import endpoints — REQ020, REQ029
- [ ] Magic link issuance for per-child and per-staff upload portals — REQ015, REQ024
- [ ] Parent upload portal frontend (`/p/:token`) — REQ015
- [ ] Staff upload portal frontend (`/s/:token`) — REQ024
- [ ] Document upload → `ck-files` (`docs/` prefix) working end-to-end — REQ016

**EOD deliverable:** Owner can add a child, copy the upload link, open it on their phone, take a photo of a fake immunization record, see it appear in the dashboard as "pending OCR".

### Day 4 — Sunday 2026-04-19 — OCR + compliance engine

- [ ] Worker binary running under systemd — REQ-INFRA-007
- [ ] OCR job queue (Postgres table + polling worker) — REQ017
- [ ] Mistral OCR integration with Gemini Flash fallback — REQ018
- [ ] Gemini Flash structured-extraction prompt for expiration dates + document kind — REQ019
- [ ] Document lifecycle: `raw` → `pending_review` → `approved` — REQ013
- [ ] `compliance` package: first pass at Florida + Texas + California rules — REQ040
- [ ] `immunization` package with CDC baseline + state overrides — REQ018
- [ ] Score calculation + `compliance_snapshot` persistence — REQ001

**EOD deliverable:** Upload a real expired CPR card from a phone → 60 seconds later dashboard shows a violation with a deadline.

### Day 5 — Monday 2026-04-20 — Notifications + chase service

- [ ] Postgres schema: `notification_queue`, `notification_log` — REQ051
- [ ] SES adapter (email) — REQ052
- [ ] Twilio adapter (SMS) — REQ053
- [ ] Nightly cron: expiration sweep, digest builder — REQ054
- [ ] Owner approval queue frontend — REQ055
- [ ] Quiet hours enforcement — REQ056
- [ ] Parent/staff chase message templates — REQ057, REQ058

**EOD deliverable:** Expiring document triggers a queued chase message; owner approves; SMS arrives on the parent's phone.

### Day 6 — Tuesday 2026-04-21 — Inspection readiness + facility/ops

- [ ] Digital daily safety checklist — REQ031
- [ ] Drill logger — REQ032
- [ ] Wall posting tracker (photo upload) — REQ033
- [ ] Ratio calculator — REQ034
- [ ] Self-inspection simulator (CA / TX / FL checklists) — REQ041
- [ ] Inspection-ready PDF export (server-rendered via Go `pdf` lib or frontend via pdf-lib) — REQ043

**EOD deliverable:** Owner can run a self-inspection, answer all yes/no, and export a PDF that mirrors the actual state form layout.

### Day 7 — Wednesday 2026-04-22 — Billing + PDF signing + polish

- [ ] Stripe integration: checkout session, customer portal, webhooks — REQ-BILL-001, BILL-002, BILL-003
- [ ] 14-day free trial enforcement — REQ-BILL-004
- [ ] Promo code support — REQ-BILL-005
- [ ] Self-built PDF signing flow (pdf-lib in browser → hash + audit on backend) — REQ046
- [ ] Signature audit trail writes to `ck-files` under `audit/` — REQ046
- [ ] Error tracking wired up (Sentry or Grafana Cloud)
- [ ] End-to-end smoke test: signup → onboard → add child → parent uploads immunization → OCR completes → dashboard updates → chase message sends → owner upgrades to paid
- [ ] Marketing landing page points "Start free trial" button at live app

**EOD deliverable:** Live product. Pay-wall enforceable. No known sev-1 bugs.

### Day 8 — Thursday 2026-04-23 — LAUNCH

- [ ] Final QA pass with Magnus's test facility (Florida)
- [ ] Seed state-specific SEO landing pages point to live app
- [ ] Announce on LinkedIn + relevant Facebook groups (daycare owner groups in FL/TX/CA)
- [ ] Monitor logs, incident response ready
- [ ] First customer acquisition effort

---

## Post-MVP

### Week 2 (2026-04-24 → 2026-05-01) — Stabilize

- Fix everything the first 10 trial users hit
- Add OR + WA checklists to `compliance` package (expansion states per CLAUDE.md)
- Automated daily backups verification
- Add structured logging fields for customer support debugging
- First "compliance consultant" partner outreach

### Week 3 (2026-05-01 → 2026-05-08) — PWA + mobile polish

- Service worker for offline viewing of dashboard
- Install-to-home-screen prompt
- Camera capture optimization (iOS Safari quirks)
- Push notifications (web push) — gradual rollout
- Start SOC 2 readiness checklist (Vanta free trial)

### Week 4 (2026-05-08 → 2026-05-15) — Growth

- Referral program ($50 credit per referred paying customer)
- Public-facing status page (status.compliancekit.app)
- Weekly digest email → add engagement metrics to influence churn signals
- First paid ad test on Facebook ($500 budget) targeting daycare owner groups
- Add New York to expansion roadmap; start regulatory research

### Week 5 (2026-05-15 → 2026-05-22) — Advanced compliance

- Inspection history import (OCR state inspection PDFs → structured data)
- Corrective action plan tracker
- Staff training hour tracker with CDA / state credential tie-ins
- Food program (CACFP) tracking — optional module, gate behind Pro tier

### Week 6 (2026-05-22 → 2026-05-29) — Integrations

- Brightwheel-export importer (so new customers can bring their roster)
- Procare-export importer
- Google Drive folder importer (owners with everything in Drive)
- CSV export of every entity

### Week 7 (2026-05-29 → 2026-06-05) — Enterprise + multi-site

- Multi-site organization model (`org` → `facility[]`)
- Org-level dashboard rolling up per-site scores
- Enterprise billing ($199/site/mo) with consolidated invoicing
- Org-admin role

### Week 8 (2026-06-05 → 2026-06-12) — SOC 2 + insurance

- Cyber insurance binder bought (expected $800–1,200/yr at first customer count)
- SOC 2 Type I kickoff with Vanta or Drata
- Security page at `compliancekit.app/security`
- Data processing addendum template for Enterprise customers
- Penetration test scoping (post-SOC-2-gap-remediation)

---

## Out of scope for Weeks 1–8

- Native mobile apps
- Inspector portal
- Public API / webhooks for customers
- Zapier / Make
- Multi-language UI
- White-labeling
- Fine-grained RBAC beyond owner + portal-link subjects

See [SPEC.md §8](SPEC.md#8-out-of-scope-for-mvp) for the MVP exclusion list.

---

**End of ROADMAP.md.**
