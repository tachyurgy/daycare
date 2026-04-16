---
id: REQ036
title: State rule packs (CA / TX / FL) as data files
priority: P0
status: backlog
estimate: XL
area: backend
epic: EPIC-06 Compliance Engine
depends_on: [REQ024, REQ035]
---

## Problem
Each state's regulatory corpus must be translated into machine-checkable rules. These are the product's moat and the slowest, highest-leverage work.

## User Story
As a director in California, I want my compliance requirements to reflect exactly what Title 22 demands of me, so that I trust the platform to keep me audit-ready.

## Acceptance Criteria
- [ ] `internal/compliance/rules/ca.yaml`, `tx.yaml`, `fl.yaml` committed with rule definitions.
- [ ] Rule schema (YAML):
  ```yaml
  - id: ca-staff-cpr
    category: staff_certs
    severity: critical
    applies_to: staff
    predicate: has_active_document
    document_type: staff_cpr_cert
    validity_days: 730
    state_reference: "22 CCR §101216.1(b)"
    message: "Staff member {staff_name} is missing an active CPR certification"
  ```
- [ ] Each state covers at minimum: staff CPR/First Aid, staff TB test, staff background check clearance, staff training hours, child immunizations, child enrollment form, child emergency contact, facility license posted, fire drill log (monthly), evacuation plan posted, licensed capacity adherence, required postings.
- [ ] Every rule cites the exact regulatory source (CCR, TAC, FAC section number).
- [ ] Rule loader: `internal/compliance/rules/load.go` parses YAML on startup, validates each rule against a schema, fails startup on invalid.
- [ ] Minimum rule counts (hard floor — more is fine):
  - CA: 35 rules
  - TX: 35 rules
  - FL: 30 rules
- [ ] YAML files reviewed against `planning-docs/state-docs/*` before merging.
- [ ] Unit tests: for each state, a "canonical clean provider" fixture yields 0 violations.

## Technical Notes
- Prefer YAML over JSON for human readability and comments.
- Schema validation via `github.com/invopop/yaml` + custom validator (avoid a JSON-Schema dep if small).
- Predicates supported initially: `has_active_document`, `has_active_document_per_child`, `has_active_document_per_staff`, `document_count_at_least`, `capacity_not_exceeded`, `drill_within_last_N_days`.
- Split into L tickets per state if needed: REQ036a (CA), REQ036b (TX), REQ036c (FL). For now track as single XL.

## Definition of Done
- [ ] All three YAML files loaded without errors.
- [ ] Rule counts meet minimums.
- [ ] Clean-provider fixture passes for each state.
- [ ] At least one reviewer (founder) sanity-reads each state's rules against source docs.

## Related Tickets
- Blocks: REQ037, REQ038, REQ039
- Blocked by: REQ024, REQ035
