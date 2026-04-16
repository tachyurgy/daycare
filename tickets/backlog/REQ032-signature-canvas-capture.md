---
id: REQ032
title: Signature canvas capture with signature_pad
priority: P1
status: backlog
estimate: M
area: frontend
epic: EPIC-05 PDF Signing
depends_on: [REQ031]
---

## Problem
Users need to draw a signature with a mouse or finger. We must capture it as a clean vector or high-res raster that embeds crisply into the PDF.

## User Story
As a parent, I want to sign the handbook acknowledgment on my phone with my finger, so that I don't need to print, sign, scan, or email anything.

## Acceptance Criteria
- [ ] `<SignatureCapture onCapture={...} />` component wrapping `signature_pad`.
- [ ] Captures signature as both PNG data URL (2x device pixel ratio) and SVG path string.
- [ ] Clear, Undo, and Accept buttons.
- [ ] Typed name fallback: user can type their name in a cursive-ish web font if drawing isn't feasible (toggle tab).
- [ ] Touch input smooth at 60fps on iOS Safari; pressure sensitivity captured where available.
- [ ] Prevents blank signature submissions (minimum 10 stroke points).
- [ ] Outputs: `{ pngDataUrl, svgPath, method: 'drawn'|'typed', typedName: string|null }` passed to `onCapture`.
- [ ] Canvas auto-resizes on viewport change without clearing.
- [ ] Accessible: screen-reader announces "Signature pad, draw here"; a keyboard-alternative (type-your-name) always available.

## Technical Notes
- Use `signature_pad` v4. Lazy-load.
- Web font options: "Caveat", "Dancing Script" via Google Fonts, with `<link rel="preload">`.
- Don't round-trip signature to server until the user accepts — all local until then.
- Metadata to collect alongside signature: capture timestamp, pointer type (mouse/touch/stylus). Passed in REQ033.

## Definition of Done
- [ ] Works on desktop (mouse), mobile (touch), iPad (Apple Pencil).
- [ ] Typed fallback renders legibly.
- [ ] PNG data URL embeds cleanly in pdf-lib (REQ033) without aliasing.

## Related Tickets
- Blocks: REQ033
- Blocked by: REQ031
