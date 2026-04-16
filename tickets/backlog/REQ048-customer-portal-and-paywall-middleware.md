---
id: REQ048
title: Customer portal + paywall middleware
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-08 Billing (Stripe)
depends_on: [REQ046, REQ047]
---

## Problem
Users need self-service to update card, change plan, cancel. We also need middleware that gates premium features cleanly rather than scattering plan checks through handlers.

## User Story
As a director, I want to update my payment method or cancel without emailing support, so that my account lifecycle is fully self-service.

## Acceptance Criteria
- [ ] `POST /api/billing/portal` creates a Stripe Billing Portal session, returns `{ portal_url }`. Requires provider-admin session.
- [ ] Billing Portal configured in Stripe with: update payment method, switch plan, cancel, view invoices.
- [ ] Paywall middleware `billing.RequirePlan(plans ...string)` returns 402 Payment Required with JSON `{"error":"plan_required","required":["pro"],"current":"starter"}` when access denied.
- [ ] Free features (baseline dashboard, compliance view read-only) always accessible.
- [ ] Premium features gated: PDF signing (REQ034), chase service sending (REQ043), parent/staff portals (REQ049/REQ050), inspection simulator (post-MVP).
- [ ] 14-day trial grants `pro` access. After trial end without payment, plan downgrades to `starter_expired` with gate on premium features.
- [ ] Grace period for past-due: 7 days of continued access with banner, then gated.
- [ ] Frontend `<Paywall feature="pdf_signing" />` component renders upgrade CTA on 402 responses.

## Technical Notes
- Plan hierarchy helper: `planGte(current, required)` uses an ordered list.
- Paywall middleware integrates with REQ013 session (reads `provider_id` → loads subscription status from cache, not Stripe every request).
- Subscription cache: 60s TTL in-memory + invalidate on webhook.

## Definition of Done
- [ ] Portal link opens Stripe portal and reflects changes back via webhook.
- [ ] Trial → paid → canceled lifecycle fully works.
- [ ] Paywall returns correct 402 on gated features.

## Related Tickets
- Blocks:
- Blocked by: REQ046, REQ047
