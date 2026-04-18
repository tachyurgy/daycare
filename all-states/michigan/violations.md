# Michigan — Violations, Inspection Data & Public Records Research

**Last updated:** 2026-04-18
**Agency:** Michigan Dept. of Lifelong Education, Advancement, and Potential (MiLEAP) — Child Care Licensing Bureau (CCLB). Prior to Dec 2023, CCLB sat within LARA / BCHS.

## Violations / Inspection Data Source

Michigan publishes inspection reports, special investigation reports, and disciplinary actions for every licensed child care center and home through two overlapping public systems:

1. **CCHIRP Statewide Facility Search (primary, since 2023):** https://cclb.my.site.com/micchirp/s/statewide-facility-search — Salesforce Experience Cloud portal that hosts every licensed facility's complete licensing history, including all **Inspection Reports, Renewal Reports, and Special Investigation Reports** going back to the rollout of CCHIRP.
2. **Legacy LARA Statewide Search (still live):** https://childcaresearch.apps.lara.state.mi.us/ — the pre-CCHIRP ASP.NET portal. Click a facility name, then drill into inspection history; **reports from on or after July 1, 2002** are online. MiLEAP has not formally sunset this URL; it is the most complete historical archive on the public web.
3. **Child Care Providers Closed/Suspended Due to Disciplinary Action (HTML list):** https://www.michigan.gov/en/mileap/Early-Childhood-Education/cclb/parents/panel-collapse/provider-choose/child-care-providers-closed-or-suspended-due-to-disciplinary-action — running list (rolling 5-year window) of licenses revoked, suspended, or non-renewed. Includes provider name, city, reason code, and action date.
4. **MiLEAP Press-Release feed (summary-suspension announcements):** e.g. https://www.michigan.gov/mileap/press-releases/ — each summary suspension is announced as an individual press release (name, county, date, brief narrative of findings).

## Data Format

| Source | Format | Bulk? |
|---|---|---|
| CCHIRP facility search | Salesforce Aura/Lightning Experience Site; inspection reports rendered as **PDF attachments** | No public bulk export — must be scraped page-by-page |
| LARA legacy search | ASP.NET; inspection reports are **PDF downloads** with predictable `FacilityId`-based URLs | Not officially bulk — but URLs are enumerable |
| Disciplinary-action page | Static HTML table (updated periodically) | Single page scrape |
| Press releases | HTML list with pagination | RSS optional |
| CCLB Sunshine (FOIA) | Email/PDF fulfillment, typically 15 business days | Yes — bulk requests accepted |

## Freshness

- CCHIRP — **near-real-time** (licensing consultants upload finalized reports directly into Salesforce; public visibility within 1–3 business days after supervisor approval).
- Legacy LARA search — mirrored from the same back-end ~daily.
- Disciplinary action list — updated on a rolling basis as adverse actions become final; lag of days to weeks.
- Press releases — same-day.

## Key Fields in Michigan Inspection Reports

- Inspection date (onsite visit date) and report finalization date
- Inspection type (Licensing Study / Renewal / Complaint-Triggered Special Investigation / Technical Assistance)
- License number (e.g., `DC750XXXXXX`, `DF250XXXXXX`, `DG250XXXXXX`)
- Facility name, program address, licensee name
- **Rule cited** (e.g., R 400.8135 "Caregiver qualifications"; R 400.8305 "Safe sleep")
- Short narrative of observation / allegation
- Finding: Violation Established / Not Established / Repeat Violation
- **Corrective Action Plan (CAP)** text submitted by provider
- Consultant name and signature date
- Follow-up visit disposition

Every PDF uses a standardized MiLEAP report template (BCAL-4617R for renewals; BCAL-SI for special investigations), which makes parsing feasible with repeatable heuristics.

## Scraping / Access Strategy

### CCHIRP (recommended primary path)

