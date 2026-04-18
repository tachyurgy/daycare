# Iowa — Violation / Inspection-Failure Data Sources

_Compiled 2026-04-18 for ComplianceKit. Companion to `compliance.md` and `SOURCES.md` (provider/lead sourcing)._

## Violations / Inspection Data Source

- **Primary — Iowa HHS Bureau of Child Care "Compliance Report" public search**, served off the DHS Titan public portal.
  - `https://secureapp.dhs.state.ia.us/dhs_titan_public/ChildCare/ComplianceReport`
  - Paginated, filterable by provider type (Center, Child Development Home Cat A/B/C, Preschool), county, or city. Each row links to a per-facility detail page listing every annual compliance evaluation + every complaint report filed.
- **Secondary — `data.iowa.gov` open-data dataset** (Socrata-hosted; maps the same Titan feed).
  - Dataset page: `https://data.iowa.gov/Child-Adult-Welfare/Child-Care-Compliance-Complaint-Reports/5kd5-9khx`
  - Views endpoint (metadata): `https://data.iowa.gov/api/views/5kd5-9khx.json`
  - Socrata API (rows, when columns are exposed): `https://data.iowa.gov/resource/5kd5-9khx.json` (and `.csv`)
  - Attribution: "Iowa Department of Health & Human Services" — category "Child & Adult Welfare" — publication stage: Published.
- **Consumer wrapper — Iowa Child Care Connect** (ISU + Resultant partnership, launched 2024): `https://iachildcareconnect.org` / `https://search.iachildcareconnect.org` — surfaces vacancies, QRS rating, compliance status, but no open CSV yet.

## Data Format

- **Hybrid.** The Titan page is the live ASP.NET interactive; the Socrata dataset appears to wrap/reference the same underlying data (view count 10,883 as of Aug 2023; columns metadata currently empty in the exposed `.json`, which means the Socrata dataset is **link-only** — it routes back to the Titan page rather than exposing tabular rows directly).
- The federal `catalog.data.gov` entry (`child-care-compliance-complaint-reports/resource/5f581e0b-724b-4843-8fe4-d945f5561f10`) harvests the Iowa record but its resource-URL field is broken.
- Per-facility detail on Titan returns HTML with structured sections: Facility info + Annual Compliance Evaluations + Complaint Reports + Corrective Actions.

## Freshness

- Titan reflects licensor entries in near-real-time (typically ≤72 hrs after a field visit).
- Socrata dataset attribution shows index build at 1559939527 (June 7, 2019) and last view-metadata update Aug 29, 2023 — which strongly suggests the `data.iowa.gov` surface is a pointer/catalog entry, not a rowset; the source of truth remains Titan.
- Iowa runs **annual unannounced on-site visits** on every licensed center (IAC 441-109.3) + **2-year license term** + provisional 6-month option.

## Key Fields

**Provider row (search listing):**

- Provider name
- Facility type (Child Care Center / Preschool / Licensed Nonregistered / CDH Cat A / Cat B / Cat C / Out-of-School)
- City, county, address
- License / registration number
- Current status

**Compliance evaluation (per-visit):**

- Visit date + type (annual / initial / renewal / complaint / follow-up)
- Licensor name
- Findings per rule (IAC 441-109.x / 441-110.x citations)
- Compliance / non-compliance status per item
- Corrective action + due date
- Final disposition (resolved / open / enforcement)

**Complaint report:**

- Intake date (via 866-448-4605 Complaint Hotline)
- Allegations summary (redacted)
- Investigation status + outcome (substantiated / unsubstantiated / partially substantiated)
- Related corrective actions / sanctions

## Scraping / Access Strategy

