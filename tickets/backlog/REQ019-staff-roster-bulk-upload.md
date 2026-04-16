---
id: REQ019
title: Staff roster bulk upload (CSV + manual)
priority: P0
status: backlog
estimate: L
area: frontend
epic: EPIC-03 Onboarding Wizard
depends_on: [REQ015, REQ018]
---

## Problem
Directors already maintain staff rosters in spreadsheets. Re-typing them is a friction killer. We need a best-effort CSV import with manual entry as a fallback.

## User Story
As a director, I want to upload a CSV of my staff or add them manually, so that my account is populated in minutes, not hours.

## Acceptance Criteria
- [ ] Fourth step: `StaffRosterStep` with two tabs: "Upload CSV" and "Add manually".
- [ ] CSV columns accepted (case-insensitive, trimmed): `first_name, last_name, email, phone, role, hire_date`. Extra columns ignored with a warning.
- [ ] Column mapping UI if the CSV header is unrecognized: drag-drop mapping UX or dropdowns per column.
- [ ] Client-side CSV parse via `papaparse`; max 500 rows; rows with missing required fields (`first_name`, `last_name`) highlighted red and skipped.
- [ ] Manual tab: inline editable table using `@tanstack/react-table`, add-row button.
- [ ] Email/phone validated with same normalizer used server-side (shared TS package or duplicated regex).
- [ ] Duplicates (same email within upload) flagged; user resolves before continuing.
- [ ] Step can be skipped (optional) — but a banner warns that chase automation depends on having staff loaded.
- [ ] Data persisted to draft as `staff: StaffRow[]`.

## Technical Notes
- `papaparse` for CSV; `react-hook-form` + `@tanstack/react-table` for the table.
- File size limit 2MB, parsed entirely in browser — no server round trip during onboarding.
- Role enum: `owner, director, teacher, assistant_teacher, aide, cook, admin, other`.
- Downloadable template CSV linked above the upload zone.

## Definition of Done
- [ ] CSV with 100 valid rows imports and shows in the table.
- [ ] Malformed rows surface validation errors inline.
- [ ] Manual entry works without uploading.

## Related Tickets
- Blocks: REQ020, REQ021
- Blocked by: REQ015, REQ018
