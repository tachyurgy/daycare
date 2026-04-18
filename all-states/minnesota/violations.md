# Minnesota — Violations, Inspections & Licensing Orders

> How Minnesota publishes compliance history, correction orders, licensing actions, and maltreatment findings for licensed child care centers.

## Violations / Inspection Data Source

Primary public-facing systems (all free, no login):

- **DHS Licensing Information Lookup (LIL)** — https://licensinglookup.dhs.state.mn.us/
  Per-provider detail pages at `https://licensinglookup.dhs.state.mn.us/Details.aspx?l={License_Nu}` — mirror of the state's licensing record for every DHS/DCYF-licensed program (child care centers, family child care, certified centers, plus unrelated DHS-licensed services).
- **DCYF Licensing Inspections for Child Care Centers** — https://dcyf.mn.gov/licensing-inspections-child-care-centers
  Narrative pages describing inspection cadence, the "Early and Often" monitoring model, and how correction orders are issued and published.
- **Parent Aware — Understanding Licensing Records** — https://www.parentaware.org/understanding-licensing-records/
  Consumer-facing explainer of what LIL posts and how to read it.

Key access URLs for bulk or systematic pulls:

- **Minnesota Geospatial Commons — Family and Child Care Centers, Minnesota** — https://gisdata.mn.gov/dataset/econ-child-care (roster / locations only; no violations).
- **MN Data Practices Act request** — https://mn.gov/dhs/general-public/about-dhs/data-requests/index.jsp (required for bulk violation/action extracts).

## Data Format

| Item | Format |
|---|---|
| LIL per-facility detail page | HTML, Microsoft Dynamics + ASP.NET (Details.aspx?l={license_number}); correction-order PDFs linked out |
| Correction orders | PDF (posted 3 days after monitoring visit, retained 4 years) |
| Licensing actions (suspend, revoke, conditional, fine) | PDF |
| Maltreatment investigative memoranda | PDF |
| Roster of centers / homes | ESRI Shapefile, FGDB, GPKG (Geospatial Commons), ~8,571 rows |
| Bulk export of violations | **Not published.** Must request via Data Practices Act |

**Dynamic behaviour:** the LIL search page uses server-side postbacks. Deep-links to detail pages are simple GETs (`Details.aspx?l=1076213` works without session). A scraper can iterate the license-number range or pull `License_Nu` from the Geospatial Commons shapefile and hit the detail URL directly.

## Freshness

- **Monitoring visit results are posted 3 days after the visit is complete.**
- **Correction orders, licensing actions, and maltreatment findings remain posted for 4 years** (per DHS/DCYF public-data policy).
- **Roster dataset (Geospatial Commons)** was last updated April 3, 2023 — continues to mirror DHS licensing data but is not a live feed; verify status via LIL.

## Key Fields (LIL detail page)

- License number, license type, license status (active, conditional, suspended, revoked)
- License holder name; on-site contact
- Program address, service/age types
- Initial effective date, expiration date
- Capacity
- **Correction orders**: category of violation, plain-language summary, corrective action taken by provider, date
- **Licensing actions**: conditional license, fines, suspensions, revocations — posted with effective date
- **Maltreatment investigations**: investigative memorandum with finding (maltreatment determined / not determined / inconclusive)

## Scraping / Access Strategy

Recommended pipeline:

