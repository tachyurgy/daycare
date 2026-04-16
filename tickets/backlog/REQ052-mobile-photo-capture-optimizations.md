---
id: REQ052
title: Mobile photo capture optimizations
priority: P1
status: backlog
estimate: M
area: frontend
epic: EPIC-09 Parent & Staff Portals
depends_on: [REQ049, REQ050]
---

## Problem
Phone-camera uploads are noisy — blur, glare, wrong orientation, 12MP files over 3G. The portal must pre-process client-side to improve OCR success and reduce upload size.

## User Story
As a parent on 3G, I want the app to resize and orient my photo before uploading, so that it goes through quickly and is actually readable.

## Acceptance Criteria
- [ ] `<PhotoCapture onCapture={...} />` component wrapping a `<canvas>` pipeline:
  - Reads file via `<input type="file" capture="environment">` or `getUserMedia` if available.
  - EXIF orientation normalized (portrait vs landscape).
  - Downscales longest side to 2400px max (preserving aspect).
  - Re-encodes to JPEG at quality 0.85.
  - Target output ≤ 1.5 MB.
- [ ] Preview step: user sees the processed image and can "Retake" or "Use this photo".
- [ ] Multi-shot capture: tap "Add page" to include multiple images, bundle into a single PDF server-side (REQ022 accepts multi-part with a `bundle=true` flag which triggers a small Go routine using pdfcpu to combine images into a PDF after complete).
- [ ] HEIC handled: if browser returns `image/heic`, convert to JPEG via `heic-to` (client-side) before the pipeline.
- [ ] Accessibility: capture button has clear label; preview image has alt text "Your document photo".
- [ ] getUserMedia path falls back cleanly to `<input type="file">` if permission denied.

## Technical Notes
- Use `browser-image-compression` or hand-roll with canvas; benchmark on mid-tier Android.
- EXIF parsing via `exifr` npm package (tiny).
- Multi-image-to-PDF on server: `pdfcpu.ImportImages` then upload the resulting PDF via normal pipeline.
- Avoid loading heic-to until the file type is actually HEIC (dynamic import).

## Definition of Done
- [ ] 12MP iPhone photo compresses to < 1.5 MB locally.
- [ ] HEIC from iPhone gallery uploads successfully.
- [ ] Multi-page bundle produces a single PDF visible in provider inbox.

## Related Tickets
- Blocks:
- Blocked by: REQ049, REQ050
