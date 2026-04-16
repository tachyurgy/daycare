---
id: REQ016
title: State selection step (CA/TX/FL only)
priority: P0
status: backlog
estimate: S
area: frontend
epic: EPIC-03 Onboarding Wizard
depends_on: [REQ015]
---

## Problem
Every downstream rule pack keys off state. We must capture state first and (softly) gate users whose state isn't supported in MVP.

## User Story
As a new user, I want to select my state and immediately know whether ComplianceKit supports it, so that I don't waste time filling out a wizard I can't finish.

## Acceptance Criteria
- [ ] First step of onboarding: `StateSelectStep`.
- [ ] Large tiles for CA, TX, FL (with state flag/icon). All 47 other states rendered as a single "Not yet supported — join waitlist" button that captures email and exits the wizard.
- [ ] Selected state persisted to draft as `state: "CA" | "TX" | "FL"`.
- [ ] Supported-states list comes from `frontend/src/features/onboarding/supportedStates.ts` and is also validated server-side against `providers.state` check constraint.
- [ ] Waitlist signup POSTs to `/api/waitlist` with `{ email, state }` and stores in `waitlist` table (simple schema: id, email, state, created_at).
- [ ] Confirmation screen: "Thanks — we'll email you when {state} is live."

## Technical Notes
- Keep state tile UI consistent with landing page state tiles so the transition feels continuous.
- Fire a PostHog/analytics event `onboarding_state_selected` with `{ state }` (PostHog added post-MVP; stub for now).
- Waitlist component is tiny — can live in `frontend/src/features/waitlist/`.

## Definition of Done
- [ ] Choosing CA/TX/FL advances the wizard and writes to draft.
- [ ] Choosing "other" renders the waitlist form.
- [ ] Waitlist submission creates a `waitlist` row.

## Related Tickets
- Blocks: REQ017, REQ020
- Blocked by: REQ015
