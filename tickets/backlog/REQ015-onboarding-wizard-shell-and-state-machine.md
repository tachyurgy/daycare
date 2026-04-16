---
id: REQ015
title: Onboarding wizard shell and state machine
priority: P0
status: backlog
estimate: L
area: frontend
epic: EPIC-03 Onboarding Wizard
depends_on: [REQ013]
---

## Problem
New providers need a guided, "TurboTax"-style signup that collects just enough to deterministically produce their required-documents checklist and initial compliance score. A blank dashboard kills conversion.

## User Story
As a new director, I want a friendly step-by-step wizard that asks me a handful of questions, so that my ComplianceKit account feels configured for me specifically.

## Acceptance Criteria
- [ ] React route `/onboarding` with a multi-step wizard. Steps: `state` → `license_type` → `facility` → `staff_roster` → `children_roster` → `review` → `done`.
- [ ] Wizard state persisted to `localStorage` under key `ck_onboarding_draft` so refreshes don't lose progress; also mirrored server-side in `onboarding_drafts` table (JSONB blob) per session.
- [ ] Each step is its own component in `frontend/src/features/onboarding/steps/*.tsx`.
- [ ] Progress bar shows step N of 6 and estimated time remaining.
- [ ] Back/Next buttons; Next disabled until step is valid (Zod schema per step).
- [ ] `POST /api/onboarding/commit` finalizes the wizard, creates `providers` + children + staff rows atomically in a transaction, deletes the draft.
- [ ] Route guarded by session (provider scope).
- [ ] If the user abandons, returning to `/onboarding` resumes from the last step.

## Technical Notes
- Use `@tanstack/react-router` or `react-router-dom@6` — pick one in repo-wide decision.
- Form state via `react-hook-form` + `zod` resolvers.
- Keep each step under 200 LOC; shared UI primitives live in `frontend/src/components/ui/`.
- TurboTax-style: one question per screen when possible, generous whitespace, large type.
- Mobile-first: all steps usable on 375px width.

## Definition of Done
- [ ] End-to-end Playwright test runs the full wizard and asserts provider + roster rows exist.
- [ ] Resume-after-refresh verified manually.
- [ ] Lighthouse mobile score ≥ 90 on the wizard.

## Related Tickets
- Blocks: REQ016, REQ017, REQ018, REQ019, REQ020, REQ021
- Blocked by: REQ013
