---
id: REQ057
title: GitHub Actions — frontend GitHub Pages deploy
priority: P0
status: backlog
estimate: M
area: infra
epic: EPIC-11 Deploy & Observability
depends_on: [REQ008, REQ056]
---

## Problem
Frontend is a public repo hosted on GitHub Pages. Every merge to `main` should ship to production automatically with preview builds on PRs.

## User Story
As an engineer, I want `git push` to main to deploy the frontend within 3 minutes, so that iteration is fast and rollback is git-native.

## Acceptance Criteria
- [ ] `.github/workflows/frontend-deploy.yml` triggers on push to `main` (path filter `frontend/**`) and on workflow_dispatch.
- [ ] Steps: checkout, setup Node 20, `npm ci` in `frontend/`, `npm run build`, upload artifact, deploy to Pages via `actions/deploy-pages`.
- [ ] Build time budget: < 2 minutes; total workflow < 4 minutes.
- [ ] Pages site configured with custom domain `app.compliancekit.com` (DNS CNAME set outside CI).
- [ ] SPA fallback via `404.html` trick or Pages config so deep links work.
- [ ] Env-specific config: `VITE_API_BASE_URL` baked at build time from repo secret `API_BASE_URL_PROD`.
- [ ] PR preview workflow `.github/workflows/frontend-preview.yml` builds every PR and uploads the dist as an artifact; optionally deploys to a preview branch (`gh-pages-preview-{pr}`) for manual smoke test.
- [ ] Cache `~/.npm` keyed by `frontend/package-lock.json`.
- [ ] Fail build on TypeScript errors, ESLint errors, and failed Vitest tests.

## Technical Notes
- Vite config sets `base` appropriately for Pages + custom domain.
- CSP meta tag or `_headers` (not honored by Pages) — use inline meta restrictive CSP.
- Keep source maps out of prod bundle (Vite `build.sourcemap=false`) unless wanted for Sentry post-MVP.

## Definition of Done
- [ ] Push to main deploys to `app.compliancekit.com`.
- [ ] PR opens a comment with preview artifact URL or preview branch link.
- [ ] Broken TS build fails workflow.

## Related Tickets
- Blocks:
- Blocked by: REQ008, REQ056
