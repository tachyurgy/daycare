---
id: REQ038
title: Compliance score 0-100 formula (documented)
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-06 Compliance Engine
depends_on: [REQ035, REQ036]
---

## Problem
The "compliance score" is the main quantitative signal in the UI and in our marketing. It must be simple, stable, and defensible. Directors will ask how it's computed.

## User Story
As a director, I want my compliance score to drop when I miss something critical and climb when I resolve it, so that I can confidently track progress.

## Acceptance Criteria
- [ ] `Score(result Result) int` implemented in `internal/compliance/score.go`. Returns integer 0..100.
- [ ] Formula (MVP, documented in `docs/compliance-score.md`):
  - Base: 100.
  - Deductions per unresolved violation:
    - `critical`: −20 each, capped at −60 total
    - `high`: −8 each, capped at −32
    - `medium`: −3 each, capped at −18
    - `low`: −1 each, capped at −6
  - Deductions per document expiring in ≤ 30 days not yet missing:
    - 0–7 days: −5
    - 8–30 days: −2
  - Floor: 0. Ceiling: 100.
- [ ] Deterministic and pure.
- [ ] `docs/compliance-score.md` explains the formula, with an example and an FAQ ("Why did my score drop?").
- [ ] Unit tests verify each deduction branch and the caps.
- [ ] Score is also broken into sub-scores per category (staff/child/facility) for the dashboard.

## Technical Notes
- Keep the numbers centralized as a package-level `scoreWeights` var so future tuning is a one-line change.
- Do not expose sub-score breakdown via API until REQ040 needs it.
- A future "V2" formula can live side-by-side behind a feature flag; don't over-engineer now.

## Definition of Done
- [ ] Tests cover every severity, cap, and expiring-soon branch.
- [ ] Fresh provider with 0 staff/children → score 100 (or documented baseline).
- [ ] Doc written and reviewed.

## Related Tickets
- Blocks: REQ040
- Blocked by: REQ035, REQ036
