---
id: REQ028
title: Document-to-child linking
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-04 Document Management
depends_on: [REQ023, REQ027]
---

## Problem
Many documents (immunizations, enrollment forms, custody orders) belong to a specific child. Compliance requirements are child-scoped, so linkage is mandatory.

## User Story
As a director, I want each immunization record to be tied to the right child, so that a missing record for a specific child raises the right alert.

## Acceptance Criteria
- [ ] `documents.linked_child_id` set during confirmation (REQ027) or at upload time when context is known (e.g., parent portal uploads default to the parent's child).
- [ ] API `POST /api/documents/{id}/link-child` accepts `{ child_id }`; validates ownership (child belongs to same provider).
- [ ] If another active doc of the same `document_type_id` already exists for that child, the new one supersedes the old: old row → `status='superseded'`, `superseded_by_document_id=new_id`.
- [ ] Auto-suggestion: if extracted `subject_name` fuzzy-matches an enrolled child (Levenshtein ≤ 2 on full name), pre-select in the UI with a "Suggested" badge.
- [ ] `GET /api/children/{id}/documents` returns active documents grouped by `document_type.category`.
- [ ] Unlinking allowed only if document isn't the sole resolver of a compliance violation (else warn).

## Technical Notes
- Fuzzy matching lives in `internal/documents/match.go`; unit-tested with canonical cases ("Mia R." → "Mia Robinson").
- Supersede is transactional: update both rows in one tx with a constraint check `not exists(select 1 where linked_child_id=... and document_type_id=... and status='active' and id != new.id)`.

## Definition of Done
- [ ] Test: uploading new CPR for same staff supersedes old.
- [ ] Test: parent portal upload auto-links to correct child.
- [ ] Suggestion UI shows for fuzzy matches.

## Related Tickets
- Blocks: REQ029, REQ040, REQ049
- Blocked by: REQ023, REQ027
