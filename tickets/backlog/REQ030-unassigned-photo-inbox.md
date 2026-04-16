---
id: REQ030
title: Unassigned photo inbox
priority: P1
status: backlog
estimate: M
area: frontend
epic: EPIC-04 Document Management
depends_on: [REQ022, REQ025, REQ026, REQ027]
---

## Problem
In the real world, a director snaps 12 photos at their desk of various cards and forms, then sorts them later. We need an inbox where unclassified/unlinked uploads land until a human triages them.

## User Story
As a director, I want to batch-upload photos from my phone and sort them later into the right children/staff, so that I can capture in bulk without context switching.

## Acceptance Criteria
- [ ] Route `/inbox` shows all docs where `status in ('classified','human_review')` and `linked_child_id is null and linked_staff_id is null`.
- [ ] Grid view with thumbnails (S3 presigned GET), doc-type chip, detected subject name, age (time since upload).
- [ ] Bulk actions: select N → "Assign to {child/staff}" or "Mark facility-wide".
- [ ] Inline quick-assign: clicking a thumbnail opens the REQ027 review modal with an "Assign & Next" button.
- [ ] Dashboard widget "Inbox: N unassigned" links here.
- [ ] Mobile-optimized camera capture: the upload button uses `<input type=file accept="image/*" capture="environment" multiple>` on mobile.
- [ ] Presigned GET URLs for thumbnails cached 10 minutes (`?X-Amz-Expires=600`).

## Technical Notes
- Thumbnail generation is deferred — for MVP, serve the original via presigned GET with `response-content-disposition=inline`. Post-MVP, generate 400px thumbs into `ck-documents` on upload.
- Grid component: CSS grid, `@tanstack/react-query` for list pagination.
- HEIC in `<img>` doesn't render on Chrome; server-side convert on ingestion or use `heic-to` client-side library.

## Definition of Done
- [ ] Inbox shows correct count and thumbnails.
- [ ] Bulk assign moves 5 docs at once.
- [ ] Mobile camera capture works on iOS Safari.

## Related Tickets
- Blocks:
- Blocked by: REQ022, REQ025, REQ026, REQ027
