---
id: REQ049
title: Per-parent magic-link upload portal
priority: P0
status: backlog
estimate: L
area: frontend
epic: EPIC-09 Parent & Staff Portals
depends_on: [REQ011, REQ012, REQ013, REQ022, REQ028]
---

## Problem
Parents are where most document gaps live (immunizations, enrollment forms, custody). We need a zero-friction, no-password, mobile-first portal so they can upload in under a minute.

## User Story
As a parent, I want to tap a link in my text, take a picture of my child's blue card, and be done, so that I don't need to create an account.

## Acceptance Criteria
- [ ] Route `/p/{provider_slug}/parent?t={token}` verifies token (REQ012), binds session scoped to that child.
- [ ] Portal shows:
  - Provider name + child first name ("Acorn Preschool — Mia R.")
  - "Documents we still need" list (only the missing/expiring docs for THIS child)
  - A big "Upload" button per doc type (tap → camera/photo picker via `<input type="file" accept="image/*,.pdf" capture="environment">`)
  - Status: "Received — we'll review shortly" once uploaded
- [ ] Upload flow: presigns (REQ022) → direct S3 PUT → `POST /api/documents/{id}/complete` with `linked_child_id` preset (because session is child-scoped) → OCR pipeline kicks off.
- [ ] No navigation exists to other children/staff/admin areas — session scope enforces isolation server-side.
- [ ] Session duration: 7 days (matches REQ009 parent portal TTL), sliding on use.
- [ ] Mobile-first layout, minimum tap target 48px, one column.
- [ ] Accessible: high contrast, real button elements, readable without JS if possible (progressive enhancement — uploads require JS, but list renders without).
- [ ] Parent can see a history of prior uploads with status (received/active/needs-info).
- [ ] Works on iOS Safari 14+, Chrome 90+, Samsung Internet.

## Technical Notes
- Route component: `frontend/src/routes/parent-portal.tsx`.
- Cookie scope `/p/{slug}/` so session doesn't leak across providers on same domain.
- Add "Report wrong link" link → `mailto:support@compliancekit.com` prefilled with slug + truncated token for operator triage.

## Definition of Done
- [ ] End-to-end: SMS magic link → mobile upload → doc appears in provider inbox linked to child.
- [ ] Session can't access any other child.
- [ ] Lighthouse mobile score ≥ 90.

## Related Tickets
- Blocks: REQ051, REQ052
- Blocked by: REQ011, REQ012, REQ013, REQ022, REQ028
