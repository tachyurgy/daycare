---
id: REQ060
title: Uptime monitoring + paging (Uptimerobot free)
priority: P1
status: backlog
estimate: S
area: infra
epic: EPIC-11 Deploy & Observability
depends_on: [REQ056, REQ058, REQ059]
---

## Problem
If the droplet goes down at 2am, the founder wants to know immediately, not from a customer email the next morning. Free-tier uptime monitoring is the cheapest credible safety net.

## User Story
As the founder, I want an SMS and email when the API goes down, so that I can respond within minutes.

## Acceptance Criteria
- [ ] Uptimerobot account configured with monitors:
  - `https://api.compliancekit.com/healthz` — HTTP keyword monitor, expecting `"status":"ok"` in body, 1-minute interval.
  - `https://app.compliancekit.com/` — HTTP 200 monitor, 5-minute interval.
  - Database reachability: a secondary endpoint `/healthz/deep` which verifies Postgres + S3 reachability, checked every 5 minutes.
- [ ] Alerts go to founder email + SMS with 2-minute dead-time before alerting (avoid transient flaps).
- [ ] Public status page at `status.compliancekit.com` using Uptimerobot's hosted status page.
- [ ] `/healthz/deep` returns 500 on any backend check failure; `/healthz` remains fast/dumb for LB.
- [ ] A weekly "uptime digest" email sent by Uptimerobot to founder.
- [ ] Runbook section `deploy/RUNBOOK.md#incident-response` documents first-5-minutes playbook for a down alert.

## Technical Notes
- `/healthz/deep` internal impl in `internal/httpx/health.go`: pings `db.Ping(ctx)`, does a HEAD against each S3 bucket, returns JSON with per-check status. Timeout 3s.
- Status page reflects only public-facing monitors (not the deep one, to avoid noise).
- Keep alert recipients in a config-committed YAML so adding an oncall isn't a secret rotation.

## Definition of Done
- [ ] Stopping the API triggers an alert within 3 minutes.
- [ ] Status page reachable at custom domain.
- [ ] Runbook written.

## Related Tickets
- Blocks:
- Blocked by: REQ056, REQ058, REQ059
