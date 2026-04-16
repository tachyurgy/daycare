---
id: REQ033
title: PDF stamp signature + metadata page (pdf-lib)
priority: P1
status: backlog
estimate: L
area: frontend
epic: EPIC-05 PDF Signing
depends_on: [REQ031, REQ032]
---

## Problem
Once a user signs, we must embed the signature image onto the PDF at the right coordinates and append a metadata page with signer identity, IP, user agent, timestamp, and SHA-256 of the original PDF. This gives us legal-defensible evidence without paying DocuSign.

## User Story
As a compliance officer, I want every signed PDF to include an audit page identifying who signed it, when, and from where, so that the document is admissible as legal evidence.

## Acceptance Criteria
- [ ] `signAndStamp(pdfBytes, signatureImg, fields, meta) -> signedPdfBytes` pure function in `frontend/src/features/signing/stamp.ts`.
- [ ] Uses `pdf-lib`.
- [ ] Fields (defined by a drag-drop placement UX or per-template config): signature image, printed name, date. Each has `{page, x, y, width, height}`.
- [ ] Signature PNG embedded via `pdf.embedPng`; typed-name variant rendered via `pdf.embedFont("Helvetica")`.
- [ ] Appends a final "Certificate of Signature" page with:
  - Signer: full name + email/phone
  - Method: drawn/typed, pointer type
  - Timestamp: ISO 8601 UTC + local timezone
  - IP address (captured on server; fetched by client via `/api/whoami`)
  - User agent
  - SHA-256 of the **original** PDF bytes (before stamping)
  - Document ID (base62)
  - Provider ID + Provider name
- [ ] Sets PDF metadata (`Author`, `Producer="ComplianceKit"`, `CreationDate`, `Title`) via pdf-lib.
- [ ] Output verified by opening in Chrome, Preview, and Acrobat — no warnings about broken structure.
- [ ] Unit tests compute the expected SHA-256 of a fixture PDF and confirm the certificate page contains it.

## Technical Notes
- Keep signing fully client-side to avoid transmitting raw signature to server before finalization.
- Original PDF SHA computed via `crypto.subtle.digest("SHA-256", bytes)`.
- Coordinate system: pdf-lib uses bottom-left origin; wrap in a helper that takes top-left coords like the UI.

## Definition of Done
- [ ] A sample 3-page handbook, signed, opens in Acrobat with the cert page intact.
- [ ] SHA-256 in cert matches the pre-stamp bytes verified by a command-line sha256 check.

## Related Tickets
- Blocks: REQ034
- Blocked by: REQ031, REQ032
