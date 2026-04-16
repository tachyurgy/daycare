---
id: REQ021
title: Required-docs checklist generator + first compliance score
priority: P0
status: backlog
estimate: L
area: backend
epic: EPIC-03 Onboarding Wizard
depends_on: [REQ019, REQ020, REQ035]
---

## Problem
After onboarding, the user must immediately see a concrete, personalized checklist and a first compliance score. Otherwise the product feels abstract.

## User Story
As a director, I want to end onboarding on a dashboard showing exactly what documents I'm missing and my current compliance score, so that I know my next action.

## Acceptance Criteria
- [ ] `POST /api/onboarding/commit` returns `{ provider_id, compliance_score, critical_alerts, checklist }` after the transaction.
- [ ] Checklist is generated deterministically from `(state, license_type, facility, staff[], children[])` by calling the compliance engine (REQ035) with an empty document set.
- [ ] Each checklist item has `{ id, category, title, required_for (facility|staff:ID|child:ID), state_reference, severity }`.
- [ ] Categories: `facility_permits, staff_clearances, staff_certs, child_immunizations, child_forms, policies_posted, drills_scheduled`.
- [ ] Initial score computed per REQ038 formula; expected range on a fresh account with no docs ≈ 15–30.
- [ ] Final wizard step (`ReviewStep`) shows a summary + the checklist preview; "Finish" hits the commit endpoint and routes to the dashboard.
- [ ] Dashboard route `/dashboard` reads the same checklist via `GET /api/compliance/score` (REQ040).
- [ ] Checklist items reference the exact state form where applicable (e.g., CA LIC-311A, TX Form 2935, FL CF-FSP 5274).

## Technical Notes
- Backend: `internal/compliance/checklist.go` exposes `Generate(state, licenseType, facility, staff, children) []Item` — pure function, no DB.
- Item references live in `internal/compliance/rules/{ca,tx,fl}.go` as data (see REQ036).
- On commit, insert a row per checklist item into `compliance_violations` with `resolved=false` so chase + dashboard use the same source of truth.

## Definition of Done
- [ ] Test: fresh account with 2 staff + 3 children in each state produces the expected checklist length and categories.
- [ ] Dashboard first-paint shows checklist within 500ms of page load.

## Related Tickets
- Blocks: REQ035, REQ040
- Blocked by: REQ019, REQ020, REQ035
