---
id: REQ017
title: License type selection step
priority: P0
status: backlog
estimate: S
area: frontend
epic: EPIC-03 Onboarding Wizard
depends_on: [REQ015, REQ016]
---

## Problem
Regulations differ dramatically between a licensed child care center and a family child care home. The document checklist, ratios, and posting requirements all branch on this.

## User Story
As a director, I want to tell ComplianceKit whether I run a center or a home-based program, so that my compliance requirements match my license class.

## Acceptance Criteria
- [ ] Second step: `LicenseTypeStep`.
- [ ] Two tiles: "Child Care Center" and "Family Child Care Home" (small icons, 2–3 line descriptions each).
- [ ] Help text keyed to selected state (e.g., in CA: "Community Care Licensing — LIC-281A vs LIC-277"; in TX: "HHSC Chapter 746 center vs Chapter 747 family home").
- [ ] Selection persisted to draft as `license_type: "center" | "family_home"`.
- [ ] Copy adapts to the state chosen in REQ016.
- [ ] "Not sure?" link opens a side sheet with a 1-paragraph explanation per state and a link to the state licensing website.

## Technical Notes
- Content keyed off `state + license_type` pairs stored in `frontend/src/features/onboarding/licenseTypeCopy.ts`.
- Component structure: `LicenseTypeStep.tsx` renders tiles, imports copy map.
- Keep the side sheet implementation in `frontend/src/components/ui/SideSheet.tsx` — reuse across wizard.

## Definition of Done
- [ ] Choosing each option advances the wizard and persists.
- [ ] Help copy validated against CA/TX/FL regulation docs in `planning-docs/state-docs/`.

## Related Tickets
- Blocks: REQ018, REQ020
- Blocked by: REQ015, REQ016
