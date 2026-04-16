---
id: REQ039
title: Per-state rule evaluator unit tests
priority: P0
status: backlog
estimate: L
area: backend
epic: EPIC-06 Compliance Engine
depends_on: [REQ035, REQ036]
---

## Problem
Rule packs are high-risk, high-leverage. A regression in one rule could silently hide a violation. We need deep, fixture-driven tests per state.

## User Story
As an engineer, I want to refactor rules confidently knowing that state-specific scenarios are locked down in tests, so that edits don't regress correctness.

## Acceptance Criteria
- [ ] `internal/compliance/evaluator_test.go` organized with `t.Run("CA", ...)`, `t.Run("TX", ...)`, `t.Run("FL", ...)`.
- [ ] For each state, fixtures in `testdata/{ca,tx,fl}/` with at minimum:
  - `clean_provider.json` (all requirements met → 0 violations)
  - `no_docs_provider.json` (all documents missing → score < 30)
  - `expiring_cpr_7_days.json` (single violation or timeline deduction)
  - `missing_immunization_one_child.json` (critical, child-scoped)
  - `exceeds_capacity.json` (critical, facility-scoped)
  - `missing_fire_drill_last_month.json` (recurring violation)
- [ ] Each fixture has an adjacent `.expected.json` with the exact expected `Result` (violations + score + timeline highlights).
- [ ] Test compares actual to expected via JSON diff; failure prints a readable diff.
- [ ] Golden-file update flag: `go test -update` rewrites expected files (for intentional changes).
- [ ] CI: tests run on every PR and must pass for merge.

## Technical Notes
- Use `github.com/google/go-cmp/cmp` for diff rendering.
- Fixture loader in `internal/compliance/testutil/`.
- Document in repo CONTRIBUTING: changing a rule? Run `go test -update`, inspect diff in review.

## Definition of Done
- [ ] ≥ 6 fixtures per state, green in CI.
- [ ] Golden update flow documented.
- [ ] Mutation test: manually breaking one rule causes a relevant fixture to fail.

## Related Tickets
- Blocks:
- Blocked by: REQ035, REQ036
