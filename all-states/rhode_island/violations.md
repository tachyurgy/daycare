# Rhode Island — Violations & Inspection Data Research

**Compiled:** 2026-04-18
**State slug:** rhode_island

## Violations / Inspection Data Source (URLs)

- **Primary (consumer-facing):** RISES Family portal — https://earlylearningprograms.dhs.ri.gov/
- **DHS Child Care Provider resources:** https://dhs.ri.gov/programs-and-services/child-care/child-care-providers
- **DHS Regulations hub:** https://dhs.ri.gov/regulations
- **Child Care Licensing Regulation Guidance (DHS, PDF):** https://dhs.ri.gov/media/4571/download?language=en
- **DCYF Licensing (for enforcement referrals):** https://dcyf.ri.gov/services/licensing
- **RI Auditor General — 2025 Child Care Audit:** covered by Rhode Island Current and WPRI (see Sources).
- **Statutory open-records basis:** R.I. Gen. Laws §38-2 — Access to Public Records Act (APRA).

## Data Format

- **Bulk export:** None published. No CSV, JSON, or Socrata feed for providers, inspections, or enforcement actions.
- **Consumer portal backend:** RISES Family portal is a **Salesforce Experience Cloud / Lightning Web Components (LWC)** community served from `ridhsrises.my.salesforce.com`. DOM is populated client-side by Aura framework; a curl fetch returns only bootstrap scripts. Data requires an authenticated Salesforce session.
- **What the portal exposes per-facility:** license status, BrightStars QRIS star rating (0-5), ages served, capacity, CCAP acceptance, hours. Inspection-report PDFs and deficiencies are surfaced per-provider under a "Licensing Details" or "Inspection Reports" section (accessible only through the portal UI).
- **DCYF enforcement referrals:** unlicensed-operator prosecutions flow from DCYF's Child Care Licensing Unit to the RI Attorney General; no public dataset of prosecutions.

## Freshness

- Inspection reports appear on RISES within days of posting by DHS licensing.
- Rolling window retention of "last 3 years" per CCDBG transparency rule (42 CFR §98.33(4)) is implemented (standard; not RI-specific published policy).
- Auditor General's 2025 audit used data through February 2025.

## Key Fields (per-facility on RISES)

- Provider/facility name, DBA, license number, license type
- Address, phone, email (provider-supplied)
- License status + effective dates
- BrightStars rating (1-5 stars, or "Participating")
- Age groups served, capacity
- CCAP (subsidy) participation
- "Licensing Details" — latest monitoring report, CAPs, enforcement actions
- "Two unannounced monitoring visits per year" per 218-RICR-70-00-1 (so reports accumulate at 2x the rate of most states)

## Scraping / Access Strategy

1. **Not bulk-accessible anonymously.** RISES's Salesforce LWC architecture defeats curl/requests scraping.
2. **Headless-browser scraper (Playwright/Puppeteer):**
   - Establish session with the Family portal (no login required for public info).
   - Enumerate providers by ZIP code radius search.
   - For each detail page, extract name, license #, license status, BrightStars rating, and inspection-report PDF URLs.
   - Expect Salesforce rate-limiting; throttle aggressively.
3. **Bulk via APRA request (preferred):**
   - File APRA request with DHS Office of Child Care (cite R.I. Gen. Laws §38-2) for provider roster + 3 yrs of monitoring visits + CAPs + enforcement actions.
   - RI response window: 10 business days (1 business day for the agency to acknowledge receipt).
4. **Auditor General's work product (2025):**
   - RI Auditor General's audit of 50 facilities has already surfaced aggregated data; report-level stats (60% significant noncompliance, 232 facility findings, 920 documentation findings) are in the report but per-facility findings may require APRA to obtain full enforcement record.

## Known Datasets / Public Records

