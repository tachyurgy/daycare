# New York — Violations / Inspections / Enforcement Research

_Updated 2026-04-18. Covers OCFS (statewide outside NYC) and NYC DOHMH (NYC-licensed centers) data sources for per-facility violation and inspection data._

## Violations / Inspection Data Source (State)
New York splits regulation between two agencies; each publishes per-facility inspection/violation data separately.

### Statewide (non-NYC): OCFS Child Care Facility Search (CCFS)
- **Portal home (search):** https://ocfs.ny.gov/programs/childcare/looking/
- **Per-facility "Program Profile"** pages are linked from each record in the data.ny.gov dataset and show current license status, program overview, inspection history, and violation-citation records (only inspections with violations cited are displayed).
- **Enforcement Action page (facilities on probation / revocation / suspension):** https://ocfs.ny.gov/programs/childcare/looking/ccfs-fie.php
- **OCFS explainer document** (how to read inspections, violations, and enforcement records, Class I/II/III severity, fine schedule): https://ocfs.ny.gov/programs/childcare/assets/docs/DCCS-Inspections-Violations-Enforcement.pdf

### NYC: DOHMH Child Care Connect
- **Portal:** https://a816-healthpsi.nyc.gov/ChildCare/childCareList.action
- Operates under NYC Health Code Article 47 — independent of OCFS. A NYC center has two regulatory records (OCFS and DOHMH) and inspection histories must be pulled from both.

## Data Format

### State: data.ny.gov Socrata — `cb42-qumz`
- **Dataset title:** Child Care Regulated Programs
- **Dataset ID:** `cb42-qumz` (also exposed as `s8uq-s4wq` for the map view and `fymg-3wv3` as the API dataset alias)
- **Base API endpoint:** `https://data.ny.gov/resource/cb42-qumz.json` (SoQL/SODA v2), or `.csv` for CSV
- **Bulk CSV:** https://data.ny.gov/api/views/cb42-qumz/rows.csv?accessType=DOWNLOAD
- **Rows:** ~16,770 regulated programs
- **Critical limitation (confirmed via columns.json):** the dataset has **33 columns** but does **NOT** contain a structured violations/inspections field. It carries `Facility Status` (values include "Pending Revocation", "Pending Revocation and Denial", "Pending Denial", "Suspended") and a URL to the `Program Profile`, which is an HTML page hosted on OCFS servers where the actual violation narrative is rendered.
- **Consequence:** to get violation-level detail, you must fetch each program-profile URL and parse it. Bulk approach is possible (16k URLs) but rate-limited by OCFS.
- **2-year violation window:** OCFS stated policy is that violation history is retained on the program profile for the prior 2 years.

### NYC: data.cityofnewyork.us Socrata — `dsg6-ifza`
- **Dataset title:** DOHMH Childcare Center Inspections (also a historical sibling under the same ID)
- **Dataset ID:** `dsg6-ifza`
- **API endpoint:** `https://data.cityofnewyork.us/resource/dsg6-ifza.json`
- **Bulk CSV:** https://data.cityofnewyork.us/api/views/dsg6-ifza/rows.csv?accessType=DOWNLOAD
- **Update frequency:** daily (per DOHMH data dictionary)
- **Contains:** facility name, permit number, address, borough, zip, building, legal name, phone, program type, status, inspection date, inspection status, violation category, violation rate (critical/general/public health hazard), health violations rates, regulation section, description.

## Freshness
- **OCFS data.ny.gov `cb42-qumz`:** updated weekly (per OCFS metadata) — facility status changes propagate within days.
- **OCFS Program Profile HTML pages:** refreshed as licensing actions close out — typical lag 1–3 weeks post-inspection.
- **NYC `dsg6-ifza`:** daily refresh (same-day to next-business-day lag).

## Key Fields (what's captured)
### OCFS Program Profile (scraped HTML)
- Inspection date
- Inspection type (initial, monitoring, renewal, complaint)
- Regulation citation (e.g., "18 NYCRR 418-1.13(a)(2)")
- Narrative of violation
- Correction due date
- Correction accepted date
- Class / severity tier (Class I = serious; Class II = public health; Class III = minor — per OCFS)
- Any fines assessed (Class II/III)

### NYC DOHMH `dsg6-ifza`
- `inspection_date`, `inspection_status`, `violation_category`, `violation_rate_per_child`, `health_violation_rate_per_child`, `regulation_summary`, `violation_category_description` — structured columns

