# ComplianceKit — Technical Architecture

**Version:** 0.1 (MVP)
**Last updated:** 2026-04-16

Companion to [SPEC.md](SPEC.md). Decisions referenced here are justified in [DECISIONS.md](DECISIONS.md).

---

## 1. System Context Diagram

```
                      +---------------------------+
                      |   Browser (React PWA)     |
                      |   GitHub Pages (static)   |
                      +-------------+-------------+
                                    |
                                    | HTTPS (api.compliancekit.app)
                                    v
+---------------+         +---------+----------+         +----------------+
|  Stripe       |<------->|  Go API            |<-- file>|  SQLite (WAL)  |
|  (billing)    |  wh     |  DigitalOcean      |         |  ck.db (local) |
+---------------+         |  Droplet (systemd) |         +----------------+
                          |                    |
+---------------+         |                    |         +----------------+
|  AWS SES      |<--------|                    |-------->|  AWS S3        |
|  (email)      |         |                    |  S3 API |  4 buckets     |
+---------------+         |                    |         +----------------+
                          |                    |
+---------------+         |                    |         +----------------+
|  Twilio       |<--------|                    |-------->|  Mistral OCR   |
|  (SMS)        |         |                    |  HTTPS  |  (primary)     |
+---------------+         |                    |         +----------------+
                          |                    |
                          |                    |         +----------------+
                          |                    |-------->|  Gemini Flash  |
                          |                    |  HTTPS  |  (LLM, narrow) |
                          +--------------------+         +----------------+
                                    ^
                                    | magic link (email/SMS)
                                    |
                          +---------+----------+
                          |   Parent / Staff   |
                          |   (phone camera)   |
                          +--------------------+
```

External integrations enumerated in [EXTERNAL_SERVICES.md](EXTERNAL_SERVICES.md).

---

## 2. Backend Architecture

### 2.1 Language & Runtime

Go 1.22+. Single statically-linked binary (`CGO_ENABLED=0`). Deployed as a systemd unit on a single DigitalOcean droplet (see [DECISIONS.md](DECISIONS.md) ADR-001, ADR-009). Data lives in a local SQLite file (ADR-017) co-resident with the binary.

### 2.2 Package Layout

All application code lives under `backend/internal/`. Public API surface is exposed through HTTP handlers only; no public Go packages at MVP.

```
backend/
  cmd/
    api/                 # main.go for the HTTP server
    worker/              # main.go for background worker (OCR, notifications)
    migrate/             # migration runner
  internal/
    config/              # env var loading, typed config struct
    db/                  # sql.DB (SQLite), pragma setup, migration runner, Tx helper
    httpx/               # router, middleware mounting, error renderer
    auth/                # magic link issuance & validation, session cookies
    middleware/          # authz, rate-limit, request logging, recover
    handlers/            # HTTP handlers grouped by resource
      dashboard/
      children/
      staff/
      facility/
      inspection/
      billing/
      webhooks/
    models/              # domain structs + repository functions
    base62/              # ID generation (16-char base62)
    compliance/          # deterministic rules engine (pure, no I/O)
    magiclink/           # token mint, hash, validate, TTL policy
    storage/             # S3 client abstraction per bucket
    notify/              # SES + Twilio adapters, templating, send queue
    billing/             # Stripe client, webhook handling, plan mapping
    ocr/                 # Mistral primary + Gemini fallback adapter
    pdfsign/             # server-side signature hashing + audit write
    immunization/        # age-based rules engine for immunization dues
  migrations/            # *.up.sql / *.down.sql files
  go.mod
  go.sum
```

### 2.3 Package responsibilities

