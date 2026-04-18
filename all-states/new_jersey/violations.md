# New Jersey — Violations, Inspection Data & Public Records Research

**Last updated:** 2026-04-18
**Agency:** New Jersey Department of Children and Families (DCF), Office of Licensing (OOL). Statutory basis: N.J.A.C. 3A:52-2.3 (inspection cadence); Child Care Center Licensing Act N.J.S.A. 30:5B-1 et seq.

## Violations / Inspection Data Source

New Jersey publishes inspection reports and complaint-investigation summaries for every licensed child care center, family child care provider, and summer camp through two DCF-branded but cross-linked portals:

1. **Child Care Explorer (NJCCIS Public Portal):** https://childcareexplorer.njccis.com/portal/ — facility-level detail pages at `https://childcareexplorer.njccis.com/portal/provider-details/<facility_id>` expose current license, capacity, ages served, QRIS (Grow NJ Kids) rating, and **all inspection reports and OOL Complaint Investigation Summary Reports** posted since the center was licensed (3-year rolling archive is guaranteed; older reports often still present).
2. **ChildCareNJ.gov Provider Search:** https://www.childcarenj.gov/Provider-Search — parent-facing front door that redirects into the same NJCCIS Explorer data model. Supports search by program name, zip code, type, county, and **NJCCIS Facility ID** (the same primary key that appears in the DCF licensing CSV).
3. **DCF Office of Licensing page:** https://www.nj.gov/dcf/about/divisions/ol/centers.html — narrative page describing how inspection reports are published; links out to the Explorer.

## Data Format

| Source | Format | Bulk? |
|---|---|---|
| NJCCIS Child Care Explorer | React SPA backed by a JSON API (`/api/...`); inspection reports rendered as **PDF downloads** | No public bulk export endpoint |
| DCF Licensed Centers CSV (roster only) | CSV via ArcGIS Hub / NJDEP monthly pipeline | Yes — `0bc9fe070d4c49e1a6555c3fdea15b8a` already pulled for roster; no violations |
| data.nj.gov (Socrata) | JSON/CSV/XML via SODA API | Legacy roster `cru5-4rmm` (frozen 2019); current `pdn3-t238` returns 403 |
| OPRA request | Email PDF fulfillment or SFTP drop for large requests | Yes — statutory right |

## Freshness

- Child Care Explorer: inspection reports are uploaded by OOL field inspectors within ~10 business days of the onsite visit and supervisor review. Lag: **1–3 weeks**.
- Complaint investigation summaries: posted after the investigation closes (typically 45–60 days from complaint intake).
- Licensed-centers roster (ArcGIS Hub): **monthly refresh** (reflects OOL monthly export; pulled April 2026 snapshot = 2026/04/08).
- Legacy Socrata `cru5-4rmm`: **not refreshed since 2019** — do not use for current state.

## Key Fields in NJ Inspection Reports (form CCC-108 — "Inspection/Violation Report")

- Inspection date, inspector name, license number
- Type: Initial / Renewal / Annual Monitoring / Complaint Investigation / Follow-up
- **Citation**: N.J.A.C. section (e.g., `3A:52-4.3` ratio, `3A:52-5.3(a) Health`, `3A:52-6 Staff records`)
- Narrative description of observation
- **Risk level**: OOL uses a qualitative classification (Critical / Significant / Minor) tied to § 3A:52 "imminent hazard" criteria in center licensing regs
- Plan of Correction (POC) — due date and provider signature
- Verification of correction — dated inspector note
- Outcome: Full / Provisional / Denial / Suspension / Revocation

## Scraping / Access Strategy

### Child Care Explorer (recommended primary path)

- Base: `https://childcareexplorer.njccis.com/portal/`
- Facility detail pattern: `/portal/provider-details/{facility_id}` — facility_id is a 6-digit integer; observed live pages: 700361, 702715, etc. Enumerating `[700000 … 900000]` with a polite delay covers the universe.
- Under the hood, the page fires a fetch against the NJCCIS public API (XHR to `njccis.com` backend) returning a JSON blob with facility metadata and a `documents[]` array of inspection PDFs, each of which has a signed S3/Azure Blob URL.
- No auth required for Explorer data. Cloudflare is present but tolerant of Playwright with typical headers.
- For scale, use Playwright or a fetch client with `Accept: application/json` after inspecting the Network tab to lock the JSON endpoint.

