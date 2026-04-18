# Arkansas — Violation / Inspection-Failure Data Sources

_Compiled 2026-04-18 for ComplianceKit. Companion to `compliance.md` and `SOURCES.md` (provider/lead sourcing)._

## Violations / Inspection Data Source

- **Primary — DHS DCCECE eLicensing portal (Salesforce-backed Experience Cloud site).** Single consumer-facing search for licensed + registered providers, including licensing-record + compliance-report history (violations, complaints, corrective actions).
  - `https://ardhslicensing.my.site.com/elicensing/s/search-provider/find-providers?language=en_US&tab=CC`
  - Search front door: `https://ardhslicensing.my.site.com/elicensing/s/search-provider`
  - Complaint intake on the same Salesforce site: `https://ardhslicensing.my.site.com/elicensing/s/complaint?language=en_US`
- **Agency landings:**
  - `https://humanservices.arkansas.gov/divisions-shared-services/child-care-early-childhood-education/`
  - `https://portal.arkansas.gov/state_agencies/department-of-human-services-dhs/division-of-child-care-and-early-childhood-education/`
  - Provider-search service wrapper: `https://portal.arkansas.gov/service/licensed-day-care-providers-search/` &rarr; redirects to the Salesforce site.
- **Complaint line:** 1-800-582-4887 / `complaints.OLTC@arkansas.gov`

## Data Format

- **Salesforce Experience Cloud (Lightning).** The portal is **JavaScript-rendered** with client-side Aura components; raw `curl` / `WebFetch` returns a near-empty HTML shell. Data flows through Salesforce's `aura-production` endpoint.
- Per-provider record exposes: program name, facility type, address, current license status, compliance report history (violations + complaints + corrective actions), Better Beginnings QRIS level.
- **No bulk CSV.** No Socrata, no ArcGIS, no opendata.arkansas.gov child-care dataset.
- The **Arkansas Advocate** covered the December 2023–2024 launch of a separate **DESE (Dept. of Education) Office of Early Childhood** searchable database — that one covers the "Better Beginnings" quality data side rather than raw licensing violations.

## Freshness

- **Unannounced inspections 1–3× per year** depending on facility type + compliance history (see `compliance.md`); record updated within days of licensor filing.
- **Fire Marshal + Health Department** inspections layered on top — records live with those agencies, not in eLicensing.
- **License renewal is annual** &mdash; so the record churns more often than the 2-year cycles common in nearby states.
- Better Beginnings QRIS ratings sit under DESE and are updated on a separate cadence.

## Key Fields

**Provider record (Salesforce):**

- Provider ID
- Name / DBA
- Facility type (Center / Licensed Family / Registered Family / OST / Night-time)
- Address, phone
- Current license status (Active / Probationary / Suspended / Revoked / Closed)
- Capacity
- Better Beginnings level (1 / 2 / 3 / not rated)
- Compliance history rollup

**Compliance report / inspection (linked):**

- Inspection date + type (Annual / Renewal / Complaint / Follow-Up / Initial)
- Cited rule (Arkansas Admin Code 016.22.20-005, specific subsection)
- Finding narrative (redacted)
- Corrective action plan + due date
- Substantiated / unsubstantiated (complaint-driven)
- Enforcement outcome (if any): probation, suspension, revocation, civil money penalty

**DESE Better Beginnings (separate):**

- QRIS level
- Program participation status (ABC Pre-K / public pre-K)

## Scraping / Access Strategy

- **Salesforce Experience Cloud = hard.** `ardhslicensing.my.site.com` returns 403 / empty shell to non-JS clients. Path:
  1. **Playwright with a real browser profile** (headed or headless-with-JS-enabled) to render the search UI and paginate results. Salesforce has historically rate-limited and even banned automated requests — use residential-proxy rotation if going at scale.
  2. **Intercept the Aura endpoints** — DevTools → Network → look for `POST /s/sfsites/aura?r=N&other.ProviderSearchController.search=1` patterns. Once the payload shape is captured, you can hit the Aura endpoint directly with a valid session (fragile — Salesforce regenerates tokens frequently).
- Historical blocks: direct `WebFetch` returned 403 on 2026-04-18. This is expected for Salesforce-gated portals; other Salesforce-backed state portals (TN, CO, FL) exhibit the same pattern.
- **Do not** scrape the complaint-submission surface; respect it as a write-only endpoint.
- If scraping is too brittle, **FOIA is the fallback** — Arkansas FOIA has a 3-business-day response window and is well-exercised for DHS data.

## Known Datasets / Public Records