- **Titan ComplianceReport is ASP.NET WebForms** with VIEWSTATE/EVENTVALIDATION hidden fields — scrape with a `requests.Session()` that submits form state, or Playwright for simpler DOM handling.
- Supports filter-driven pagination (county filter is most stable); iterate county-by-county to fully enumerate (~99 counties).
- `secureapp.dhs.state.ia.us` certs are valid; no Cloudflare / bot block observed. Polite throttle (≤2 req/sec) is sufficient.
- **Socrata path is currently not row-accessible** (empty columns metadata). Periodically re-check `/resource/5kd5-9khx.json?$limit=1` — if Iowa publishes columns in the future, the dataset becomes the easiest ingest.
- **Iowa Child Care Connect** (`search.iachildcareconnect.org`) likely fronts a JSON API — inspect network tab; an Elasticsearch-style endpoint would dramatically simplify ingest if exposed.
- No scrape-detection issues historically with Titan; 2024 observer dumps of ~2,400 centers + ~3,000 registered CDH homes were completed successfully at slow-crawl rates.

## Known Datasets / Public Records

- **data.iowa.gov** dataset `5kd5-9khx` — catalog entry (link-only).
- **catalog.data.gov** harvest: `https://catalog.data.gov/dataset/child-care-compliance-complaint-reports/resource/5f581e0b-724b-4843-8fe4-d945f5561f10` (resource link broken).
- **Iowa CCR&R statistics** (aggregates only): `https://iowaccrr.org/data/`
- **Iowa Quality for Kids (IQ4K®)**: `https://hhs.iowa.gov/programs/programs-and-services/child-care/iq4k` — QRIS rating data (5 levels).
- **Comm. 204 Licensing Standards** handbook (Rev. 7/2025): `https://hhs.iowa.gov/media/6489/download?inline`

## FOIA / Open-Records Path

- **Iowa Open Records Act — Iowa Code Chapter 22.** File with Iowa HHS Records Custodian (`ombudsman@dhs.iowa.gov` / records officer).
- Complaint intake forms (470-4067, 470-5393, 470-5281) are public records with redaction of complainant PII.
- **Statutory response:** no strict deadline, but Iowa Code 22.8 requires reasonable promptness; 10-20 business days typical.
- Child-abuse registry information is confidential under Iowa Code 235A; facility compliance data is presumed open.
- **Abuse & Fraud reporting (complaint side):** `https://hhs.iowa.gov/report-abuse-fraud`
- **Iowa HHS Child Care Complaint Hotline:** `866-448-4605`

## Sources

- Iowa HHS Child Care: https://hhs.iowa.gov/programs/programs-and-services/child-care
- Iowa HHS Titan Compliance Report: https://secureapp.dhs.state.ia.us/dhs_titan_public/ChildCare/ComplianceReport
- Provider Portal: https://ccmis.dhs.state.ia.us/providerportal/
- Client portal (subsidy side): https://ccmis.dhs.state.ia.us/clientportal/ProviderSearch.aspx
- data.iowa.gov dataset: https://data.iowa.gov/Child-Adult-Welfare/Child-Care-Compliance-Complaint-Reports/5kd5-9khx
- Socrata metadata endpoint: https://data.iowa.gov/api/views/5kd5-9khx.json
- data.gov harvest entry: https://catalog.data.gov/dataset/child-care-compliance-complaint-reports/resource/5f581e0b-724b-4843-8fe4-d945f5561f10
- Iowa Child Care Connect: https://iachildcareconnect.org
- Iowa CCR&R: https://iowaccrr.org/data/
- IAC 441-109 Centers (full chapter PDF): https://www.legis.iowa.gov/docs/aco/chapter/441.109.pdf
- IAC 441-109.8 Ratios: https://www.legis.iowa.gov/docs/iac/rule/441.109.8.pdf
- Comm. 204 Licensing Standards (Rev. 7/2025): https://hhs.iowa.gov/media/6489/download?inline
- Complaint intake form 470-5393: https://hhs.iowa.gov/media/5982/download?inline
- Complaint form 470-4067: https://hhs.iowa.gov/media/5368
- Complaint form 470-5281: https://hhs.iowa.gov/media/5911/download?inline
- Iowa Child Care Complaint Hotline: https://hhs.iowa.gov/contacts/iowa-child-care-complaint-hotline
- Report Abuse & Fraud: https://hhs.iowa.gov/report-abuse-fraud
- IQ4K QRIS: https://hhs.iowa.gov/programs/programs-and-services/child-care/iq4k
