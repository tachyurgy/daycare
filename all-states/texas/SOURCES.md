# Texas — Source URLs &amp; Data Provenance

**Date collected:** 2026-04-18

## Pre-existing product spec (reference)
- `/Users/magnusfremont/Desktop/daycare/planning-docs/state-docs/texas/texas-compliancekit-product-spec.html` — 1,608-line authoritative HTML product spec for TX. Facts cross-referenced for this compliance.md, including Chapter 746 standards, deficiency weight system, inspection process, and forms.
- Supporting PDFs at the same path:
  - `chapter-746-minimum-standards-centers.pdf` — 26 TAC Ch. 746 for Child-Care Centers
  - `form-1100-daily-building-grounds-checklist.pdf` — Daily Building &amp; Grounds Checklist
  - `form-2935-admission-information.pdf` — Admission Information
  - `form-2941-sign-in-sign-out-log.pdf` — Sign-In / Sign-Out Log
  - `form-2948-plan-of-operation.pdf` — Plan of Operation
  - `form-7239-incident-illness-report.pdf` — Incident / Illness Report
  - `form-7259-personnel-records-evaluation.pdf` — Personnel Records Evaluation (inspector)
  - `form-7260-childrens-records-evaluation.pdf` — Children's Records Evaluation (inspector)
  - `form-7261-center-records-evaluation.pdf` — Center Records Evaluation (inspector)
  - `form-7263-emergency-practices.pdf` — Emergency Practices

## Regulatory sources
- https://www.hhs.texas.gov/services/family-safety-resources/child-care — HHSC Child Care hub
- https://www.hhs.texas.gov/providers/child-care-regulation/minimum-standards — Minimum Standards index
- https://childcare.hhs.texas.gov/ — Public Search Texas Child Care
- https://childcare.hhs.texas.gov/Child_Care/ — Texas Child Care Licensing portal (alternate)
- https://www.hhs.texas.gov/about/records-statistics/data-statistics/child-care-regulation-statistics — CCR Statistics
- https://www.hhs.texas.gov/services/safety/child-care/frequently-asked-questions-about-texas-child-care/what-are-ccr-reports-inspections-enforcement-actions — CCR FAQ
- https://www.dfps.texas.gov/child_care/ — DFPS legacy page (pre-2017)
- https://texreg.sos.state.tx.us/public/readtac$ext.ViewTAC?tac_view=4&amp;ti=26&amp;pt=1&amp;ch=746 — 26 TAC Chapter 746 (Secretary of State)
- https://licensingregulations.acf.hhs.gov/licensing/contact/texas-health-and-human-services-child-care-regulation — ACF entry

## Open-data bulk sources
- https://data.texas.gov/ — Texas Open Data Portal (Socrata)
- https://data.texas.gov/See-Category-Tile/HHSC-CCL-Daycare-and-Residential-Operations-Data/bc5r-88dy — HHSC CCL Daycare and Residential Operations Data (Socrata dataset group)
- https://data.texas.gov/dataset/Monthly-Child-Care-Services-Data-Report-Child-Care/c7ep-cuy6 — Monthly Child Care Services Data Report
- https://data.texas.gov/See-Category-Tile/Monthly-Child-Care-Services-Data-Report-Children-S/xge9-adrm — Children Served by County
- https://data.texas.gov/dataset/Child-and-Adult-Care-Food-Programs-CACFP-Child-Cen/y9zm-iygj — CACFP Child Centers
- https://data.texas.gov/dataset/Child-and-Adult-Care-Food-Programs-CACFP-Day-Care-/ub2y-4i6h — CACFP Day Care Homes (site-level)
- https://data.texas.gov/dataset/Child-and-Adult-Care-Food-Programs-CACFP-Day-Care-/x9ve-x3iy — CACFP Day Care Home meal reimbursement
- https://www.twc.texas.gov/programs/child-care/data-reports-plans — Texas Workforce Commission child care data

## Provider list / leads CSV

### Primary (used): `texas_leads.csv`
- File: `/Users/magnusfremont/Desktop/daycare/texas_leads.csv`
- Rows: **9,686** (including header)
- Data rows: ~9,685 providers
- **Coverage:** strong coverage of major Texas MSAs (Houston, DFW, San Antonio, Austin, El Paso). TX has ~16,000-18,000 regulated operations overall; this CSV represents ~54-60% of the market and is heavily weighted toward licensed centers.
- Fields: name, city, zip, phone (standard leads schema)
- Email / website: largely blank

### Authoritative enrichment (bulk available natively)
- TX is the exception — HHSC **publishes deficiency data natively** via Search Texas Child Care. Combined with the Texas Open Data Portal (Socrata), TX is the richest state for publicly-accessible child care inspection data in the US.
- The Socrata API (`https://data.texas.gov/resource/<id>.json`) enables direct pulls without scraping. Facility roster + deficiencies can be joined in database workflows.

## Texas Public Information Act (PIA) Path
- **Statute:** Texas Government Code **Chapter 552** (Public Information Act).
- **Response window:** 10 business days initial.
- **Custodian:** HHSC Public Information Office.
- Supplementary request typically needed only for fields not published through the Socrata feeds or the public search — e.g., internal investigation narratives, staff-level training hour records, specific complaint allegations that were unsubstantiated.

## Leads CSV output
- File: `/Users/magnusfremont/Desktop/daycare/texas_leads.csv`
- Rows: 9,686 (including header)
- Note: given TX's native public deficiency data, the lead enrichment workflow is unusually efficient — license number + current compliance score can be fetched for every row via the Socrata API.
