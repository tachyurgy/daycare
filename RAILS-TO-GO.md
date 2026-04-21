# Rails → Go for Magnus

You're coming from Rails. Go doesn't give you the same ocean of built-in stuff. This doc is every piece of magic you had for free in Rails and what we're using instead in ComplianceKit, with file pointers to where it lives in the repo.

**TL;DR.** Rails is a framework. Go has a standard library + a bag of small libraries. We assemble the bag. The trade is: more code on day 1, far fewer surprises on day 365.

---

## Cheat-sheet — "In Rails I'd…" → "In our Go stack we…"

| Rails feature | Our equivalent | File / package |
|---|---|---|
| `Rails.logger` | `log/slog` (stdlib, structured JSON) | `cmd/server/main.go` sets `slog.SetDefault`; every handler takes `*slog.Logger` |
| `rails routes` | Chi router, routes declared in code | `internal/api/router.go` — one big `NewRouter(Deps) http.Handler` function |
| ActiveRecord models | Plain structs + hand-written SQL via `database/sql` | `internal/models/models.go` + SQL literals in `internal/handlers/*.go` |
| ActiveRecord migrations | `golang-migrate/migrate` CLI + raw `.up.sql` / `.down.sql` | `backend/migrations/*.sql` (12 so far) |
| `rails db:migrate` | `migrate -path backend/migrations -database sqlite://ck.db up` | Shell command — run by CI + the deploy script |
| Form builders / strong params | `httpx.DecodeJSON` + hand-written struct with `json` tags | `internal/httpx/*.go` |
| `before_action :authenticate_user!` | Chi middleware `mw.RequireProviderSession` | `internal/middleware/auth.go` |
| `protect_from_forgery` / CSRF | Not needed — we're API-only + `SameSite=Lax` cookies + CORS allow-list | `router.go` CORS config + cookie settings in `handlers/providers.go` |
| `flash[:notice]` | Not a concept — API returns JSON status+message; frontend toast | `frontend/src/components/common/Toast.tsx` |
| Session store | Server-side session table + HttpOnly cookie w/ base62 ID | `internal/magiclink/*.go`, migration `000009_sessions_chase_drills.sql` |
| Devise / Sorcery | Our own passwordless magic-link flow | `internal/magiclink/`, `handlers/providers.go` Signup/Signin/Callback |
| Pundit / CanCan (authz) | `mw.RequireRole("provider_admin")` middleware | `internal/middleware/rbac.go` |
| ActionMailer | `notify.Emailer` (AWS SES client wrapper) | `internal/notify/email.go` + templates in `notify/templates.go` |
| ActionText / Rich text | Not applicable — no rich text fields at MVP | — |
| ActiveStorage | `storage.Client` (AWS S3 client wrapper) | `internal/storage/s3.go` |
| Active Job / Sidekiq | Goroutines with 24h ticker loops | `internal/notify/chase.go` + `internal/workers/workers.go` + `internal/retention/purge.go` |
| Action Cable / WebSockets | Not at MVP (polling-only frontend) | — |
| Turbo / Hotwire | React + React Query | `frontend/src/*` |
| Sprockets / Asset pipeline | Vite (ESBuild under the hood) | `frontend/vite.config.ts` |
| ERB / Slim templates | React JSX | `frontend/src/pages/*.tsx` |
| `rake` | `make`, plain shell scripts, or `go run` | `infra/scripts/*.sh`, `.github/workflows/*.yml` |
| RSpec | `go test` | `internal/*/*_test.go` + `test/integration/*_test.go` |
| FactoryBot | Hand-written test fixtures | `test/integration/fixtures.go` has `NewHarness(t)` + `AuthAs(t, state)` |
| Capybara / system tests | Playwright | `frontend/e2e/*.spec.ts` |
| Rails console | `sqlite3 ck.db` or a custom `cmd/admin` binary | No custom admin yet — post-MVP |
| `rails credentials:edit` | Environment variables in `/etc/compliancekit/env` | See `DEPLOY-HETZNER.md` §10 |
| Annotate / schema.rb | `backend/db-schema.md` (hand-maintained summary) | `backend/db-schema.md` |
| `.env` / dotenv | `backend/.env.example` + `internal/config/config.go` | We use OS env; systemd loads the env file |
| `rails new` generators | `cookiecutter`-style? We don't have one. Copy/paste from similar handlers. | — |
| Bullet (N+1 detection) | Not automated — reviews & EXPLAIN QUERY PLAN | — |
| Brakeman (security) | `gosec` — run in CI | Not yet wired (see Gaps below) |
| Rubocop | `golangci-lint` (or `go vet` + `gofmt`) | `go vet ./...` green |
| RuboCop `rails` cops | N/A | — |
| `config/initializers/` | `cmd/server/main.go` run() function sets everything up once | The whole top half of `main.go` |
| I18n / locale files | Not at MVP (English only); frontend hard-coded | — |
| Fixtures (test) | Direct SQL inserts in test setup + API POSTs | `test/integration/fixtures.go` |
| `rails server` | `go run ./cmd/server` or pre-built binary | — |
| Puma workers | Built-in: Go HTTP server is concurrent per-goroutine | — |
| PgBouncer | N/A — single SQLite file, single writer | — |
| `bundle exec` | `go run` / `go build` — Go tool handles deps via `go.mod` | — |
| Heroku / Capistrano deploys | GitHub Actions → `scp` binary → `systemctl restart` | `.github/workflows/backend-deploy.yml` + `DEPLOY-HETZNER.md` §17 |

