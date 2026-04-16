---
id: REQ011
title: SMS magic link delivery via Twilio
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-02 Auth & Magic Links
depends_on: [REQ003, REQ009]
---

## Problem
Many parents and staff don't check email in a timely way. SMS is how we actually collect uploads. We need reliable SMS delivery for magic links and later chase notifications.

## User Story
As a parent, I want a text message with a one-tap link to upload my child's immunization record, so that I can comply in under 60 seconds.

## Acceptance Criteria
- [ ] `backend/internal/sms/twilio.go` exports `Sender` with `SendMagicLink(ctx, to, link, purpose string) error` and `Send(ctx, msg Message) error`.
- [ ] Uses `github.com/twilio/twilio-go` SDK.
- [ ] Message format: `"ComplianceKit: Upload {doc name} for {child first name}: {short_link}. Expires {time}. Reply STOP to opt out."` Kept under 160 chars when possible; long links shortened via internal shortener (REQ049 QR infra).
- [ ] Phone numbers validated and normalized to E.164 before send; rejected if not US (+1) for MVP.
- [ ] STOP / HELP keywords honored — Twilio handles, but we mirror opt-out in DB column `users.sms_opted_out`.
- [ ] Twilio status callback at `POST /webhooks/twilio/status` logs `queued/sent/delivered/failed/undelivered` into `notification_events`.
- [ ] Retries on 5xx with backoff, max 3 attempts. Hard-fail on 4xx (invalid number).
- [ ] Unit tests use a mocked Twilio client; integration test gated by `TWILIO_INTEGRATION=1`.

## Technical Notes
- Use A2P 10DLC-registered long code for compliance. Sending number in `TWILIO_FROM_NUMBER`.
- Do not send SMS to users with `sms_opted_out=true`; return a typed error.
- Per-provider daily quota configurable via `providers.sms_daily_limit` (default 500).
- Rate limit enforcement lives in REQ014.

## Definition of Done
- [ ] Live test SMS sent in staging to a real phone.
- [ ] Status callbacks captured and correlated to the notification event row.
- [ ] STOP message from recipient updates `sms_opted_out`.

## Related Tickets
- Blocks: REQ015, REQ043, REQ049
- Blocked by: REQ003, REQ009
