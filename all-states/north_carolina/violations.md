# North Carolina — Violations / Inspections / Enforcement Research

_Updated 2026-04-18. Covers NC DCDEE per-facility compliance history, administrative actions, and monitoring visit data._

## Violations / Inspection Data Source
North Carolina DCDEE exposes per-facility compliance history through the main child care search, but the authoritative portal is built on legacy ASP Classic and lacks bulk export, making scraping non-trivial.

- **Primary search (Telerik UI):** https://ncchildcare.ncdhhs.gov/childcaresearch
- **Per-facility Visits (legacy ASP):** https://ncchildcaresearch.dhhs.state.nc.us/Visits.asp?Facility_ID={id} — the "DCDEE Visits" tab accessed from the main search routes to this URL. Pattern is simple; the `Facility_ID` is an 7-8 digit integer.
- **Find Monitoring Reports (how-to):** https://ncchildcare.ncdhhs.gov/How-Do-I/Find-Monitoring-Reports
- **Child Care Statistical Detail monthly PDF** (all licensed facilities + star ratings, no phones): https://ncchildcare.ncdhhs.gov/Portals/0/documents/pdf/S/statistical_detail_report_january_2026.pdf
- **Data Behind the Dashboard:** https://ncchildcare.ncdhhs.gov/Home/Data/Dashboards/Data-Behind-the-Dashboard
- **Summary Statistical Report:** monthly PDFs linked off the Statistical Report page: https://ncchildcare.ncdhhs.gov/County/Child-Care-Snapshot/Child-Care-Statistical-Report

## Data Format
- **Main search (`childcaresearch`):** Telerik RadGrid / DotNetNuke ASP.NET on `ncchildcare.ncdhhs.gov`. Client-side encrypted ViewState + RadComboBox; straight `requests` is infeasible — requires **Playwright/Selenium** to drive.
- **Legacy Visits.asp:** Classic ASP HTML tables, URL pattern `Visits.asp?Facility_ID={id}`. Scrapable with `requests` + BeautifulSoup. Shows:
  - Visit Date
  - Visit Type (Announced / Unannounced)
  - Visit Reason (Renewal, Complaint, Monitoring, Special Investigation)
  - Violation flag (Yes/No)
  - Link to visit summary (sometimes PDF)
- **Per-visit detail** is typically displayed inline on Visits.asp or linked out as PDFs hosted on ncchildcare servers.
- **Statistical Report PDF:** 800+ page monthly PDF with all facilities by county — useful for facility list cross-checks but contains no violation detail.
- **No JSON/CSV API, no Socrata dataset** — NC publishes zero structured bulk data for child-care violations as of 2026-04.

## Freshness
- Visits.asp: updated as inspection reports close out; typical lag 14-30 days.
- Statistical Detail PDF: monthly, posted first week of each month.
- Administrative Actions: posted when published; revocations / summary suspensions occasionally lag 60+ days pending legal review.

## Key Fields (per-facility, from Visits.asp + linked PDFs)
- Facility Name, Facility ID, License #, Star Rating, Operator
- Visit Date
- Visit Type (announced / unannounced)
- Visit Reason (Renewal / Monitoring / Complaint / Special / Other)
- Violations (Y/N)
- Rule citation (e.g., `10A NCAC 09 .0713(a)`)
- Finding narrative
- Corrective Action
- Administrative Action taken (if any):
  - Written Warning
  - Special Provisional License
  - Summary Suspension
  - License Revocation / Denial
  - Abuse / Neglect finding
- Correction-verified date

## Scraping / Access Strategy
### Step 1 — get Facility IDs
Two paths:
- **Path A (Playwright):** drive `childcaresearch` UI page-by-page for every county; extract each row's Facility ID link. Slow (~4,500 IDs) but completes in ~1 hour headless.
- **Path B (OCR the Statistical Detail PDF):** 813 pages, but the PDF is text-layered. Extract each facility's 7-8 digit license number programmatically (pdfplumber works). This gets you the full population of IDs without browser automation.
- **Path C (aggregator fallback):** childcarecenter.us NC county pages (how existing `north_carolina_leads.csv` was generated) — covers only ~1,150 of ~4,500 facilities.

### Step 2 — pull violations
For each Facility ID:
```
curl 'https://ncchildcaresearch.dhhs.state.nc.us/Visits.asp?Facility_ID={id}'
```
Parse HTML table → rows of (visit_date, type, reason, violations_yes_no, detail_link).
Rate-limit to 1 req/sec; legacy ASP server is slow (60s timeouts observed) but responds.