- **config** — Loads `CK_*` environment variables. Fails loud at startup on missing required keys.
- **db** — Wraps `database/sql` with the pure-Go `modernc.org/sqlite` driver. Applies WAL, foreign_keys, and busy_timeout pragmas at open. Exposes `Tx` helper and typed repository accessors. No ORM. See ADR-017.
- **httpx** — chi router + panic recovery + request ID injection + structured JSON error responses.
- **auth** — Two magic-link flavors: `auth.IssueOwnerLink(email)` (15 min TTL) and `auth.IssuePortalLink(facilityID, subjectID, kind)` (30 day TTL). Validates session cookies.
- **middleware** — `RequireOwner`, `RequireFacilityScope`, `RateLimit`, `RequestLog`.
- **handlers** — Thin HTTP layer. Parses request, calls models, renders JSON.
- **models** — Domain types (`Facility`, `Child`, `Staff`, `Document`, `Signature`, `Notification`, etc.) + repository functions. Repository is file-per-resource.
- **base62** — `base62.New()` returns a 16-character base62 ID (~95 bits of entropy). All primary keys use this. See [DECISIONS.md](DECISIONS.md) ADR-004.
- **compliance** — Pure package. Input: facts (documents, children, staff, facility, state). Output: `Evaluation` (score 0–100, violations list, upcoming deadlines). No I/O, no time calls (takes `now time.Time`). Fully unit-testable.
- **magiclink** — Token = `base62(32 random bytes)`. Stored as SHA-256 hash in DB. Record includes `expires_at`, `used_at`, `issued_ip`, `issued_ua`, `consumed_ip`, `consumed_ua`.
- **storage** — Thin wrapper over `aws-sdk-go-v2/service/s3`. One client per bucket: `storage.Documents`, `storage.Signed`, `storage.Audit`, `storage.RawUploads`. Enforces per-bucket prefix rules.
- **notify** — Queue-backed. `notify.Enqueue(ctx, n Notification)` → row in `notification_queue`. Worker drains the queue, picks SES or Twilio based on channel, retries with exponential backoff, writes to `notification_log`.
- **billing** — Stripe checkout session creation, customer portal, webhook handler (`customer.subscription.*`, `invoice.*`). Maps Stripe price IDs to internal plan enum.
- **ocr** — Interface `ocr.Extractor`. Default impl = `ocr.Mistral`. Fallback = `ocr.GeminiFlash`. Called from the worker, not the API.
- **pdfsign** — Client stamps signature; server hashes (SHA-256) and persists hash + audit trail JSON. Audit JSON includes: token used, IP, UA, ts, doc ID, signature PNG SHA-256, pdf byte count.
- **immunization** — CDC-aligned schedule, with per-state overrides (California personal-belief exemption removed per SB 277; Texas Form 2935 exception tracking; Florida DH 680 form acceptance).

### 2.4 Data Model (key tables)

```sql
facility(id PK, state, name, license_number, license_expires_at, plan, stripe_customer_id, created_at)
account(id PK, facility_id FK, email, role, created_at, last_login_at)
child(id PK, facility_id FK, first_name, last_name, dob, enrolled_at, withdrawn_at)
staff(id PK, facility_id FK, first_name, last_name, role, hired_at, terminated_at)
document(id PK, facility_id FK, subject_type, subject_id, kind, expires_at, s3_key, status, ocr_confidence)
magic_link(id PK, token_hash, facility_id, subject_type, subject_id, kind, expires_at, used_at, issued_ip, consumed_ip)
notification_queue(id PK, facility_id, channel, to_address, template, payload jsonb, scheduled_for, sent_at, status)
notification_log(id PK, queue_id, provider_message_id, status, error, ts)
signature(id PK, facility_id, document_id, signer_subject_type, signer_subject_id, pdf_sha256, audit_s3_key, signed_at)
audit_log(id PK, facility_id, actor_id, action, resource_type, resource_id, ip, ua, ts)
compliance_snapshot(id PK, facility_id, score, violations jsonb, evaluated_at)
```

Primary keys are all base62 strings (TEXT PRIMARY KEY, NOT NULL, default via app layer). Concrete types under SQLite (see ADR-017): TIMESTAMPTZ → TEXT (ISO 8601, default `CURRENT_TIMESTAMP`), JSONB → TEXT validated with `json_valid()`, BYTEA → BLOB, INET → TEXT, CITEXT → `TEXT COLLATE NOCASE`.

---

## 3. Frontend Architecture

### 3.1 Stack

- React 18 + Vite + TypeScript (strict)
- Zustand for state management
- React Router v6
- Tailwind CSS (utility, no component library)
- pdf-lib for client-side PDF signature stamping
- Hosted on GitHub Pages from a public repo

### 3.2 Routes

| Path | Component | Access |
|------|-----------|--------|
| `/` | MarketingLanding | public |
| `/login` | MagicLinkRequest | public |
| `/auth/callback` | MagicLinkConsume | token-gated |
| `/app` | Dashboard | owner-session |
| `/app/children` | ChildrenList | owner-session |
| `/app/children/:id` | ChildDetail | owner-session |
| `/app/staff` | StaffList | owner-session |
| `/app/staff/:id` | StaffDetail | owner-session |
| `/app/facility` | FacilityChecklist | owner-session |
| `/app/inspection` | InspectionSimulator | owner-session |
| `/app/notifications` | ChaseQueue | owner-session |
| `/app/billing` | BillingPortal | owner-session |
| `/p/:token` | ParentUploadPortal | portal-token |
| `/s/:token` | StaffUploadPortal | portal-token |
| `/sign/:token` | SigningFlow | portal-token |

### 3.3 State Management (Zustand)

