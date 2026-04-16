---
id: REQ013
title: Session cookies and auth middleware
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-02 Auth & Magic Links
depends_on: [REQ009, REQ012]
---

## Problem
Once a magic link is redeemed we need a durable, secure session so the user isn't re-challenged on every page. Cookies must be safe against CSRF, XSS, and hijack.

## User Story
As a user, I want my sign-in to persist across pages and refreshes, so that I only authenticate when truly necessary.

## Acceptance Criteria
- [ ] On successful magic-link verify, server issues a session:
  - Cookie name: `ck_session`
  - Attributes: `HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=2592000` (30 days for provider), `7200` (2h for parent), `14400` (4h for staff).
  - Value: opaque session ID (prefix `ses_`) — never a JWT.
- [ ] `sessions` table columns: `id, user_or_subject_id, provider_id, scope, expires_at, last_seen_at, ip, user_agent, revoked_at, created_at`.
- [ ] Middleware `httpx.RequireSession(scope)` loads session from cookie, verifies not expired/revoked, injects `auth.Principal` into `context.Context`. 401 on failure.
- [ ] `auth.Principal` exposes `ProviderID()`, `SubjectID()`, `Scope()`.
- [ ] `POST /api/auth/logout` revokes the current session (sets `revoked_at`) and clears the cookie.
- [ ] CSRF: for state-changing requests (POST/PUT/DELETE), require either `X-CK-CSRF` header matching a value stored in session, or a fetch from the same origin (SameSite=Lax covers top-level navs, we add the header for XHR/fetch).
- [ ] Session sliding: `last_seen_at` updated at most once per minute (avoid write amplification).
- [ ] Test: expired cookie → 401. Revoked session → 401. Wrong scope (parent hits admin API) → 403.

## Technical Notes
- `Secure` attribute off in dev when `CK_ENV=dev` and host is `localhost`. Guard in code.
- Session lookup uses a cached read (in-memory LRU, 30s TTL) keyed by session ID to avoid DB hit per request.
- Cookie signing not needed (opaque random ID), but verify via lookup.

## Definition of Done
- [ ] Integration test covers login → protected endpoint → logout → protected endpoint (401).
- [ ] CSRF defense verified by cross-origin fetch attempt in test.

## Related Tickets
- Blocks: REQ014, REQ015, REQ049
- Blocked by: REQ009, REQ012
