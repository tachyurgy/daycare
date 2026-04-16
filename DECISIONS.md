# ComplianceKit — Architecture Decision Records

A log of architecture decisions. Each ADR is immutable once Accepted; subsequent changes are added as new ADRs that supersede prior ones. Format follows Michael Nygard's template.

---

## ADR-001 — Go for backend language

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

The backend needs: fast HTTP serving, strong static typing, easy deployment as a single binary, good ecosystem for AWS SDK / Stripe / Postgres. Founder is solo and already productive in Go. The product's hot paths are I/O-bound (Postgres, S3, SES, Twilio) and the OCR pipeline is orchestration, not compute.

### Decision

Use Go 1.22+ for the backend. No Node.js. No Python. No Rust.

### Consequences

- Single static binary, trivial deployment via `rsync` + `systemctl restart`.
- No framework lock-in. Use stdlib `net/http` + chi for routing.
- Fewer third-party SDK options than Node/Python in some places (e.g., Stripe SDK is less feature-complete in Go; Mistral OCR has no official Go client — roll a thin HTTP wrapper).
- Hiring pool is narrower, but not relevant at solo stage.

---

## ADR-002 — React (Vite + TypeScript) for frontend

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

Frontend needs: fast dev loop, static-host-deployable (no SSR at MVP), strong typing, rich ecosystem for PDF manipulation (pdf-lib), drag-drop uploads, camera capture. Considered SvelteKit (smaller bundle, less mature) and Next.js (SSR overhead not needed, would force Vercel or self-hosted Node).

### Decision

Use React 18 + Vite + TypeScript (strict). Tailwind for styling. Zustand for state.

### Consequences

- Static build → host on GitHub Pages (free).
- pdf-lib works directly in browser for signing flow.
- No SSR, so SEO content stays in the existing HTML marketing pages (hand-written), not the app.
- Broadest library ecosystem.
- Bundle size is a concern; mitigate with code-splitting and tree-shaking.

---

## ADR-003 — PostgreSQL for primary datastore

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

Data is inherently relational: facility → staff, facility → child, child → document, staff → certification. Compliance rules require joins across all of these. Document metadata needs query-ability (expiring in 30 days, missing by state rule). Considered MongoDB (no joins, would regret), DynamoDB (vendor lock-in), SQLite (single-node too constraining given managed-DB option is cheap).

### Decision

PostgreSQL 16, DigitalOcean managed tier ($15/mo entry).

### Consequences

