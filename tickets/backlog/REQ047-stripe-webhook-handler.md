---
id: REQ047
title: Stripe webhook handler
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-08 Billing (Stripe)
depends_on: [REQ046]
---

## Problem
Subscription state lives in Stripe. Without webhook handling, cancellations, payment failures, and plan changes silently drift our DB out of sync with reality.

## User Story
As an operator, I want provider subscription status to always reflect Stripe's truth, so that premium features are correctly gated and delinquent accounts don't get service for free.

## Acceptance Criteria
- [ ] `POST /webhooks/stripe` handler.
- [ ] Verifies `Stripe-Signature` using `StripeWebhookSecret` via SDK helper. Rejects with 400 on mismatch.
- [ ] Handles events:
  - `checkout.session.completed` → link subscription → provider
  - `customer.subscription.created/updated` → upsert into `subscriptions` table
  - `customer.subscription.deleted` → mark provider `subscription_status='canceled'`, schedule grace period (see REQ055)
  - `invoice.payment_succeeded` → record payment
  - `invoice.payment_failed` → mark `subscription_status='past_due'`, send dunning email (via SES)
  - `invoice.paid` → clear `past_due`
- [ ] Idempotent: stores `stripe_events(id, event_id unique, type, received_at, processed_at, error)`; duplicate event_id → no-op.
- [ ] Returns 2xx quickly; heavy work deferred to a goroutine that updates processed_at.
- [ ] Unhandled event types logged and 200-returned (Stripe best practice).
- [ ] Integration test via Stripe CLI `stripe trigger invoice.payment_failed`.

## Technical Notes
- Use `webhook.ConstructEvent` for signature verification.
- Keep handler thin; dispatch to `internal/billing/events/*.go` per event type.
- Dunning email template lives in `internal/email/templates/dunning_*.tmpl.*`.

## Definition of Done
- [ ] Stripe CLI tests verify each event type updates DB as expected.
- [ ] Signature mismatch rejected.
- [ ] Duplicate event dropped silently.

## Related Tickets
- Blocks: REQ048
- Blocked by: REQ046