- `useAuthStore` — session state, logout
- `useFacilityStore` — facility profile, plan, state rules
- `useComplianceStore` — latest score + violations + deadlines, refetch on mutation
- `useUploadStore` — in-flight uploads with progress + retry
- `useNotifyStore` — pending chase messages awaiting owner approval

### 3.4 API Client

Single module `src/api/client.ts`. All calls go through `fetchJSON(method, path, body?)`. Base URL from `VITE_API_BASE`. Bearer token from cookie (HttpOnly, SameSite=Lax, Secure). Retries: 1x on 5xx. Surfaces typed errors to Zustand stores.

---

## 4. Data Flow — Document Upload

The critical path that exercises every layer.

```
Parent/Staff phone
    │ tap magic link → open upload portal
    ▼
Browser uploads file → POST /portal/:token/upload (multipart)
    │
    ▼
Go API
    │ 1. validate token, resolve facility_id + subject_id
    │ 2. generate base62 doc ID
    │ 3. PUT to s3://ck-files/docs/{facility_id}/{doc_id}.{ext}
    │ 4. INSERT document row (status='raw', ocr_confidence=NULL)
    │ 5. INSERT ocr_job row
    ▼
Worker process (pulls from ocr_job queue)
    │ 1. GET from ck-files
    │ 2. send bytes to Mistral OCR
    │ 3. on failure: retry Gemini Flash
    │ 4. send extracted text to Gemini Flash with prompt: extract {kind, expires_at, subject_name}
    │ 5. UPDATE document SET status='pending_review', expires_at=?, ocr_confidence=?
    │ 6. INSERT audit_log
    ▼
Owner dashboard
    │ polls GET /documents?status=pending_review
    │ reviews extracted metadata, approves or edits
    ▼
Go API
    │ UPDATE document SET status='approved'
    │ trigger compliance re-evaluation (async job)
    ▼
compliance package
    │ load facts (all documents, children, staff, facility, state)
    │ evaluate rules (pure fn)
    │ write compliance_snapshot row
    ▼
Frontend
    │ refetch /dashboard → new score, updated deadline list
```

---

## 5. Compliance Engine

The compliance engine is **pure, deterministic, and NOT LLM-backed at runtime**. See [DECISIONS.md](DECISIONS.md) ADR-008.

### 5.1 Interface

```go
package compliance

type Facts struct {
    Facility Facility
    Children []Child
    Staff    []Staff
    Documents []Document
    Now      time.Time
}

type Evaluation struct {
    Score       int           // 0..100
    Violations  []Violation
    Deadlines   []Deadline    // next 90 days
    EvaluatedAt time.Time
}

func Evaluate(facts Facts) Evaluation
```

### 5.2 Rule types

- **Required-document rules:** "Every child in Florida must have CF-FSP 5316 on file within 30 days of enrollment."
- **Expiration rules:** "CPR certification expires 24 months from issue; flag at 90/60/30/7 days."
- **Posting rules:** "Facility must have license, ratio chart, menu, emergency procedures, disaster plan posted."
- **Ratio rules:** "Texas infant room ratio is 1:4 up to 11 months."
- **Drill cadence rules:** "Texas: monthly fire drill, documented."
- **Immunization rules:** Delegated to `immunization` package; age-based.

### 5.3 Scoring

Weighted. Violations carry severity (critical/high/medium/low) and weight (4/3/2/1). Score = 100 × (1 − Σ(weight × count) / maxPossibleWeight). Clamped to [0, 100].

### 5.4 State configuration

Per-state rules live in Go code, not config files, at MVP. Tests cover each state's checklist against a known "passing" fixture. Adding Oregon/Washington = add a package with rules + fixtures.

---

## 6. Deployment Topology

### 6.1 Frontend

- Built with `vite build` → static assets in `dist/`
- Deployed via GitHub Actions to GitHub Pages from `compliancekit/frontend` (public repo)
- Custom domain: `app.compliancekit.app` via CNAME
- Cache headers via `_headers` file (Cloudflare if in front) or via GitHub's defaults

### 6.2 Backend

- Single DigitalOcean droplet, 2 vCPU / 4GB RAM, $24/mo, Ubuntu 24.04
- Systemd units:
  - `ck-api.service` — HTTP server, port 8080, reverse-proxied by Caddy on 443
  - `ck-worker.service` — OCR + notification worker
  - `ck-cron.service` — nightly compliance re-eval, expiration sweep, digest builder
- Caddy provides automatic TLS from Let's Encrypt for `api.compliancekit.app`
- Environment variables in `/etc/ck/env`, chmod 600, loaded via `EnvironmentFile` directive
- Deploy = rsync binary + `systemctl restart`. CI/CD via GitHub Actions SSH job.

### 6.3 Database

