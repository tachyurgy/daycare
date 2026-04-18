# Wyoming — Violations & Inspection Data

**Date collected:** 2026-04-18
**State rank (population):** 50

## Violations / Inspection Data Source

Wyoming publishes certification history, substantiated complaints, and compliance notes through the **Find Child Care Wyoming** facility finder operated by the DFS Division of Early Care and Education.

- Current finder: https://childcare.dfs.wyo.gov/home/ (also reachable at findchildcarewy.org → redirects here)
- DFS Report-a-Concern portal: https://dfs.wyo.gov/providers/child-care-2/report-a-concern-on-a-child-care-facility/
- DFS Child Care Licensing hub: https://dfs.wyo.gov/providers/child-care-2/

## Data Format

- **Per-facility** only. No public Socrata, ArcGIS, JSON, or bulk CSV.
- HTML + PDF: each facility page shows certification status and links to substantiated-complaint summaries.
- Underlying system is a vendor-hosted facility finder (CCX); not a public-data-portal platform.

## Freshness

- **Substantiated complaints from 2019 to present** are displayed on the Find Child Care site.
- Pre-2019 records and records for **permanently closed facilities** are not surfaced publicly — must be requested via DFS open-records.
- New complaints appear on the facility profile after DFS substantiation (process typically days to weeks post-investigation).

## Key Fields

- Facility name, certification number, facility type (FCCH / FCCC / CCC / School-Age)
- Certification status (active / expired / surrendered / revoked / denied)
- Capacity, ages served
- Address + geolocation
- Substantiated complaints list with:
  - Date
  - Rule cited (WY DFS Chapter 2 / 5 / 6 / 7)
  - Summary
  - Resolution / corrective-action status
- STAR quality rating (voluntary QRIS, 1-4 STARS)

## Scraping / Access Strategy

1. **Provider enumeration:** iterate the finder by zip / county / city (Wyoming has 23 counties and ~99 incorporated places). Low-cardinality sweep possible in an hour.
2. **Profile fetch:** finder results link to facility-detail URLs; parse HTML for certification table + substantiated complaints.
3. **Headless browser:** UI is JS-rendered; use Playwright.
4. **Complement via DFS Subsidy Policy Manual:** identifies eligible-but-not-certified providers (Family Friend or Neighbor tier) which are excluded from the finder but are still regulated-for-subsidy.
5. **Small-state advantage:** ~500-650 certified facilities statewide — a complete snapshot scrape is feasible in a single afternoon.

## Known Datasets / Public Records

- **Wyoming Early Childhood Professional Learning** system — tracks staff PD hours, not facility compliance.
- **DFS Chapter 5 / 6 / 7** regulatory PDFs published on wyoleg.gov and publichealthlawcenter.org — regulatory text, not record-level data.
- **Public Health Law Center** archive mirrors: https://www.publichealthlawcenter.org/sites/default/files/resources/Wyoming_Child%20Care%20Regulations.pdf
- No known academic or journalistic aggregator covers Wyoming child care inspections. Wyoming Public Media and Cowboy State Daily have published individual incident stories but no structured dataset.

## FOIA / Open-Records Path

- Statute: **W.S. § 16-4-201 through § 16-4-205** — Wyoming Public Records Act. Presumption of openness; exemptions for confidential CPS files.
- Requests go to: **WY Department of Family Services**, 2300 Capitol Avenue, Cheyenne, WY 82002 | (307) 777-7564.
- **Useful request:** "Full extract of all certification-history records for currently-certified and historically-certified child care providers (all types: FCCH, FCCC, CCC, School-Age) for the preceding 10 years, in CSV or Excel format. Include certification number, facility type, dates of issuance / renewal / surrender / revocation, all substantiated complaints with DFS chapter citation, and all administrative enforcement actions."
- **Useful companion request:** "The subsidy-eligible Family Friend or Neighbor (FFN) provider registry, if maintained by DFS, with any associated background-check compliance records redacted of PII."

## Sources

- https://childcare.dfs.wyo.gov/home/ — Find Child Care WY finder
- https://findchildcarewy.org/ — legacy finder (redirects to DFS)
- https://dfs.wyo.gov/providers/child-care-2/ — DFS Child Care hub
- https://dfs.wyo.gov/providers/child-care-2/report-a-concern-on-a-child-care-facility/ — complaint intake
- https://dfs.wyo.gov/providers/child-care-2/licensing-rules/ — Licensing rules index
- https://dfs.wyo.gov/about/policy-manuals/child-care-subsidy-policy-manual/ — Subsidy manual
- https://dfs.wyo.gov/providers/child-care-support/ — background-check info
- https://wyoleg.gov/ARules/2012/Rules/ARR16-058.pdf — Chapter 5 (FCCH)
- https://www.publichealthlawcenter.org/sites/default/files/resources/Wyoming_Child%20Care%20Regulations.pdf — consolidated regs
- https://wyoleg.gov/statutes/compress/title16.pdf — W.S. Title 16 (includes Public Records Act)
- https://licensingregulations.acf.hhs.gov/licensing/contact/wyoming-department-family-services — ACF contact
