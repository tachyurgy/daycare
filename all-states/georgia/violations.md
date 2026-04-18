# Georgia — Violations / Inspections / Enforcement Research

_Updated 2026-04-18. Covers Georgia DECAL (Bright from the Start) per-facility compliance, enforcement, and inspection data._

## Violations / Inspection Data Source
Georgia DECAL surfaces enforcement data via a parent-facing "Compliance at a Glance" dashboard on families.decal.ga.gov and a separate DECAL-branded Enforcement Actions tracker on decal.ga.gov. The agency publishes everything from citations to revocations.

- **Provider search (per-facility compliance & inspections):** https://families.decal.ga.gov/ChildCare/Search
- **Compliance at a Glance FAQ:** https://families.decal.ga.gov/Provider/ComplianceFAQ.aspx
- **Provider Data Export (bulk CSV):** https://families.decal.ga.gov/Provider/Data
- **Enforcement Actions landing:** https://www.decal.ga.gov/EnforcementActions/Default.aspx
- **Enforcement Fines / Restricted Licenses listing (`type=3`):** https://www.decal.ga.gov/EnforcementActions/EnforcementList.aspx?type=3
- **Data Dictionary:** https://www.decal.ga.gov/Documents/Attachments/DataExportDataDictionary.pdf

## Data Format
- **Provider Data Export (`/Provider/Data`):** ASP.NET form. Check program-type boxes (9 types), optional county/zip filter, Export button returns UTF-16 CSV `ProviderData_*.csv`. ~7,914 rows (existing georgia_leads.csv).
- **Enforcement Actions list (`EnforcementList.aspx?type=3`):** HTML table with **"Save results to File" button → CSV export** confirmed via crawl. Columns: Provider Name, License #, Initial Adverse Action, Final Adverse Action, Date Issued, Status, County, Zip.
- **Enforcement `type` query param** encodes the action class:
  - `type=1` Denials
  - `type=2` Revocations / Refusals to Renew
  - `type=3` Fines / Restricted Licenses
  - (additional types are reachable from the Default.aspx landing page)
- **Per-facility monitoring reports:** rendered as PDFs linked from each provider's detail page. Pattern: DECAL produces a "Visit Report" PDF for every inspection and attaches it to the provider record.
- **Inspection types** (per DECAL CCS-1700):
  - **Licensing Study** — annual full rule-by-rule inspection
  - **Monitoring Visit** — annual partial (core-rule) inspection
  - **Complaint / Incident Investigation** — reactive

## Freshness
- **Provider Data Export:** refreshed nightly per DECAL.
- **Enforcement Action list:** updated as actions are published — typical lag 30-60 days from initial adverse action to posting.
- **Compliance at a Glance:** rolling 12-month window.
- **Per-facility visit report PDFs:** posted within 14 days of visit closure.

## Key Fields
### Provider Data Export CSV
- Location, City, State, Phone, Email, Program Type, Capacity by age band, Hours of Operation, **Quality Rated** star rating, CAPS subsidy participation, accreditations, license # — no violations column in this CSV.

### Per-facility compliance (scraped from HTML / PDF)
- Visit Type (Licensing Study / Monitoring Visit / Complaint / Incident)
- Visit Date
- Rule citation (e.g., `591-1-1-.13(2)(a)`)
- Compliance (Y/N)
- Description of violation
- Corrective Action required
- Corrected (Y/N)
- Repeat violation flag

### Enforcement list CSV (type=3)
- Provider Name, License #, Initial Adverse Action date, Final Adverse Action date, Date Issued, Status, County, Zip, link to the Adverse Action letter (PDF).

## Scraping / Access Strategy
### Provider Data Export — done
Existing `georgia_leads.csv` came from this. UTF-16 → UTF-8 conversion required.

### Enforcement list CSV — trivial
1. GET `https://www.decal.ga.gov/EnforcementActions/EnforcementList.aspx?type=3` (carry cookies).
2. POST with `__VIEWSTATE`, `__EVENTTARGET=btnExport` → CSV.
3. Repeat for `type=1`, `type=2`, `type=4` etc. to cover all adverse actions.

### Compliance at a Glance per facility
1. From the Provider Data Export CSV, read each Facility ID.
2. Follow pattern: `https://families.decal.ga.gov/ChildCare/Details/{FacilityId}` (ASP.NET; cookies needed).
3. Scrape the "More Details" section → 12-month monitoring history.
4. For each visit, the PDF Visit Report link follows: `https://families.decal.ga.gov/Provider/PrintVisitReport.aspx?VisitID={id}` (observed).

### Hot-leads query
- **Enforcement CSVs** (union of type 1-4): any facility appearing in the last 90 days = intent signal.
- **Compliance zone = "Deficient" or "Support"** on the Compliance at a Glance dashboard = strong intent signal (meaning the 12-month violation count exceeds thresholds).
- Cross-reference by License # against the Provider Data Export for contact info.

## Known Datasets / Public Records
- **families.decal.ga.gov/Provider/Data** — official Provider Data Export (used).
- **DECAL Enforcement Actions** — official adverse-actions tracker (used).
- **Quality Rated** star-rating dataset: https://families.decal.ga.gov/ChildCare/Search — star ratings are surfaced in the Provider Data Export.
- **Georgia Open Data portal:** no dedicated child-care violations dataset (DECAL publishes on its own site).
- **Journalism:** WABE, AJC, and Georgia News Lab periodically publish analyses using the DECAL enforcement list; no structured dataset.

## FOIA / Open-records Path
- **Statute:** Georgia Open Records Act, O.C.G.A. §§ 50-18-70 et seq.
- **DECAL Open Records:** open-records requests to `decal.openrecords@decal.ga.gov` or via fax per https://www.decal.ga.gov/AboutUs/OpenRecordsRequest.aspx
- **3-business-day response window (per statute).**
- **Useful for:** un-redacted complaint investigation files, internal corrective-action plans, deficiency statements (DECAL Form CCS-1800), subsidy-participation detail beyond the public CAPS flag, the full back-catalog of visit-report PDFs.

## Sources
- DECAL Provider Search: https://families.decal.ga.gov/ChildCare/Search
- Compliance at a Glance FAQ: https://families.decal.ga.gov/Provider/ComplianceFAQ.aspx
- Provider Data Export: https://families.decal.ga.gov/Provider/Data
- Data Dictionary: https://www.decal.ga.gov/Documents/Attachments/DataExportDataDictionary.pdf
- DECAL Enforcement Actions landing: https://www.decal.ga.gov/EnforcementActions/Default.aspx
- Enforcement Fines/Restricted Licenses (type=3): https://www.decal.ga.gov/EnforcementActions/EnforcementList.aspx?type=3
- DECAL CCS-1700 Licensing Studies Policy: https://www.decal.ga.gov/documents/attachments/CCS-1700LicensingStudiesPolicy.pdf
- CCLC Rules (591-1-1): https://www.decal.ga.gov/documents/attachments/CCLCRulesandRegulations.pdf
- DECAL ReportFraud FAQ: https://www.decal.ga.gov/ReportFraud/FAQ.aspx
- DECAL / Bright from the Start home: https://www.decal.ga.gov/
- Quality Rated: https://www.decal.ga.gov/QualityRated/
- Rules portal (GA Secretary of State): https://rules.sos.state.ga.us/gac/591-1-1
