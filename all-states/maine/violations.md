# Maine — Violations & Inspection Data Research

**Compiled:** 2026-04-18
**State slug:** maine

## Violations / Inspection Data Source (URLs)

- **Primary (consumer-facing):** Maine Licensed Child Care Search — https://search.childcarechoices.me/
- **License-exempt monitoring inspection reports:** https://childcarechoices.me/index.php/license-exempt-monitoring/
- **OCFS Child Care Licensing:** https://www.maine.gov/dhhs/ocfs/provider-resources/child-care-licensing
- **Rule basis for online posting:** 10-148 CMR Ch. 32 + 42 CFR §98.33(4) (federal CCDBG transparency rule, 3-year rolling window).
- **Statutory open-records basis:** 1 M.R.S. §408-A (Freedom of Access Act — FOAA).

## Data Format

- **Bulk export:** None published. Maine does not expose a provider-level bulk CSV/JSON feed.
- **Consumer search backend:** `search.childcarechoices.me` is ASP.NET WebForms with ViewState tokens. Queries require city/ZIP/address + radius; no "list all" affordance. Inspection reports and "Step Reports" (QRIS/Rising Stars) are linked from each facility's detail page.
- **Published cadence:** Since 2015, Maine has posted inspection data online for the first time (Press Herald, 2015-01-05). Reports are retained for a rolling 3-year window per 42 CFR §98.33(4).

## Freshness

- **Inspection reports:** posted by OCFS shortly after each on-site visit; rolling 3-year retention on portal.
- **License actions:** not published as a standing list; conditional licenses are flagged on per-facility pages.
- **Key context (Maine Monitor / Bangor Daily News, 2024):** Since 2021, 1,481 facilities accrued 16,000+ citations; 64 conditional licenses have been issued; **zero licenses have been revoked**; zero fines have been assessed despite statutory authority of $50–$500 per incident. Enforcement posture is monitoring-and-correction, not punitive.

## Key Fields (per-facility on childcarechoices.me)

- Facility name, license number, license type (Child Care Center / Small CCF / Nursery School / FCCP)
- Address, phone, capacity (on many pages)
- Rising Stars for ME rating (2-5 star)
- Open slots by age group, CCAP acceptance
- **"Licensing Details / Step Report"** link → inspection report PDFs, citations, corrective action statuses
- Provider's operating hours, ages served

## Scraping / Access Strategy

1. **childcarechoices.me scraper** — feasible but requires ASP.NET ViewState handling:
   - Iterate through ZIP codes (Maine has ~400) with a large radius → deduplicate.
   - For each facility detail page, extract license number + inspection PDF URLs + Rising Stars rating.
   - Respect robots.txt; throttle at 1 req/sec.
2. **Bulk approach (preferred):** file a **FOAA request** to OCFS CLIS for a flat-file provider export + inspection report index. 1 M.R.S. §408-A requires acknowledgment within 5 business days and production within a reasonable timeframe (typically 10–20 business days for structured data).
3. **Journalism precedent:** The Maine Monitor + Center for Public Integrity (2024) reviewed 6,000+ inspection reports — they confirm the data is obtainable in bulk and machine-parseable via FOAA. Their methodology is a template.
4. **OCFS direct contact:**
   - Child Care Licensing Unit: (207) 287-9300 / (800) 791-4080
   - Children's Licensing and Investigation: (207) 287-5020
   - Mailing: 11 State House Station, Augusta, ME 04333-0011

## Known Datasets / Public Records

- **Maine Licensed Child Care Search (per-facility, last 3 yrs):** https://search.childcarechoices.me/
- **Search — LE-CCSP (license-exempt list):** https://search.childcarechoices.me/searchLECCSP.aspx
- **License-Exempt Monitoring inspection reports:** https://childcarechoices.me/index.php/license-exempt-monitoring/
- **Maine Monitor / Center for Public Integrity investigation (2024):** https://themainemonitor.org/childcare-providers-violations/
- **Bangor Daily News coverage (2024-10-14):** https://www.bangordailynews.com/2024/10/14/state/child-care-providers-maine-numerous-safety-violations/
- **Bangor Daily News (2025-10-13) — reporting failures:** https://www.bangordailynews.com/2025/10/13/state/state-health/maine-day-cares-child-abuse-neglect-reporting/
- **Press Herald (2015) — inspection data first posted online:** https://www.pressherald.com/2015/01/05/state-data-on-day-care-inspections-goes-online-for-first-time/

## FOIA / Open-Records Path

- **Statute:** 1 M.R.S. Chapter 13, Subchapter 1-A — Maine Freedom of Access Act (FOAA). Core provision: 1 M.R.S. §408-A.
- **Submit to:** Maine DHHS Public Information Officer; OCFS CLIS records custodian (contact via (207) 287-5020 or the OCFS landing page).
- **Suggested request scope:** "Pursuant to 1 M.R.S. §408-A, I request electronic copies of: (1) a roster of all currently licensed Child Care Facilities and Family Child Care Providers including name, address, phone, license type, license number, capacity, and license status; (2) all inspection reports and citations issued under 10-148 CMR Ch. 32 and Ch. 33 for the period [DATE] to [DATE]; (3) all Corrective Action Plans; (4) all conditional licenses issued since 2021. CSV/Excel preferred; PDFs acceptable."
- **Response window:** Acknowledgment within 5 business days; production within reasonable time.
- **Fees:** $15/hour search + copy costs; fee waiver available for public interest.
- **Appeals:** Superior Court under 1 M.R.S. §409.

## Sources

- Maine OCFS — Child Care Licensing: https://www.maine.gov/dhhs/ocfs/provider-resources/child-care-licensing
- Maine OCFS Landing: https://www.maine.gov/dhhs/ocfs
- Maine Licensed Child Care Search: https://search.childcarechoices.me/
- License-Exempt Monitoring reports: https://childcarechoices.me/index.php/license-exempt-monitoring/
- Reporting Child Care Concerns: https://www.maine.gov/dhhs/ocfs/support-for-families/child-care/reporting-child-care-concerns
- Consumer Education Statement (PDF): https://childcarechoices.me/wp-content/uploads/2022/05/Consumer-Education-Statement-5-22.pdf
- 10-148 CMR Ch. 32 (rule PDF): https://www.maine.gov/dhhs/sites/maine.gov.dhhs/files/inline-files/Rules-for-the-Licensing-of-Child-Care-Facilities-10-148-Ch-32.pdf
- 1 M.R.S. §408-A (FOAA): https://www.mainelegislature.org/legis/statutes/1/title1sec408-A.html
- Maine Monitor investigation: https://themainemonitor.org/childcare-providers-violations/
- Bangor Daily News (2024): https://www.bangordailynews.com/2024/10/14/state/child-care-providers-maine-numerous-safety-violations/
- Bangor Daily News (2025): https://www.bangordailynews.com/2025/10/13/state/state-health/maine-day-cares-child-abuse-neglect-reporting/
- Press Herald (2015): https://www.pressherald.com/2015/01/05/state-data-on-day-care-inspections-goes-online-for-first-time/
- National Database (ACF — ME): https://licensingregulations.acf.hhs.gov/licensing/contact/maine-department-health-and-human-services-office-child-and-family-services