- Base site: `https://cclb.my.site.com/micchirp/s/`
- Search entry: `/statewide-facility-search`
- Facility detail: URLs are driven by Lightning `recordId` parameters; the page itself lazily loads attachments via Salesforce Aura RPC. Easiest automation path is **Playwright** (Chromium) driving the search form, clicking through each facility, and downloading the PDFs that load in the "Licensing History" Lightning component.
- Rate: Salesforce Sites tolerates ~1 req/sec; parallelize across 3–5 concurrent browsers to stay under detection thresholds.
- No authentication required for public data.

### LARA legacy (backup for historical bulk)

- Base: `https://childcaresearch.apps.lara.state.mi.us/`
- Form POST: `default.aspx` with ViewState + `txtProviderName`, `ddlCounty`, etc.
- Facility page URL: `Profile.aspx?FacilityId=<int>`
- Inspection PDF URL: `GetDocument.aspx?DocID=<int>`
- `FacilityId` appears to be a sequential int; full enumeration feasible (est. 10–12k historical IDs).
- Friendly rate limit (unofficial): <2 req/sec; pages are lightweight ASP.NET responses.

### Disciplinary-action list

- Single HTML page scrape; `<table>` with columns Provider / City / Action / Date.
- BeautifulSoup + requests is sufficient.

## Known Datasets / Public Records

- **MiLEAP/LARA Child Care (facility roster only — no violations):** ArcGIS item `a79c3b0caedf412599085941e2af91d4` — already retrieved for `michigan_leads.csv`; contains facility identifiers that can be joined against scraped CCHIRP data.
- **No third-party journalism dataset** on Michigan child-care violations has been published that we could locate (contrast with Texas, where journalism open-data projects exist). ProPublica's *Nursing Home Inspect* covers LTC only.
- **Michigan Open Data Portal** (`data.michigan.gov`) — does not currently expose a child-care inspection or complaint dataset as of April 2026.

## FOIA / Open-Records Path

Michigan's FOIA statute is the **Michigan Freedom of Information Act, MCL 15.231 et seq.** — 5-business-day initial response, 10-day extension permitted; records for any period older than 3 years (not online) must be obtained this way.

- **MiLEAP CCLB FOIA coordinator:** MiLEAP-CCLB-Help@michigan.gov (general) and the department-wide FOIA office at FOIA@michigan.gov.
- **Phone:** 517-284-9730 (CCLB main).
- Fee structure: first 2 hours of search + duplication costs per MCL 15.234; indigent waivers available.
- Reasonable ask: "All inspection reports, special investigation reports, and corrective action plans for all licensed child care centers and homes issued between <start> and <end>, in electronic format." In practice MiLEAP will push to the public CCHIRP portal rather than fulfill bulk extracts, but a formal FOIA establishes right to enforce.

## Sources

- MiLEAP CCLB home: https://www.michigan.gov/mileap/early-childhood-education/cclb
- CCHIRP Statewide Facility Search: https://cclb.my.site.com/micchirp/s/statewide-facility-search
- CCHIRP Portal root: https://cclb.my.site.com/micchirp/s/
- CCHIRP info page (MiLEAP): https://www.michigan.gov/mileap/early-childhood-education/cclb/cchirp
- Legacy LARA Statewide Search: https://childcaresearch.apps.lara.state.mi.us/
- Inspections for Child Care Centers (MiLEAP): https://www.michigan.gov/mileap/early-childhood-education/cclb/providers/insp
- Disciplinary-Action list: https://www.michigan.gov/en/mileap/Early-Childhood-Education/cclb/parents/panel-collapse/provider-choose/child-care-providers-closed-or-suspended-due-to-disciplinary-action
- LARA Disciplinary-Action Reports index: https://scprod.michigan.gov/lara/bureau-list/cscl/complaints/disciplinary
- MiLEAP press releases (summary suspension announcements example): https://www.michigan.gov/mileap/press-releases/2025/02/12/mileap-summarily-suspends-a-family-child-care-home-license-in-washtenaw-county
- NASCIO 2023 Award write-up for CCHIRP: https://www.nascio.org/wp-content/uploads/2024/08/MI_Digital-Services-Government-to-Business.pdf
- Michigan FOIA (MCL 15.231 et seq.): https://www.legislature.mi.gov/Laws/MCL?objectName=mcl-Act-442-of-1976
