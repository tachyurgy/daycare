# Connecticut — Violation / Inspection-Failure Data Sources

_Compiled 2026-04-18 for ComplianceKit. Companion to `compliance.md` and `SOURCES.md` (provider/lead sourcing)._

## Violations / Inspection Data Source

- **Primary — CT OEC Division of Licensing via the state eLicense platform.** Inspection reports, licensing actions, and complaint findings are exposed as PDF attachments hung off each licensee's eLicense record.
  - eLicense lookup: `https://www.elicense.ct.gov/Lookup/LicenseLookup.aspx`
  - Per-document viewer (deep link): `https://elicense.ct.gov/Lookup/ViewPublicLookupDocument.aspx?DocumentIdnt={INT}&GUID={GUID}` — e.g., a seven-page facility inspection viewable at `DocumentIdnt=7873363`.
  - Roster generator: `https://www.elicense.ct.gov/lookup/GenerateRoster.aspx` (allows filtered CSV-style roster export by program type for CT licensees — requires form-POST + captcha; not headless-fetchable).
- **Secondary — 211 Child Care search tool** (state-partnered, consumer-friendly wrapper of the same OEC data, with inspections + substantiated complaints for last 5 years).
  - Listing page: `https://www.211childcare.org/listings/{LISTING_ID}`
  - Inspections tab: `https://www.211childcare.org/listings/{LISTING_ID}/inspections`
- **Third-party — CT Mirror "Day Care Inspector"** — investigative nonprofit that FOIA'd fiscal-2017 inspection reports and built a searchable archive. `http://daycare.ctmirror.org/` (historical window; useful for pre-2019 context).

## Data Format

- **Per-facility, hybrid.** eLicense presents structured license-metadata rows (status, issue/expiry, discipline/actions) plus **unstructured PDF inspection reports** keyed by `DocumentIdnt`.
- 211 Child Care wraps the same feed as HTML inspection/complaint cards (inspection date, type, findings summary, corrective action closed/open).
- Annual aggregate PDFs: OEC publishes "Number of Deaths, Serious Injuries, Substantiated Child Abuse & Neglect in Child Care Settings" — one PDF per year, 2016–2025, posted at 211 Child Care resources.
- No Socrata or ArcGIS dataset; **data.ct.gov has no child-care-licensee dataset as of 2026-04-18.**

## Freshness

- eLicense is the live system of record — updated within 24–72 hours of a licensor filing.
- 211 Child Care synced nightly from OEC feeds; displays **last 5 years** of inspections + substantiated complaints.
- Annual injury/death reports posted Q1 of the following year (2025 report is live at the time of this compile).
- Background-check currency (2-yr cycle) drives many re-inspections — so records churn more often than the 4-yr license term implies.

## Key Fields

**eLicense license record:**

| Field | Example |
|-------|---------|
| License number | `CCC.000xxxx` (Child Care Center); `GCC.000xxxx`; `FCC.000xxxx`; `YC.000xxxx` |
| License type | Child Care Center / Group Child Care Home / Family Child Care Home / Youth Camp |
| Licensee name | Business name |
| Address | Street, city, ZIP |
| Status | Active / Lapsed / Suspended / Revoked |
| Issue date / Expiration date | Dates |
| Discipline / enforcement actions | Consent orders, summary suspensions (text) |
| Attached documents | List of `DocumentIdnt` rows with title + filed-date |

**Inspection PDF (unstructured):**

- Division of Licensing letterhead
- Facility name + license #
- Inspection date + type (Annual / Complaint / Follow-Up / Initial)
- Itemized regulatory citation (e.g., `RCSA 19a-79-4a(e)` staffing ratio, `19a-79-9` physical plant)
- Finding narrative (what was observed)
- Corrective action plan + due date
- Licensor signature + date

**OEC annual aggregate report (one PDF/yr):**

- Count of deaths in care
- Count of serious injuries (fracture, 2nd/3rd-degree burn, concussion)
- Count of substantiated abuse & neglect findings
- Breakdown by license type (center / group / family / camp)

## Scraping / Access Strategy

