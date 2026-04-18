# Louisiana — Violations, Inspections & Licensing Data

> How Louisiana publishes compliance history, deficiency findings, and enforcement actions against Early Learning Centers (Bulletin 137) and related subsidies.

## Violations / Inspection Data Source

Primary public-facing system:

- **Louisiana School & Center Finder** — https://louisianaschools.com/ (operated by LDE; includes all K-12 schools, Early Learning Centers, and Type I/II/III child-care licensees).
- **Per-facility inspection page** — `https://louisianaschools.com/schools/{FACILITY_CODE}/Inspections`
  Examples observed live:
  - https://louisianaschools.com/schools/KDS001/Inspections (CHILDS Childcare)
  - https://louisianaschools.com/schools/KLC001/Inspections (Kids of Excellence Learning Center)
  - https://louisianaschools.com/schools/B13001/Inspections (Kid City Daycare and Preschool)
  - https://louisianaschools.com/schools/KAO001/Inspections (Four Stars Childcare Facility)
  - https://louisianaschools.com/schools/YKC001/Inspections (Viv's Angels Childcare Center)
  - https://louisianaschools.com/schools/KZX001/Inspections (Kids Kampus Learning Center)
  - https://louisianaschools.com/schools/EE-12302/Inspections (Kids in Motion Daycare)
- **Critical Incident Reports** must be submitted to LDE within 24 hours; aggregate incident data surfaces in Bulletin 137 compliance reports.
- **DCFS legacy Care Facility search** — https://webapps.dcfs.la.gov/carefacility/index — slow/partial, retained for pre-Oct 2014 licensure history.

## Data Format

| Item | Format |
|---|---|
| Inspection page | HTML (ASP.NET MVC, server-rendered); facility code URL format is stable |
| Inspection record | Per-visit row: date, inspection type, 43 regulation categories, findings |
| Violation detail | In-line — regulation cited, description, corrected / pending, corrective-action date |
| Enforcement actions | Listed on facility "About" page (revocation notices posted publicly) |
| Bulk export | **Not published.** No CSV, Excel, or API exposed |
| Critical Incident counts | Aggregate totals in Bulletin 137 annual performance profiles |

**Facility code alphabet:** codes are alphanumeric (e.g., `KDS001`, `B13001`, `EE-12302`). LDE uses prefix letters that appear to map to region/type; the code is not publicly documented, so a complete seed requires scraping the search results.

## Freshness

- Inspections posted **within days to weeks** of the visit (no documented SLA; LDE practice is roughly 2-3 weeks).
- All inspection history is retained publicly — **no rolling drop-off window** as in SC. Records appear indefinitely.
- Licensing action news releases (revocations, suspensions) issued via press release and retained in the DCFS/LDE news archive.

## Key Fields (inspection page)

- Inspection date
- Inspection type (initial, renewal, annual monitoring, complaint, critical-incident follow-up)
- Inspector name / region
- **43 Bulletin 137 regulations** — each flagged "In Compliance" / "Not In Compliance"
- For each non-compliance: regulation citation (LAC 28:CLXI.xxxx), narrative description, corrective action due date, resolution date, resolution status
- Overall inspection finding (pass / fail / probation)

The "About" page per facility also exposes:
- License type (Type I, II, III)
- License number
- Parish, physical address
- Capacity (number of seats)
- Academic Approval status (Type III only — tied to Bulletin 140 performance profile)
- Performance Profile rating (LA Quality Start star rating)

## Scraping / Access Strategy

1. **Seed facility codes** — paginate the https://louisianaschools.com/searchresults endpoint by parish (64 LA parishes) and facility type (filter to "Type I, II, III Early Learning Center"). Harvest each facility's code from the result cards.
2. **Fetch** — `GET /schools/{code}/Inspections` for inspection history and `/schools/{code}/About` for license metadata. Straight HTML; no JS rendering required.
3. **Parse** — table structure is consistent across providers. 43 regulation slots map to known Bulletin 137 citations.
4. **Refresh** — weekly. Critical-incident follow-ups appear promptly and are a strong compliance signal.
5. **Cross-reference** — DCFS legacy search for pre-2014 history if needed (timeout-prone; retry with longer timeout).

