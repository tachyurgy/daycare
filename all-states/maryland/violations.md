# Maryland — Violations & Inspection Data

**Date collected:** 2026-04-18

## Violations / Inspection Data Source (URLs)

- **Primary (per-facility):** https://www.checkccmd.org/ — MSDE/OCC-operated **CheckCCMD** database. Mandated public publication of inspection results since January 2011. Exposes license status, verified complaints, annual inspection reports, and full violation histories.
- **Search tool:** https://www.checkccmd.org/SearchResults.aspx (form POST; querystring params `fn=<name>`, `ft=<facilityType>`, `cnty=<county>`, `st=<status>`)
- **Bulk "Open Provider Report":** https://www.checkccmd.org/PublicReports/OpenProviderReport.aspx?ft=ALL — dynamically generated PDF listing all open providers (centers + homes + large homes + LOC). Used as the primary bulk source in `SOURCES.md` (~11,165 blocks, ~3,579 currently open).
- **Additional public reports:** https://www.checkccmd.org/PublicReports/ — PDFs such as "Providers Serving Special Needs," "Accredited Providers," "Providers Offering Evening/Weekend Care."
- **MSDE Division of Early Childhood data hub:** https://earlychildhood.marylandpublicschools.org/data — aggregate program counts, subsidy utilization.

## Data Format

| Channel | Format | Bulk? |
|---|---|---|
| CheckCCMD search (per-facility) | HTML detail pages; inline "Inspection Findings" grid and "Complaints" grid | No — one provider at a time |
| Individual inspection report | PDF attachment per visit (OCC inspection form output) | Per-inspection |
| Open Provider Report | PDF (no CSV/Excel export) | Yes — providers, but NOT violations |
| MSDE DEC data page | PDFs + aggregate tables | Aggregate |

**No API, Socrata feed, or bulk CSV/Excel of CheckCCMD violation data exists.** Bulk violation collection requires scraping each provider's CheckCCMD detail page. Maryland Open Data Portal (`opendata.maryland.gov`) does NOT publish a licensed child care facilities dataset.

## Freshness

- CheckCCMD: Inspection reports posted after licensing specialist finalizes report; typically **within 30 days of visit**.
- Verified complaints: posted within the same window.
- Open Provider Report PDF: regenerated daily from the live OCC database (confirmed via page timestamp on regeneration).

## Key Fields Exposed Per Provider

- License/Registration number (OCC ID), legal name, regional office
- Facility type (Child Care Center / Family Child Care Home / Large FCCH / Letter of Compliance)
- License status (Open / Pending / Revocation / Closed / Suspended / Revoked)
- Capacity, age groups, accreditation, Maryland EXCELS level
- **Inspection visits** — date, type (Annual / Complaint / Follow-up / Monitoring), inspector region
- **Areas of non-compliance** — cited COMAR regulation (13A.16.xx / 13A.15.xx), narrative
- **Corrected?** — yes/no/date for each finding
- **Complaint outcome** — Substantiated / Unsubstantiated / Unable to Verify, summary narrative
- Contact email (published), director name

## Scraping / Access Strategy

1. **Provider enumeration:** Parse the CheckCCMD Open Provider Report PDF (as done in `SOURCES.md`) or scrape `SearchResults.aspx` per county × facility type combination with ASP.NET `__VIEWSTATE` POST discipline.
2. **Per-facility URL:** `https://www.checkccmd.org/ProviderInformation.aspx?ProvNum=<OCC_license_number>` — renders name, address, status, and three collapsible panels: Inspections, Complaints, License Actions.
3. **Inspection PDFs:** Each inspection row exposes a "View Inspection Report" link resolving to `https://www.checkccmd.org/PublicReports/InspectionReport.aspx?InspId=<guid>` (PDF-rendered). Direct GET works once `ProvNum` session is warmed; without session, the server returns a generic "missing parameter" page.
4. **Rate & bot behavior:** ASP.NET Web Forms; no explicit rate limit observed. Suggested throttle ~1 req/sec. No CAPTCHA; viewstate tokens rotate per session.
5. **Email harvesting:** CheckCCMD publishes provider email on the detail page (confirmed in `SOURCES.md` — ~1,000 open-provider emails already captured). Phone is NOT published in CheckCCMD reports; combine with Maryland SDAT business registry or Maryland EXCELS roster for phones.

## Known Datasets / Public Records & Journalism

- **Maryland Comptroller report (Dec 2024):** "State of the Economy Series: Child Care and the Economy" — https://www.marylandcomptroller.gov/content/dam/mdcomp/md/reports/research/childcare.pdf — aggregates facility counts, closures, economic impact.
- **Maryland Family Network LOCATE service:** https://marylandchild.org/care/ — refers parents and consolidates provider quality indicators.
- **Washington Post / Baltimore Sun** spot coverage of specific closures and enforcement actions, typically in response to injuries; no recent long-running investigative series.
- **CheckCCMD is itself a legislative response** to the 2010–2011 push for transparency following high-profile incidents; statutory basis is COMAR 13A.16.01 and MD Educ. Art. § 9.5-401 et seq.

## FOIA / Public Records Path

- **Maryland Public Information Act (PIA), GP § 4-101 et seq.**
- **MSDE PIA portal:** https://marylandpublicschools.org/programs/pages/superintendent/communications/pia/index.aspx
- **MSDE Public Records Center** (online submission recommended)
- **Fees:** First 2 hours free; reasonable cost per hour thereafter (MSDE rate ~$60/hr); copy costs $0.25/page.
- **Response:** 30 days standard; extensions permitted.
- **Expected records:** Full CheckCCMD backing tables (Inspections, Findings, Complaints, Enforcement Actions, License Actions) by date range as Excel export; MSDE has fulfilled similar requests for academic researchers. Also regional-office enforcement letters and inspector narratives.

## Sources

- https://www.checkccmd.org/
- https://www.checkccmd.org/SearchResults.aspx
- https://www.checkccmd.org/PublicReports/OpenProviderReport.aspx?ft=ALL
- https://earlychildhood.marylandpublicschools.org/child-care-providers/licensing
- https://earlychildhood.marylandpublicschools.org/data
- https://earlychildhood.marylandpublicschools.org/system/files/filedepot/3/center_inspection_report.pdf
- https://marylandchild.org/care/
- https://marylandpublicschools.org/programs/pages/superintendent/communications/pia/index.aspx
- https://www.marylandcomptroller.gov/content/dam/mdcomp/md/reports/research/childcare.pdf
- https://dhs.maryland.gov/licensing-and-monitoring/
- https://licensingregulations.acf.hhs.gov/licensing/contact/maryland-state-department-education-division-early-childhood-office-child-care
