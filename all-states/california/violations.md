# California — Violations &amp; Inspection Data

**Date collected:** 2026-04-18
**State rank (population):** 1

## Violations / Inspection Data Source

California publishes the richest per-facility inspection transparency on the west coast through the **CCLD Transparency Website** (facility search). Two complementary surfaces:

1. **CCLD Facility Search** (`ccld.dss.ca.gov/carefacilitysearch/`) — per-facility inspection reports, deficiency listings, correction plans, complaint investigations. **April 2015 - present.**
2. **CCLD Data Hub** (`cdss.ca.gov/inforesources/cdss-programs/community-care-licensing/ccld-data`) — aggregate statistics, fatality summaries, capacity trends. Not per-facility.

For bulk / structured per-facility data, the state's **Licensing Information System (LIS)** extract must be obtained via California Public Records Act (CPRA) request. There is no public Socrata / ArcGIS / JSON feed.

## Data Format

### CCLD Facility Search (primary public surface)
- **Per-facility** — users search by name, address, license number, city/county.
- **HTML + PDF** — each facility page displays inspection visits in a table; each visit links to a full PDF inspection report with narrative, deficiency citations, and correction plans.
- **Excel export** — a "Facility Reports" / "Download Data" feature lets users export the visible result-set list to Excel (but not full deficiency detail).
- No public JSON API.

### CCLD Data Hub (aggregate only)
- **Excel:** "General Statistics About Licensed Facilities"
- **PDF:** heat-map capacity reports, fatality summaries, AB 388 (law-enforcement contact), SB 484 (psychotropic medication) reports
- No bulk per-facility dataset.

## Freshness

- **Inspection reports from April 2015 - present** on the facility search portal.
- New inspections appear within days-to-weeks of LPA report finalization.
- Data hub aggregate reports publish on annual / semiannual cadence.

## Key Fields (per inspection report)

- Facility name, license number, license type (CCC / FCCH-Small / FCCH-Large / Infant Center / School-Age)
- Address, phone, licensed capacity, director/provider name
- Inspection date
- Inspection type (initial, annual, unannounced random, complaint, post-incident, case management)
- LPA (Licensing Program Analyst) name
- Title 22 citation per deficiency
- Citation type:
  - **Type A** — present immediate health / safety / personal-rights risk
  - **Type B** — affect facility operations but not immediate risk
- Corrective Action Plan (CAP) + due date
- Civil penalty assessment (LIC 421) — amount, status
- Complaint disposition (substantiated / unsubstantiated / inconclusive)

## Scraping / Access Strategy

1. **Facility enumeration:** iterate CCLD Facility Search by county (58) + facility type combinations. Result sets paginate; each row links to a stable facility-id URL.
2. **Per-facility scrape:** fetch facility detail HTML; parse inspection visit table; collect visit-id URLs.
3. **PDF extraction:** download each visit's report PDF; OCR / text-extract the deficiency list and correction plan into a normalized schema: `(license_number, visit_date, visit_type, citation, type_a_or_b, narrative, cap_due, civil_penalty)`.
4. **Headless browser (Playwright)** required; portal is JS + session-cookie driven.
5. **Rate limiting:** no documented published limit; stay polite (1 req/sec, parallelism ≤5).
6. **Scale consideration:** CA is the largest state by facility count. Full-state scrape is non-trivial (~28,000 facilities × ~5-10 years × multiple visits per year = millions of PDFs). Plan incremental extraction by region / county.

## Known Datasets / Public Records

- **data.chhs.ca.gov — Community Care Licensing Facilities** (https://data.chhs.ca.gov/dataset/ccl-facilities) — CHHS Open Data Portal dataset of licensed facilities. Periodically refreshed. Facility-level roster (not deficiencies) — a good starting registry.
- **data.ca.gov — Community Care Licensing Facilities** (https://data.ca.gov/dataset/community-care-licensing-facilities) — federated mirror of the CHHS dataset.
- **catalog.data.gov** — federated entry (https://catalog.data.gov/dataset/community-care-licensing-facilities).
- **Berkeley Parents Network** article ("How to Look Up a License for Preschools &amp; Daycares") — walks parents through CCLD Facility Search, confirms public access, explains how to interpret deficiency types.
- **AB 388 / SB 484 reports** — targeted public reports on specific enforcement areas (foster / group home law-enforcement contact; psychotropic medication).
- **CCLD Video Resources** (ccld.childcarevideos.org) — CCLD-sanctioned explainer content.
- No single journalistic investigation has assembled a statewide deficiency dataset comparable to what the **Tampa Bay Times** did for Florida or what **Texas HHSC** publishes natively. California's per-facility detail is accessible but requires scraping at scale.

## FOIA / CPRA Path

- **Statute:** California Public Records Act (CPRA), **Gov. Code § 7920.000 et seq.** (post-2023 renumber; formerly § 6250 et seq.). Presumption of openness.
- **Initial determination:** **10 calendar days** from receipt.
- **Custodian:** CDSS Office of Legal Services / CCLD Public Records Coordinator.
- **Address:** California Department of Social Services, Community Care Licensing Division, 744 P Street, Sacramento, CA 95814.
- **Useful request:** "Complete extract of the Licensing Information System (LIS) records for all licensed Child Care Centers and Family Child Care Homes statewide, covering January 1, 2016 through the date of this request. Fields requested: license number, facility name, license type, license status, issue date, expiration date, address, city, ZIP, capacity, all inspection visits (date, type, LPA), all deficiencies (Title 22 citation, Type A/B classification, narrative, corrective-action plan, due date, completion status), all civil penalty assessments (LIC 421 amount, disposition), and all complaints (date, allegation, disposition). Requested format: CSV, Excel, or direct database export."
- **Supplementary request:** "Any published CCLD data dictionary / schema for the LIS extract."

## Sources

- https://www.ccld.dss.ca.gov/carefacilitysearch/ — CCLD Facility Search (primary public surface)
- https://cdss.ca.gov/inforesources/cdss-programs/community-care-licensing/ccld-data — CCLD Data Hub
- https://www.cdss.ca.gov/inforesources/community-care-licensing/facility-search-welcome — Facility Search welcome
- https://www.cdss.ca.gov/inforesources/child-care-licensing — CDSS Child Care Licensing
- https://data.chhs.ca.gov/dataset/ccl-facilities — CHHS Open Data Portal (facility roster)
- https://data.ca.gov/dataset/community-care-licensing-facilities — California Open Data (mirror)
- https://catalog.data.gov/dataset/community-care-licensing-facilities — data.gov federated entry
- https://www.berkeleyparentsnetwork.org/advice/childcare/violations — Berkeley Parents Network explainer
- https://ccld.childcarevideos.org/ — CCLD-sanctioned video resources
- https://leginfo.legislature.ca.gov/faces/codes_displayText.xhtml?lawCode=GOV&amp;division=10.&amp;title=1.&amp;part=&amp;chapter= — CPRA (Gov. Code § 7920 et seq.)
- https://www.ylc.org/wp-content/uploads/2023/06/CCL-Complaint-Overview-062323.pdf — Youth Law Center complaint-process overview
- `/Users/magnusfremont/Desktop/daycare/planning-docs/state-docs/california/california-compliancekit-product-spec.html` — pre-existing CA product spec (reference)
