---
id: REQ045
title: Unsubscribe handling + notification event log
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-07 Chase Service
depends_on: [REQ043, REQ044]
---

## Problem
Legal (CAN-SPAM, TCPA) and deliverability both demand honored unsubscribes and a searchable log of every send. This also gives directors visibility into "did the parent even see my chase?"

## User Story
As a parent, I want a clear way to opt out, so that I control my own inbox without having to talk to my director.

## Acceptance Criteria
- [ ] Every chase email includes a `List-Unsubscribe` header and a visible unsubscribe link: `GET /u/{token}` where token is a signed, per-recipient value.
- [ ] `GET /u/{token}` renders a one-click unsubscribe page listing categories ("Chase reminders", "Billing & account", "Product updates") with checkboxes and a "Confirm" button. One-click mailers (RFC 8058) POST handled too.
- [ ] Unsubscribing records `unsubscribes(recipient_hash, category, unsubscribed_at, source)`.
- [ ] SMS STOP keyword (handled by Twilio) mirrored into `unsubscribes` with category `sms_all`.
- [ ] Sender (REQ043) checks `unsubscribes` before sending and skips.
- [ ] Directors can NOT be opted out of **critical** account emails (billing, breach, suspension) — enforced by flagging those categories as `can_unsubscribe=false`.
- [ ] Notification event log UI: `/notifications` route for provider admins showing every send with filters by channel, recipient, document, and status. Paginated, searchable.
- [ ] Director can resend any notification from the UI (creates a fresh row, resets dedupe window).

## Technical Notes
- Unsubscribe token = HMAC-SHA256(`recipient_hash|category`, server secret) + base62 encode — stateless, revocable by rotating secret.
- UI pages can be static-ish templates served from Go; simpler than React route here.
- Notification log uses server-side pagination with cursor.

## Definition of Done
- [ ] One-click unsubscribe flow verified end-to-end.
- [ ] Sender refuses to send to unsubscribed recipient.
- [ ] Director notification log shows real sends.

## Related Tickets
- Blocks: REQ055
- Blocked by: REQ043, REQ044
