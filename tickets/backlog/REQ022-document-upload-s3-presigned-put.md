---
id: REQ022
title: Document upload via S3 presigned PUT
priority: P0
status: backlog
estimate: L
area: backend
epic: EPIC-04 Document Management
depends_on: [REQ002, REQ003, REQ013]
---

## Problem
Uploading documents through our API would double bandwidth costs and add latency. Clients should upload directly to S3 via short-lived presigned URLs.

## User Story
As a director, I want uploads to feel fast and not chew up my mobile data, so that I can load 20 documents without frustration.

## Acceptance Criteria
- [ ] `POST /api/documents/presign` accepts `{ filename, content_type, size_bytes }` and returns `{ document_id, upload_url, fields, expires_at }`.
- [ ] Presigned URL expires in 5 minutes; `Content-Length` must match; `Content-Type` whitelist: `image/jpeg, image/png, image/heic, application/pdf`.
- [ ] Max size 25 MB; API rejects larger.
- [ ] Document row inserted in `documents` table with `status='uploading'`, `s3_key='docs/{prv_id}/{doc_id}{ext}'`. (All objects live in `ck-files`; no per-row bucket column — see 000004 migration.)
- [ ] On successful client-side PUT, client calls `POST /api/documents/{id}/complete` which: verifies the object exists (HeadObject), moves status to `uploaded`, enqueues OCR job (REQ024).
- [ ] S3 bucket policy denies public access; server-side encryption (SSE-S3) enforced; object tagging `ck-provider={prv_id}`.
- [ ] Tests with LocalStack or moto verify presign roundtrip.

## Technical Notes
- AWS SDK v2: `s3.PresignClient`. Condition: `s3.WithPresignExpires(5*time.Minute)`.
- Frontend uses `fetch(uploadUrl, { method: 'PUT', body: file, headers: {...} })`.
- HEIC needs explicit support; later OCR path may convert to JPEG (libvips or Lambda).
- Strip any client-provided `x-amz-*` headers we didn't sign for.

## Definition of Done
- [ ] End-to-end upload from browser → S3 verified with a real file.
- [ ] Unauthorized content-type rejected.
- [ ] LocalStack test in CI.

## Related Tickets
- Blocks: REQ023, REQ024, REQ025, REQ029, REQ030
- Blocked by: REQ002, REQ003, REQ013
