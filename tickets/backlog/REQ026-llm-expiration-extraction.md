---
id: REQ026
title: LLM expiration-date extraction (Gemini Flash)
priority: P0
status: backlog
estimate: L
area: backend
epic: EPIC-04 Document Management
depends_on: [REQ024, REQ025]
---

## Problem
Raw OCR text is useless until we pull structured fields out: document type, expiration date, subject name, issue date. The chase service keys off expiration dates, so accuracy matters.

## User Story
As a director, I want ComplianceKit to auto-detect the expiration date on my staff's CPR card, so that I don't have to type it in.

## Acceptance Criteria
- [ ] `internal/extract/` package with `Extract(ctx, ocrText string, candidateTypes []DocumentType) (ExtractResult, error)`.
- [ ] Uses Gemini Flash with structured-output mode (`response_mime_type: application/json`) enforcing schema:
  ```json
  {"document_type_code":"string","subject_name":"string","issued_date":"YYYY-MM-DD|null","expiration_date":"YYYY-MM-DD|null","confidence":0.0-1.0,"notes":"string"}
  ```
- [ ] Prompt includes the filtered `document_types` list (from REQ024) so the model picks a valid `code`.
- [ ] Prompt includes reasoning guardrails: if no explicit expiration on doc, compute from `issued_date + default_validity_days` and note it.
- [ ] Confidence: low (<0.6) → document routes to `status='human_review'`; 0.6–0.85 → flagged with banner in UI; >0.85 → auto-activate.
- [ ] `documents.extracted`, `documents.expiration_date`, `documents.expiration_confidence`, `documents.document_type_id` all populated.
- [ ] Cost/latency budget: p95 ≤ 3s, average ≤ $0.005 per doc.
- [ ] Input/output of every call logged to `ck-audit-trail` S3 bucket for later retraining/debug.

## Technical Notes
- Gemini SDK via HTTP directly; don't depend on a Google SDK we don't need.
- Prompt lives in `internal/extract/prompt.tmpl` — versioned with `_v1` suffix.
- Add `max_output_tokens: 512` and low temperature (0.1) for stability.
- If Gemini returns unparsable JSON, retry once; on second failure, route to human review.

## Definition of Done
- [ ] Unit tests with fake client cover high/medium/low confidence branches.
- [ ] Golden-file test against 10 real OCR outputs from sample docs asserts expected extractions.
- [ ] Cost monitoring log shows per-doc token counts.

## Related Tickets
- Blocks: REQ027, REQ041
- Blocked by: REQ024, REQ025
