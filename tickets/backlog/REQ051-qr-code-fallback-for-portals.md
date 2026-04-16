---
id: REQ051
title: QR code fallback for portals
priority: P1
status: backlog
estimate: M
area: frontend
epic: EPIC-09 Parent & Staff Portals
depends_on: [REQ049, REQ050]
---

## Problem
Directors want printable posters ("Scan to upload your child's forms") for open houses and pickup/drop-off. SMS/email can't reach everyone. A QR code at the front desk converts the stragglers.

## User Story
As a director, I want to print a QR poster parents can scan at pickup, so that I capture missing documents without chasing each family.

## Acceptance Criteria
- [ ] Route `/admin/portal-links` (provider-admin only) shows:
  - "General parent upload" QR (portal landing where parent enters child's name/email to receive a real magic link)
  - Per-child and per-staff QR codes in tables, downloadable individually as PNG/SVG.
- [ ] QR codes encode a URL with an **intake token** (not a magic-link token) that is longer-lived (30 days), rate-limited, and requires the user to identify themselves before a true magic link is issued.
- [ ] Intake flow: scan QR → landing page "Tell us who you are" → email/phone → check provider roster for match → issue standard magic link (email/SMS) → parent proceeds via REQ049.
- [ ] Non-matches get a "Please contact your provider" message. No enumeration leak.
- [ ] Printable poster PDF generated via `pdf-lib` with provider name, QR code, and short instructions. 8.5x11", US Letter.
- [ ] QR generation in browser via `qrcode` npm package.
- [ ] "Regenerate" button invalidates prior intake token.

## Technical Notes
- Intake token stored in `intake_tokens(id, provider_id, kind='parent'|'staff', created_at, revoked_at, usage_count, last_used_at)`.
- Rate limit: 5 intakes per intake_token per hour (abuse protection).
- QR URL pattern: `https://app.compliancekit.com/i/{intake_token}`.

## Definition of Done
- [ ] QR code scans on iPhone camera and lands on intake form.
- [ ] Printed poster PDF looks clean at 100% scale.
- [ ] Unknown email submission shows generic message.

## Related Tickets
- Blocks: REQ052
- Blocked by: REQ049, REQ050
