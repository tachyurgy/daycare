---
id: REQ042
title: Notification schedule (6w / 4w / 2w / 1w / 3d)
priority: P0
status: backlog
estimate: S
area: backend
epic: EPIC-07 Chase Service
depends_on: [REQ041]
---

## Problem
The chase cadence must be aggressive enough to drive action without triggering opt-outs. We picked a five-step schedule; it needs to be a single source of truth consulted by scanner + templates.

## User Story
As a director, I want reminders to escalate as an expiration approaches, so that early reminders are gentle but late reminders are urgent.

## Acceptance Criteria
- [ ] `internal/chase/schedule.go` exports `Thresholds = []Threshold{ {Days:42,Tone:"gentle"}, {Days:28,Tone:"nudge"}, {Days:14,Tone:"firm"}, {Days:7,Tone:"urgent"}, {Days:3,Tone:"critical"} }`.
- [ ] Post-expiration: one more at day 0 (day of) with `Tone:"overdue"` and then weekly until resolved (max 8 weeks).
- [ ] `ShouldNotify(lastSentAt, expirationDate, now) (Threshold, bool)` returns the next threshold crossed and whether to send.
- [ ] If multiple thresholds have been crossed without a send (e.g., new provider joins with already-expiring docs), only the most recent (urgent-most) threshold fires to avoid spam.
- [ ] Critical violations (missing immunization, missing background check) always send at first detection and then weekly.
- [ ] Unit tests cover: exact-day crossings, skipped thresholds, overdue escalation, resolved-in-between.

## Technical Notes
- Keep pure. No DB or network.
- The scanner (REQ041) queries `notification_events` for last-sent timestamp per subject+document_type.
- Threshold definitions shared via constants with the email template (REQ043) so tone language stays in sync.

## Definition of Done
- [ ] Tests: all threshold crossings.
- [ ] README (in-package) documents the schedule.
- [ ] Used by REQ041 and REQ043 correctly.

## Related Tickets
- Blocks: REQ043, REQ044
- Blocked by: REQ041