---

## Long form — where each Rails thing went

### 1. Routing

**Rails.** `config/routes.rb` is the central map. Resources, constraints, concerns.

**Us.** `internal/api/router.go` — one function `NewRouter(d Deps) http.Handler` that wires everything. No DSL, just method calls on a `chi.Router`. You see every route in one screenful.

Example from our repo:
```go
r.Route("/api", func(r chi.Router) {
    r.With(d.RateLimit.Middleware).Post("/auth/signup", d.Providers.Signup)
    r.Group(func(r chi.Router) {
        r.Use(mw.RequireProviderSession(d.Session))
        r.Get("/me", d.Providers.Me)
        r.With(adminOnly(d)).Post("/children", d.Children.Create)
    })
})
```

What you lose: scaffolded REST routes, namespacing magic, nested resources.
What you gain: every route is explicit; no accidental exposure via `resources :users`.

### 2. Models / persistence

**Rails.** `class Child < ApplicationRecord` gives you callbacks, validations, scopes, `belongs_to`, associations, lazy loading, mass assignment, serialization.

**Us.** `internal/models/models.go` is a pile of dumb structs. All SQL is hand-written at the handler level. No ORM.

Example:
```go
// Hand-written SQL (handlers/children.go):
rows, err := h.Pool.QueryContext(ctx, `
    SELECT id, first_name, last_name, date_of_birth
    FROM children WHERE provider_id = ? AND deleted_at IS NULL
    ORDER BY enrollment_date DESC`, providerID)
```

You lose: associations (`child.guardians`), eager loading, validations baked into the model, dirty tracking.
You gain: every query visible + explainable. No N+1 surprises. Database schema and Go structs don't silently drift — until they do, and our integration tests catch it (see migrations `000012` + `000015` which reconciled schema drift caught by integration tests).

**What to do about validations?** We do two things:
1. JSON schema validation at the edge via the struct's `json` tags + hand-written `if`-checks in the handler.
2. CHECK constraints in the SQL schema (e.g., `CHECK (status IN ('active','inactive','terminated'))`).

### 3. Migrations

**Rails.** `rails g migration AddNameToProviders name:string` → Ruby DSL that becomes SQL.

**Us.** Raw `.up.sql` + `.down.sql` pairs under `backend/migrations/`. Numbered 000001, 000002, etc. Apply with the `golang-migrate/migrate` CLI. That's it.

Example: `000012_reconcile_provider_columns.up.sql`:
```sql
ALTER TABLE providers ADD COLUMN name TEXT;
UPDATE providers SET name = COALESCE(NULLIF(dba, ''), legal_name) WHERE name IS NULL;
-- …
```

You lose: `change :up / :down` rollback auto-generation.
You gain: any DBA can read the migration. No Ruby in production.

### 4. Background jobs

