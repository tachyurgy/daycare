# South Carolina — Violations, Inspections & Deficiencies

> How South Carolina publishes compliance history, deficiencies, and enforcement actions for licensed and registered child-care facilities.

## Violations / Inspection Data Source

Primary public-facing system (free, no login):

- **SC Child Care Services Provider Search** — https://www.scchildcare.org/search.aspx
  Name/city/zip search that returns individual provider pages with full compliance history.
- **Per-provider pages** at `https://www.scchildcare.org/provider/{id}/{slug}/` — expose a "Compliance" tab with all deficiencies logged in the past 36 months, categorized High / Medium / Low.
- **ABC Quality** (state QRIS for subsidy-participating providers) — https://abcquality.org/families/find-a-provider/ — parallel directory with a separate "compliance" view for rated providers.

## Data Format

| Item | Format |
|---|---|
| Provider detail page | HTML — SCChildCare.org CMS (Umbraco / .NET); URLs are stable and crawlable |
| Compliance tab | HTML list of deficiencies with date, regulation cited, severity, resolution status |
| Bulk export | **Not published.** No CSV, Excel, or API |
| Complaint / enforcement action history | Embedded on provider detail page |
| Inspection-report PDFs | Not uniformly linked — some pages include PDFs, some summarize |

**Per-provider URL:** `https://www.scchildcare.org/provider/{numeric_id}/{name-slug}/` — both numeric ID and slug must be present. Examples from live site: `/provider/165/sunshine-house-2/`, `/provider/47986/vivian-goldsborough/`, `/provider/47701/melanie-pierce-greer/`, `/provider/48030/alicia-leaks/`, `/provider/48462/debra-eaddy/`.

## Freshness

- **Deficiencies posted within days** of the inspection or complaint-investigation findings.
- **36-month rolling window** — deficiencies older than three years drop off the public listing.
- **Severity codes:** **High** = serious risk to child health and safety; **Medium** = significant risk to health and safety; **Low** = non-compliance with no immediate health/safety risk.

## Key Fields (provider detail page)

- Provider name, address, phone
- Facility type (Licensed Center, Group Home, Family Home, Registered, Exempt)
- License / registration number
- License status (active, probationary, suspended, revoked)
- ABC Quality rating (if participating)
- Capacity, hours of operation
- **Compliance Violations** table:
  - Date cited
  - Regulation (e.g., 114-502(E))
  - Severity (High / Medium / Low)
  - Description
  - Resolution status (corrected, pending, plan of correction accepted)
- Enforcement actions (probation, fine, revocation) with dates

## Scraping / Access Strategy

1. **Seed** — SC does not publish a provider ID list. Build the seed by paginating directory searches on https://www.scchildcare.org/search.aspx (by city or zip) and harvesting `/provider/{id}/{slug}/` hrefs. childcarecenter.us is a decent alternate seed to cross-reference (already used in leads pull).
2. **Fetch** — `GET /provider/{id}/{slug}/` for each seeded URL. The compliance tab is rendered server-side — no JS required.
3. **Parse** — extract the compliance table and enforcement-actions block. Fields are consistent across providers.
4. **Refresh cadence** — weekly is ample. Severity-promoted deficiencies (a Medium re-cited → High on re-inspection) are the key signal for a compliance SaaS.
5. **Rate limit** — ~1 req/sec. The site is Umbraco-hosted and modestly sized; be polite.

## Known Datasets / Public Records

- No formal open-data dataset. The state operates the CMS above as the "open data" vehicle for compliance info.
- **Children's Trust of South Carolina investigation** (2021 analysis of DSS CCL records) — "Despite violations, many child care facilities stay in business" — https://scchildren.org/despite-violations-many-child-care-facilities-stay-in-business/ — tallied **8,537 serious violations statewide in a 4-year span**; top categories: improper supervision (3,044 high-severity), out-of-ratio (2,605 high-severity). Based on a DSS record extract obtained via FOIA.
- **Winnie — "How to Look up Daycare Violations"** — https://winnie.com/resources/how-to-look-up-daycare-violations — includes SC walkthrough.
- **Berger Law SC — Day Care Facility Safety Regulations** — https://www.bergerlawsc.com/library/south-carolina-day-care-facility-safety-regulations.cfm — cites DSS records.

## FOIA / Open-Records Path

South Carolina Freedom of Information Act (S.C. Code § 30-4-10 et seq.).

- **Submit to:** SC DSS FOIA Officer, 1535 Confederate Ave., Columbia, SC 29201; FOIA e-mail via https://dss.sc.gov/about/foia/ .
- **Turnaround:** SC FOIA requires written response within **10 business days** of receipt; production within **30 business days** (fulfilled in full by 90 days for large extracts).
- **Cost:** search/retrieval at lowest-paid staff rate, reasonable redaction fees. Electronic extracts often free for public-interest requests.
- **Recommended scope:** "Complete list of licensed child care centers and registered family/group child care homes active at any time between 2023-01-01 and present, together with all compliance deficiencies and enforcement actions cited or taken during that window, in machine-readable format (CSV or Excel) with fields: facility name, license/registration number, license type, address, county, date cited, regulation cited, severity code, description, resolution status, plan-of-correction date."
- Children's Trust of SC used a similar scope to get the 4-year dataset referenced above.

## Sources

- SC Child Care Services provider search: https://www.scchildcare.org/search.aspx
- Example provider page — Sunshine House: https://scchildcare.org/provider/165/sunshine-house-2/
- Example provider page — Melanie Pierce-Greer: https://www.scchildcare.org/provider/47701/melanie-pierce-greer/
- Example provider page — Vivian Goldsborough: https://www.scchildcare.org/provider/47986/vivian-goldsborough/
- Filing a Complaint (SC CCS): https://www.scchildcare.org/families/filing-a-complaint/
- ABC Quality provider directory: https://abcquality.org/families/find-a-provider/
- Children's Trust of SC 4-year violation study: https://scchildren.org/despite-violations-many-child-care-facilities-stay-in-business/
- Winnie — SC walkthrough: https://winnie.com/resources/how-to-look-up-daycare-violations
- SC Code Title 63 Chapter 13 (licensing law): https://www.scstatehouse.gov/code/t63c013.php
- SC FOIA (DSS): https://dss.sc.gov/about/foia/
- S.C. Code § 30-4-10 et seq. (SC FOIA): https://www.scstatehouse.gov/code/t30c004.php