- ACID, joins, JSONB when useful, full-text search built-in.
- Managed backups. DR baseline solved.
- Single-writer single-region at MVP. Revisit at 10k+ facilities.
- No ORM (pgx directly + repository layer). See [ARCHITECTURE.md §2](ARCHITECTURE.md#2-backend-architecture).

---

## ADR-004 — Base62 IDs over UUID

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

Primary keys show up in URLs (portal links, magic links, resource pages). UUIDs are 36 chars, ugly, hard to type or say on a phone. Sequential IDs leak volume. Needed: URL-safe, short, unguessable, non-colliding.

### Decision

Use 16-character base62 strings (alphabet `[0-9A-Za-z]`) derived from 10 random bytes (~95 bits entropy). Magic link tokens use 32 random bytes (~190 bits entropy), rendered as base62.

### Consequences

- Primary keys are `TEXT PRIMARY KEY` instead of `UUID`. Slightly larger than binary UUID but negligible at our scale.
- URLs look like `/app/children/8kJ3mN2qRtBvX7Zp` instead of `/app/children/c8f1f3e7-...`.
- Collision probability at 95 bits is cryptographically negligible.
- Need to write a small `base62` package (trivial).

---

## ADR-005 — Magic links over passwords

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

Target users are owner/directors aged 38–62 with moderate tech literacy. Password reset is the #1 support burden in SMB SaaS. The product already integrates email (SES) and SMS (Twilio). Parents and staff uploading documents have zero reason to maintain a password — they are touching the app for a single document, then leaving.

### Decision

No passwords. Two-part magic link system:

1. Owner login — email magic link, 15-minute TTL, single-use, issues a 14-day rolling session cookie.
2. Portal link — per-parent or per-staff, 30-day TTL, multi-use within TTL, revocable by owner.

### Consequences

- Zero password-reset support load.
- Requires reliable email/SMS delivery — SES and Twilio carry that risk.
- Account sharing risk: if an owner forwards their magic link to an assistant, it works. Accept this at MVP.
- Deep link UX on mobile mail clients has quirks; mitigate with clear "tap this button" CTAs.

---

## ADR-006 — Self-built PDF signing over PSPDFKit / DocuSign

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

Compliance workflows include staff acknowledgments (handbook, confidentiality) that benefit from a signing step. DocuSign starts at ~$45/user/mo and does not embed well. PSPDFKit is powerful but $2,400+/yr. Our signing needs are narrow: one signer at a time, signature rendered as PNG stamped onto a PDF, audit trail required.

### Decision

Self-build. Browser uses pdf-lib to stamp the signature PNG onto the PDF. Backend hashes the signed PDF (SHA-256), stores the PDF in `ck-signed-pdfs`, and writes an audit JSON (IP, UA, token, timestamp, SHA-256 of signature PNG, SHA-256 of signed PDF) to `ck-audit-trail`.

### Consequences

- $0 incremental cost.
- Audit trail is legally defensible for internal use but not ESIGN/UETA-certified. That is acceptable for child care compliance artifacts, not for contracts worth defending in court.
- Code surface to maintain: ~500 LOC split across `pdfsign` package and frontend signing route.
- Future: can layer a qualified e-signature vendor in if a customer requires it.

---

## ADR-007 — Mistral OCR as primary, Gemini Flash as fallback

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

Documents arrive as phone photos (immunization cards, CPR cards, handwritten daycare forms) and PDFs. OCR quality is the main variable. Evaluated AWS Textract, Google Document AI, Mistral OCR, Gemini Vision.

- **Textract:** strong, expensive (~$1.50/1k pages), AWS dependency.
- **Google Document AI:** strong, similar price, GCP dependency.
- **Mistral OCR:** competitive quality, ~$1/1k pages, independent vendor.
- **Gemini Flash vision:** cheapest, weaker on handwritten content but solid on typed documents.

### Decision

Primary: Mistral OCR. Fallback on Mistral failure / timeout / low confidence: Gemini Flash. If both fail, document goes to a manual review queue.

### Consequences

- Two vendor dependencies instead of one.
- Cost stays low while quality stays high.
- Must build a thin HTTP client for Mistral (no Go SDK).
- Not locked into AWS for OCR — useful if we ever leave AWS.

---

## ADR-008 — Deterministic compliance engine, not LLM-at-runtime

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

Compliance rules are regulation-derived: "Florida requires every child to have CF-FSP 5316 on file within 30 days of enrollment." These rules do not change based on free-form user input. Running them through an LLM introduces non-determinism, hallucination risk, latency, and cost — for a problem that is already well-defined.

### Decision

The `compliance` Go package is a pure function: `Evaluate(Facts) → Evaluation`. No I/O, no LLM calls. Rules encoded in Go code with per-state branches. Full unit-test coverage per state.

LLMs (Gemini Flash) are used ONLY for:
1. OCR structured extraction (expiration dates, document kind) — narrow.
2. Onboarding chat ("help me figure out my facility type") — conversational, not safety-critical.

### Consequences

- Compliance engine is explainable: an owner can always ask "why is my score 82?" and get a deterministic answer tied to a specific rule.
- Lower runtime cost; the rules engine runs in under 10ms for any facility we will serve at MVP scale.
- Adding rules requires code changes, not prompt changes. Deliberate tradeoff.

---

## ADR-009 — Single DigitalOcean droplet over Kubernetes

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

At MVP (solo founder, 0 customers at launch, target 100 customers by day 90), the operational overhead of K8s is obviously wrong. The question is droplet vs. Fly.io vs. Render vs. Hetzner.

### Decision

Single DigitalOcean droplet (2 vCPU, 4 GB, $24/mo). Caddy + systemd. Managed Postgres alongside. Deploy via GitHub Actions SSH + rsync.

### Consequences

- Single point of failure. Accept it at MVP — target SLA is 99.5%.
- Trivially debuggable: SSH in, tail journalctl, see what is broken.
- Vertical scaling: 4x to 8 vCPU / 16 GB is a one-click resize (~$96/mo). Gets us to 10,000 facilities before topology needs to change.
- Revisit when we hit the first of: 5,000 paying customers, a second engineer, or a compliance certification (SOC 2) that prefers multi-AZ.

---

## ADR-010 — S3 bucket partitioning by content type

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

Different document types have different security, retention, and access-pattern needs. Original parent uploads are arbitrary phone photos; we do not want them co-mingled with signed PDFs or audit blobs. A single bucket with prefixes works but complicates IAM scoping.

### Decision

Four dedicated buckets:

- `ck-raw-uploads` — ephemeral, 7-day lifecycle delete, OCR worker reads here, gets scrubbed after move.
- `ck-documents` — originals after approval, versioning on, retain forever.
- `ck-signed-pdfs` — completed signed PDFs, versioning on, retain forever.
- `ck-audit-trail` — signature audit JSON, Object Lock (WORM) mode, 7-year retention.

Each bucket has its own IAM user with scoped permissions.

### Consequences

- Four sets of access keys to manage — mitigated by env-var convention (`CK_S3_DOCS_ACCESS_KEY`, etc.).
- Clear blast-radius boundaries: compromise of the raw-uploads key cannot read signed PDFs.
- Audit bucket WORM policy means even a compromised admin cannot tamper with signature history.
- Slightly higher S3 cost (per-bucket request overhead is negligible at our scale).

---

## ADR-011 — GitHub Pages + DigitalOcean droplet over Vercel / Render

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

Modern serverless-leaning PaaS (Vercel, Render, Fly) would run both frontend and backend. Benefits: less ops. Costs: Vercel's bandwidth pricing punishes file-heavy apps, Render's backend tier is $7+/mo with colder starts, platform lock-in constrains future decisions.

### Decision

Frontend: GitHub Pages (free, public repo). Backend: DigitalOcean droplet (owned infra).

### Consequences

- Public frontend repo — acceptable because the React code is not a moat.
- No serverless cold-start problems.
- Owned infra means systemd + journalctl + rsync remain viable forever.
- Slightly more deploy pipeline to maintain (two repos, two workflows). Acceptable.

---

## ADR-012 — No native mobile apps at MVP; PWA only

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

Parents and staff will use phones heavily (photo uploads). Owner will use both phone and laptop. Native apps mean App Store + Play Store submission, two additional codebases, and review cycles that are incompatible with a 1-week MVP.

### Decision

Build a mobile-optimized React PWA. Install-to-home-screen, service worker, camera capture via `<input type="file" capture>`. No native apps in 2026.

### Consequences

- All users install-to-home-screen via the browser. Friction is minimal but non-zero.
- Push notifications are web push, which has iOS limitations (requires iOS 16.4+ and home-screen install for Safari).
- No App Store distribution, no App Store fees.
- If a strong user signal emerges post-launch for native, revisit. Until then, the PWA covers the 80% case.

---

## ADR-013 — WA LLC serves all states at MVP (no foreign qualification)

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

The legal entity is a Washington LLC. Customers are in FL, TX, CA initially. "Foreign qualification" (registering to do business in each state) triggers state franchise taxes, registered agent fees, and ongoing filings in each foreign state. Legal guidance (from our legal agent's docs) confirms that selling SaaS into a state does not categorically require foreign qualification.

### Decision

Operate under the WA LLC only at MVP. Do not foreign-qualify in CA, TX, FL. Revisit if: physical presence (office, employee) in another state, or revenue in a state crosses $250k/yr where franchise tax economics flip.

### Consequences

- Saves ~$800/yr/state in filings and franchise tax minimums.
- Some risk of being deemed "doing business" in a state; case law generally protects pure-SaaS out-of-state sellers.
- Revisit annually or on material change in facts.

---

## ADR-014 — No cyber insurance at MVP (buy at first customer)

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

Cyber liability insurance is a standard risk-transfer instrument. At zero customers, there is no PII to lose. At first paying customer, the story changes immediately.

### Decision

No cyber insurance before first paying customer. Policy bound within 14 days of first paid subscription. Expected cost: $800–1,500/yr at MVP revenue.

### Consequences

- Zero insurance premium burn during pre-revenue phase.
- Carrier selection done under deadline pressure. Mitigate by pre-shopping 2–3 brokers before launch (homework to do Day 7).
- Claims-made policies require continuous coverage once started; plan to maintain.

---

## ADR-015 — No SOC 2 at MVP; kick off after $10k MRR

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

SOC 2 Type I + Type II is the de facto enterprise SaaS security credential. Target market at MVP is single-site owner/directors who do not ask for SOC 2. Enterprise tier (multi-site) will ask, but Enterprise is not the MVP ICP. SOC 2 costs: $7k–15k for Type I via Vanta/Drata, plus 3–6 months of controls work.

### Decision

Defer SOC 2 until $10k MRR is stable. At that point, kick off Vanta or Drata for Type I. Build security practices toward SOC 2 from day one (least-privilege IAM, audit logs, MFA everywhere, encryption at rest, written policies) so that the audit-readiness phase is weeks not months.

### Consequences

- No enterprise-tier contracts until certified. Acceptable — MVP does not chase them.
- Must maintain discipline so that when the audit starts, controls already hold. The architecture in [ARCHITECTURE.md](ARCHITECTURE.md) is drawn to this shape deliberately.
- If a major Enterprise opportunity walks in pre-MRR-target, reassess.

---

## ADR-016 — Zustand over Redux / MobX / Jotai

- **Date:** 2026-04-16
- **Status:** Accepted

### Context

Frontend state needs: session, facility profile, compliance scores, in-flight uploads, pending chase messages. Redux Toolkit is heavyweight for a five-store app. Jotai's atomic model fits some parts but not others. Zustand is tiny (1 KB), works with hooks, no provider boilerplate.

### Decision

Zustand.

### Consequences

- Stores are colocated with features.
- No time travel / devtools out of the box (Zustand has a devtools middleware; acceptable).
- Migration path to Redux or TanStack Query possible if scale demands.

---

**End of DECISIONS.md.**
