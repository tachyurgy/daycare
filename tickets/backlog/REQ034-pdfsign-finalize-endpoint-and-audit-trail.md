---
id: REQ034
title: /api/pdfsign/finalize endpoint + audit trail
priority: P1
status: backlog
estimate: L
area: backend
epic: EPIC-05 PDF Signing
depends_on: [REQ022, REQ033]
---

## Problem
The server must verify, persist, and audit every signed PDF. Without server-side verification and immutable audit storage, the signatures have no legal weight.

## User Story
As a compliance officer, I want signed PDFs stored in a tamper-evident bucket with an accompanying audit trail record, so that we can defend the signature's validity in an inspection or lawsuit.

## Acceptance Criteria
- [ ] `POST /api/pdfsign/finalize` accepts multipart: field `signed_pdf` (bytes), `original_document_id`, `signer` JSON `{name,email,phone,method,typed_name?}`, `fields` JSON (placements), `original_sha256`.
- [ ] Server verifies `original_sha256` matches the actual original stored in `ck-files` under `docs/`.
- [ ] Server re-computes SHA-256 of submitted signed PDF and stores it as `signatures.signed_sha256`.
- [ ] Signed PDF uploaded to `ck-files` at key `signed/{prv_id}/{doc_id}/{sig_id}.pdf`.
- [ ] Audit JSON uploaded to `ck-files` at key `audit/{prv_id}/{sig_id}.json` with all signer metadata, timestamps, request IP, UA, original SHA, signed SHA, document ID, and the exact request body (excluding PDF bytes).
- [ ] `ck-files` has bucket-level versioning on; `audit/` objects are never deleted or overwritten by application code.
- [ ] `signatures` table row inserted linking `document_id`, `signer_user_id` (or null for portal signers), `signed_sha256`, `signed_s3_key`, `audit_s3_key`, `created_at`.
- [ ] Response: `{ signature_id, signed_pdf_url (presigned GET, 5min), audit_id }`.
- [ ] Rejection cases: wrong SHA, malformed PDF (pdf-lib parse fail server-side), too large (>50MB).
- [ ] Server-side PDF validation uses `github.com/pdfcpu/pdfcpu` — must successfully parse.

## Technical Notes
- pdfcpu parsing: `api.ReadContext(bytes.NewReader(pdfBytes), nil)` — returns error on broken structure.
- Object Lock configured via REQ056 infra script, but enforced in bucket policy before ticket is DoD.
- IP captured from `X-Forwarded-For` trusted only behind CloudFront/DO load balancer config.

## Definition of Done
- [ ] End-to-end sign → finalize → retrieve flow verified.
- [ ] Audit JSON inspected and contains all required fields.
- [ ] Object Lock retention confirmed via `aws s3api get-object-retention`.

## Related Tickets
- Blocks:
- Blocked by: REQ022, REQ033
