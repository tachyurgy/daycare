---
id: REQ041
title: Cron-driven chase job scanner
priority: P0
status: backlog
estimate: L
area: backend
epic: EPIC-07 Chase Service
depends_on: [REQ026, REQ035]
---

## Problem
The chase service is the product's active value: it nags the right people at the right time about the right missing document. It needs a scheduler that runs nightly, computes who to notify, and hands off to the sender.

## User Story
As a director, I want ComplianceKit to automatically remind my parents and staff about expiring documents, so that I don't have to chase them manually.

## Acceptance Criteria
- [ ] `internal/chase/scanner.go` implements `Scanner` with `ScanOnce(ctx) error` that iterates all active providers.
- [ ] Runs on a cron in-process via `github.com/robfig/cron/v3` at `0 9 * * *` (9am local server time, UTC in prod) + a startup run (configurable via `CK_CHASE_CRON`).
- [ ] For each provider, calls `Evaluate(...)` (REQ035) and iterates violations + expiring documents.
- [ ] For each item, determines whether any notification is due per the schedule (REQ042).
- [ ] Produces `ChaseTask{ subject_kind, subject_id, document_type, trigger_reason, recipients[] }` and hands to the sender queue.
- [ ] Scanner is idempotent: re-running within the same day does not duplicate sends (dedupe via REQ044).
- [ ] Scans in parallel with bounded concurrency (`sem := make(chan struct{}, 8)`).
- [ ] Dry-run mode (`--dry-run` CLI flag on `cmd/chase-scan`) prints tasks without sending.
- [ ] Metrics: `chase_providers_scanned`, `chase_tasks_emitted`, `chase_scan_duration_ms`.

## Technical Notes
- Prefer one long-lived binary (`ck-api`) with cron embedded over a separate cron binary for MVP simplicity — gate cron with `CK_RUN_CRON=true` so only one replica runs it.
- Snapshot builder reused from REQ040 to keep consistency.
- `ChaseTask`s written to a simple queue table `chase_queue` with `status` and `scheduled_for` columns.

## Definition of Done
- [ ] Scanner runs nightly in staging and populates the queue.
- [ ] Dry-run output reviewed manually against expected expirations.
- [ ] Tests cover: no notifications before threshold, right notification at threshold, dedupe on re-scan.

## Related Tickets
- Blocks: REQ042, REQ043, REQ044, REQ045
- Blocked by: REQ026, REQ035