1. **Seed** — pull the ~8,571 `License_Nu` values from the Geospatial Commons shapefile (https://resources.gisdata.mn.gov/pub/gdrs/data/pub/us_mn_state_mngeo/econ_child_care/shp_econ_child_care.zip). Filter to Child Care Center + Certified Child Care Center (~2,376 rows).
2. **Fetch** — `GET https://licensinglookup.dhs.state.mn.us/Details.aspx?l={License_Nu}` for each license number. Low rate (~1-2 req/sec) is polite.
3. **Parse** — HTML tables for license status, correction-order list, licensing-actions list, maltreatment list. Follow PDF links for full order text.
4. **Refresh** — weekly refresh is sufficient given the 3-day posting lag. Diff against prior snapshot to generate "new correction order" alerts per center.
5. **Fallback** — for license numbers not surfaced in the shapefile (new/renewed since April 2023), do a name search via LIL's AJAX search endpoint (`Search.aspx` postback) or request the current roster via MDPA.

## Known Datasets / Public Records

- **Geospatial Commons child-care dataset** (licensees, no violations) — https://gisdata.mn.gov/dataset/econ-child-care
- **DCYF "Licensing inspections" provider page** — https://dcyf.mn.gov/licensing-inspections-child-care-centers
- **DHS monitoring publication — DHS-6385-ENG "Monitoring Licensed Child Care"** (practitioner guide) — https://edocs.dhs.state.mn.us/lfserver/Public/DHS-6385-ENG

Media / research:

- **Star Tribune** has long covered Minnesota child care safety failures and fraud — e.g., "viral video prompts new scrutiny of alleged fraud" (Jan 2026) https://www.startribune.com/viral-video-prompts-new-scrutiny-of-alleged-fraud-and-draws-quick-reaction-from-mn-regulators/601554058 and "Minnesota pauses licenses for new adult day care centers amid fraud concerns" https://www.startribune.com/minnesota-pauses-licenses-for-new-adult-day-care-centers-amid-fraud-concerns/601546733
- **KSTP 5 Eyewitness News** — "62 investigations underway involving federally-funded Minnesota child care centers" — https://kstp.com/kstp-news/top-news/62-investigations-underway-involving-federally-funded-minnesota-child-care-centers/
- **Minnesota House Session Daily** — oversight coverage of child care fraud hearings — https://www.house.mn.gov/sessiondaily/Story/18508
- **19th News fact check on MN child care fraud (Jan 2026)** — https://19thnews.org/2026/01/child-care-fraud-minnesota-fact-check/

These stories reference LIL records (correction orders, revocations) as the public evidence; the Star Tribune archive has multiple multi-part investigations going back to 2017 ("A License to Operate," etc.) that cite MDPA records.

## FOIA / Open-Records Path

Minnesota Government Data Practices Act (Minn. Stat. Ch. 13) — not technically a FOIA, but functionally equivalent.

- **Submit:** https://mn.gov/dhs/general-public/about-dhs/data-requests/index.jsp (for DHS records) or email DCYF Data Practices liaison (listed on https://dcyf.mn.gov/).
- **Turnaround:** MDPA requires "reasonable time and without delay" — in practice 10-30 business days for a defined request.
- **Cost:** nominal per-page copy fees; waivable for electronic records.
- **Scope request template:** "All correction orders, licensing actions, and maltreatment determinations issued against child care centers (license types `Child Care Center` and `Certified Child Care Center`) for the period 2022-01-01 to present, in machine-readable format (CSV/JSON) including provider name, license number, order date, violation citation, finding, and corrective action."

DHS routinely fulfills compliance-record requests; bulk extract of correction orders has been provided to media outlets and advocacy groups in past cycles.

## Sources

- DHS Licensing Information Lookup: https://licensinglookup.dhs.state.mn.us/
- Sample detail page: https://licensinglookup.dhs.state.mn.us/Details.aspx?l=1076213
- DCYF Licensing Inspections for Child Care Centers: https://dcyf.mn.gov/licensing-inspections-child-care-centers
- DHS Monitoring Licensed Child Care (DHS-6385-ENG): https://edocs.dhs.state.mn.us/lfserver/Public/DHS-6385-ENG
- Parent Aware — Understanding Licensing Records: https://www.parentaware.org/understanding-licensing-records/
- MN Geospatial Commons — Child Care: https://gisdata.mn.gov/dataset/econ-child-care
- MN DHS Data Requests portal: https://mn.gov/dhs/general-public/about-dhs/data-requests/index.jsp
- Minn. Stat. Chapter 13 (MGDPA): https://www.revisor.mn.gov/statutes/cite/13
- Star Tribune — viral video scrutiny (Jan 2026): https://www.startribune.com/viral-video-prompts-new-scrutiny-of-alleged-fraud-and-draws-quick-reaction-from-mn-regulators/601554058
- Star Tribune — adult day care license pause (2026): https://www.startribune.com/minnesota-pauses-licenses-for-new-adult-day-care-centers-amid-fraud-concerns/601546733
- KSTP — 62 investigations: https://kstp.com/kstp-news/top-news/62-investigations-underway-involving-federally-funded-minnesota-child-care-centers/
- MN House Session Daily (oversight): https://www.house.mn.gov/sessiondaily/Story/18508
- 19th News fact-check (Jan 2026): https://19thnews.org/2026/01/child-care-fraud-minnesota-fact-check/
