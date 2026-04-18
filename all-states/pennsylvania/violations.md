# Pennsylvania — Violations / Inspections / Enforcement Research

_Updated 2026-04-18. Covers DHS OCDEL Bureau of Certification Services per-facility inspection/violation data._

## Violations / Inspection Data Source
Pennsylvania DHS OCDEL publishes per-facility inspection results through **two** public channels:

### 1. COMPASS Provider Search ("Find Child Care")
- **URL:** https://www.compass.dhs.pa.gov/providersearch/
- **Alternate branded URL:** https://www.findchildcare.pa.gov (redirects to the same search tool)
- Per-provider detail pages expose:
  - Certification status (Regular / Provisional)
  - Current Keystone STARS rating
  - **"View Inspection Summary"** link → list of every inspection done on that facility with date, type (annual / renewal / complaint / monitoring), outcome, and a line-by-line list of regulation violations with correction status.
- Powered by the underlying OCDEL "Certification Inspection Instrument" (CII) data.

### 2. DHS Quarterly Licensing Report
- **Landing page:** https://www.pa.gov/agencies/dhs/resources/data-reports/quarterly-licensing-report
- Quarterly PDFs enumerate, for all 5 DHS licensing offices (including OCDEL):
  - Provisional Licenses Issued (facility name, county, license type, capacity)
  - Licenses Revoked
  - Illegal / Unlicensed providers identified
  - Annual inspections completed count
  - Complaint investigations completed count

## Data Format
- **COMPASS Provider Search:** ASP.NET MVC application. Returns HTML; no official API or CSV export button on the search page.
- **"View Inspection Summary":** renders HTML table; each inspection ID is a deep-link that opens a separately-keyed HTML page of regulation-level detail. Inspection reports may also be surfaced as PDFs (CII instrument output).
- **Quarterly Licensing Report:** PDF, tabular. Not machine-readable without OCR.
- **data.pa.gov `ajn5-kaxt`** (Provider listing) is Socrata-hosted and has facility contacts/ratings but **no** violation columns — confirmed against existing SOURCES.md.
- **PA Human Service Provider Directory** (`humanservices.state.pa.us/HUMAN_SERVICE_PROVIDER_DIRECTORY/`) returns facility + certificate data only, not violations.

## Freshness
- **COMPASS:** near-real-time (inspection reports typically posted within 30-60 days of visit).
- **Quarterly Licensing Report:** lags by 2-3 months (Q2 report typically posted late Q3).
- **Under Act 24 of 2011** (amending the Public Welfare Code), PA DHS is required to publish licensing action data; this is the statutory basis for the Quarterly Report.

## Key Fields
### Per-facility inspection record (COMPASS)
- Facility Legal Name, DBA, Certificate Number
- Inspection Date
- Inspection Type (Initial / Annual Renewal / Complaint / Unannounced Monitoring / Complaint Follow-up)
- Regulation Citation (e.g., `55 Pa. Code § 3270.113`)
- Violation narrative
- Plan of Correction (POC) required (Y/N)
- POC due date
- POC accepted date
- Repeat violation flag

### Quarterly Licensing Report (aggregate)
- County
- License Type (Child Day Care Center, Group, Family)
- Capacity
- Facility Name
- Action (Provisional Issued / Revoked / Denied / Surrendered / Illegal Operation)

## Scraping / Access Strategy
### COMPASS per-facility scrape
1. **List acquisition:** start from the `ajn5-kaxt` dataset (7,473 rows with `Facility ID`) — existing CSV at project root.
2. **Detail fetch:** resolve each facility ID to a COMPASS provider detail URL. Pattern: `https://www.compass.dhs.pa.gov/providersearch/Home/ProviderDetails/{FacilityId}` (observed parameter).
3. **Tech:** ASP.NET MVC, no ViewState mysteries, but **cookies required** (session cookie issued on first GET; subsequent requests must carry it). No captcha or bot protection observed on the facility-detail route.
4. **Inspection summary:** a second request (often `/Home/InspectionSummary/{FacilityId}`) returns the violation table.
5. **Rate limiting:** ~1 req/sec is polite; 7,500 facilities × 2 requests = ~4 hours with a single-threaded fetch.

### Hot-leads heuristic (Provisional certificates)
A "Provisional" certificate signals the facility is out of compliance and is being allowed to continue under a plan of correction — these are the highest-intent ComplianceKit leads. Pull the quarterly PDF, OCR the Provisional Licenses Issued table, deduplicate against prior quarters, and that's the hot list.

### Quarterly PDF pipeline
```bash
# Example: fetch the most recent quarterly licensing report
curl -sL 'https://www.pa.gov/agencies/dhs/resources/data-reports/quarterly-licensing-report' \
  | grep -oE 'https://[^"]+Quarterly[^"]+\.pdf'
# Then OCR the PDF and parse the OCDEL sections
```

## Known Datasets / Public Records
- **data.pa.gov `ajn5-kaxt`:** Child Care Providers listing — names, addresses, STAR rating, NOT violations.
- **PA Open Data portal:** no dedicated violations dataset as of 2026-04. Confirmed via data.pa.gov search.
- **PA Key / Pennsylvania Professional Development Registry (pakeys.org):** holds staff PD data, not violation records.
- **Spotlight PA** and **ProPublica Local Reporting Network** have investigated PA daycare safety but have not published a structured dataset.

## FOIA / Open-records Path
- **Statute:** PA Right-to-Know Law (RTKL), 65 P.S. §§ 67.101–67.3104.
- **DHS RTKL office:** https://www.dhs.pa.gov/about/Pages/RTKL.aspx — formal request via `RA-PWOpenRecords@pa.gov` or the RTKL form. 5-business-day initial response (per statute).
- **Used for:** the full Certification Inspection Instrument (CII) PDF for a specific facility, bulk export of OCDEL inspection dataset (yes, it has been granted as a CSV in the past per prior RTKL responses), POC (plan-of-correction) documents, and complaint files with redactions.

## Sources
- COMPASS Provider Search: https://www.compass.dhs.pa.gov/providersearch/
- Find Child Care PA (alternate URL): https://www.findchildcare.pa.gov
- DHS Quarterly Licensing Report: https://www.pa.gov/agencies/dhs/resources/data-reports/quarterly-licensing-report
- Sample quarterly PDF (Q3 2021): https://www.pa.gov/content/dam/copapwp-pagov/en/dhs/documents/services/assistance/documents/quarterly-licensing-report/2021-Q3-DHS-Quarterly-Licensing-Report.pdf
- Sample quarterly PDF (Q4 2021): https://www.pa.gov/content/dam/copapwp-pagov/en/dhs/documents/services/assistance/documents/quarterly-licensing-report/Q4-2021_DHS_Quarterly_Licensing_Report.pdf
- data.pa.gov provider listing (`ajn5-kaxt`): https://data.pa.gov/Services-Near-You/Child-Care-Providers-including-Early-Learning-Prog/ajn5-kaxt
- PA Human Service Provider Directory: https://www.humanservices.state.pa.us/HUMAN_SERVICE_PROVIDER_DIRECTORY/
- DHS File a Child Care Facility Complaint: https://www.pa.gov/services/dhs/file-a-child-care-facility-complaint
- PA RTKL information: https://www.dhs.pa.gov/about/Pages/RTKL.aspx
- PA Key Certification resources: https://www.pakeys.org/certification/
- PA Promise for Children regulation explainer: https://papromiseforchildren.com/how-early-learning-programs-are-regulated-in-pennsylvania/