- **NextRequest portal for DHS FOIA requests:** `https://arkansas-department-of-human-ser.nextrequest.com/` — allows public submission + lookup of others' responses.
- **childcarear.com** — AR Child Care Aware / CCR&R consumer search (no bulk dataset): `https://childcarear.com/`
- **Better Beginnings QRIS landing:** `https://arbetterbeginnings.com/`
- **DESE Office of Early Childhood:** `https://dese.ade.arkansas.gov/offices/office-of-early-childhood`
- **Arkansas Advocate** coverage of the 2023–2024 DESE database launch (historical context): `https://arkansasadvocate.com/briefs/arkansas-department-of-education-creates-searchable-child-care-provider-database/`
- **Arkansas Online** 2018 investigation into DHS ratio-violation case (precedent that Arkansas DHS does release inspection records to journalists): `https://www.arkansasonline.com/news/2018/jan/31/dhs-investigation-central-arkansas-daycare-stems-s/`
- **Crimes Against Children Division (state police):** `https://dps.arkansas.gov/law-enforcement/arkansas-state-police/divisions/crimes-against-children/` — parallel abuse-registry channel.

## FOIA / Open-Records Path

- **Arkansas Freedom of Information Act (§ 25-19-101 et seq.).** 3-business-day statutory response window.
- **DHS FOIA landing:** `https://humanservices.arkansas.gov/divisions-shared-services/shared-services/office-of-communications-community-engagement/foia/`
- **NextRequest portal:** `https://arkansas-department-of-human-ser.nextrequest.com/` — the easiest filing path; also exposes **previously-fulfilled requests** (useful to see what's been released historically).
- **Redactions:** child maltreatment registry + minor-PII redacted per Ark. Code § 12-18; facility compliance data presumed open.
- FOIA handbook (State Police, general template): `https://www.dps.arkansas.gov/wp-content/uploads/2020/07/FOIA-Handbook_18th-edition_2017-2.pdf`
- Reporters Committee open-government guide: `https://www.rcfp.org/open-government-guide/arkansas/`
- Sample template: `https://www.nfoic.org/arkansas-sample-foia-request/`

## Sources

- DCCECE (Arkansas portal): https://portal.arkansas.gov/state_agencies/department-of-human-services-dhs/division-of-child-care-and-early-childhood-education/
- DCCECE Division Policies: https://humanservices.arkansas.gov/divisions-shared-services/child-care-early-childhood-education/division-policies/
- Provider search (Salesforce): https://ardhslicensing.my.site.com/elicensing/s/search-provider/find-providers
- Provider search alt: https://ardhslicensing.my.site.com/elicensing/s/search-provider
- Complaint intake (Salesforce): https://ardhslicensing.my.site.com/elicensing/s/complaint?language=en_US
- Provider-search service wrapper: https://portal.arkansas.gov/service/ar-child-care-provider-search/
- Licensed Day Care Providers Search: https://portal.arkansas.gov/service/licensed-day-care-providers-search/
- DHS Report a Concern: https://humanservices.arkansas.gov/report-a-concern/
- DHS FOIA: https://humanservices.arkansas.gov/divisions-shared-services/shared-services/office-of-communications-community-engagement/foia/
- NextRequest DHS FOIA portal: https://arkansas-department-of-human-ser.nextrequest.com/
- Minimum Licensing Requirements (Dec 2020 PDF): https://licensingregulations.acf.hhs.gov/sites/default/files/licensing_regulation/AR_Center_Dec_2020_508.pdf
- Admin Code Rule 016.22.20-005: https://regulations.justia.com/states/arkansas/agency-016/division-22/rule-016-22-20-005/
- DESE Office of Early Childhood: https://dese.ade.arkansas.gov/offices/office-of-early-childhood
- Better Beginnings: https://arbetterbeginnings.com/
- Arkansas CCR&R (childcarear.com): https://childcarear.com/
- Arkansas Advocate — DESE database launch: https://arkansasadvocate.com/briefs/arkansas-department-of-education-creates-searchable-child-care-provider-database/
- Arkansas Online — 2018 daycare investigation: https://www.arkansasonline.com/news/2018/jan/31/dhs-investigation-central-arkansas-daycare-stems-s/
- Crimes Against Children Division: https://dps.arkansas.gov/law-enforcement/arkansas-state-police/divisions/crimes-against-children/
- Reporters Committee AR guide: https://www.rcfp.org/open-government-guide/arkansas/
- AR FOIA sample request: https://www.nfoic.org/arkansas-sample-foia-request/
- AR FOIA Handbook (PDF): https://www.dps.arkansas.gov/wp-content/uploads/2020/07/FOIA-Handbook_18th-edition_2017-2.pdf
