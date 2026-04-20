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
  - `id TEXT PRIMARY KEY` (prefix `doc_`), `provider_id TEXT FK`, `bucket TEXT`, `s3_key TEXT`, `content_type TEXT`, `size_bytes INTEGER`, `sha256 TEXT`
  - `document_type_id TEXT FK -> document_types` (nullable until classified)
  - `linked_child_id TEXT FK null`, `linked_staff_id TEXT FK null`
  - `status TEXT CHECK IN ('uploading','uploaded','ocr_pending','ocr_failed','classified','human_review','active','superseded','deleted')`
  - `ocr_raw TEXT NULL CHECK (ocr_raw IS NULL OR json_valid(ocr_raw))`, `ocr_provider TEXT NULL`, `ocr_attempts INTEGER DEFAULT 0`
  - `extracted TEXT NULL CHECK (extracted IS NULL OR json_valid(extracted))` (expiration_date, issued_date, subject_name, etc.)
  - `expiration_date TEXT NULL` (ISO date), `expiration_confidence REAL NULL` (0..1)
  - `uploaded_by_user_id TEXT`, `uploaded_via TEXT` (web|parent_portal|staff_portal|sms_upload|email_import)
  - `filename_original TEXT`, `deleted_at TEXT NULL`, `superseded_by_document_id TEXT NULL`
- [ ] Partial index: `documents (linked_child_id) WHERE deleted_at IS NULL`.
- [ ] Partial index: `documents (expiration_date) WHERE status='active'` for chase scanner (REQ041).
- [ ] `internal/documents/repo.go` exports typed methods: `Insert`, `Get`, `ListByProvider`, `ListByChild`, `ListByStaff`, `MarkStatus`, `SetExtracted`, `Supersede`, `SoftDelete`.
- [ ] All mutations write to audit log (REQ034).

## Technical Notes
- SQLite dialect (ADR-017).
- Use `database/sql` with manual `rows.Scan` into typed row structs in `internal/documents/model.go`.
- JSON columns: store as TEXT validated by `json_valid()`. Read back with `json_extract`, or unmarshal in Go.
- Status transitions enforced in code; no triggers. Add a `StatusTransition` whitelist map.
- `extracted` JSON schema versioned with `_version: "v1"` key.

## Definition of Done
- [ ] Migration applies cleanly against a fresh SQLite file.
- [ ] Repo methods covered by tests against an in-memory SQLite (`file::memory:?cache=shared`).
- [ ] pprof: ListByProvider with 5k rows < 50ms.

## Related Tickets
- Blocks: REQ024, REQ025, REQ028, REQ029
- Blocked by: REQ002, REQ022
