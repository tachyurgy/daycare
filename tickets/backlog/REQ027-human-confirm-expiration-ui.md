---
id: REQ027
title: Human-confirm-expiration UI
priority: P0
status: backlog
estimate: M
area: frontend
epic: EPIC-04 Document Management
depends_on: [REQ026]
---

## Problem
LLM extraction is good, not perfect. Directors must see a draft, confirm or correct, and activate the document. Blindly trusting the model would cause false-clear compliance states.

## User Story
As a director, I want to review what ComplianceKit detected on a document and fix any mistakes in one click, so that I trust the automated tracking.

## Acceptance Criteria
- [ ] Route `/documents/{id}/review` and inline review modal accessible from document list.
- [ ] Left side: PDF/image viewer (react-pdf for PDFs, `<img>` with pan/zoom for images).
- [ ] Right side: form pre-filled with extracted fields — `document_type` (searchable select), `subject` (dropdown of children/staff filtered by type), `issued_date`, `expiration_date`.
- [ ] Visual confidence indicator: green check (>0.85), yellow warning (0.6–0.85), red alert (<0.6).
- [ ] "Looks good, activate" primary button; "Needs edits" reveals the editable fields.
- [ ] On submit: `POST /api/documents/{id}/confirm` with the corrected fields. Server updates doc, transitions to `status='active'`, recomputes compliance (REQ038).
- [ ] If user marks "This isn't the right document type" the doc is recycled back to classification with the new type hint.
- [ ] Keyboard shortcuts: `A` activate, `E` edit, `→` next doc in review queue.
- [ ] Mobile layout collapses to vertical stack with viewer on top.

## Technical Notes
- Viewer component `<DocumentViewer />` in `frontend/src/components/documents/`. Use `pdfjs-dist` via `react-pdf`.
- Form uses `react-hook-form` + shared Zod schema with backend.
- "Review queue" is `GET /api/documents?status=human_review` — paginate, show count badge in nav.

## Definition of Done
- [ ] Review flow tested end-to-end with a real OCR'd doc.
- [ ] Keyboard shortcuts work.
- [ ] Activating updates compliance score visibly on the dashboard.

## Related Tickets
- Blocks: REQ028, REQ040
- Blocked by: REQ026
