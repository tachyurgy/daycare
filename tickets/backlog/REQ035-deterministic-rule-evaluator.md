---
id: REQ035
title: Deterministic compliance rule evaluator
priority: P0
status: backlog
estimate: L
area: backend
epic: EPIC-06 Compliance Engine
depends_on: [REQ002, REQ023, REQ024]
---

## Problem
Compliance is the core of the product. The evaluator must be a pure function over provider data + rule pack → violations + deadlines + score. Purity lets us unit-test exhaustively and replay history.

## User Story
As an engineer, I want to call `Evaluate(state, providerSnapshot)` and get back the exact same violations every time given the same input, so that dashboards, reports, and chase decisions are all consistent.

## Acceptance Criteria
- [ ] `internal/compliance/evaluator.go` exports:
  ```go
  type ProviderSnapshot struct { Provider, Facility, Staff []StaffRow, Children []ChildRow, Documents []DocumentRow, Now time.Time }
  type Violation struct { ID, Category, Severity, Subject (facility|child:ID|staff:ID), DocumentTypeCode, DueDate, RuleID, Message string }
  type Result struct { Violations []Violation, Score int, NextDeadlines []Deadline }
  func Evaluate(state string, snap ProviderSnapshot) Result
  ```
- [ ] Pure function: no DB, no network, no clock reads other than `snap.Now`.
- [ ] `Severity` enum: `critical, high, medium, low`.
- [ ] Deterministic output: same input → byte-identical output (sort violations by `(severity desc, DueDate asc, RuleID)`).
- [ ] State rule pack selected by `state` (loaded via REQ036).
- [ ] Handles missing-document violations, expiring-document violations (computed against `snap.Now` using 6w/4w/2w/1w/3d thresholds matching REQ042), and structural violations (e.g., no background check on staff).
- [ ] Property tests via `testing/quick` covering stability, determinism, and sort order.

## Technical Notes
- Rules are data (not code) where possible — see REQ036. The evaluator is a small interpreter.
- Avoid allocations in the hot path; pre-size slices.
- Add `EvaluateWithTrace` that also returns per-rule evaluation steps for the debug dashboard (post-MVP but stubbed).

## Definition of Done
- [ ] Evaluator test suite covers CA, TX, FL with ≥ 3 fixture providers each.
- [ ] Determinism test: 1000 evaluations of same input yield identical output.
- [ ] Benchmarks under 5ms for a 30-staff/120-child snapshot.

## Related Tickets
- Blocks: REQ036, REQ037, REQ038, REQ039, REQ040, REQ041
- Blocked by: REQ002, REQ023, REQ024
