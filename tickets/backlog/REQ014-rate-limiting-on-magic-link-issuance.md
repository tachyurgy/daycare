---
id: REQ014
title: Rate limiting on magic link issuance
priority: P0
status: backlog
estimate: S
area: backend
epic: EPIC-02 Auth & Magic Links
depends_on: [REQ009, REQ010, REQ011]
---

## Problem
Unlimited magic-link requests burn SES/Twilio credits, enable spam, and let attackers probe for accounts. We need per-destination and per-IP rate limits.

## User Story
As an operator, I want `POST /api/auth/magic` to reject abuse patterns, so that we control costs and prevent account harassment.

## Acceptance Criteria
- [ ] `POST /api/auth/magic` accepts `{"email": "...", "phone": "..."}` plus optional `purpose` and slug for portal links.
- [ ] Rate limits (enforced in order):
  - Per email/phone destination: max 5 links in a rolling 15-minute window.
  - Per IP: max 20 link requests per hour.
  - Per provider slug (for parent/staff portals): max 200 links / hour.
- [ ] On limit breach, response is `429 Too Many Requests` with `Retry-After` header and generic `{"error":"rate_limited"}` body.
- [ ] Even on rate limit breach, the endpoint still returns `202 Accepted` to unauthenticated callers if the address has never been seen before (to avoid enumeration attacks) — but silently skips send. This behavior is config-gated (`CK_AUTH_ENUMERATION_PROTECTION=true`).
- [ ] Limits backed by a Postgres table `rate_limit_buckets(key, window_start, count)` keyed by `dest_hash|ip|slug`. No Redis for MVP.
- [ ] Metrics: every rate-limit hit increments a counter and is logged at `warn` with the key hash (not the raw address).

## Technical Notes
- Use a sliding window approximation: bucket per minute, sum last N minutes. Cheap with a GIN/BRIN or just an index on `(key, window_start)`.
- Destination key is SHA-256 of normalized email/phone to avoid leaking PII in logs.
- Put the rate limiter behind an interface so it can be swapped for Redis post-MVP.

## Definition of Done
- [ ] Burst test hitting the email limit returns 429 on the 6th request within 15 min.
- [ ] Enumeration test: unknown email never reveals existence via timing or status code differences.

## Related Tickets
- Blocks: REQ015
- Blocked by: REQ009, REQ010, REQ011
