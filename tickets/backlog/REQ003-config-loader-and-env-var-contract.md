---
id: REQ003
title: Config loader and env var contract
priority: P0
status: backlog
estimate: S
area: backend
epic: EPIC-01 Foundation
depends_on: [REQ001]
---

## Problem
Config will be sprawled across billing, storage, email, SMS, OCR. We need one typed loader with validation so a misconfigured deploy fails fast at startup, not mid-request.

## User Story
As an operator, I want the API to refuse to start when a required env var is missing or malformed, so that misconfiguration is caught immediately.

## Acceptance Criteria
- [ ] `backend/internal/config/config.go` exports `type Config struct` with typed fields for: `Env` (dev/staging/prod), `HTTPAddr`, `DatabaseURL`, `SessionSigningKey` (32-byte base64), `StripeSecretKey`, `StripeWebhookSecret`, `TwilioAccountSID`, `TwilioAuthToken`, `TwilioFromNumber`, `SESRegion`, `SESFromEmail`, `S3Region`, `S3Buckets` (struct of 4: Documents, SignedPDFs, AuditTrail, RawUploads), `MistralAPIKey`, `GeminiAPIKey`, `PublicBaseURL`, `APIBaseURL`.
- [ ] `Load()` reads from env, falls back to `.env` file in dev only.
- [ ] Missing required vars produce a single error listing all missing/invalid fields, not one-at-a-time.
- [ ] `SessionSigningKey` must decode to exactly 32 bytes; else error.
- [ ] `.env.example` committed with placeholder values and a comment per field.
- [ ] Unit test `config_test.go` covers: all-present success, missing-required failure, malformed signing key failure.

## Technical Notes
- Use `github.com/caarlos0/env/v10` or hand-rolled reflection; avoid Viper (overkill).
- Do NOT log the Config struct; add `String()` that redacts secrets.
- Bucket names are env-driven so dev/staging/prod can differ.
- `Env == "dev"` enables `.env` loading via `github.com/joho/godotenv`.

## Definition of Done
- [ ] Starting the API with missing vars prints every missing field and exits 1.
- [ ] Starting with a valid `.env` succeeds and logs a redacted config summary.
- [ ] Tests passing in CI.

## Related Tickets
- Blocks: REQ007, REQ009, REQ011, REQ022, REQ024, REQ046
- Blocked by: REQ001
