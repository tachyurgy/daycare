# Indiana — Violations & Inspection Data

**Date collected:** 2026-04-18

## Violations / Inspection Data Source (URLs)

- **Primary (consumer-facing):** https://secure.in.gov/apps/fssa/providersearch/home/category/ch — FSSA Child Care Finder search. Each provider page exposes inspection history, monitoring reports, and a red "Critical Health and Safety Violation" flag when applicable.
- **Program overview:** https://www.in.gov/fssa/childcarefinder/ — consumer landing
- **Critical violations explainer:** https://www.in.gov/fssa/carefinder/critical-health-and-safety-violations-qa/ — defines the "red notification" categorization used in the search results
- **Bulk provider listings (PDF):**
  - Licensed Centers: https://www.in.gov/fssa/carefinder/files/Indiana_Licensed_Child_Care_Center_Listing.pdf
  - Licensed Homes: https://secure.in.gov/fssa/carefinder/files/Indiana_Licensed_Child_Care_Home_Listing.pdf (addresses redacted by IC 12-17.2-2-1(9))
  - Registered Child Care Ministries: separate PDF
- **FSSA OIG:** https://www.in.gov/fssa/ompp/ompp-program-integrity/ and https://www.in.gov/oig/ — program-integrity / fraud referrals; does not publish facility-level compliance data for child care but is the path for fraud-related referrals

## Data Format

| Channel | Format | Bulk? |
|---|---|---|
| providersearch (INconnect) | Dynamic ASP.NET / Angular HTML; per-provider inspection detail pages | No |
| Inspection reports on provider pages | PDF attachments | Per-provider |
| Listings (Centers / Homes / Ministries) | PDF | Yes — names/capacity only, no violations |
| Critical Health & Safety Violation flag | Red badge rendered on provider page | Per-provider |

**No CSV/Socrata/ArcGIS feed exists** for Indiana child care. The state publishes PDFs for bulk lists and renders inspection data only on a per-provider basis. FSSA confirmed (per federal CCDBG reporting) that roughly 28,000 monitoring inspections and ~3,000 complaint investigations are completed statewide each year — none of which are published as a bulk structured dataset.

## Freshness

- providersearch inspection pages: updated in near-real-time after a licensing consultant finalizes a monitoring report
- Critical violation red flag: shown until the noncompliance is corrected and FSSA verifies
- PDF listings: refreshed quarterly (Center PDF run date: Jul 25, 2025)

## Key Fields Exposed Per Provider

- License number, legal name, program type (Licensed Center / Licensed Home Class I / II / Registered Ministry / License-Exempt)
- Address (redacted for licensed Homes by statute), phone
- PTQ (Paths to QUALITY) level 1–4
- Licensed capacity, ages served, hours
- **Inspection history** — date, type (Initial / Annual Monitoring / Complaint / Follow-up), inspector
- **Rule violation citations** — references to 470 IAC 3-4.7 (centers) or 3-1.1 (homes) sections
- **Critical Health & Safety Violation** red flag with category
- Correction plan / compliance status per finding

## Scraping / Access Strategy

1. **Provider ID enumeration:** Scrape the center listing PDF (already done — see `SOURCES.md`) or the search endpoint `https://secure.in.gov/apps/fssa/providersearch/` with county filter POST to build a master list of facility numbers.
2. **Detail page retrieval:** URL pattern observed: `https://secure.in.gov/apps/fssa/providersearch/details/<facilityId>` renders a page with "Inspection Information" link. Clicking loads a sub-view with inspection records; each row includes a PDF download URL of the form `/apps/fssa/providersearch/files/<reportId>.pdf`.
3. **Anti-bot:** The INconnect platform enforces server-side session validation (ASP.NET `__VIEWSTATE` + `__EVENTVALIDATION` POST tokens). A persistent session cookie is required; bare HTTP GETs to detail URLs return empty shells. Use a headless browser (Playwright recommended) to warm the session, then harvest XHR responses.
4. **Rate:** No published limits; empirically ~2 req/sec is safe. No CAPTCHAs observed.
5. **Home providers:** Per IC 12-17.2-2-1(9), street addresses are redacted in listings and on providersearch; inspection findings ARE visible but the location is generalized to city/county.

## Known Datasets / Public Records & Journalism

- **"Our Everyday Life" walkthrough** (evergreen how-to for parents): https://oureverydaylife.com/daycare-inspection-reports-indiana-8322560.html — confirms current user flow for inspection reports
- **WFYI / Brighter Futures Indiana** (consumer guidance): https://brighterfuturesindiana.org/quality-care
- **Childcare.gov state resources:** https://childcare.gov/state-resources/indiana
- No long-running Indianapolis Star / IndyStar investigative series on child care compliance comparable to the MJS Wisconsin Shares series — smaller investigative coverage is typically event-driven (facility closure, injury)

## FOIA / Public Records Path

- **APRA (Indiana Access to Public Records Act, IC 5-14-3):** request to FSSA's public records office
- **FSSA public records:** https://www.in.gov/fssa/5417.htm (Public Records Request)
- **Child care specific:** FSSA Office of Early Childhood and Out-of-School Learning — carefinder@fssa.in.gov; 877-511-1144
- **Fees:** Copying costs only ($0.10/page or reasonable cost for electronic reproduction). No hourly research fee unless redaction exceeds 2 hours.
- **Response:** 7 calendar days to acknowledge; "reasonable time" to produce. Deny/redact citations required.
- **Expected usable records:** statewide inspection-finding extract (Excel), critical-violation registry, substantiated-complaint summaries. These are routinely released to researchers/journalists with PII redactions.

## Sources

- https://secure.in.gov/apps/fssa/providersearch/home/category/ch
- https://www.in.gov/fssa/childcarefinder/
- https://www.in.gov/fssa/carefinder/critical-health-and-safety-violations-qa/
- https://www.in.gov/fssa/carefinder/index.html
- https://www.in.gov/fssa/carefinder/files/Indiana_Licensed_Child_Care_Center_Listing.pdf
- https://secure.in.gov/fssa/carefinder/files/Indiana_Licensed_Child_Care_Home_Listing.pdf
- https://www.in.gov/fssa/5417.htm
- https://www.in.gov/oig/
- https://licensingregulations.acf.hhs.gov/licensing/contact/indiana-family-and-social-services-administration-office-early-childhood-and-out
- https://childcare.gov/state-resources/indiana
