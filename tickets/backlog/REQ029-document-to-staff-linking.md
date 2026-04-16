---
id: REQ029
title: Document-to-staff linking
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-04 Document Management
depends_on: [REQ023, REQ027, REQ028]
---

## Problem
Staff-scoped documents (CPR, TB, background check, training certs) need to hang off a specific staff member. Same pattern as child linking but with staff-specific rules (e.g., one active CPR per staff at a time).

## User Story
As a director, I want each staff certification to be attached to the right teacher, so that I can see at a glance who is expired and where.

## Acceptance Criteria
- [ ] `documents.linked_staff_id` set during confirmation or staff-portal upload.
- [ ] API `POST /api/documents/{id}/link-staff` accepts `{ staff_id }`, validates same-provider ownership.
- [ ] Mutual exclusivity: a document can have exactly one of `linked_child_id` or `linked_staff_id` set (CHECK constraint).
- [ ] Facility-wide documents (license postings, evacuation maps) have neither set — `scope='facility'` added to docs or inferred from type.
- [ ] Supersede same as REQ028.
- [ ] `GET /api/staff/{id}/documents` returns active docs grouped by category.
- [ ] Auto-suggest by fuzzy staff-name match mirrors REQ028.
- [ ] Delete of a staff member soft-archives their docs (`status='deleted'`) — not hard delete.

## Technical Notes
- Add DB constraint:
  ```sql
  alter table documents add constraint documents_subject_mutex
    check (num_nonnulls(linked_child_id, linked_staff_id) <= 1);
  ```
- Reuse `internal/documents/match.go` across child and staff.

## Definition of Done
- [ ] Constraint rejects dual-linked row.
- [ ] Supersede works for staff CPR renewals.
- [ ] Delete staff → their docs soft-archived.

## Related Tickets
- Blocks: REQ040, REQ050
- Blocked by: REQ023, REQ027, REQ028