## Scraping / Access Strategy
### For statewide OCFS data
1. Pull full `cb42-qumz` list via SODA with an app token: `curl 'https://data.ny.gov/resource/cb42-qumz.json?$limit=50000&$$app_token=YOUR_TOKEN'`
2. For each row, follow the `program_profile` URL (typically `https://hs.ocfs.ny.gov/CCFS/Provider/Facility?id=...`) and parse the rendered HTML for the "Inspections / Violations" section. No captcha observed; basic rate-limiting of ~1 req/sec is safe.
3. For enforcement actions specifically, scrape https://ocfs.ny.gov/programs/childcare/looking/ccfs-fie.php — this is a static list that renders all facilities currently under a published enforcement action.
4. Observed tech: OCFS CCFS provider portal is an ASP.NET Core application (`Microsoft.AspNetCore` headers) — no ViewState encryption on the public Program Profile route, so straight `requests` + BeautifulSoup is sufficient.

### For NYC DOHMH data
1. Direct SODA query — no scraping needed: `curl 'https://data.cityofnewyork.us/resource/dsg6-ifza.json?$where=inspection_date>"2026-01-01"&$limit=50000'`
2. For day-over-day changes, filter on `:updated_at` to fetch only new records.

### Hot-leads query (last 90 days, state)
```bash
# Active enforcement actions state-wide
curl 'https://data.ny.gov/resource/cb42-qumz.json?$where=facility_status in ("Pending Revocation","Pending Revocation and Denial","Pending Denial","Suspended")&$limit=5000'
```

### Hot-leads query (last 90 days, NYC)
```bash
curl 'https://data.cityofnewyork.us/resource/dsg6-ifza.json?$where=inspection_date>"2026-01-18" AND violation_category is not null&$limit=10000'
```

## Known Datasets / Public Records
- **data.ny.gov open-data portal:** https://data.ny.gov/ — search "child care" returns `cb42-qumz`, `s8uq-s4wq` (map view), `fymg-3wv3` (API alias), `x7qk-znn4` (Queens Daycare subset). None publish inspection/violation rows as structured columns, only status + profile URL.
- **NYC Open Data `dsg6-ifza`:** the only structured, bulk-available inspection dataset in the state.
- **Journalism / investigations:**
  - NYC City News Service "Day Care Danger" project (2015-era): https://daycaredanger.nycitynewsservice.com/new-york/ — early catalog of NYC daycare deaths and violations.
  - NY State Senate IDC "Hidden Dangers in Day Care" report (2016): https://www.nysenate.gov/sites/default/files/hidden_dangers_in_daycare_full_report.pdf — aggregates OCFS violation data with policy critique.
- **Aggregate CCDBG statistics** (state-level serious-incident reports, not per-facility): https://ocfs.ny.gov/programs/childcare/aggregate-data.php and https://hs.ocfs.ny.gov/DCFS/Home/AggData.

## FOIA / Open-records Path
- **Statute:** NY Public Officers Law Article 6 (Freedom of Information Law, "FOIL").
- **OCFS FOIL:** https://ocfs.ny.gov/main/legal/foil.asp — submit request via email to `FOIL.Office@ocfs.ny.gov`. Typical response 20 business days. Violation histories older than 2 years (off the public portal) and any redacted investigation narrative require a FOIL.
- **NYC DOHMH FOIL:** https://www.nyc.gov/site/doh/about/foil-request.page — rarely needed because DOHMH publishes at `dsg6-ifza` daily.

## Sources
- OCFS Child Care Facility Search landing: https://ocfs.ny.gov/programs/childcare/looking/
- OCFS Enforcement Action list: https://ocfs.ny.gov/programs/childcare/looking/ccfs-fie.php
- OCFS Inspections/Violations explainer PDF: https://ocfs.ny.gov/programs/childcare/assets/docs/DCCS-Inspections-Violations-Enforcement.pdf
- OCFS Child Care Data hub: https://ocfs.ny.gov/programs/childcare/data/
- data.ny.gov Child Care Regulated Programs (`cb42-qumz`): https://data.ny.gov/Human-Services/Child-Care-Regulated-Programs/cb42-qumz
- data.ny.gov API alias (`fymg-3wv3`): https://data.ny.gov/Human-Services/Child-Care-Regulated-Programs-API/fymg-3wv3
- data.ny.gov Map view (`s8uq-s4wq`): https://data.ny.gov/Human-Services/Child-Care-Regulated-Programs-Map/s8uq-s4wq
- NYC Open Data DOHMH Childcare Inspections (`dsg6-ifza`): https://data.cityofnewyork.us/Health/DOHMH-Childcare-Center-Inspections/dsg6-ifza
- NYC DOHMH Child Care Connect portal: https://a816-healthpsi.nyc.gov/ChildCare/childCareList.action
- OCFS Aggregate Data (CCDBG): https://ocfs.ny.gov/programs/childcare/aggregate-data.php
- NYS Senate "Hidden Dangers in Day Care": https://www.nysenate.gov/sites/default/files/hidden_dangers_in_daycare_full_report.pdf
- NYC City News Service daycare project: https://daycaredanger.nycitynewsservice.com/new-york/