- SQLite 3.40+ via `modernc.org/sqlite` (pure-Go, no CGO). See ADR-017.
- File at `/var/lib/compliancekit/ck.db` on the droplet, mode 0600, owned by the `compliancekit` service user.
- Opened with pragmas: `journal_mode=WAL`, `synchronous=NORMAL`, `foreign_keys=ON`, `busy_timeout=5000`, `temp_store=MEMORY`.
- Nightly backup: `sqlite3 $DB '.backup /tmp/snap.db'` (online, consistent), gzip, upload to `ck-backups` in S3, 7-day retention via lifecycle rule.
- Tested restore quarterly: download latest backup, `sqlite3 new.db '.restore'`, run a smoke query set.

### 6.4 Storage

One S3 bucket, `us-west-2`:

| Bucket | Purpose | Notes |
|--------|---------|-------|
| `ck-files` | All uploaded documents, signed PDFs, and signature audit JSON | Versioning on |

Key prefixes inside the bucket: `docs/`, `templates/`, `signed/`, `audit/`. One IAM user scoped to this bucket. See [DECISIONS.md](DECISIONS.md) ADR-010.

---

## 7. Security Model

### 7.1 Encryption

- In transit: TLS 1.3 everywhere. HSTS preload eligible.
- At rest: SQLite DB file on the droplet's encrypted root volume (DigitalOcean volumes are encrypted at rest by default). File perms 0600, owned by the service user. SSE-S3 (AES256) on `ck-files`.

### 7.2 IAM

One IAM user (`ck-deploy`) scoped to `ck-files`: `s3:PutObject`, `s3:GetObject`, `s3:GetObjectVersion`, `s3:DeleteObject`, `s3:ListBucket`, `s3:GetBucketLocation`.

### 7.3 Magic Links

Token format: `base62(32 random bytes)` — 44 characters, ~190 bits entropy.

Storage model: token is NEVER stored plaintext. Only `sha256(token)` lives in `magic_link.token_hash`. On consumption, server hashes incoming token and looks it up.

Issuance metadata: `issued_ip`, `issued_ua`, `issued_at`.
Consumption metadata: `consumed_ip`, `consumed_ua`, `used_at`.

Owner links: TTL 15 minutes, single-use.
Portal links (parent/staff): TTL 30 days, multi-use within TTL. Can be revoked by the owner from the dashboard.

### 7.4 Session

Post-magic-link-consumption, backend issues a session cookie: HttpOnly, Secure, SameSite=Lax, 14-day rolling TTL. Session record in Postgres is the source of truth; cookie value is an opaque base62 ID.

### 7.5 Audit Trail

Every mutation writes to `audit_log`. IP and UA captured on every authenticated request via middleware. Retained forever for MVP; lifecycle policy to be revisited at scale.

---

## 8. Observability

- **Logs:** Structured JSON to stdout. systemd captures via journald. Forwarded to Grafana Cloud free tier via Promtail (10GB/mo free).
- **Metrics:** Prometheus endpoint on `:9090/metrics`. Scraped by Grafana Cloud agent. Free-tier limits sufficient at MVP.
- **Traces:** Deferred post-MVP.
- **Alerts:** Three initial alerts in Grafana Cloud:
  - API p95 latency > 1s for 5 min
  - OCR queue depth > 50 for 10 min
  - Magic link send failure rate > 5% over 15 min
- **Uptime:** BetterStack / UptimeRobot (free tier) pinging `/healthz` every minute.

---

## 9. Cost Estimate @ 100 Paying Customers/Month

| Line item | Cost |
|-----------|------|
| DigitalOcean droplet (2 vCPU, 4GB) | $24 |
| SQLite (local file on droplet) | $0 |
| AWS S3 storage (est. 200GB documents + versioning) | $6 |
| AWS S3 requests | $3 |
| AWS SES (est. 30k emails/mo) | $3 |
| Twilio SMS (est. 10k SMS/mo @ $0.0083) | $83 |
| Mistral OCR (est. 15k pages/mo @ $1/1k) | $15 |
| Gemini Flash (est. 50k extractions/mo) | $5 |
| Domain + DNS (Cloudflare free) | $1 |
| Grafana Cloud + UptimeRobot | $0 |
| Stripe fees (2.9% + 30¢ on $9,900 MRR) | $317 |
| **Total infra/COGS** | **~$457/mo** |
| **Revenue @ 100 × $99** | **$9,900/mo** |
| **Gross margin** | **~95%** |

SMS is the single largest COGS line. Owner-approved batching (no runaway spend) and the option to downgrade to email-only for cost-sensitive plans are already in scope.

---

**End of ARCHITECTURE.md.** Next: [ROADMAP.md](ROADMAP.md).
