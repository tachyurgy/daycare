---
id: REQ044
title: Dedupe, quiet hours, and daily digest
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-07 Chase Service
depends_on: [REQ043]
---

## Problem
If we send 12 separate messages to a parent in one morning we'll get opted out fast. Bundling, dedupe, and quiet-hours logic protect user trust and our deliverability reputation.

## User Story
As a parent, I want one consolidated message per day instead of a flurry, so that ComplianceKit feels helpful, not spammy.

## Acceptance Criteria
- [ ] Per `(provider_id, recipient, channel)` cap: max 1 SMS per day, max 2 emails per day. Additional items bundle into the first.
- [ ] Digest email template: lists all pending tasks for that recipient with links; single summary subject line.
- [ ] Digest SMS: up to 3 highest-severity items summarized in ≤160 chars with a single portal link.
- [ ] Quiet hours: no SMS sent between 9pm and 7am recipient local time. Emails always OK. Recipient timezone resolved via provider timezone (providers have `timezone` column default from state).
- [ ] Dedupe: same (subject_id, document_type, threshold_tone) within 24h never sends twice.
- [ ] Holidays: no chase sends on US federal holidays (centralized list in `internal/chase/calendar.go`).
- [ ] Override: "overdue" tone bypasses quiet hours for email only; still respects SMS quiet hours.

## Technical Notes
- Dedupe via query against `notification_events`.
- Digest aggregator: scanner produces tasks tagged with a `digest_group` key `(recipient_hash, channel)`. Sender groups before send.
- Holiday list: `map[string]bool{"2026-01-01":true, "2026-07-04":true, ...}` maintained yearly.

## Definition of Done
- [ ] Load scenario: 20 expiring items for one child → parent receives 1 email and 1 SMS.
- [ ] Quiet hours enforced in tests via injected `now` clock.
- [ ] Holiday dates skipped in tests.

## Related Tickets
- Blocks: REQ045
- Blocked by: REQ043
