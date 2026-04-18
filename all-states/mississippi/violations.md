# Mississippi — Child Care Violations & Inspection Data Research

**State rank:** 34  
**Collection date:** 2026-04-18  
**Licensing authority:** Mississippi State Department of Health (MSDH) — Child Care Facilities Licensure Branch

## Violations / Inspection Data Source (URLs)

- **Child Care Facility Regulatory Violations landing page (MSDH):** https://msdh.ms.gov/page/30,0,183,707.html
- **Static mirror of the same page:** https://msdh.ms.gov/msdhsite/_static/30,0,183,707.html
- **MSDH Child Care Facility Search (per-facility inspection history + violations):** https://www.msdh.provider.webapps.ms.gov/
- **Alternate facility search URL:** https://msdh.ms.gov/page/30,332,183,438.html
- **MSDH Complaints page (complaint process + public records info):** https://msdh.ms.gov/page/30,0,183,787.html
- **MSDH Child Care Facilities Licensure program page:** https://msdh.ms.gov/page/30,0,183.html
- **Complaint intake email:** CC.ComplaintUnit@msdh.ms.gov
- **Complaint hotline:** 1-866-489-8734

## Data Format

- **Primary access:** per-facility lookup via the MSDH provider search web app (`msdh.provider.webapps.ms.gov/ccsearch.aspx`). Returns inspection history, cited violations, and monetary penalties assessed for "significant violations" for each licensed facility.
- **No bulk download** of violations is offered. The "Regulatory Violations" landing page describes the policy and data dictionary rather than exposing a downloadable list.
- **Class I violations** (most serious) carry statutory monetary penalties: **$500 first occurrence, $1,000 for subsequent occurrences** (Mississippi Admin. Code, Title 15, Part 11, Subpart 55 rules and Miss. Code Ann. §43-20-8).
- **Complaints** are logged and investigated by MSDH but are not automatically published online; records obtainable via public records request.

## Freshness

- Inspection records posted to the facility search are updated as MSDH representatives complete and upload reports (generally within days of the on-site visit).
- MSDH conducts inspections **at least twice per year** per Mississippi statute; additional unannounced inspections permitted any time.
- No published timestamp for data refresh on the public search; each record carries the inspection-date field.

## Key Fields (per facility, per inspection)

- Facility name, license number, address, city, county, zip
- Type (Center / Home ≤ 12)
- License status (Open / Closed / Suspended / Provisional)
- Inspection date
- Inspection type (routine / complaint / follow-up / renewal)
- Cited violation codes with short description (mapped to 15 Miss. Admin. Code Part 11, Subpart 55 rule section)
- Violation severity class (Class I — monetary penalty eligible; lower classes — corrective action)
- Monetary penalty amount (when assessed)
- Corrective action plan and resolution date

## Scraping / Access Strategy

1. **Enumeration:** no alphabetical or ZIP-wise list-all on the MSDH search app; queries require facility name / city / county inputs. Enumerate via the facility roster already collected in `mississippi_leads.csv` (1,414 names), then hit the search app for each name.
2. **Request pattern:** ASP.NET WebForms (ViewState + EventValidation tokens) — use Playwright or `requests-html` with session cookies; scrape the results detail page per facility.
3. **Parsing:** detail pages render each inspection as an HTML table; extract rows with `BeautifulSoup`. Field order is stable across facility pages.
4. **Rate:** conservative 1–2 req/sec with polite user-agent; no explicit rate limit published but the app is single-tenant IIS.
5. **Cross-reference:** geocoding via the MARIS shapefile already in `nebraskamap`-style format (see `SOURCES.md`) keeps lat/lon for mapping violation density by county.

## Known Datasets / Public Records

- **MARIS Licensed Child Care Facilities (2023 shapefile)** — geospatial layer (already used for leads CSV) — no violation data but has stable `ID` keying to MSDH license numbers. https://maris.mississippi.edu/HTML/DATA/data_Education/LicensedChildCareFacilities.html
- **MSDH Public Records Request Portal** — required for bulk violation / complaint pulls. Cited on the Complaints and Regulatory Violations pages.
- **Mississippi Administrative Code, Title 15, Part 11, Subpart 55, Chapter 1** — defines violation classes. https://msdh.ms.gov/msdhsite/_static/resources/78.pdf
- **Mississippi Administrative Code Chapter 9 Rule 18-17-9.2** — Child Care Facility Complaint Process. https://regulations.justia.com/states/mississippi/title-18/part-17/chapter-9/rule-18-17-9-2/

## FOIA / Open-records Path

- **Mississippi Public Records Act (Miss. Code §25-61-1 et seq.)** — MSDH is a covered public body.
- Requests routed to the **MSDH Office of Health Informatics** via the public records request form linked from msdh.ms.gov.
- Typical response window: 7 working days (statutory) with reasonable extensions.
- For violation-specific requests, cite Miss. Code Ann. §43-20-8 (child care regulatory authority) and ask for "all inspection reports and violation histories for [facility names/license #s] in [date range]" to get machine-readable exports where possible (MSDH historically ships CSV or PDF).

## Sources

- MSDH Child Care Facility Regulatory Violations — https://msdh.ms.gov/page/30,0,183,707.html
- MSDH Complaints — https://msdh.ms.gov/page/30,0,183,787.html
- MSDH Child Care Facility Search — https://www.msdh.provider.webapps.ms.gov/
- MSDH Child Care Facilities Licensure — https://msdh.ms.gov/page/30,0,183.html
- Mississippi Administrative Code Title 15 Part 11 Subpart 55 — https://msdh.ms.gov/msdhsite/_static/resources/78.pdf
- MARIS Licensed Child Care Facilities dataset — https://maris.mississippi.edu/HTML/DATA/data_Education/LicensedChildCareFacilities.html
- Mississippi Public Records Act — Miss. Code §25-61-1 et seq.
- Complaint Process rule (Justia mirror) — https://regulations.justia.com/states/mississippi/title-18/part-17/chapter-9/rule-18-17-9-2/
