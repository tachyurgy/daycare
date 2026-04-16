---
id: REQ050
title: Per-staff magic-link upload portal
priority: P0
status: backlog
estimate: M
area: frontend
epic: EPIC-09 Parent & Staff Portals
depends_on: [REQ011, REQ012, REQ013, REQ022, REQ029, REQ049]
---

## Problem
Staff certifications (CPR, First Aid, TB, training) expire constantly. Staff are more likely to keep current on them than directors. Give them a self-service portal tied to their own record.

## User Story
As a teacher, I want to upload my renewed CPR card directly, so that I don't have to hand it to my director or email it to anyone.

## Acceptance Criteria
- [ ] Route `/p/{provider_slug}/staff?t={token}` verifies token, binds session scoped to that staff member.
- [ ] Portal shows:
  - Staff name + provider name
  - List of staff-required certifications from state rules (REQ036) with current status (active/expiring/missing)
  - Upload button per cert, plus a general "Upload any doc" button
- [ ] Upload flow identical to REQ049 but auto-sets `linked_staff_id` from session.
- [ ] Staff can also view their training hours total and download a log (from existing docs). Simple list, no chart.
- [ ] Session duration: 7 days (same as parent portal).
- [ ] Same accessibility + mobile requirements as REQ049.
- [ ] Reuse `<RosterDocumentsList />` component with a `scope='staff'` prop.

## Technical Notes
- Share route-guard HOC with parent portal.
- Copy strings differ (staff vs parent tone); keep in `frontend/src/i18n/en.ts` keyed by portal type.
- Log all staff-portal uploads in audit trail with staff subject ID.

## Definition of Done
- [ ] Staff member receives email/SMS with link → uploads renewed CPR → old CPR is auto-superseded in provider view.
- [ ] Session can't see other staff or admin areas.
- [ ] Mobile flow tested on iPhone + Android.

## Related Tickets
- Blocks: REQ051, REQ052
- Blocked by: REQ011, REQ012, REQ013, REQ022, REQ029, REQ049
