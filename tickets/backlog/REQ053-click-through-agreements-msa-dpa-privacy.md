---
id: REQ053
title: Click-through MSA + DPA + Privacy at signup
priority: P0
status: backlog
estimate: M
area: legal
epic: EPIC-10 Legal & Data
depends_on: [REQ015]
---

## Problem
We handle PII of children, staff, and parents — many under 13. We need enforceable, versioned click-through agreements before a provider touches the product. Without them, we can't lawfully collect child data.

## User Story
As a founder, I want every new provider to accept our MSA, DPA, and Privacy policies before using the app, so that our data collection is lawful and our contractual position is clear.

## Acceptance Criteria
- [ ] Three documents drafted and committed to `legal/` as Markdown: `msa.md`, `dpa.md`, `privacy.md`. Each has a front-matter `version: 2026-04-01` and `effective_date`.
- [ ] A sign-off screen renders in the onboarding wizard (insert between REQ018 and REQ019) showing all three linked in modals/tabs, plus a single checkbox: "I have read and agree to the MSA, DPA, and Privacy Policy."
- [ ] Unchecking blocks "Next". Checkbox is required; no dark-pattern pre-check.
- [ ] On commit (REQ021), `policy_acceptances` row inserted: `(user_id, policy_code, version, accepted_at, ip, user_agent)`.
- [ ] Separate explicit consent checkbox for "I am authorized to upload child and staff personal information on behalf of my organization."
- [ ] COPPA attestation: "Children under 13 data will only be collected after we have received parental consent on your behalf."
- [ ] Footer links to `/legal/msa`, `/legal/dpa`, `/legal/privacy` serve the current version publicly.
- [ ] Static legal content versioned; old versions accessible via `/legal/privacy/v/2026-04-01`.

## Technical Notes
- Legal docs authored by founder (or counsel). Engineer responsible only for plumbing.
- Markdown rendered server-side (from Go `markdown` or frontend MDX) — either is fine; keep a single implementation.
- Version string is the single source of truth used in REQ054.

## Definition of Done
- [ ] Signup blocked without acceptance.
- [ ] Acceptance rows exist in DB with correct versions.
- [ ] Public legal pages render correctly.

## Related Tickets
- Blocks: REQ054, REQ055
- Blocked by: REQ015
