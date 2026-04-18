# Wisconsin — Violations & Inspection Data

**Date collected:** 2026-04-18

## Violations / Inspection Data Source (URLs)

- **Primary (per-facility):** https://childcarefinder.wisconsin.gov/ — **Regulated Child Care and YoungStar Public Search**. Displays, per facility: YoungStar rating, inspection visits, Noncompliance Statements, Correction Plans, Compliance Statements, enforcement actions — all visits from the **previous 3 years**.
- **DCF Child Care Regulation hub:** https://dcf.wisconsin.gov/ccregulation
- **Most Frequently Cited Rule Violations:** https://dcf.wisconsin.gov/ccregulation/providers/most-freq-cited — DCF's own top-violations list (background checks, physical exams, abuse/neglect training, child tracking, CPR, supervision)
- **Serious Violations list:** https://dcf.wisconsin.gov/cclicensing/seriousviolations (also at `/ccregulation/serious-violations`) — categorized list of what counts as "serious" under DCF 250 and DCF 251
- **Illegal / Revoked Providers list:** https://dcf.wisconsin.gov/ccregulation/illegal-revoked — names of providers who have lost licensure or operate without
- **Child Abuse Critical Incident Reports (public disclosure):** https://dcf.wisconsin.gov/cps/incidents — publishes a redacted summary for each substantiated critical incident
- **WISCCRS** (internal data system — Wisconsin Child Care Regulatory System): source of truth; Regulation Details on the public search are fed from WISCCRS "within 24 hours of entry"
- **Child Care Data hub:** https://dcf.wisconsin.gov/childcare/data
- **DHS open spatial:** https://data.dhsgis.wi.gov/datasets/wisconsin-licensed-and-certified-childcare/about — ArcGIS feature service with location + basic attributes (no violations)

## Data Format

| Channel | Format | Bulk? |
|---|---|---|
| childcarefinder.wisconsin.gov | Dynamic HTML (Angular front-end pulling from WISCCRS API) | No public bulk |
| Noncompliance Statement / Correction Plan | PDF (rendered from WISCCRS template) | Per-visit |
| LCC Directory (bulk facilities) | Excel (.xlsx, daily refresh) at https://dcf.wisconsin.gov/files/ccdir/lic/excel/LCC%20Directory.xlsx | Yes — facilities only; no violations |
| Per-county LCC directories | Excel (72 county files) | Yes — facilities only |
| ArcGIS Feature Service (DHS GIS) | REST JSON / GeoJSON | Yes — facilities only; no violations |
| Illegal/Revoked list | HTML table | Yes — names + dates |
| Critical Incident reports (CPS) | HTML summaries | Per-incident |

**No bulk CSV of per-facility violations is published.** However, the `childcarefinder` Angular UI calls a public JSON API at `https://childcarefinder.wisconsin.gov/api/` (no auth token observed), which is the most efficient violation-harvesting path.

## Freshness

- childcarefinder: live from WISCCRS; "most recent Noncompliance Statement is posted immediately following an on-site visit" (per DCF docs). Correction Plan posted as soon as received from licensee.
- Retention on public view: **3-year rolling window** (older violations move to WISCCRS internal archive).
- LCC Directory Excel: daily refresh; header stamp "Last Refreshed Date" confirms.
- Serious Violations list (the policy document): updated when rules change.

## Key Fields Exposed Per Provider

- Provider number, facility name, facility type (Licensed Group / Licensed Family / School-Based / Day Camp / Certified)
- Address, county, phone, contact name
- Capacity, age range, hours, full-time/part-time
- Licensed date, current status (Regular / Provisional / Probationary / Revoked / Continuous)
- **YoungStar rating (1–5 stars)**
- **Each inspection/monitoring visit** — date, type, staff
- **Violation citations** — DCF 250.xx / 251.xx administrative rule number, narrative
- **Correction Plan** — licensee's response, target date
- **Enforcement actions** — warnings, conditions, probation, suspension, revocation
- **Complaint results**
- Critical incidents (if any substantiated)

## Scraping / Access Strategy

