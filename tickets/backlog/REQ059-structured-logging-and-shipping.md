---
id: REQ059
title: Structured JSON logging + log shipping
priority: P1
status: backlog
estimate: M
area: infra
epic: EPIC-11 Deploy & Observability
depends_on: [REQ005, REQ056]
---

## Problem
Logs trapped on one droplet are useless for debugging and gone when the droplet dies. We need cheap, centralized log storage searchable over time.

## User Story
As an operator, I want to search across all production logs by request ID and time range, so that I can investigate incidents from anywhere.

## Acceptance Criteria
- [ ] All API logs are JSON (REQ005) flowing to stdout → journald → cursor-based shipper.
- [ ] Log shipper: `vector` (https://vector.dev) installed on droplet via REQ056 script, reading from journald and shipping to an S3 bucket `ck-logs` with 90-day lifecycle.
- [ ] Logs partitioned in S3 by `year=/month=/day=/hour=` for cheap scans with Athena/S3 Select.
- [ ] Log levels: prod = `info`, staging = `debug`.
- [ ] Per-request log correlates via `request_id`; `provider_id` attached to every log inside authenticated handlers.
- [ ] PII-safe: email/phone/payment fields scrubbed before shipping (regex-based redactor in vector config).
- [ ] Panics and 5xx responses generate a structured `error` log with stack trace.
- [ ] Ops doc `deploy/RUNBOOK.md#logs` explains how to pull logs from S3 for a given timeframe.

## Technical Notes
- Vector config at `deploy/vector/vector.toml` committed.
- Redactor transforms: redact `email`, `phone`, `card_last4`, `ssn` keys — keep hashed versions for correlation.
- For MVP, no Loki/ELK cluster; S3 + occasional `aws s3 sync + jq` is fine.

## Definition of Done
- [ ] Production logs visible in `ck-logs` S3 bucket within 60s of a request.
- [ ] PII redaction verified against a log containing a test email.
- [ ] Runbook section written.

## Related Tickets
- Blocks: REQ060
- Blocked by: REQ005, REQ056
