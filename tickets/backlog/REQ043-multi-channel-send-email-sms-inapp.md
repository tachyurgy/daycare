---
id: REQ043
title: Multi-channel send (email / SMS / in-app)
priority: P0
status: backlog
estimate: L
area: backend
epic: EPIC-07 Chase Service
depends_on: [REQ010, REQ011, REQ041, REQ042]
---

## Problem
A single channel isn't enough. Parents respond to SMS; directors want email summaries; everyone looks at the dashboard. Chase tasks must fan out to the right channels per recipient preferences.

## User Story
As a parent, I want to get a text with a one-tap link to upload my child's missing form, so that I can comply while waiting in the car line.

## Acceptance Criteria
- [ ] `internal/chase/sender.go` consumes `ChaseTask`s from the queue and dispatches.
- [ ] Channels: `email` (SES), `sms` (Twilio), `inapp` (row in `inapp_notifications` table rendered in dashboard).
- [ ] Per-subject recipient resolution:
  - Child-scoped: parent1 + parent2 contacts (email + phone each).
  - Staff-scoped: staff member's own email + phone.
  - Facility-scoped: provider admin(s).
- [ ] Channel selection: if recipient has email, send email; if has phone and `sms_opted_out=false`, send SMS. Always create an in-app notification for the director.
- [ ] Each channel uses a template keyed by (subject_kind, threshold_tone). Templates in `internal/chase/templates/*.tmpl.{html,txt,sms}`.
- [ ] Every send records a row in `notification_events(id, provider_id, subject_kind, subject_id, document_type, channel, recipient_hash, threshold_tone, status, provider_response, sent_at)`.
- [ ] Sending is queued; on channel failure, retry via REQ044 dedupe-aware retry.
- [ ] Parent portal links (REQ049) and staff portal links (REQ050) embedded with magic-link tokens.

## Technical Notes
- Worker pool with bounded concurrency (16), consumes `chase_queue` rows with `SKIP LOCKED`.
- Template rendering via `text/template` + `html/template`; strict undefined-variable errors.
- Use `recipient_hash = sha256(channel|destination)` for logs (no PII).

## Definition of Done
- [ ] End-to-end test: simulated expiring CPR at 14d → parent receives SMS with working portal link (verified in staging).
- [ ] Failure on SMS send retries up to 3x, then records failure, doesn't block email.
- [ ] In-app count badge updates live via polling every 60s.

## Related Tickets
- Blocks: REQ044, REQ045
- Blocked by: REQ010, REQ011, REQ041, REQ042
