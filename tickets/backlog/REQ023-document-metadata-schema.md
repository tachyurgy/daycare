---
id: REQ023
title: Document metadata schema and repository
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-04 Document Management
depends_on: [REQ002, REQ022]
---

## Problem
Documents are the central data object. Schema must support OCR results, expiration tracking, confidence scores, linkage to children/staff, and auditability.

## User Story
As an engineer, I want a clear, queryable documents table, so that compliance, chase, and reporting features all read from the same source.

## Acceptance Criteria
- [ ] `documents` table columns (migration adds to REQ002 base):
  - `id text pk` (prefix `doc_`), `provider_id text fk`, `bucket text`, `s3_key text`, `content_type text`, `size_bytes bigint`, `sha256 text`
  - `document_type_id text fk -> document_types` (nullable until classified)
  - `linked_child_id text fk null`, `linked_staff_id text fk null`
  - `status text check in ('uploading','uploaded','ocr_pending','ocr_failed','classified','human_review','active','superseded','deleted')`
  - `ocr_raw jsonb null`, `ocr_provider text null`, `ocr_attempts int default 0`
  - `extracted jsonb null` (expiration_date, issued_date, subject_name, etc.)
  - `expiration_date date null`, `expiration_confidence numeric null` (0..1)
  - `uploaded_by_user_id text`, `uploaded_via text` (web|parent_portal|staff_portal|sms_upload|email_import)
  - `filename_original text`, `deleted_at timestamptz null`, `superseded_by_document_id text null`
- [ ] Partial index: `documents (linked_child_id) where deleted_at is null`.
- [ ] Partial index: `documents (expiration_date) where status='active'` for chase scanner (REQ041).
- [ ] `internal/documents/repo.go` exports typed methods: `Insert`, `Get`, `ListByProvider`, `ListByChild`, `ListByStaff`, `MarkStatus`, `SetExtracted`, `Supersede`, `SoftDelete`.
- [ ] All mutations write to audit log (REQ034).

## Technical Notes
- Use `pgx`'s `CollectRows` with typed row structs in `internal/documents/model.go`.
- Status transitions enforced in code; no triggers. Add a `StatusTransition` whitelist map.
- `extracted` JSON schema versioned with `_version: "v1"` key.

## Definition of Done
- [ ] Migration applies cleanly.
- [ ] Repo methods covered by tests against dockerized Postgres.
- [ ] pprof: ListByProvider with 5k rows < 50ms.

## Related Tickets
- Blocks: REQ024, REQ025, REQ028, REQ029
- Blocked by: REQ002, REQ022