**Rails.** Active Job w/ Sidekiq or Redis queue. Retries, scheduling, UI dashboard.

**Us.** Plain goroutines with 24h ticker loops. No external queue at MVP. Pattern:

```go
// main.go
go chase.RunDaily(rootCtx)
go sessionGC.RunDaily(rootCtx)
go snapshotWorker.RunDaily(rootCtx)
go purgeWorker.RunDaily(rootCtx)
```

Each worker:
- Runs one pass immediately on boot (operators see output).
- `time.NewTicker(24 * time.Hour)` + a `select` on `ctx.Done()` for clean shutdown.
- Logs a summary after each pass.

Where they live: `internal/notify/chase.go`, `internal/workers/workers.go`, `internal/retention/purge.go`.

You lose: retries with exponential backoff, visibility UI, priority queues, cron-style scheduling.
You gain: zero external dependencies. At scale (>1k providers) we'd swap in a real queue (Asynq or River), but that's a day-365 decision.

### 5. Authentication

**Rails.** Devise with `devise :database_authenticatable, :recoverable, :rememberable` gives you: signup, login, password reset, session, "remember me" all in two lines.

**Us.** We wrote a passwordless magic-link system from scratch. See `internal/magiclink/` + `handlers/providers.go`.

Flow:
1. User posts email → we mint a token (32 random bytes, base62-encoded), hash it with HMAC-SHA256, store only the hash in `magic_link_tokens`, email the plaintext in a URL.
2. User clicks link → we re-hash the URL param, look up by hash, verify TTL + not-consumed, mark consumed, mint a session row + HttpOnly cookie.
3. Middleware `RequireProviderSession` reads the cookie on every request and puts `provider_id` + `user_id` on the request context.

Why we rolled our own: passwords are a liability. Magic links + 2FA-grade password reset flows have converged. We have one mechanism, not two.

You lose: password flows, OAuth providers, 2FA, account lockout.
You gain: simpler threat model. No bcrypt to tune. No "forgot password" flow to build.

### 6. Authorization

**Rails.** Pundit or CanCan — policy objects on models.

**Us.** `mw.RequireRole(role)` Chi middleware on routes. See `internal/middleware/rbac.go`.

```go
// router.go
r.With(adminOnly(d)).Post("/children", d.Children.Create)  // admin-only
r.Get("/children", d.Children.List)                         // both roles
```

What we don't do: row-level authorization (can this user edit THIS child?). Every handler manually filters by `provider_id`. That's tenant isolation, not RBAC.

You lose: policy classes per model, automatic scoping.
You gain: fewer layers. Row-level auth failures are easier to see because they're inline in the SQL.

### 7. Sessions / Cookies / CSRF

**Rails.** `session[:user_id]`, cookie store signed with a secret, auto-CSRF via `protect_from_forgery`.

**Us.**
- Sessions live in the `sessions` table (server-side). The cookie carries just the session ID.
- Cookie: `HttpOnly; Secure; SameSite=Lax; Domain=.compliancekit.com`. See `handlers/providers.go::Callback`.
- CSRF: we don't use the standard double-submit pattern. We rely on:
  1. `SameSite=Lax` on the session cookie (blocks cross-origin POST, including forms).
  2. CORS allow-list (only `https://compliancekit.com` + `localhost:5173` in dev).
  3. Cookies scoped to the API subdomain.

For the webhook-receive endpoint (`/webhooks/stripe`), we don't use the session cookie at all — we verify Stripe's signature header.

You lose: auto-CSRF token plumbing.
You gain: one less cookie. Simpler for a SPA.

### 8. Mailers

**Rails.** `ActionMailer::Base.deliver_later` → background job → SMTP/SES.

**Us.** `internal/notify/email.go` — a thin wrapper around the AWS SES client. Calls are currently synchronous inside request handlers (the magic-link signup path). The chase worker uses them from a goroutine.

Templates: `internal/notify/templates.go` — Go `text/template` + `html/template` with a shared layout string. The HTML templates are ugly strings in Go code, not ERB files. It's fine at MVP — 4 email types total.