Third-party aggregators (childcarecenter.us, used in the leads pull) only provide roster, not inspection history.

## Known Datasets / Public Records

- **LDE Bulletin 137 Hot Topics 2024** — https://doe.louisiana.gov/docs/default-source/early-childhood/bulletin-137-hot-topics-ecc2024.pdf — top-cited regulations.
- **LA Legislative Auditor — Regulation of Child Care Providers** — https://app.lla.state.la.us/PublicReports.nsf/616C448CC80CCEC48625832200708DC0/$FILE/0001A9C2.pdf — audit-report analysis of LDE inspection cadence and violation rates.
- **LA Illuminator — "A 'shockingly broken system': more than a dozen states fail to meet child care safety regulations" (Feb 2024)** — https://lailluminator.com/2024/02/08/child-care-safety/ — reporting on state-by-state compliance with ACF reporting rules; LA referenced.
- **LegalClarity — Louisiana Daycare Violations** — https://legalclarity.org/louisiana-daycare-violations-common-issues-and-legal-consequences/ — plaintiff-side summary.
- **DCFS news archive — license revocations**:
  - https://www.dcfs.louisiana.gov/news/356 — two centers revoked for safety violations
  - https://www.dcfs.louisiana.gov/news/381 — false records / inadequate supervision; Baton Rouge area
  - https://dcfs.louisiana.gov/news/366 — four licenses revoked for serious safety violations

These revocation press releases cite specific Bulletin 137 / LAC 28 CLXI violations and are a good model for Louisiana's public-data disclosure pattern.

## FOIA / Open-Records Path

Louisiana Public Records Act — La. R.S. 44:1 et seq.

- **Submit to:** LDE Office of General Counsel / Public Records Officer via publicrecords@la.gov, or to LDE Early Childhood Licensing (ldelicensing@la.gov; 225-342-9905). DCFS historical records: DCFS Public Information at https://www.dcfs.louisiana.gov/page/public-records .
- **Turnaround:** La. R.S. 44:33 requires a response within **3 business days** and production within "reasonable time." Complex extracts typically 30-60 days.
- **Cost:** reasonable copying fees; electronic production often waived.
- **Recommended scope:** "For all Type I, II, and III Early Learning Centers licensed under Bulletin 137 active at any time between 2023-01-01 and present, produce in machine-readable format (CSV or Excel): facility name, facility code (e.g., KDS001), license number, license type, parish, physical address, capacity, each inspection date, inspection type, every Bulletin 137 regulation cited as non-compliant, corrective-action due date, resolution date and status, and any enforcement action (probation, suspension, revocation, fine) with effective date."

## Sources

- Louisiana School & Center Finder: https://louisianaschools.com/
- Inspection URL pattern example (CHILDS Childcare): https://louisianaschools.com/schools/KDS001/Inspections
- LDE Child Care Facility Licensing: https://doe.louisiana.gov/early-childhood/child-care-facility-licensing
- DCFS Care Facility legacy search: https://webapps.dcfs.la.gov/carefacility/index
- DCFS news — two centers revoked: https://www.dcfs.louisiana.gov/news/356
- DCFS news — false records, Baton Rouge: https://www.dcfs.louisiana.gov/news/381
- DCFS news — four licenses revoked: https://dcfs.louisiana.gov/news/366
- LA Legislative Auditor report — Regulation of Child Care Providers: https://app.lla.state.la.us/PublicReports.nsf/616C448CC80CCEC48625832200708DC0/$FILE/0001A9C2.pdf
- Louisiana Illuminator — "shockingly broken system" (2024): https://lailluminator.com/2024/02/08/child-care-safety/
- LegalClarity — Louisiana daycare violations: https://legalclarity.org/louisiana-daycare-violations-common-issues-and-legal-consequences/
- Bulletin 137 Hot Topics 2024: https://doe.louisiana.gov/docs/default-source/early-childhood/bulletin-137-hot-topics-ecc2024.pdf
- LDE contact for licensing records: ldelicensing@la.gov / 225-342-9905
- La. R.S. 44:1 et seq. (Public Records Act): https://legis.la.gov/Legis/Law.aspx?d=99562
