---
id: REQ020
title: Children roster bulk upload (CSV + manual)
priority: P0
status: backlog
estimate: L
area: frontend
epic: EPIC-03 Onboarding Wizard
depends_on: [REQ015, REQ016, REQ017, REQ018]
---

## Problem
Per-child compliance (immunizations, emergency contacts, custody forms) is half the product. Without a roster, there's nothing to chase.

## User Story
As a director, I want to upload or enter my currently enrolled children, so that ComplianceKit can start tracking their compliance immediately.

## Acceptance Criteria
- [ ] Fifth step: `ChildrenRosterStep` with tabs "Upload CSV" / "Add manually" (mirrors REQ019).
- [ ] CSV columns: `first_name, last_name, date_of_birth, enrollment_date, parent1_name, parent1_email, parent1_phone, parent2_name, parent2_email, parent2_phone`. At least one parent contact required.
- [ ] Date parsing accepts `MM/DD/YYYY`, `YYYY-MM-DD`, `M/D/YY`.
- [ ] Ages computed from DOB; banner warns if any DOB implies age > 13 or < 0 (likely bad data).
- [ ] Manual entry table like REQ019; row includes one expandable "Add second parent" toggle.
- [ ] Max 500 rows per upload.
- [ ] Data persisted to draft as `children: ChildRow[]`.
- [ ] Step is optional but strongly encouraged; if skipped, the dashboard shows "Add your children" as the top action item.

## Technical Notes
- Shared CSV/table infrastructure with REQ019 — factor out `<RosterUploadTab />` and `<RosterManualTab />` generics.
- Parent contact stored embedded on `children` rows for MVP (`parent1_*`, `parent2_*`); if we later need a `parents` table we migrate then.
- DOB is `date` type, not `timestamptz`.

## Definition of Done
- [ ] CSV with 30 valid rows imports cleanly.
- [ ] Manual entry works end-to-end.
- [ ] Age heuristic warnings appear on bad DOBs.

## Related Tickets
- Blocks: REQ021, REQ049
- Blocked by: REQ015, REQ016, REQ017, REQ018
