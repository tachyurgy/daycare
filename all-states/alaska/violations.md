# Alaska — Violations & Inspection Data

**Date collected:** 2026-04-18
**State rank (population):** 48

## Violations / Inspection Data Source

Alaska operates **two parallel data sources** because of its dual-licensor structure:

1. **AKCCIS (Alaska Child Care Information System)** — state-level CCPO licensing history for all facilities licensed outside the Municipality of Anchorage. https://akccis.com/client/home
2. **Municipality of Anchorage (MOA) Child Care Licensing** — publishes facility-level inspection reports for every MOA-licensed facility, plus a Socrata **Childcare Inspections** open dataset at the Anchorage Open Data Portal. https://data.muni.org/Public-Health/Childcare-Inspections/abmr-hyh6/data

The MOA open dataset is the **single best child care inspection dataset available for any of the low-population states** — true machine-readable, Socrata-backed, field-level records with map coordinates.

## Data Format

### AKCCIS (state, outside Anchorage)
- **Per-facility** provider search; license status and compliance summary rendered client-side. No public bulk export.
- Requires JS; WebFetch returns a shell only.

### Anchorage Open Data — Childcare Inspections (`abmr-hyh6`)
- **Socrata** dataset. Full-table CSV, JSON, XML, RDF, and API (`https://data.muni.org/resource/abmr-hyh6.json`) download.
- Map view dataset (`pqqp-cdt5`) gives geolocated sites.
- Companion MOA page lists per-facility inspection PDFs for direct download.

## Freshness

- **AKCCIS:** live license status and history. Display horizon not publicly documented; 2-year licensing cycle means at minimum the current + prior term is surfaced.
- **Anchorage Open Data:** published inspection records **January 1, 2008 – present**. Due to MOA DB migration, pre-October-2024 inspection PDFs require email/phone request to Child Care Licensing (907-343-4758, hhsccl@muni.org); the Socrata dataset still carries the tabular record.
- Anchorage dataset refresh cadence: documented as ongoing; Socrata last-updated timestamp is the authoritative signal.

## Key Fields

### AKCCIS (per facility)
- Facility name, license number, license type (Center, Home, Group Home, School-Age)
- License status (active / probation / revoked / surrendered)
- Address + geolocation
- Compliance / monitoring summary

### Anchorage Open Data dataset
- Facility name, address, license number
- Inspection date, inspector, inspection type
- Inspection categories scored: General Sanitation, Program, Hazards, Infant & Toddler Care, Handwashing, Equipment & Supplies, Toileting Facilities, Playground & Climbing Equipment, Supervision, Medication & Topical Products, Behavioral Guidance, Food Safety & Nutrition, Caregiver Attributes, Facility Records
- Violation code (AMC 16.55 citation)
- Observation / narrative
- Correction deadline
- Latitude / longitude (Map of Locations dataset)

## Scraping / Access Strategy

1. **MOA (Anchorage, ~50% of state's market):** direct Socrata pull via SODA API. No scraping needed.
   - `curl 'https://data.muni.org/resource/abmr-hyh6.json?$limit=50000'` returns the full record set.
   - Socrata app-token recommended for higher quota.
2. **Rest-of-state (AKCCIS):**
   - Enumerate via AKCCIS search (by community / zip). Alaska has ~350 rural census areas; iterate from Anchorage outward.
   - Use Playwright; parse rendered compliance table per facility.
   - Optional: cross-reference SEED Registry (seedalaska.org) for staff-level training completeness.
3. **Merge step:** deduplicate providers appearing in both AKCCIS and MOA data by license number + address.
4. **Serious-incident feed:** per 7 AAC 57.545 facilities must self-report within 24 hours; those reports are not on the public portal but are obtainable via records request.

## Known Datasets / Public Records

- **Anchorage Open Data — Childcare Inspections** (`abmr-hyh6`): the canonical machine-readable dataset. Also surfaced at **catalog.data.gov/dataset/childcare-inspections**.
- **Anchorage Open Data — Childcare Inspections: Map of Locations** (`pqqp-cdt5`): geocoded companion.
- **CCAP Policies & Procedures Manual** (statewide subsidy): has rate and eligibility tables but not compliance data.
- No VTDigger-equivalent Alaska outlet maintains a public investigative dataset for child care.

## FOIA / Open-Records Path

- Alaska's public-records statute is **AS 40.25 (Public Records)**. Presumption of openness; exemptions for child-specific abuse investigations.
- Statewide requests go to: **DOH Child Care Program Office**, 619 E. Ship Creek Ave., Suite 230, Anchorage, AK 99501 | (907) 269-4500 | CCPO@alaska.gov.
- Anchorage-specific requests go to: **MOA Health Department, Child Care Licensing**, hhsccl@muni.org | (907) 343-4758.
- **Useful statewide request:** "Full facility-level extract of AKCCIS license status, license term, monitoring visits, deficiencies cited (with 7 AAC 57 citation numbers), and enforcement actions for the preceding 7 years, in CSV format."
- **Useful MOA request:** "All inspection reports for MOA-licensed child care facilities, Oct 2024 – present, including reports not yet fully migrated to the current database."

## Sources

- https://akccis.com/client/home — AKCCIS provider portal (state CCPO licensed facilities)
- https://dpaworks.dhss.alaska.gov/FindProviderVS8/zSearch.aspx — legacy ICCIS search (being deprecated)
- https://data.muni.org/Public-Health/Childcare-Inspections/abmr-hyh6/data — MOA Socrata Childcare Inspections dataset
- https://data.muni.org/Public-Health/Childcare-Inspections-Map-of-Locations/pqqp-cdt5 — MOA Map of Locations dataset
- https://catalog.data.gov/dataset/childcare-inspections — data.gov federated entry
- https://www.muni.org/Departments/health/childcare/Pages/default.aspx — MOA Child Care Licensing landing
- https://hhs.muni.org/cac/ — MOA Child & Adult Care
- https://health.alaska.gov/en/division-of-public-assistance/child-care-program-office/ — CCPO
- https://seedalaska.org — SEED Alaska Early Childhood Registry
- https://www.akleg.gov/basis/statutes.asp#40.25 — AS 40.25 (Public Records)
