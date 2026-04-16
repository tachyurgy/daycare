---
id: REQ037
title: 90-day deadline timeline computation
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-06 Compliance Engine
depends_on: [REQ035, REQ036]
---

## Problem
The dashboard's marquee feature is a 90-day timeline of upcoming deadlines. We need a tight, sorted projection from the evaluator output.

## User Story
As a director, I want a single view of every compliance deadline in the next 90 days, so that I can plan renewals instead of reacting to alerts.

## Acceptance Criteria
- [ ] Function `BuildTimeline(result Result, horizon time.Duration) []TimelineItem` in `internal/compliance/timeline.go`.
- [ ] `TimelineItem`: `{ date, kind (expiring|missing|drill_due|recurring), subject, message, severity, source_rule_id, document_id? }`.
- [ ] Includes:
  - Documents with `expiration_date` within horizon.
  - Violations whose `DueDate` falls within horizon.
  - Scheduled recurring obligations (fire drills next due date computed from last drill date).
- [ ] Sorted by `date asc` then `severity desc`.
- [ ] Groups items by week bucket for UI consumption (`week_of` field).
- [ ] Horizon parameter caps output; returns empty slice not nil if nothing in range.
- [ ] Returns an empty slice within 1ms for a typical provider.

## Technical Notes
- Pure function, no DB. Consumes `Result` from REQ035 plus document rows.
- Week bucketing via `week_of = startOfWeek(item.date, time.Monday)`.
- Returned from API by REQ040.

## Definition of Done
- [ ] Tests cover: horizon boundary, tie-break sort, empty result.
- [ ] Benchmark: 500-item timeline sorts in < 1ms.

## Related Tickets
- Blocks: REQ040
- Blocked by: REQ035, REQ036
