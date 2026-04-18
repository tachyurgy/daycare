# Missouri — Violations & Inspection Data

**Date collected:** 2026-04-18

## Violations / Inspection Data Source (URLs)

- **Primary (per-facility):** https://healthapps.dhss.mo.gov/childcaresearch/ — **Show Me Child Care Provider Search**. The site moved from DHSS to DESE's oversight in 2021 but the underlying ASP.NET app remained on DHSS infrastructure. Exposes inspection history, substantiated complaint summaries, and compliance history.
- **DESE Child Care landing:** https://dese.mo.gov/childhood/child-care
- **DESE "Inspection Process" explainer:** https://dese.mo.gov/childhood/child-care/inspection-process — describes the annual unannounced visit, fire/sanitation/health inspections, and complaint-investigation workflow
- **DESE Compliance & Regulation Data Dashboard (quarterly):** https://dese.mo.gov/childhood/child-care/child-care-data-dashboards — PDF only. Most recent: "2024 Q4 Child Care Compliance and Regulation Dashboard" at https://dese.mo.gov/media/pdf/2024-q4-child-care-compliance-and-regulation-dashboard. Aggregate: facility counts, slots, pending, inspection volume, time-to-license.
- **Child Care Licensing Indicator System (CCLIS) — 2026 rollout:** https://dese.mo.gov/childhood/child-care-licensing-indicator-system — new pilot-to-statewide abbreviated-inspection model scheduled for statewide implementation by June 2026. Will change data fields and cadence.
- **Complaint filing:** https://dese.mo.gov/childhood/child-care/concerns

## Data Format

| Channel | Format | Bulk? |
|---|---|---|
| Show Me Provider Search | ASP.NET Web Forms; per-facility HTML; inspection findings rendered as a grid with PDF links | No bulk |
| Inspection report | PDF attachment per visit | Per-inspection |
| DESE quarterly dashboard | PDF | Aggregate only |
| DESE Child Care Data System | Salesforce-backed, auth-required (subsidy provider portal) | No public export |

**No official bulk CSV/Excel/Socrata dataset exists** for Missouri licensed child care or violations. `data.mo.gov` does not publish a licensed-provider dataset (confirmed via Socrata federated catalog). DESE's consumer-facing redirect from `dese.mo.gov/childhood/child-care/find-care` lands on the DHSS legacy search portal.

## Freshness

- Show Me Provider Search: updated in near-real-time as SCCR (Section for Child Care Regulation) inspectors upload reports.
- Quarterly dashboards: posted ~45 days after quarter close.
- Inspection cadence: federal CCDBG requires at least one unannounced monitoring visit/year; MO also runs annual fire + sanitation + health inspections via coordinated partner agencies.

## Key Fields Exposed Per Provider

- License number, legal name, license type (Licensed Child Care Center / Group Home / Family Home / License-Exempt)
- Status (Active / Provisional / Probation / Suspended / Revoked / Closed)
- Capacity, age groups, hours
- **Inspection history** — date, type (Annual / Complaint / Follow-up / Initial)
- **Rule violations** — cited 5 CSR 25-500.xxx section (pre-2022 citations still reference 19 CSR 30-62 in older records)
- **Substantiated complaint conclusion summaries**
- **Corrective Action Plan** — required corrections and deadlines
- **Enforcement actions** — probation, suspension, revocation (on record)
- Contact phone

## Scraping / Access Strategy

1. **App quirk:** Show Me Provider Search is a classic ASP.NET Web Forms app with heavy `__VIEWSTATE` and `__EVENTVALIDATION` dependency. Automated POSTs return HTTP 500 unless a user session (anti-forgery cookies + viewstate from a prior GET) is established. Documented failure path in `SOURCES.md`.
2. **Recommended pipeline:**
   - Drive the search page with Playwright/Puppeteer in headless mode; perform the search form submit (county dropdown, then city/ZIP filter); harvest the results grid XHR.
   - Each result row links to `/childcaresearch/ProviderDetail.aspx?providerNum=<id>`.
   - The detail page includes an "Inspection Reports" tab that AJAX-loads rows. Each row's "View Report" link downloads a PDF at `/childcaresearch/InspectionReport.aspx?inspId=<id>`.
3. **Rate:** Recommend ~0.5 req/sec. Persistent session cookie required; rotating IPs may trigger viewstate invalidation.
4. **Complaints:** Substantiated complaint summaries are inlined on the detail page (not separate PDFs).
5. **Alternative path (fallback):** DESE directly publishes NO bulk violation data. `mochildcareaware.org/data-and-reports/` accepts custom data requests; aggregate county reports are PDF-only.

## Known Datasets / Public Records & Journalism

- **Missouri Child Care Aware — "Understanding Child Care Licensing Reports"** (2024 update): https://mochildcareaware.org/wp-content/uploads/2024/09/Understanding-Child-Care-Licensing-Reports-9.26.24.pdf — translates 5 CSR 25-500 citations for parents
- **Child Care Licensing Indicator System (CCLIS)** overview: https://dese.mo.gov/childhood/child-care-licensing-indicator-system — watch for schema changes in 2026
- **Finney Injury Law** article on safety regulations: https://www.finneyinjurylaw.com/library/daycare-safety-regulations-childcare-injury.cfm — plaintiff's bar attention signal
- **Jett Legal blog** on MO licensing: https://jettlegal.com/blog/missouri-daycare-licensing-requirements/
- **Historical context:** When licensing moved from DHSS to DESE in 2021 (SB 710 consolidation), "serious deficiency" tracking terminology was revised; pre-2022 enforcement action records are retained but cited under 19 CSR 30-62 in legacy PDFs.
- **St. Louis Post-Dispatch** has covered specific daycare incidents but no long-running investigative series on MO compliance data integrity.

## FOIA / Public Records Path

- **Missouri Sunshine Law (RSMo §§ 610.010–610.035)**
- **DESE Office of Childhood:** Childcare@dese.mo.gov, 573-751-2450
- **Request portal:** https://dese.mo.gov/sunshine-law-requests
- **Response:** No later than 3 business days to acknowledge; "as soon as possible" to produce
- **Fees:** Research/redaction at average clerical hourly wage; copy at $0.10/page
- **Expected records:** Statewide violation extract (CSR citation, date, facility, outcome) by date range; the 2021 DHSS → DESE migration retained records. Pre-2021 DHSS records may require a cross-agency request citing M.O.U. transition.

## Sources

- https://healthapps.dhss.mo.gov/childcaresearch/
- https://dese.mo.gov/childhood/child-care
- https://dese.mo.gov/childhood/child-care/find-care
- https://dese.mo.gov/childhood/child-care/inspection-process
- https://dese.mo.gov/childhood/child-care/concerns
- https://dese.mo.gov/childhood/child-care/child-care-data-dashboards
- https://dese.mo.gov/media/pdf/2024-q4-child-care-compliance-and-regulation-dashboard
- https://dese.mo.gov/childhood/child-care-licensing-indicator-system
- https://dese.mo.gov/sunshine-law-requests
- https://mochildcareaware.org/wp-content/uploads/2024/09/Understanding-Child-Care-Licensing-Reports-9.26.24.pdf
- https://licensingregulations.acf.hhs.gov/licensing/contact/missouri-department-elementary-and-secondary-education-office-childhood