You lose: previewing mails in dev (Rails' email preview).
You gain: one less service (no Mailcatcher needed — we test with MailHog locally or just read the server logs for the magic-link URL).

### 9. File uploads / object storage

**Rails.** ActiveStorage: `has_one_attached :file`, direct uploads to S3, variants (resizing), everything wired.

**Us.** `internal/storage/s3.go` is an AWS SDK v2 wrapper. Flow:
1. Frontend requests a presigned PUT URL via `POST /api/documents/presign`.
2. Frontend uploads the file directly to S3 using that URL (no backend bandwidth).
3. Frontend posts to `/api/documents/{id}/finalize` which reads the S3 object, runs OCR, writes metadata.

No variants, no image transforms. If we ever need thumbnails, we'll add a worker that reads the object and writes a `{key}-thumb.jpg` alongside it.

You lose: `attachment.variant(resize_to_fit: [300, 300])`.
You gain: presigned direct-upload = tens of times cheaper bandwidth-wise.

### 10. Testing

**Rails.** RSpec + FactoryBot + Capybara + VCR. Rich DSL.

**Us.**
- **Unit tests**: `go test` + standard `testing` package. Table-driven tests are idiomatic. See `internal/compliance/engine_test.go` and `ratios_test.go`.
- **Integration tests**: `net/http/httptest.NewServer` + a migration-applying harness. Fresh SQLite per test, real HTTP requests. See `test/integration/fixtures.go`.
- **E2E tests**: Playwright against a real running backend + Vite dev server. See `frontend/e2e/`.

Run the whole suite:
```bash
cd backend && go test ./... -count=1 -race
cd frontend && npm run test:e2e
```

You lose: the rich RSpec DSL (`let`, `subject`, `shared_examples`).
You gain: tests that run in <2 seconds for the full backend, zero external dependencies, deterministic (fresh DB per test).

### 11. Logging + error tracking

**Rails.** `Rails.logger.info`, `Rails.logger.error` to a dev log file, in prod to stdout, Bugsnag / Sentry for errors.

**Us.** Standard library `log/slog` with JSON handler. Structured from day 1.

```go
log.Info("session gc complete", "sessions_deleted", n, "tokens_deleted", n2)
```

Output:
```json
{"time":"2026-04-20T18:47:34Z","level":"INFO","msg":"session gc complete","component":"session_gc","sessions_deleted":12,"tokens_deleted":0}
```

Each handler carries a `Log *slog.Logger` field set to `log.With("component", "providers")`. The request-ID middleware adds `request_id` to every log line in that request.

Error tracking: none yet. Sentry is an env-var flip away in the frontend (`VITE_SENTRY_DSN` already defined). Backend: route every `panic` through `chimw.Recoverer` which logs the stack. Post-MVP we add [Sentry-Go](https://github.com/getsentry/sentry-go).

You lose: Rails' automatic param sanitization in log lines (passwords, tokens).
You gain: you KNOW what gets logged because you wrote the log line.

### 12. Configuration

**Rails.** `Rails.application.config.X`, `Rails.env`, `credentials.yml.enc`.

**Us.** Plain env vars + a `config.Load()` that parses + validates them once at startup. See `internal/config/config.go`.

```go
cfg, err := config.Load()
// cfg.DatabaseURL, cfg.StripeSecretKey, cfg.FrontendBaseURL, ...
```

Env vars live in `/etc/compliancekit/env` (production) or `backend/.env` (dev). Template is `backend/.env.example`.

You lose: encrypted credentials file in the repo.
You gain: 1:1 mapping with The Twelve-Factor App + systemd's `EnvironmentFile`.

### 13. Seeds

**Rails.** `db/seeds.rb`.

**Us.** We don't have a canonical seed file yet. Tests build their own data via the HTTP API (see `test/integration/fixtures.go`). Writing a `cmd/seed` binary that inserts demo CA/TX/FL providers is a 15-minute TODO — post-MVP.

### 14. HTTP middleware

**Rails.** `config/application.rb` pipeline: `Rack::Runtime`, `ActionDispatch::RequestId`, etc.

**Us.** Chi middleware stack in `router.go`:
```go
r.Use(chimw.RequestID)        // generate request ID
r.Use(chimw.RealIP)           // honor X-Forwarded-For
r.Use(chimw.Recoverer)        // catch panics → 500
r.Use(slogRequestLogger(log)) // log every request
r.Use(chimw.Timeout(30*time.Second))
r.Use(cors.Handler(...))
```

Every middleware is a `func(http.Handler) http.Handler` — the net/http pattern.

You lose: Rails' middleware inspector.
You gain: you can read the whole stack in 6 lines.

### 15. WebSockets / realtime

**Rails.** Action Cable. Redis backend.

**Us.** Nothing. Dashboard polls every few seconds via React Query's `refetchInterval`. At MVP scale that's fine and easier to scale. If we ever need realtime we'll probably use Server-Sent Events first (no new dependency) before WebSockets.

### 16. Caching

**Rails.** `Rails.cache.fetch("key", expires_in: 5.min) { expensive_thing }`. Redis / Memcached backing.

**Us.** We cache the compliance score in the `compliance_snapshots` table (DB as cache). The chase worker also writes dedup rows to prevent double sends. No in-memory cache beyond what Chi does for routing.

You lose: 1-line cache wrappers.
You gain: nothing to vacuum, nothing to warm. Post-MVP if we need it, `github.com/coocood/freecache` or `sync.Map` will do for a while; Redis is a year away.

---

## Best-practice checklist — things we're doing right, things to watch

### Green (aligned with idiomatic Go + Rails equivalents)

- ✅ **Context propagation.** Every handler uses `r.Context()`; DB queries use `QueryContext`, `ExecContext`. Cancellations cascade.
- ✅ **Structured logging.** `slog` with JSON handler, component tags, request IDs on every line.
- ✅ **Graceful shutdown.** `signal.NotifyContext` on SIGINT/SIGTERM; 20s drain window; workers respect `ctx.Done()`.
- ✅ **Dependency injection via struct fields.** Every handler has `Pool`, `Log`, `S3`, etc. as fields; no package-level globals. Tests inject fakes.
- ✅ **Env var config + validation at startup.** `config.Load()` fails fast on missing required vars.
- ✅ **Tenant isolation in every SQL query.** Every SELECT, UPDATE, DELETE scopes to `provider_id`.
- ✅ **Idempotent webhooks.** Stripe webhook events deduped via `stripe_events.stripe_event_id UNIQUE`.
- ✅ **Migrations.** Forward-only in CI; both `.up.sql` and `.down.sql` per migration.
- ✅ **Server-side session store.** Cookie carries opaque ID, no sensitive data.
- ✅ **Presigned S3 URLs.** Zero bandwidth through our VM on document upload.
- ✅ **`go test -race` green.** No data race bugs as of the last commit.
- ✅ **`go vet` clean.** No static analysis red flags.

### Yellow (good but missing polish)

- 🟡 **No `golangci-lint` in CI.** Add a config that turns on errcheck, govet, staticcheck, ineffassign, unparam, unused. Small PR.
- 🟡 **No `gosec` scans.** Run on every PR (GitHub Action is two lines).
- 🟡 **No code-coverage badge.** `go test -cover` works locally; publish to Codecov or Coveralls in CI.
- 🟡 **Audit-log emission is per-handler.** Every new handler has to remember to call `auditlog.EmitX`. A middleware that emits for every mutating route would be less error-prone — but would lose the per-event metadata richness. Judgment call; we're OK here.
- 🟡 **No request payload size limits.** Chi defaults are loose. We set `client_max_body_size 30M` in nginx; the Go server should also set `http.MaxBytesReader` in DocumentHandler.Presign to match.
- 🟡 **Handler SQL vs. schema drift.** Integration tests caught migrations 000012 + 000015. A smarter approach: generate Go types FROM the schema (sqlc, xo, or goyesql). Post-MVP — for now, integration tests are the guard rail.
- 🟡 **Background worker errors are logged, not alerted.** If the chase worker panics in a loop, we'll only know from logs. Post-MVP: wire slog.Handler to fire a Slack message on level=error.
- 🟡 **No Prometheus metrics.** Useful at month 2+. `prometheus/client_golang` + Chi middleware is half a day of work.

### Red (things we need to address before paying customers land)

- 🔴 **No max-body reader on document uploads.** The presign flow is fine (file goes direct to S3), but other JSON POST endpoints have no body limit — a malicious payload could OOM. Add `http.MaxBytesReader(w, r.Body, 1<<20)` in every POST handler, or globally via middleware.
- 🔴 **Hand-written SQL is not parameterized in 100% of places.** I spot-checked — every query I read uses `?` placeholders. Run `gosec` before launch to confirm no string concatenation crept in.
- 🔴 **No CSP header.** Add a Content-Security-Policy response header from nginx or Go middleware. Baseline: `default-src 'self'; script-src 'self' https://js.stripe.com; frame-src https://js.stripe.com; img-src 'self' data: https:`.
- 🔴 **Rate limiting is only on auth endpoints.** A logged-in user can hammer `POST /api/documents/presign` freely. Apply `d.RateLimit.Middleware` to the full `/api` subtree — small change in `router.go`.
- 🔴 **No audit log on `GET` reads of sensitive documents.** We log mutations; a data-breach forensic case would want "who viewed this kid's immunization record." Add a `GET` audit hook on `documents.Get`.

---

## "Rails-isms I miss that we should just build"

- **Rails console.** 10-minute task: write a `cmd/console/main.go` that loads config, opens the DB, drops into the user's interactive `sqlite3` client with helpful aliases.
- **Schema annotations.** Run a script that appends the current schema summary to `backend/db-schema.md` on every migration. Automate via `.github/workflows/schema-annotate.yml`.
- **Seed script.** `cmd/seed/main.go` that inserts a CA + TX + FL demo provider with a handful of children/staff/drills. Useful for demos and dev onboarding.

---

## Files you'll touch most

- **Add a feature?** Start in `SPEC.md`, then:
  1. Write a migration if schema changes.
  2. Add the handler struct + methods in `internal/handlers/{feature}.go`.
  3. Mount the route in `internal/api/router.go`.
  4. Wire the handler into `Deps` in `cmd/server/main.go`.
  5. Write an integration test in `test/integration/{feature}_test.go`.
  6. Add a Playwright test in `frontend/e2e/live/{feature}.spec.ts`.
  7. Update `FEATURES.md`, `FEATURE-AUDIT.md`, `QA-TESTING-GUIDE.md`.

- **Fix a bug?** Reproduce with an integration test first. Then fix.

- **Deploy?** Push to `main` → GitHub Actions runs `backend-deploy.yml` → SSH → migrate + replace binary + restart. See `DEPLOY-HETZNER.md` §17.

---

## When it's worth dropping in a framework

Here's the honest calculus on when Go's "assemble-it-yourself" approach would start to hurt:

- **Pure CRUD with 50+ tables** → you'd want sqlc or an ORM. We have ~22 tables today. Not yet.
- **10+ feature teams working in parallel** → some convention helps. We're one person. Not yet.
- **Complex background-job DAGs** → Temporal or River. We have 4 workers that don't depend on each other. Not yet.
- **Complex admin CRUD for non-engineers** → consider GoFrame or a Retool-style internal tool. Not yet.

For the foreseeable future (first 500 customers, 1 engineer), this stack is right-sized. The moment any of the above becomes true, the right-sized move is to add a library, not to port to a framework.

---

## Further reading that'll smooth the transition

- [Effective Go](https://go.dev/doc/effective_go) — once, in full. It's short.
- [Go Proverbs](https://go-proverbs.github.io/) — "don't communicate by sharing memory; share memory by communicating" — internalize these.
- [Practical Go](https://dave.cheney.net/practical-go/presentations/qcon-china.html) by Dave Cheney.
- [Go Programming Language](https://www.gopl.io/) (the Kernighan book) — the O'Reilly hippo of Go.
- For Chi-specific patterns: [Chi's own GitHub examples](https://github.com/go-chi/chi/tree/master/_examples).
- For SQLite in Go: [modernc.org/sqlite docs](https://pkg.go.dev/modernc.org/sqlite) — pure-Go port, no cgo, works great for our scale.

The cultural shift from Rails is: **fewer moving parts, more typing; your blast radius is smaller but your upfront cost is higher.** You break fewer things in production, and it takes longer to get there.
