---
id: REQ054
title: Versioned policy acceptance log + re-acceptance flow
priority: P1
status: backlog
estimate: M
area: backend
epic: EPIC-10 Legal & Data
depends_on: [REQ053]
---

## Problem
Policies change. When we update terms, existing users must re-accept before continuing. We need a reliable record and a re-acceptance UX.

## User Story
As a founder, I want to update our Privacy Policy and force all active users to re-accept it, so that ongoing use reflects current terms.

## Acceptance Criteria
- [ ] Current versions registered in `internal/legal/versions.go`:
  ```go
  var Current = map[string]string{ "msa": "2026-04-01", "dpa": "2026-04-01", "privacy": "2026-04-01" }
  ```
- [ ] Middleware `legal.RequireCurrentAcceptance` runs after session middleware on provider-admin routes; loads latest accepted versions for user; if any outdated, responds with 428 Precondition Required JSON `{"error":"reaccept_required","documents":["privacy"],"versions":{"privacy":"2026-05-01"}}`.
- [ ] Frontend interceptor catches 428 and renders a full-screen re-acceptance modal showing only the changed documents.
- [ ] Parent + staff portals do NOT re-prompt (they never accepted anything; upload flow is consent-by-use with notice).
- [ ] Admin audit view `/admin/legal-acceptances` (provider-admin only) shows their org's acceptance history.
- [ ] Export: `GET /api/legal/acceptances.csv` downloads the provider's acceptance records for their records.
- [ ] Bumping a version is a one-line change in `versions.go`.

## Technical Notes
- Acceptance check hot-path: cache per-user accepted versions 5 min in-memory; invalidate on accept.
- Never delete or mutate old acceptance rows — append-only.
- If a user is locked out due to re-accept, they can still hit `/legal/*` public pages.

## Definition of Done
- [ ] Bumping privacy version forces re-accept on next API call.
- [ ] Audit CSV downloads correctly.
- [ ] Portal routes unaffected.

## Related Tickets
- Blocks: REQ055
- Blocked by: REQ053
