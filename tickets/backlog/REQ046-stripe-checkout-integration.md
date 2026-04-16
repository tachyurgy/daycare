---
id: REQ046
title: Stripe Checkout integration for $99/mo Pro
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-08 Billing (Stripe)
depends_on: [REQ003, REQ013]
---

## Problem
We need a working purchase flow that takes a new provider from signup to paid subscription in under two minutes. Stripe Checkout is the fastest route.

## User Story
As a director, I want to enter my card once and start using ComplianceKit Pro, so that I can unlock premium features immediately.

## Acceptance Criteria
- [ ] Stripe products created (via Stripe CLI or dashboard, config-checked in): `ComplianceKit Pro` at $99/mo, `ComplianceKit Starter` at $49/mo, `ComplianceKit Enterprise` at $199/mo per site. Price IDs stored in config.
- [ ] `POST /api/billing/checkout` accepts `{ plan: "pro"|"starter"|"enterprise", promo_code?: string }` and returns `{ checkout_url, session_id }`.
- [ ] Server creates a Stripe Checkout Session with: `mode=subscription`, `customer` created or reused (`stripe_customers(provider_id, stripe_customer_id)`), `success_url`, `cancel_url`, `allow_promotion_codes=true`.
- [ ] On session `success_url` (`/billing/success?session_id=...`), client posts `session_id` to `POST /api/billing/confirm` which pulls the session from Stripe, verifies status, updates provider to `plan=pro`, `subscription_status=active`, `trial_ends_at=null`.
- [ ] Free trial: new providers get 14-day trial without card. Trial created by local logic (not Stripe trial) since we want to gate features ourselves.
- [ ] Idempotency: `POST /api/billing/checkout` uses `Idempotency-Key` derived from `provider_id + plan + day` to avoid duplicate sessions.
- [ ] API and webhook calls use Stripe SDK `github.com/stripe/stripe-go/v78`.

## Technical Notes
- `internal/billing/stripe.go` wraps SDK usage in testable interfaces.
- Never hit Stripe from the frontend directly; all calls go through our API.
- Tax: enable Stripe Tax (automatic calculation) at session creation.

## Definition of Done
- [ ] End-to-end test with Stripe test cards converts a trial account to paid.
- [ ] 4000 0000 0000 0002 (declined) card shows proper error UI.
- [ ] Promo code flow verified.

## Related Tickets
- Blocks: REQ047, REQ048
- Blocked by: REQ003, REQ013