### Step 3 — follow administrative action links
Administrative Actions have their own URL pattern on the legacy site; parse them for revocation / summary-suspension detail.

### Hot-leads query
- Any facility with a Visits.asp row in the last 90 days where `Violations = Yes` → intent signal.
- Any facility listed in the monthly Administrative Actions section of the Statistical Detail report → strongest intent.
- Star Rating of 1 or 2 (public data) correlates with repeat deficiencies — secondary signal.

## Known Datasets / Public Records
- **ncchildcaresearch.dhhs.state.nc.us Visits.asp:** authoritative but per-facility only.
- **ncchildcare.ncdhhs.gov/childcaresearch:** Telerik-based authoritative search, same underlying data.
- **Data Behind the Dashboard:** https://ncchildcare.ncdhhs.gov/Home/Data/Dashboards/Data-Behind-the-Dashboard — DCDEE published some downloads, but none include per-facility violation rows.
- **Statistical Detail monthly PDFs:** https://ncchildcare.ncdhhs.gov/County/Child-Care-Snapshot/Child-Care-Statistical-Report — useful for facility-list validation.
- **childcarecenter.us aggregator** (existing lead source): 89 NC county pages; top 15-20 per county.
- **Journalism:** NC Health News, WRAL and EdNC have published a-guide-to-finding-daycare-violations-style articles using the DCDEE tool (https://www.ednc.org/a-guide-to-finding-the-best-child-care-for-you-using-dhhs-look-up-tool/) but no structured datasets.
- **Early Years NC** parent guide: https://www.earlyyearsnc.org/families/child-care-quality/

## FOIA / Open-records Path
- **Statute:** N.C. Gen. Stat. § 132 (Public Records Act). NC presumption is strongly in favor of disclosure.
- **DCDEE Public Records:** email `publicinfo@dhhs.nc.gov` or call 1-919-814-6300. No statutory deadline but practical turnaround is 2-4 weeks.
- **Useful for:**
  - Full back-catalog of Administrative Actions in CSV form (DCDEE has granted this on request).
  - Un-redacted complaint files (may require a signed non-disclosure / confidentiality acknowledgment if they involve protected child information).
  - The full Facility ID list in machine-readable form — the strongest ROI for a bulk-leads approach since it bypasses the Telerik portal entirely.
  - CCHC (Child Care Health Consultant) review reports.

## Sources
- NC DCDEE home: https://ncchildcare.ncdhhs.gov/
- Child Care Facility Search (Telerik): https://ncchildcare.ncdhhs.gov/childcaresearch
- Legacy Visits.asp (per-facility visits): https://ncchildcaresearch.dhhs.state.nc.us/Visits.asp?Facility_ID=9255230
- Find Monitoring Reports how-to: https://ncchildcare.ncdhhs.gov/How-Do-I/Find-Monitoring-Reports
- Child Care Statistical Detail (January 2026): https://ncchildcare.ncdhhs.gov/Portals/0/documents/pdf/S/statistical_detail_report_january_2026.pdf
- Child Care Statistical Report landing: https://ncchildcare.ncdhhs.gov/County/Child-Care-Snapshot/Child-Care-Statistical-Report
- Data Behind the Dashboard: https://ncchildcare.ncdhhs.gov/Home/Data/Dashboards/Data-Behind-the-Dashboard
- NCABCMS background-check portal: https://ncabcms.nc.gov/DCDEE/Applicant/
- NC Child Care Rules (Chapter 9, Nov 2024): https://ncchildcare.ncdhhs.gov/Portals/0/documents/pdf/C/Chapter_9_Child_Care_Rules_effective_November_1_2024.pdf
- EdNC guide to using the DHHS look-up tool: https://www.ednc.org/a-guide-to-finding-the-best-child-care-for-you-using-dhhs-look-up-tool/
- Early Years NC: https://www.earlyyearsnc.org/families/child-care-quality/
- NC Health and Human Services Chapter 09 full rulebook (OAH): http://reports.oah.state.nc.us/ncac/title%2010a%20-%20health%20and%20human%20services/chapter%2009%20-%20child%20care%20rules/chapter%2009%20rules.pdf
- Penalty overview (NorthState Law Firm, 2025): https://www.northstatelawfirm.com/blog/penalties-for-childcare-facility-license-violations-in-north-carolina/