- **RISES Family portal (per-facility, live):** https://earlylearningprograms.dhs.ri.gov/
- **RI AirCare Immunization Data Hub (child care pages):** https://ricair-data-rihealth.hub.arcgis.com/pages/child-care — DOH-side cross-reference for licensed programs.
- **RI Current / WPRI / Ocean State Media coverage of 2025 AG audit:**
  - https://rhodeislandcurrent.com/2025/08/15/auditor-general-paints-a-picture-of-imperfect-safety-in-r-i-child-care-facilities/
  - https://www.wpri.com/target-12/new-audit-finds-widespread-health-and-safety-issues-in-ri-day-cares/
  - https://www.oceanstatemedia.org/education/auditor-general-paints-a-picture-of-imperfect-safety-in-r-i-child-care-facilities
- **DHS plan to visit every RI child care provider (TurnTo10):** https://turnto10.com/news/local/dhs-to-visit-every-child-care-provider-in-ri

## FOIA / Open-Records Path

- **Statute:** R.I. Gen. Laws §38-2 — Access to Public Records Act (APRA).
- **Submit to:** RI DHS Public Records Officer — forms at https://dhs.ri.gov (Access to Public Records page). Cc Office of Child Care.
- **Suggested request scope:** "Pursuant to R.I. Gen. Laws §38-2-3, I request electronic copies of: (1) the current roster of licensed Child Care Centers, Family Child Care Homes, and Group Family Child Care Homes including name, address, phone, license number, license type, and BrightStars rating; (2) all monitoring inspection reports and CAPs issued between [DATE] and [DATE]; (3) all license revocations, suspensions, and conditional licenses during the same period; (4) aggregated counts of deficiencies cited by rule number. CSV/Excel preferred; PDFs acceptable."
- **Response window:** 10 business days (§38-2-3(e)); 20-business-day extension available for "good cause."
- **Fees:** $0.15/page for copies; search/retrieval hourly after the first hour.
- **Appeals:** R.I. Attorney General Office of Open Government under §38-2-8; also Superior Court.

## Sources

- RI DHS — Child Care Providers: https://dhs.ri.gov/programs-and-services/child-care/child-care-providers
- RI DHS Regulations: https://dhs.ri.gov/regulations
- Child Care Licensing Regulation Guidance (PDF): https://dhs.ri.gov/media/4571/download?language=en
- RISES Early Learning Programs portal: https://earlylearningprograms.dhs.ri.gov/
- RI DCYF Licensing: https://dcyf.ri.gov/services/licensing
- 218-RICR-70-00-1 (Center & School-Age) SOS text: https://rules.sos.ri.gov/Regulations/part/218-70-00-1
- 218-RICR-70-00-1 full PDF: https://dhs.ri.gov/sites/g/files/xkgbur426/files/2022-02/218-ricr-70-00-1-child-care-center-and-school-age-program-regulations-for-licensure.pdf
- 218-RICR-70-00-2 (FCCH): https://rules.sos.ri.gov/regulations/part/218-70-00-2
- 218-RICR-70-00-7 (Group FCCH) PDF: http://risos-apa-production-public.s3.amazonaws.com/DHS/REG_10927_20191206131704.pdf
- R.I. Gen. Laws §38-2 (APRA): http://webserver.rilegislature.gov/Statutes/TITLE38/38-2/INDEX.HTM
- R.I. Gen. Laws §42-12.5 (licensing & monitoring of child day care providers): https://law.justia.com/codes/rhode-island/2022/title-42/chapter-42-12-5/
- Rhode Island Current — AG Audit 2025: https://rhodeislandcurrent.com/2025/08/15/auditor-general-paints-a-picture-of-imperfect-safety-in-r-i-child-care-facilities/
- WPRI Target 12 — RI AG Audit: https://www.wpri.com/target-12/new-audit-finds-widespread-health-and-safety-issues-in-ri-day-cares/
- Ocean State Media: https://www.oceanstatemedia.org/education/auditor-general-paints-a-picture-of-imperfect-safety-in-r-i-child-care-facilities
- TurnTo10 — DHS to visit every provider: https://turnto10.com/news/local/dhs-to-visit-every-child-care-provider-in-ri
- BrightStars RI: https://brightstars.org/
- RI AirCare Data Hub (child care): https://ricair-data-rihealth.hub.arcgis.com/pages/child-care
- National Database (ACF — RI): https://licensingregulations.acf.hhs.gov/licensing/contact/rhode-island-department-human-services-office-child-care
