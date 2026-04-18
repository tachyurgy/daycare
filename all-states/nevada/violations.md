# Nevada — Violation / Inspection-Failure Data Sources

_Compiled 2026-04-18 for ComplianceKit. Companion to `compliance.md` and `SOURCES.md` (provider/lead sourcing)._

## Violations / Inspection Data Source

- **Primary — Aithent-hosted ALiS Licensee Search** (the state's public licensee-lookup portal; the same backend that `findchildcare.nv.gov` links into).
  - Child care program search (HF): `https://nvdpbh.aithent.com/Protected/LIC/LicenseeSearch.aspx?Program=HF&PubliSearch=Y&returnURL=~/Login.aspx?TI=2`
  - HHF variant (health facilities surface): `https://nvdpbh.aithent.com/Protected/LIC/LicenseeSearch.aspx?Program=HHF&PubliSearch=Y&returnURL=~/Login.aspx?TI%3D0`
  - Facility detail pages list per-licensee **Regulatory Actions** (inspection reports, complaints, enforcement actions).
- **Agency landings (post-7/1/2024 DSS consolidation):**
  - `https://www.dss.nv.gov/programs/child-care-licensing-ccl/`
  - `https://www.dss.nv.gov/child-care/child-care-licensing-ccl/`
  - `https://www.dpbh.nv.gov/regulatory/child-care-facilities/` (legacy DPBH host still serves archival content + forms).
- **Statewide Annual Licensing Report** (aggregate: counts of licensed facilities, substantiated & unsubstantiated complaints, by facility type, jurisdiction). Latest publicly linked: **Jan 2022 – Dec 2022**. Additional 2023–2025 "Serious Injury, Death, and Substantiated Abuse & Neglect" report referenced but not always URL-stable.

## Data Format

- **Per-facility, HTML (Aithent ASP.NET).** Facility profile exposes license type, status, current address, Regulatory Actions tab (inspection reports with date + findings).
- **No bulk CSV / JSON / ArcGIS.** The 2016 archival PDF `Facility_List_March_2016.pdf` on dpbh.nv.gov is stale; the 2024-era statewide PDF URL on dpbh.nv.gov returns 404 (consolidation + host migration artifact).
- Annual licensing reports are published as PDF (narrative + tables).

## Freshness

- **2 unannounced inspections per 12-month licensing period** mandated by NRS 432A.180 / NAC 432A.190. Complaint follow-ups on top. Aithent record updated within days of a licensor filing.
- **Consolidation (7/1/2024):** Washoe County CCL absorbed into DSS; Clark County family-home licensing remains local (county business licensing layer). This means **county-local family-home inspection records** live outside the state Aithent portal — request via Clark County / Washoe County.
- Annual licensing report cadence: calendar-year, published ~Q2 of the following year.

## Key Fields

**Licensee profile (Aithent):**

- License number
- License type (Child Care Center / Child Care Institution / Nursery for Infants & Toddlers / Special Needs / Accommodation Facility / Special Events / Outdoor Youth / Family CCH / Group CCH)
- Licensee name + DBA
- Address, phone
- License status (Active / Expired / Suspended / Revoked / Voluntarily Surrendered)
- Issue / expiration dates
- Regulatory Actions log — inspection date, type, findings, corrective action

**Inspection report (linked PDF/HTML):**

- Inspection date + type (Routine / Complaint / Follow-Up / Initial / Renewal)
- Surveyor name + ID
- Itemized citations to NAC 432A sub-rules
- Findings narrative
- Corrective action plan + due date
- Substantiated / unsubstantiated determination (complaint-driven only)
- Civil money penalty assessed (dollar amount, if any)

**Statewide Annual Licensing Report (aggregate):**

- Total licensed facilities by type
- Counts of substantiated vs unsubstantiated complaints
- Deaths / serious injuries in care
- New license issuances / revocations

## Scraping / Access Strategy

- **Aithent ALiS is ASP.NET WebForms.** `/Protected/` path name is misleading — `PubliSearch=Y` flag disables the auth wall for public programs. VIEWSTATE/EVENTVALIDATION required for pagination; Playwright is the simplest path.
- Licensee-number enumeration: observed prefixes include `LCCH-######` for centers, `FCCH-######` for family homes; a sequential sweep within known ranges will catch actives + lapsed records.
- **Rate limit:** Aithent is a shared platform (serves multiple NV program types: HHF/HF/EHS). ≤1 req/sec recommended; no Cloudflare observed.
- **County-local (Clark County family homes):** separate portal (`Clark County Business License / Social Service`) — not Aithent-backed. Washoe County legacy records (pre-7/1/2024) may need county-level records request.
- **findchildcare.nv.gov** is a thin wrapper that redirects to the Aithent search — same backend.
- 2016 archival PDF `Facility_List_March_2016.pdf` still served at dpbh.nv.gov; 2024+ statewide PDF link 404 — consider as **data-gap signal** in messaging to prospects.

## Known Datasets / Public Records

- **Statewide Annual Licensing Report (2022)** — PDF, aggregate stats only.
- **Serious Injury, Death, and Substantiated Abuse & Neglect 2023–2025** — referenced in DPBH / DSS page copy; URL not stable.
- **No data.nv.gov / opendata.nv.gov** child-care dataset as of 2026-04-18.
- Nevada Registry (professional development): `https://www.nevadaregistry.org/` — staff credential enrollment roster (login-gated for individual detail; aggregated counts public).
- Carson City environmental-health child-care inspections (local overlay): `https://www.gethealthycarsoncity.org/divisions/environmental-health/programs-inspections/child-care`

## FOIA / Open-Records Path

- **Nevada Public Records Act — NRS Chapter 239.** DHHS specifically commits to transparency under NRS 239.
- DHHS Public Records Request portal: `https://dhhs.nv.gov/about/publicrecordsrequest/`
- DHS: `https://www.dhs.nv.gov/aboutus/publicrecordsrequest/`
- Statutory response: **5 business days** (acknowledge / provide / deny with reason); extensions permitted for voluminous requests.
- Complaint investigative files: redactions under NRS 432B for child-abuse-specific content; facility compliance data presumed open.
- State-level overview: `https://nsla.nv.gov/public-records/nevada-public-records-act-resources`

## Sources

- DSS Child Care Licensing (post-reorg): https://www.dss.nv.gov/programs/child-care-licensing-ccl/
- DSS CCL alt: https://www.dss.nv.gov/child-care/child-care-licensing-ccl/
- DPBH Child Care Facilities (legacy host, forms): https://www.dpbh.nv.gov/regulatory/child-care-facilities/
- DPBH Child Care Statutes & Regulations: https://www.dpbh.nv.gov/regulatory/child-care-facilities/statutes/child-care-statutes-and-regulations/
- DPBH Child Care Licensing FAQ: https://www.dpbh.nv.gov/regulatorypgms/child-care-facilities/nevada-child-care-licensing-faqs/
- Find Child Care NV: https://www.dpbh.nv.gov/regulatory/child-care-facilities/media/find-child-care/
- DSS Find a Child Care Facility: https://www.dss.nv.gov/programs/child-care-licensing-ccl/find-a-health-facility/
- Aithent HF Licensee Search: https://nvdpbh.aithent.com/Protected/LIC/LicenseeSearch.aspx?Program=HF&PubliSearch=Y&returnURL=~/Login.aspx?TI=2
- Aithent HHF Licensee Search: https://nvdpbh.aithent.com/Protected/LIC/LicenseeSearch.aspx?Program=HHF&PubliSearch=Y&returnURL=~/Login.aspx?TI%3D0
- DPBH Child Care Licensing — Complaints: https://dpbh.nv.gov/Reg/ChildCare/dta/Complaints/Child_Care_Licensing_-_Complaints/
- NRS Chapter 432A: https://www.leg.state.nv.us/nrs/nrs-432a.html
- NAC Chapter 432A: https://www.leg.state.nv.us/nac/NAC-432A.html
- NAC 432A.5205 Ratios: https://www.law.cornell.edu/regulations/nevada/NAC-432A-5205
- Nevada Registry: https://www.nevadaregistry.org/ece-resources/child-care-licensing/
- NV Child Care Licensing Contact List: https://www.nevadaregistry.org/ece-resources/child-care-licensing/statewide-contact-list/
- NV CCR&R Licensing: https://www.nevadachildcare.org/licensing/
- Carson City Environmental Health: https://www.gethealthycarsoncity.org/divisions/environmental-health/programs-inspections/child-care
- NRS 239 (Public Records): https://www.leg.state.nv.us/NRS/NRS-239.html
- DHHS Public Records Request: https://dhhs.nv.gov/about/publicrecordsrequest/
- DHS Public Records Request: https://www.dhs.nv.gov/aboutus/publicrecordsrequest/
- Nevada State Library — Public Records resources: https://nsla.nv.gov/public-records/nevada-public-records-act-resources