1. **Facility universe:** Download `LCC Directory.xlsx` (daily-refreshed, ~4,242 providers) as the master list. Already done — see `SOURCES.md`.
2. **Violation enrichment:** childcarefinder.wisconsin.gov loads per-provider detail via an XHR pattern like:
   - `GET https://childcarefinder.wisconsin.gov/api/provider/<providerNumber>` (returns JSON with sub-arrays `inspections`, `violations`, `enforcementActions`, `youngStar`, `complaints`)
   - Endpoint was returning 502 at time of this research (Child Care Finder error banner observed via WebFetch); expect intermittent outages. Retry with backoff.
3. **Alternative XHR:** `/api/providers/search?county=<n>&status=OPEN` for bulk listing; pagination by skip/take.
4. **Rate:** No explicit limit. ~2 req/sec safe; wrap with retries.
5. **Noncompliance PDFs:** Linked from each detail JSON as `reportUrl`. Direct GET works.
6. **Illegal/Revoked:** Scrape the HTML table at `/ccregulation/illegal-revoked` directly; ~150–300 names at any given time.
7. **Critical incidents:** `/cps/incidents` renders a paginated list of redacted narratives; scrape HTML.

## Known Datasets / Public Records & Journalism

- **Milwaukee Journal Sentinel — "Cashing In On Kids" (2009, Pulitzer Prize):** landmark investigation that exposed Wisconsin Shares subsidy fraud and ghost-enrollment by providers. Triggered the 2010–2011 reforms (expanded background checks, DCF fraud unit, WISCCRS audit system). Archive at MJS (paywalled) and public discussion at Shepherd Express — https://shepherdexpress.com/news/features/wisconsin-day-care-centers-fraud-honest-mistakes/
- **Wisconsin Examiner (Jan 2026):** "Wisconsin Children and Families secretary says he's confident in child care accountability measures" — https://wisconsinexaminer.com/2026/01/15/wisconsin-children-and-families-secretary-says-hes-confident-in-child-care-accountability-measures/
- **Wisconsin Public Radio:** ongoing coverage of CCDBG freeze impact — https://www.wpr.org/news/minnesota-child-care-fraud-allegations-wisconsin-shares
- **FOX 11:** https://fox11online.com/news/state/wisconsin-officials-highlight-measures-to-prevent-child-care-fraud-amid-minnesota-scandal-department-children-families-integrity-welfare-subsidies-jeff-pertl-milwaukee-journal-sentinel-restrictions
- **Wisconsin State Law Library topic guide:** https://wilawlibrary.gov/topics/familylaw/childdaycare.php

## FOIA / Public Records Path

- **Wisconsin Public Records Law (Wis. Stat. §§ 19.31–19.39)**
- **DCF Records Custodian:** DCF Open Records, 201 E. Washington Ave, Madison WI 53707
- **Email:** DCFOpenRecords@wisconsin.gov
- **Fees:** Up to $0.25/page for copies; staff time only when "necessary" and at actual cost
- **Response:** "As soon as practicable and without delay" — typically 10 business days
- **Expected records:** WISCCRS violation/enforcement extract by date range (Excel); investigator case files; subsidy fraud referrals. Wisconsin has a strong open-records culture and DCF routinely produces bulk extracts to academic researchers and media under WPRL.

## Sources

- https://childcarefinder.wisconsin.gov/
- https://dcf.wisconsin.gov/ccregulation
- https://dcf.wisconsin.gov/ccregulation/faq
- https://dcf.wisconsin.gov/ccregulation/providers/most-freq-cited
- https://dcf.wisconsin.gov/cclicensing/seriousviolations
- https://dcf.wisconsin.gov/ccregulation/illegal-revoked
- https://dcf.wisconsin.gov/cps/incidents
- https://dcf.wisconsin.gov/childcare/data
- https://dcf.wisconsin.gov/files/ccdir/lic/excel/LCC%20Directory.xlsx
- https://data.dhsgis.wi.gov/datasets/wisconsin-licensed-and-certified-childcare/about
- https://dcf.wisconsin.gov/manuals/cclicensing-manual/Monitoring/Monitoring-Noncompliance_Statement_Correction_Plan/9-licensee-correction-plan.htm
- https://shepherdexpress.com/news/features/wisconsin-day-care-centers-fraud-honest-mistakes/
- https://wisconsinexaminer.com/2026/01/15/wisconsin-children-and-families-secretary-says-hes-confident-in-child-care-accountability-measures/
- https://licensingregulations.acf.hhs.gov/licensing/contact/wisconsin-department-children-and-families