- **eLicense lookup** is server-rendered ASP.NET with VIEWSTATE; scrapeable via Playwright or a careful `requests` + VIEWSTATE session. CT does not aggressively block — polite rate limit (≤1 req/sec) acceptable.
- **Roster generator** requires JS execution + a reCAPTCHA v2 challenge. Path: manual interactive download, saved to S3 as a quarterly snapshot. Output is a CSV-like Excel/HTML table.
- **211 Child Care** listing pages have stable integer `LISTING_ID` path. Enumerate `1`&rarr;`40000`; persist; parse inspection cards. Lighter page weight than eLicense.
- **Inspection PDFs** via `ViewPublicLookupDocument.aspx?DocumentIdnt=N&GUID=G` — GUID is required but is exposed in the license-detail HTML as a query-string pair; cache alongside the license record.
- No rate-limit errors observed as of 2026-04-18 at ≤60 req/min. ASP.NET session state does not require login for public lookup.

## Known Datasets / Public Records

- **OEC Agency Program Reports:** `https://www.ctoec.org/agency-program-reports/` — links to narrative PDFs; not a dataset.
- **211 Child Care "Other Reports"** page hosts the annual death/injury PDFs: `https://resources.211childcare.org/reports/other-reports/`
  - 2025: `https://resources.211childcare.org/wp-content/uploads/2026/01/2025-Number-of-Deaths-Serious-Injuries-and-Incidences-of-Substantiated-Child-Abuse-and-Neglect-in-Child-Care-Settings.pdf`
  - 2024: `https://resources.211childcare.org/wp-content/uploads/2025/02/2024-Number-of-Deaths-Serious-Injuries-and-Incidences-of-Substantiated-Child-Abuse-and-Neglect-in-Child-Care-Settings.pdf`
- **CT Mirror archive** for fiscal 2017 inspection reports (obtained via state records request): `http://daycare.ctmirror.org/`
- **No data.ct.gov child-care dataset** — confirmed 2026-04-18.
- **CT Office of the Child Advocate** Critical Incident reports (multi-agency) include OEC findings: `https://portal.ct.gov/oca/`

## FOIA / Open-Records Path

- **Connecticut Freedom of Information Act, CGS §§ 1-200 et seq.** Filed with OEC's records officer.
- OEC FOIA contact: OEC Legal Affairs, 450 Columbus Blvd, Hartford, CT 06103, (860) 500-4450, `oec.foi@ct.gov` (verify).
- Complaint investigation files are subject to CT DCF abuse-and-neglect confidentiality (CGS § 17a-28); redacted summaries releasable.
- Statutory response window: **4 business days** for acknowledgment; actual production 10–60 days for bulk inspection exports.
- CT Mirror's 2018 precedent: obtained **all fiscal 2017 inspection reports** as PDFs through OEC; CT Mirror publicly noted "state doesn't maintain electronic copies of all documents" — expect partial fulfillment on pre-2020 years.
- FOI Commission complaint path if OEC denies: `https://portal.ct.gov/foi`

## Sources

- CT OEC: https://www.ctoec.org/
- CT OEC Licensing Look-up: https://www.ctoec.org/licensing/look-up-providers-and-programs/
- CT eLicense Lookup: https://www.elicense.ct.gov/Lookup/LicenseLookup.aspx
- eLicense Generate Roster tool: https://www.elicense.ct.gov/lookup/GenerateRoster.aspx
- Sample eLicense inspection PDF: https://elicense.ct.gov/Lookup/ViewPublicLookupDocument.aspx?DocumentIdnt=7873363&GUID=3D38D34C-7769-4B48-B22A-8F334FF71450
- 211 Child Care search: https://resources.211childcare.org/
- 211 Child Care — Licensing info: https://resources.211childcare.org/parents/licensing/
- 211 Child Care — Other reports (death/injury PDFs): https://resources.211childcare.org/reports/other-reports/
- CT Mirror Day Care Inspector: http://daycare.ctmirror.org/
- CT Mirror 2018 database launch article: https://ctmirror.org/2018/10/22/looking-child-care-heres-database-quality-benchmarks/
- CT Mirror 2013 home-daycare audit: https://ctmirror.org/2013/10/02/safety-violations-found-all-20-home-day-care-centers-audited-ct-federal-report-says/
- CT FOI Commission: https://portal.ct.gov/foi
- CGS Ch. 368a (19a-77 through 19a-87e): https://www.cga.ct.gov/current/pub/chap_368a.htm
