# Texas — Violations &amp; Inspection Data

**Date collected:** 2026-04-18
**State rank (population):** 2

## Violations / Inspection Data Source

Texas publishes **the most complete per-facility deficiency dataset of any state in the country**. Two complementary surfaces:

1. **Search Texas Child Care** (https://childcare.hhs.texas.gov/) — the public-facing HHSC inspection record. Every deficiency cited at any licensed operation is posted within 14 days of the visit with full Minimum Standard citation, narrative, deficiency weight, corrective action, and resolution.
2. **Texas Open Data Portal** (https://data.texas.gov, Socrata) — bulk / machine-readable access to HHSC CCL operations data plus adjacent CACFP and monthly services datasets.

## Data Format

### Search Texas Child Care (primary public surface)
- **Per-operation HTML** with full deficiency table inline on the operation's profile page.
- Filterable search by name, city, zip, license number.
- Deep-linkable operation pages.
- Deficiency rows include: date, Minimum Standard cited, standard number, weight, narrative, corrective action, compliance status.

### Texas Open Data Portal (bulk)
- **Socrata.** All datasets support CSV, JSON, XML, RDF, RSS export and the **SODA REST API** (`https://data.texas.gov/resource/<dataset-id>.json`).
- Dataset group "HHSC CCL Daycare and Residential Operations Data" (`bc5r-88dy`) contains facility-level compliance datasets and sub-datasets.
- Monthly Child Care Services Data Reports (`c7ep-cuy6`, `xge9-adrm`) are aggregate but useful for sizing and trend analysis.
- CACFP site-level datasets (`y9zm-iygj`, `ub2y-4i6h`, `x9ve-x3iy`) provide a parallel facility registry with federal participation flags.

## Freshness

- **Inspection reports posted within 14 days** of the visit (HHSC published timing).
- Public record retention is long — multi-year history is visible on each operation's profile.
- Socrata datasets refresh on documented cadences (monthly for the Monthly Child Care Services Data Report series; variable for the HHSC CCL operations datasets).

## Key Fields (per deficiency)

- Operation number (license number), operation name
- Operation type (Licensed Center / LCCH / RCCH / Listed Family / School-Age)
- Address, phone, licensed capacity
- Owner / director (where publicly posted)
- Visit date
- Visit type (initial, monitoring, follow-up, complaint, self-reported)
- **Minimum Standard cited** (Chapter 746 / 747 / 744 / 745 section number)
- **Deficiency weight:** High / Medium-High / Medium / Medium-Low / Low
- Narrative description
- Corrective action specified + due date
- Compliance status (corrected / outstanding / referred for enforcement)
- Administrative penalty (if applicable) — amount, status
- Enforcement action (evaluation, probation, suspension, revocation, adverse action)

## Scraping / Access Strategy

Texas is an **API-first** state for this data — scraping is usually unnecessary.

1. **Start with Socrata SODA API** at data.texas.gov. Pull the HHSC CCL operations data (`bc5r-88dy`) and related datasets via:
   ```
   curl 'https://data.texas.gov/resource/<dataset-id>.json?$limit=500000'
   ```
2. **Enumerate operations** from the Socrata roster. Cross-reference with CACFP site-level datasets for parallel registry + federal participation flag.
3. **For gaps / richer narratives** — the public Search Texas Child Care page on childcare.hhs.texas.gov renders additional per-visit detail (narratives, corrective action text) that may not be surfaced in all Socrata tables. Scrape the per-operation page when needed using standard HTTP (no JS required for most of the public surface).
4. **Socrata App Tokens** recommended for production ingestion — higher rate limits.
5. **Monthly Child Care Services Data Report** (`c7ep-cuy6`) for workload sizing.

## Known Datasets / Public Records

- **data.texas.gov HHSC CCL Daycare and Residential Operations Data** — the core. https://data.texas.gov/See-Category-Tile/HHSC-CCL-Daycare-and-Residential-Operations-Data/bc5r-88dy
- **Monthly Child Care Services Data Report - Child Care Facilities** (`c7ep-cuy6`).
- **Monthly Child Care Services Data Report - Children Served by County** (`xge9-adrm`).
- **CACFP Child Centers** (`y9zm-iygj`) — federally-reimbursed centers.
- **CACFP Day Care Homes - site-level** (`ub2y-4i6h`) — federally-reimbursed family homes.
- **CACFP Day Care Home meal reimbursement** (`x9ve-x3iy`).
- **Texas Workforce Commission child care data** — https://www.twc.texas.gov/programs/child-care/data-reports-plans — subsidy-side reporting, complementary to HHSC licensing data.
- **The Button Law Firm** operator-facing explainer ("How Do I Look Up Daycare Violations in Texas?") confirms the native transparency that is TX's market-defining feature.
- **HHSC CCR Statistics** — https://www.hhs.texas.gov/about/records-statistics/data-statistics/child-care-regulation-statistics — annual aggregate reports.

## FOIA / Texas Public Information Act Path

- **Statute:** Texas Government Code **Chapter 552** (Public Information Act / "TPIA").
- **Response window:** 10 business days initial determination; production on reasonable-time basis.
- **Custodian:** HHSC Office of General Counsel / Public Information Office.
- **Useful request:** "Complete database extract of all HHSC Child Care Regulation deficiencies cited against any licensed, registered, or listed operation from January 1, 2018 through the date of this request. Fields requested: operation number, operation name, operation type, address, visit date, visit type, Minimum Standard cited (chapter, subchapter, section), deficiency weight, narrative, corrective action, due date, compliance status, administrative penalty (amount, status), and enforcement action. Requested in CSV or Socrata-compatible tabular format."
- **Supplementary request:** internal data dictionaries, Minimum Standard weight tables, and any enforcement decision memos used by CCR regional supervisors.

## Sources

- https://childcare.hhs.texas.gov/ — Search Texas Child Care (primary)
- https://childcare.hhs.texas.gov/Child_Care/ — Child Care Licensing (alt)
- https://www.hhs.texas.gov/services/family-safety-resources/child-care — HHSC Child Care hub
- https://www.hhs.texas.gov/providers/child-care-regulation/minimum-standards — Minimum Standards
- https://www.hhs.texas.gov/about/records-statistics/data-statistics/child-care-regulation-statistics — CCR Statistics
- https://www.hhs.texas.gov/services/safety/child-care/frequently-asked-questions-about-texas-child-care/what-are-ccr-reports-inspections-enforcement-actions — CCR FAQ
- https://data.texas.gov/ — Texas Open Data Portal
- https://data.texas.gov/See-Category-Tile/HHSC-CCL-Daycare-and-Residential-Operations-Data/bc5r-88dy — HHSC CCL operations data
- https://data.texas.gov/dataset/Monthly-Child-Care-Services-Data-Report-Child-Care/c7ep-cuy6 — Monthly services report
- https://data.texas.gov/See-Category-Tile/Monthly-Child-Care-Services-Data-Report-Children-S/xge9-adrm — Children served by county
- https://data.texas.gov/dataset/Child-and-Adult-Care-Food-Programs-CACFP-Child-Cen/y9zm-iygj — CACFP Centers
- https://data.texas.gov/dataset/Child-and-Adult-Care-Food-Programs-CACFP-Day-Care-/ub2y-4i6h — CACFP Homes (site-level)
- https://data.texas.gov/dataset/Child-and-Adult-Care-Food-Programs-CACFP-Day-Care-/x9ve-x3iy — CACFP Homes (meal reimbursement)
- https://www.twc.texas.gov/programs/child-care/data-reports-plans — TWC child care data
- https://www.buttonlawfirm.com/faqs/how-do-i-look-up-daycare-violations-in-texas-.cfm — How to look up deficiencies (explainer)
- https://www.dfps.texas.gov/child_care/ — DFPS legacy (pre-2017)
- https://licensingregulations.acf.hhs.gov/licensing/contact/texas-health-and-human-services-child-care-regulation — ACF DB
- https://texreg.sos.state.tx.us/public/readtac$ext.ViewTAC?tac_view=4&amp;ti=26&amp;pt=1&amp;ch=746 — 26 TAC 746
- https://statutes.capitol.texas.gov/Docs/GV/htm/GV.552.htm — Gov. Code Ch. 552 (TPIA)
- `/Users/magnusfremont/Desktop/daycare/planning-docs/state-docs/texas/texas-compliancekit-product-spec.html` — pre-existing TX product spec