### DCF public complaint form (outbound only)

- https://njccis.com/njccis/public-complaint is the inbound complaint form; doesn't expose outcome data.

### OPRA bulk strategy

- OPRA custodian (DCF): https://www.nj.gov/dcf/about/divisions/opra/ (or humanservices carve-out at https://www.nj.gov/humanservices/olra/public/opra/). DCF standard turnaround: 7 business days per N.J.S.A. 47:1A-5.
- Reasonable bulk ask: *"All inspection reports, complaint investigation summary reports, and administrative actions (revocation, suspension, denial) issued by DCF Office of Licensing for child care centers and registered family child care homes between <start> and <end>, in electronic format (PDF or structured CSV)."*
- DCF generally fulfills large OOL requests by producing redacted PDFs; structured CSV requires articulating the need and often a negotiation with the custodian.
- **OPRAmachine** (https://opramachine.com/) publishes text of past OPRA requests and fulfillments — worth checking for prior precedents before filing.

## Known Datasets / Public Records

- **Licensed Child Care Centers — NJOIT Open Data** (legacy, Socrata `cru5-4rmm`): https://data.nj.gov/Public-Safety/Licensed-Child-Care-Centers/cru5-4rmm — 4,163 rows, frozen May 2019.
- **Child Care Centers of New Jersey (ArcGIS Hub, primary roster):** https://njogis-newjersey.opendata.arcgis.com/datasets/njdep::child-care-centers-of-new-jersey/about — 4,287 rows, monthly refresh via NJDEP SRWMP pipeline from NJDCF Office of Licensing.
- **data.nj.gov Explorer (`pdn3-t238`):** returns 403 externally; appears gated/internal.
- No known journalism dataset for NJ child care violations has been published.

## FOIA / Open-Records Path

- Statute: **Open Public Records Act (OPRA), N.J.S.A. 47:1A-1 et seq.**
- Central OPRA portal: https://www.nj.gov/opra/
- DCF/OOL custodian: contact through the DCF web form at https://www.nj.gov/dcf/about/divisions/opra/ (turnaround 7 business days, fee schedule per N.J.S.A. 47:1A-5; electronic delivery free of copy fees).
- Template language for bulk violations: see "OPRA bulk strategy" above.
- Government Records Council appeals process: https://www.nj.gov/grc/

## Sources

- DCF Office of Licensing (centers): https://www.nj.gov/dcf/about/divisions/ol/centers.html
- Child Care Explorer: https://childcareexplorer.njccis.com/portal/
- Provider detail example A: https://childcareexplorer.njccis.com/portal/provider-details/700361
- Provider detail example B: https://childcareexplorer.njccis.com/portal/provider-details/702715
- ChildCareNJ.gov provider search: https://www.childcarenj.gov/Provider-Search
- ChildCareNJ licensing overview: https://www.childcarenj.gov/Parents/Licensing
- Child Care Connection NJ — inspection reports how-to: https://childcareconnection-nj.org/families/child-care-referrals/child-care-inspection-reports/
- Public complaint intake: https://njccis.com/njccis/public-complaint
- Legacy Socrata roster (frozen): https://data.nj.gov/Public-Safety/Licensed-Child-Care-Centers/cru5-4rmm
- ArcGIS Hub roster (current monthly): https://njogis-newjersey.opendata.arcgis.com/datasets/njdep::child-care-centers-of-new-jersey/about
- OPRA Central: https://www.nj.gov/opra/
- DCF OPRA hub: https://www.nj.gov/dcf/about/divisions/opra/
- OPRAmachine (third-party request archive): https://opramachine.com/
- Information-to-Parents statement (OOL): https://www.nj.gov/dcf/providers/licensing/CCL.Information.to.Parents.Statement.pdf
