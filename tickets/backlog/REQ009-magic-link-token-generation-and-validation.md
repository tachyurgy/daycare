---
id: REQ009
title: Magic link token generation and validation
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-02 Auth & Magic Links
depends_on: [REQ002, REQ004, REQ005]
---

## Problem
Passwordless auth is the whole auth story for ComplianceKit — directors, parents, and staff all authenticate via magic links. We need a rock-solid primitive for issuing, storing, and redeeming those tokens.

## User Story
As a user, I want to click a link from my email or SMS and be securely signed in, so that I never have to manage a password.

## Acceptance Criteria
- [ ] `backend/internal/auth/magiclink.go` exports `Issue(ctx, db, params IssueParams) (*MagicLink, error)` and `Redeem(ctx, db, rawToken string) (*MagicLink, error)`.
- [ ] `IssueParams` includes: `Email` (optional), `Phone` (optional), `Purpose` (enum: `signup`, `provider_login`, `parent_portal`, `staff_portal`), `ProviderID` (nullable), `SubjectID` (nullable — child/staff ID for portal links), `TTL` (time.Duration).
- [ ] Token is `id.MagicToken()` — 32 random bytes base62-encoded (~43 chars).
- [ ] DB stores only the **SHA-256 hash** of the token, never the raw token. Column `magic_links.token_hash` is unique.
- [ ] TTL: `signup` + `provider_login` → 15 minutes; `parent_portal` + `staff_portal` → 7 days (sliding: extend on use up to max 90 days).
- [ ] `Redeem` is idempotent for portal links (multi-use within TTL) but single-use for `signup`/`provider_login` — after redeem, set `redeemed_at`, reject further use.
- [ ] Redemption checks: not expired, not (for single-use) already redeemed, not revoked.
- [ ] On redeem, return the linked provider/subject so the caller can create a session.
- [ ] Tests cover: happy path, expired, replay, tampered token, unknown token, revoked.

## Technical Notes
- Use `crypto/sha256` for hashing — we don't need bcrypt here, tokens are high-entropy random.
- Schema: `magic_links(id, token_hash, purpose, email, phone, provider_id, subject_id, expires_at, redeemed_at, revoked_at, last_used_at, use_count, created_at)`.
- Add index on `token_hash`, `expires_at`.
- Never log the raw token — log only `id` and purpose.

## Definition of Done
- [ ] Issue + Redeem flow covered by table-driven tests.
- [ ] Benchmark: 10k issue/s on a laptop.
- [ ] Security review checklist: timing-safe comparison used for token lookups.

## Related Tickets
- Blocks: REQ010, REQ011, REQ049, REQ050
- Blocked by: REQ002, REQ004, REQ005
