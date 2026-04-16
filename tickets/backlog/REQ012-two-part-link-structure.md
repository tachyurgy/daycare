---
id: REQ012
title: Two-part magic link structure (provider + individual)
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-02 Auth & Magic Links
depends_on: [REQ009]
---

## Problem
Providers, parents, and staff each need distinct sign-in experiences. A provider's link drops them into the admin dashboard; a parent's link drops them into a per-child upload portal. The link structure must encode which is which without leaking info.

## User Story
As a director, I want different portal URLs for parents vs staff vs myself, so that each audience sees only what they need and nothing more.

## Acceptance Criteria
- [ ] URL shape:
  - Provider: `https://app.compliancekit.com/auth/magic?t={token}`
  - Parent: `https://app.compliancekit.com/p/{provider_slug}/parent?t={token}`
  - Staff: `https://app.compliancekit.com/p/{provider_slug}/staff?t={token}`
- [ ] `provider_slug` is a base62 8-char random string stored on `providers.slug`, unique. Not the raw provider ID.
- [ ] Server-side `GET /api/auth/magic/verify?t=...` endpoint validates the token, checks that `purpose` matches the URL path (parent link cannot be redeemed at provider endpoint), and on success issues the appropriate session.
- [ ] Cross-purpose redemption returns 403 with generic "invalid link" message — no info leak.
- [ ] Magic links for portals (parent/staff) include `subject_id` (child or staff) in the DB row; endpoint loads and scopes the session accordingly.
- [ ] Frontend route handlers in `frontend/src/routes/` match the URL shapes and call the verify endpoint before rendering portal UI.
- [ ] Tests cover: correct purpose + url combo, wrong purpose (e.g., parent token at staff URL), missing slug, unknown slug.

## Technical Notes
- Slug generation: `id.New("")` style but without prefix; 8 chars is sufficient since we're not blindly scanning.
- Session issued after verify is scoped: `session.Scope = "provider" | "parent" | "staff"`, enforced in middleware (REQ013).
- Keep the token in query string, not path, so server logs can redact on the fly (REQ005 middleware strips `t=...`).

## Definition of Done
- [ ] End-to-end test: issue parent link → visit URL → session bound to the single child.
- [ ] Cross-purpose attack test returns 403.

## Related Tickets
- Blocks: REQ013, REQ049, REQ050
- Blocked by: REQ009
