---
id: REQ018
title: Facility questionnaire step
priority: P0
status: backlog
estimate: M
area: frontend
epic: EPIC-03 Onboarding Wizard
depends_on: [REQ015, REQ017]
---

## Problem
Compliance requirements further branch on facility attributes: capacity, age groups served, hours, whether they serve meals, transport children, etc. We need these answers to produce an accurate checklist.

## User Story
As a director, I want to answer a handful of yes/no and numeric questions about my facility, so that my requirements reflect how I actually operate.

## Acceptance Criteria
- [ ] Third step: `FacilityStep`.
- [ ] Fields captured:
  - License number (text, optional)
  - Licensed capacity (integer, required)
  - Age groups served (multi-select: infant, toddler, preschool, school-age)
  - Operating hours start/end (time pickers)
  - Days of operation (Mon–Sun checkboxes)
  - Serves meals? (yes/no)
  - Transports children? (yes/no)
  - Outdoor play area on-site? (yes/no)
  - Has pool/water feature? (yes/no)
- [ ] Persisted to draft as `facility: {...}`.
- [ ] Validation: capacity 1–400 for centers, 1–12 for family homes.
- [ ] Each field has an inline help tooltip explaining why we're asking.
- [ ] Step scrollable on mobile; each field has a native-feeling input.

## Technical Notes
- Use `react-hook-form` with a single form per step.
- Time inputs via `<input type="time">` (native, avoids library bloat).
- Multi-selects rendered as checkbox groups for accessibility.
- Answers feed the rule evaluator (REQ035) — keep field names stable; they're a public-ish contract.

## Definition of Done
- [ ] All fields validated and saved to draft.
- [ ] Family home capacity cap enforced.
- [ ] Accessibility audit: all inputs labeled, keyboard-navigable.

## Related Tickets
- Blocks: REQ019, REQ020, REQ035
- Blocked by: REQ015, REQ017
