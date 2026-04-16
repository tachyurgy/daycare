---
id: REQ031
title: In-browser PDF viewer with react-pdf
priority: P1
status: backlog
estimate: M
area: frontend
epic: EPIC-05 PDF Signing
depends_on: [REQ022]
---

## Problem
Self-built e-signature means users must view, zoom, and navigate PDFs in the browser without kicking over to a third-party. The base viewer is shared by the review UI (REQ027) and the signing flow (REQ032).

## User Story
As a user, I want to read a PDF inline and flip through its pages before signing, so that I feel confident about what I'm signing.

## Acceptance Criteria
- [ ] `<PDFViewer src={url} />` component in `frontend/src/components/pdf/PDFViewer.tsx`.
- [ ] Uses `react-pdf` (wraps PDF.js) with a pinned version.
- [ ] Supports page navigation (prev/next + thumbnail sidebar), zoom in/out/fit, rotate.
- [ ] Renders PDFs up to 50 pages without UI jank; lazy-renders pages using `react-virtuoso` for thumbnail strip.
- [ ] Accessible: keyboard nav (arrow keys), aria-labels on controls, focus ring visible.
- [ ] Fallback: on PDF.js error, shows a download link and "Unable to preview" message — never a white screen.
- [ ] Hosts PDF.js worker locally (not from CDN) to avoid CSP issues. Worker served from `/pdf.worker.min.js`.
- [ ] Mobile: pinch zoom, single-column page view, larger tap targets.

## Technical Notes
- `react-pdf` v7+. Configure `pdfjs.GlobalWorkerOptions.workerSrc` to local URL.
- Presigned GET URL loaded with `fetch` into an ArrayBuffer to work around cross-origin PDF.js quirks on GitHub Pages.
- Do not import `react-pdf` synchronously in the main bundle; lazy-import via `React.lazy`.

## Definition of Done
- [ ] Loads a 20-page PDF in ≤ 2s on mid-tier laptop.
- [ ] Works in Chrome, Safari, Firefox, iOS Safari.
- [ ] No CSP violations in console.

## Related Tickets
- Blocks: REQ032, REQ033
- Blocked by: REQ022
