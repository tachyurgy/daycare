# California — Source URLs &amp; Data Provenance

**Date collected:** 2026-04-18

## Pre-existing product spec (reference)
- `/Users/magnusfremont/Desktop/daycare/planning-docs/state-docs/california/california-compliancekit-product-spec.html` — 2,250-line authoritative HTML product spec for CA. Facts cross-referenced for this compliance.md, including Title 22 citations, LIC form catalog, ratio tables, and enforcement framework.
- Supporting PDFs at the same path:
  - `title-22-regulations-ccc3.pdf` — Title 22 Div. 12 regulations
  - `lic-281a-application-booklet.pdf` — center application booklet
  - `lic-311a-records-to-maintain.pdf` — center records requirements
  - `lic-311d-family-child-care-home-records.pdf` — FCCH records
  - `lic-421-civil-penalty-assessment.pdf` — civil penalty assessment
  - `evaluator-manual-ccc.pdf` — LPA evaluator manual

## Regulatory sources
- https://www.cdss.ca.gov/inforesources/child-care-licensing — CDSS Child Care Licensing portal
- https://www.ccld.dss.ca.gov/carefacilitysearch/ — CCLD Facility Search (inspection reports, deficiency listings, correction plans)
- https://cdss.ca.gov/inforesources/cdss-programs/community-care-licensing/ccld-data — CCLD Data Hub
- https://www.cdss.ca.gov/inforesources/community-care-licensing/policy/child-care-regulations — Title 22 Div. 12 regulations
- https://www.cdss.ca.gov/inforesources/community-care-licensing/facility-search-welcome — Facility Search welcome / instructions
- https://www.cdss.ca.gov/inforesources/child-care-licensing/public-information-and-resources — Public Information &amp; Resources
- https://leginfo.legislature.ca.gov/faces/codes_displayText.xhtml?lawCode=HSC&amp;division=2.&amp;title=&amp;part=&amp;chapter=3.4.&amp;article= — Health &amp; Safety Code § 1596.70 et seq.
- https://ccld.childcarevideos.org/ — CCLD-sanctioned Resources for Parents &amp; Providers (videos, transcripts)
- https://licensingregulations.acf.hhs.gov/licensing/contact/california-department-social-services-community-care-licensing-division-child — ACF Licensing Regulations Database entry

## Provider list / leads CSV

### Primary (used): `california_leads.csv`
- File: `/Users/magnusfremont/Desktop/daycare/california_leads.csv`
- Rows: **9,402** (including header)
- Data rows: ~9,401 providers
- **Coverage:** substantial statewide coverage. CA has ~28,000+ licensed facilities (centers + FCCH); this CSV represents ~33-35% of the licensed market, heavily skewed toward centers and major MSAs.
- Fields: name, city, zip, phone (per standard schema for the leads corpus)
- Email / website fields: largely blank (source aggregator does not publish)

### Authoritative data (reference, not bulk-downloaded)
- **CCLD Facility Search** at ccld.dss.ca.gov/carefacilitysearch is the source of truth for CA provider status, license number, and full inspection history (April 2015-present). Full bulk access requires scraping or public records request (see violations.md).
- **CCLD Data Hub** at cdss.ca.gov/inforesources/cdss-programs/community-care-licensing/ccld-data publishes **aggregate statistics** (facility / capacity trends, fatality counts, AB 388 law-enforcement contact data) but **no machine-readable per-facility deficiency dataset**. The hub publishes an Excel "General Statistics About Licensed Facilities" and several PDF reports. No Socrata, no JSON API.

### Authoritative bulk data (does not exist publicly)
- California does **not** publish a public Socrata or ArcGIS feed of per-facility inspection records. The CCLD Facility Search is the per-facility public surface; bulk extracts require a California Public Records Act (CPRA) request. Historical community references to "LIS" (Licensing Information System) refer to CCLD's internal case-management system; public extracts of LIS must go through CPRA.

## CPRA / Public-Records Path
- **Governing statute:** California Public Records Act (CPRA), Gov. Code § 7920.000 et seq. (post-2023 renumber of former § 6250).
- **Primary custodian:** CDSS Office of Legal Services / CCLD Public Records Coordinator.
- **Response window:** 10 calendar days initial determination; production on reasonable-time basis.
- Useful request phrasing in violations.md.

## Leads CSV output
- File: `/Users/magnusfremont/Desktop/daycare/california_leads.csv`
- Rows: 9,402 (including header)
- Note: email/website enrichment is a separate workstream — the CSV currently carries name, city, zip, phone only. CCLD Facility Search provides license number and phone on the public profile and is the natural enrichment source.
