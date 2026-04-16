---
id: REQ058
title: Backend CI — test + build + ship artifact
priority: P0
status: backlog
estimate: M
area: infra
epic: EPIC-11 Deploy & Observability
depends_on: [REQ008, REQ056]
---

## Problem
Every backend merge must be tested and built into a shippable artifact, then deployed to the production droplet. Manual scp-and-restart is fragile.

## User Story
As an engineer, I want merges to main to run the full CI pipeline and deploy to the droplet, so that production reflects HEAD without manual steps.

## Acceptance Criteria
- [ ] `.github/workflows/backend-ci.yml` triggers on push to `main` (path filter `backend/**`) and PRs.
- [ ] PR job: `make ci` (fmt, lint, test, build) with a Postgres service container for integration tests. Race detector on.
- [ ] Main job: on green CI, builds `linux/amd64` binary, SHA256-hashes it, uploads to a GitHub release (automated), and posts an SSH-based deploy step to the droplet:
  - Copies binary to `/opt/ck/bin/ck-api.new`
  - Verifies SHA256 against recorded value
  - Atomic swap: `mv ck-api.new ck-api` + `systemctl restart ck-api`
  - Waits for `curl localhost:8080/healthz` to return 200 within 30s; rolls back if not.
- [ ] SSH deploy uses a dedicated deploy key (not the founder's personal key) stored in repo secrets.
- [ ] Migrations: prior to binary swap, runs `migrate -path ./migrations -database $DATABASE_URL up`. On migration failure, aborts deploy.
- [ ] Status reported in Slack (via webhook) or at minimum GitHub PR checks.

## Technical Notes
- Cache Go modules: `actions/setup-go@v5` with built-in caching.
- Use `ssh-agent` action or explicit `ssh -i` with key from secret.
- Keep deploy idempotent — re-running should no-op if binary hash matches running.

## Definition of Done
- [ ] Push to main → droplet runs new binary within 5 minutes.
- [ ] Healthcheck rollback tested by pushing a deliberately broken binary.
- [ ] Migration failure halts deploy.

## Related Tickets
- Blocks: REQ060
- Blocked by: REQ008, REQ056
