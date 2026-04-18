# Kansas — Child Care Violations & Inspection Data Research

**State rank:** 35  
**Collection date:** 2026-04-18  
**Licensing authority:** Kansas Department of Health and Environment (KDHE) — Child Care Licensing Program (transitioning to Office of Early Childhood by July 1, 2026 per HB 2045).

## Violations / Inspection Data Source (URLs)

- **KDHE OIDS — Online Facility Compliance Search (primary):** https://khap.kdhe.ks.gov/OIDS/
- **KDHE OIDS alternate host:** https://khap2.kdhe.state.ks.us/OIDS/
- **OIDS Search Tips guide (PDF):** https://www.kdhe.ks.gov/DocumentCenter/View/23686/OIDS-Search-Tips-PDF
- **Example Search Walkthrough (PDF):** https://www.kdhe.ks.gov/DocumentCenter/View/2157/Example-Search-for-a-Licensed-Child-Care-Facility-Inspection-Results-PDF
- **Facility Inspection Results landing page:** https://www.kdhe.ks.gov/386/Facility-Inspection-Results
- **Licensed Child Care Facility Inspection Results hub:** https://www.kdhe.ks.gov/386/Licensed-Child-Care-Facility-Inspection-
- **File a Complaint:** https://www.kdhe.ks.gov/381/File-a-Complaint
- **Child Care Data Request (KORA bulk data):** https://www.kdhe.ks.gov/2185/Data-Request
- **CLARIS — Provider Access Portal (auth):** https://claris.kdhe.state.ks.us:8443/claris/public/publicAccess.3mv
- **Johnson County CC Licensing (delegated authority):** https://www.jocogov.org/department/health-and-environment/child-care-licensing
- **Child Care in Kansas — Inspection Reports resource hub:** https://childcareinkansas.com/resource/inspection-reports/

## Data Format

- **Per-facility lookup only.** OIDS returns violation lists for a single facility per search. Each surveyed facility yields a list of cited regulations (KSA / KAR numbers) flagged as noncompliant at the time of survey. Compliant regulations are omitted.
- **Search-form protected by Google reCAPTCHA** and an ASP.NET ViewState (<code>Telerik.Web.UI.WebResource.axd</code> token). No list-all export.
- **Search fields:** License #, owner first/last name, facility name, program type (11 categories), county (all 105 + Out of State), city, ZIP.
- **Kansas Provider Access Portal (CLARIS)** requires login for list views &mdash; not publicly enumerable.
- **No downloadable bulk CSV/JSON.** KDHE explicitly directs bulk data seekers to the <em>Child Care Data Request</em> page (KORA — Kansas Open Records Act).
- **Historic inspection window published:** last 3 years retained on OIDS results.

## Freshness

- OIDS updated rolling as surveys are uploaded by KDHE inspection specialists (typically within days of the on-site survey).
- No public "data as of" timestamp; each inspection record carries the on-site date.
- Kansas HB 2045 (2025) transition to OEC with effective date July 1, 2026 &mdash; OIDS host & URL likely to migrate in that window; plan for redirect-handling.

## Key Fields (per facility, per inspection)

- Facility name, license number, license type
- Owner name
- Address, city, county, ZIP
- Inspection/survey date
- Inspection type (annual / initial / complaint / follow-up / monitoring)
- Cited regulation number (K.A.R. 28-4-xxx or K.S.A. 65-xxx) + short description
- Noncompliance status at time of survey
- Repeat-citation flag (if cited in consecutive visits)
- Corrective action deadlines

## Scraping / Access Strategy

1. **Bypass captcha-locked enumeration is infeasible at scale**; instead use the 770 facilities in `kansas_leads.csv` as seed.
2. **Playwright with a real browser** + solve reCAPTCHA v3 via 2Captcha / anti-captcha API; submit one license-# at a time. (Cost: ~$0.002/solve × 770 = ~$1.50.)
3. **Parse** the results table (facility header + list of cited K.A.R. sections + inspection metadata).
4. **For production**: do NOT scrape at scale; file a KORA request (see below) for the bulk export, which is the sanctioned channel.
5. **Secondary enumeration:** `childcareinkansas.com/resource/inspection-reports/` also links to OIDS content but does not bypass the captcha.

## Known Datasets / Public Records

- **No open-data portal listing.** Kansas data.kansas.gov and Kansas Geospatial Community Commons do not host KDHE's child-care roster.
- **No HIFLD mirror** located at collection time.
- **KDHE Child Care Data Request page** is the official bulk-data channel; requires KORA request, affidavit of non-commercial intent or paid copy fees. https://www.kdhe.ks.gov/2185/Data-Request
- **Investigative journalism references:**
  - <em>Flatland KC</em> (Kansas City PBS) "Child Care Crisis Challenges Families, Economy" &mdash; https://flatlandkc.org/news-issues/child-care-crisis-challenges-families-economy/
  - <em>The Beacon</em> on KS foster/group home inspection cadence &mdash; https://thebeaconnews.org/stories/2025/07/24/kansas-officials-want-to-inspect-group-foster-care-units-more-often/
  - <em>Kansas Reflector</em> &mdash; https://kansasreflector.com/2024/10/02/latest-kansas-foster-care-report-describes-big-problems-potential-for-improvement/
  - <em>Kansas Action for Children</em> media mentions &mdash; https://www.kac.org/media_mentions
  (No single "Kansas News Service" investigation of KDHE child care violations has been published to date, but the topical pattern exists around foster care.)

## FOIA / Open-records Path

- **Kansas Open Records Act (KORA)**, K.S.A. 45-215 et seq.
- Route through the **KDHE Child Care Data Request page** (https://www.kdhe.ks.gov/2185/Data-Request). Submit written request naming the records sought (e.g., "all inspection results / violation histories for licensed child care centers and family child care homes for calendar years 2023-2026, in CSV or Excel format"). Statutory response: 3 business days; reasonable extension allowed.
- Fees: copy costs + staff time (often waived for news/nonprofit/research use).
- KDHE historically delivers KORA outputs as Excel or CSV via email link.

## Sources

- KDHE OIDS &mdash; https://khap.kdhe.ks.gov/OIDS/
- OIDS Search Tips &mdash; https://www.kdhe.ks.gov/DocumentCenter/View/23686/OIDS-Search-Tips-PDF
- KDHE Facility Inspection Results &mdash; https://www.kdhe.ks.gov/386/Facility-Inspection-Results
- KDHE Child Care Data Request (KORA) &mdash; https://www.kdhe.ks.gov/2185/Data-Request
- KDHE File a Complaint &mdash; https://www.kdhe.ks.gov/381/File-a-Complaint
- CLARIS Provider Access Portal &mdash; https://claris.kdhe.state.ks.us:8443/claris/public/publicAccess.3mv
- Child Care in Kansas (inspection reports resource) &mdash; https://childcareinkansas.com/resource/inspection-reports/
- Flatland KC child care coverage &mdash; https://flatlandkc.org/news-issues/child-care-crisis-challenges-families-economy/
- KLRD 2024 regulation update &mdash; https://klrd.gov/2024/12/18/updated-child-care-regulations/
- HB 2045 (2025) &mdash; https://kslegislature.gov/li/b2025_26/measures/documents/summary_hb_2045_2025
