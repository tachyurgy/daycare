---
id: REQ024
title: Document types taxonomy (state-specific)
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-04 Document Management
depends_on: [REQ002, REQ023]
---

## Problem
"Immunization record" in California is a Blue Card (CDPH 286); in Florida it's DH 680. We need a stable taxonomy that maps user-facing document types to state-specific document types so OCR classification and compliance checking are consistent.

## User Story
As an engineer, I want a single table of canonical document types with state variants, so that compliance rules and OCR classifiers reference one source of truth.

## Acceptance Criteria
- [ ] `document_types` table: `id text pk (prefix dt_), code text unique, category text, label text, state text (nullable for universal), applies_to text ('child'|'staff'|'facility'), has_expiration boolean, default_validity_days int null`.
- [ ] Seed migration inserts canonical types, at minimum:
  - Universal: `staff_cpr_cert`, `staff_first_aid_cert`, `staff_background_check`, `staff_tb_test`, `staff_training_hours_log`, `child_enrollment_form`, `child_emergency_contact`, `child_custody_order`
  - CA: `ca_lic_281a_facility_application`, `ca_lic_311a_staff_application`, `ca_lic_503_health_screening`, `ca_lic_9227_admission_agreement`, `ca_cdph286_blue_card_immunization`
  - TX: `tx_form_1100_child_enrollment`, `tx_form_2935_staff_personnel_record`, `tx_form_2941_director_qualifications`, `tx_form_7259_immunization`
  - FL: `fl_cf_fsp_5274_facility_app`, `fl_cf_fsp_5316_staff_background`, `fl_dh680_immunization`, `fl_cf_fsp_5337_child_enrollment`
- [ ] Each type has `default_validity_days` where applicable (e.g., CPR = 730, TB = 365, background check = 1825).
- [ ] API `GET /api/document-types?state=CA&applies_to=staff` returns filtered list.
- [ ] LLM classifier prompt (REQ026) includes this type list.

## Technical Notes
- Seed via SQL `COPY` or an idempotent `INSERT ... ON CONFLICT` migration.
- Keep `code` human-readable and stable — rules (REQ036) will reference codes.
- Source of truth for each type is cited in `planning-docs/state-docs/*` — put citation in a code comment per type.

## Definition of Done
- [ ] Seed migration runs and populates ≥ 25 document types.
- [ ] Filter API returns correct subsets.
- [ ] Types referenced by all state rule packs in REQ036.

## Related Tickets
- Blocks: REQ025, REQ026, REQ036
- Blocked by: REQ002, REQ023
