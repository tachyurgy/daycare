# North Carolina — Leads CSV Source Attribution

## CSV Source
- **File:** `/Users/magnusfremont/Desktop/daycare/north_carolina_leads.csv`
- **Primary URL(s):** https://childcarecenter.us/county/{county}_nc (89 NC county pages, one per county)
- **Secondary URL (authoritative regulator, not used for extraction):** https://ncchildcare.ncdhhs.gov/childcaresearch (NC DCDEE Child Care Facility Search — Telerik RadGrid UI; not scrape-friendly without headless browser)
- **Reference:** NC DCDEE monthly **Child Care Statistical Detail Report** (813-page PDF, January 2026) at https://ncchildcare.ncdhhs.gov/Portals/0/documents/pdf/S/statistical_detail_report_january_2026.pdf — used for provider counts / cross-verification only; the PDF does NOT contain phone numbers or street addresses
- **Publisher of aggregated leads:** childcarecenter.us (commercial third-party aggregator compiling public NC DCDEE data)
- **Source format:** HTML county listing pages scraped for provider names, cities, and phone numbers

## Row Count
- **Rows written to CSV:** **1,152** North Carolina licensed child care centers (deduplicated by name + city)
- **Rows with phone number:** 1,151 (99.9%)

## Columns Captured
`business_name,city,state,phone,email,website`
- Source fields mapped:
  - business_name ← provider name heading (`<h3>`)
  - city ← city shown in the provider card
  - state ← "NC"
  - phone ← phone number shown after city/zip
  - email — blank (not listed on aggregator cards)
  - website — blank (not listed on aggregator cards)

## Limitations
- **NC DCDEE's authoritative dataset is not bulk-downloadable.** The official Child Care Facility Search (`https://ncchildcare.ncdhhs.gov/childcaresearch`) uses a Telerik / DotNetNuke ASP.NET form with encrypted ViewState and client-side RadComboBox components that require a headless browser (Playwright/Selenium) — not achievable within the scraping toolchain available for this run.
- **The DCDEE monthly Statistical Detail Report PDF** (813 pages for January 2026, ~5,000 licensed centers + homes by county) contains facility name and operation type but NO phone numbers or street addresses, so it is not suitable for outbound lead generation.
- **childcarecenter.us** aggregator shows approximately 15–20 centers per NC county page (top-featured listings), drawn from DCDEE public data. There is no pagination on the county pages, so the 1,152 rows represent the aggregator's top listings across all 89 counties rather than every NC licensed facility. NC actually has ~4,500 licensed child care facilities statewide — this CSV covers roughly 25% of them.
- Emails and websites are not present in the source.
- **Recommendation for a full NC lead list:** either (1) file a public-records request with NC DCDEE for the statewide facility list in CSV, or (2) drive the DCDEE search portal with Playwright/Selenium to capture all facilities city-by-city.

## Date Fetched
**2026-04-18**
