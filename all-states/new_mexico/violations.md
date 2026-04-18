# New Mexico — Child Care Violations & Inspection Data Research

**State rank:** 36  
**Collection date:** 2026-04-18  
**Licensing authority:** New Mexico Early Childhood Education and Care Department (ECECD) — Regulatory Oversight Unit (Child Care Services Bureau)

## Violations / Inspection Data Source (URLs)

- **ECECD Child Care Licensed & Registered Provider Inspection Surveys (primary):** https://www.nmececd.org/child-care-services/child-care-licensed-and-registered-provider-inspection-surveys/
- **ECECD Child Care Finder (per-facility page with complaint history):** https://childcare.ececd.nm.gov/search
- **ECECD Child Care Finder alternate entry:** https://childcare.ececd.nm.gov/al/new
- **NewMexicoKids verification portal:** https://search.newmexicokids.org/
- **ECECD Regulatory Oversight Unit:** https://www.nmececd.org/child-care-licensing-and-registered-homes/
- **Complaint intake hotline:** 1-888-351-0037
- **Complaint email:** ChildCare.Complaint@state.nm.us
- **IPRA public-records request portal:** https://www.nmececd.org/inspection-of-public-records-act-ipra/
- **IPRA records custodian:** ececd.records@ececd.nm.gov
- **Universal Child Care regulations update (Oct 2025):** https://www.nmececd.org/wp-content/uploads/2025/10/UCC-Provider-Update-on-Final-Regulations_10.24.25.pdf

## Data Format

- **Per-facility inspection surveys (PDF)** hosted on the ECECD website under the Inspection Surveys index page. Covers **last 3 years** of inspection records; older surveys require IPRA request.
- **No bulk CSV/JSON** of surveys or violations.
- **Child Care Finder** (`childcare.ececd.nm.gov`) is the public search UI. Interactive filtered search only; no list-all export. Some per-facility records expose a Complaints / History panel with substantiated complaint summaries.
- **NewMexicoKids search** (`search.newmexicokids.org/mariosearch`) accepts `{fullname, zip}` and returns yes/no registration verification &mdash; not a bulk enumeration tool.
- ECECD explicitly states they do **not** store full address info centrally at NewMexicoKids (only city/county/ZIP).

## Freshness

- Inspection surveys updated within the Surveys landing page as ECECD staff upload them post-visit.
- 3-year retention window &mdash; older data via IPRA only.
- No published data-refresh timestamp.
- New "Universal Child Care" (UCC) program regulations finalized **October 2025**; phase-in of new provider contract obligations across 2025-2026. UCC-participating providers have additional oversight, so expect richer enforcement data going forward.

## Key Fields (per survey)

- Facility name, license/registration number
- Address, city, county, ZIP
- Survey date and type (initial / renewal / complaint / follow-up / annual)
- Cited regulation section (8.16.2 NMAC subsection)
- Narrative observation / finding
- Corrective action deadline
- Signed acknowledgment by licensee
- (On complaint surveys) substantiation status

## Scraping / Access Strategy

1. **Surveys page** is the main enumeration surface. Download the static index + per-provider PDF survey files; parse PDFs with `pdfplumber` or `pdfminer.six`.
2. **Seed list:** use our 770-row `new_mexico_leads.csv` plus the ECECD Child Care Finder's county / city filter results to expand coverage to registered homes not in the childcarecenter.us aggregator.
3. **Child Care Finder** queries are JavaScript-rendered; use Playwright to iterate county filter values and paginate results; extract provider IDs / detail URLs.
4. **For violation-level completeness**: file IPRA requests (sanctioned) rather than rely on the 3-year window of surveys alone.
5. **Match keys:** ECECD provider IDs + (name, city, ZIP) as composite key; match to `new_mexico_leads.csv` via fuzzy name-city match.

## Known Datasets / Public Records

- **No open-data portal listing.** `data.nm.gov` does not host ECECD provider data.
- **No HIFLD mirror** located.
- **Inspection Surveys page** is the authoritative per-facility PDF repository (3-year window).
- **Searchlight New Mexico** coverage of the Universal Child Care rollout (January 2026): <em>"Growing pains: Challenges emerge as New Mexico rolls out no-cost child care for all"</em> &mdash; https://searchlightnm.org/growing-pains-challenges-emerge-as-new-mexico-rolls-out-no-cost-child-care-for-all/
- Prior CYFD-era reporting (pre-2021 transfer) may be under different URLs; not currently indexed from ECECD site but accessible via IPRA.

## FOIA / Open-records Path

- **New Mexico Inspection of Public Records Act (IPRA)**, NMSA 1978 &sect;14-2-1 et seq.
- **ECECD IPRA portal:** https://www.nmececd.org/inspection-of-public-records-act-ipra/
- **Records custodian email:** ececd.records@ececd.nm.gov
- **Records custodian address:** 1120 Paseo De Peralta, Santa Fe, NM 87501
- Statutory response: records must be provided "immediately or as soon as practicable," no later than **15 calendar days** after request (with reasonable extension if overly burdensome).
- Suggested request: "All inspection surveys and violation findings for ECECD-licensed and -registered child care providers, calendar years 2020-2026, in machine-readable (CSV/XLSX) format." Justify detailed ask by referencing 8.16.2.16 NMAC inspection records retention.

## Sources

- ECECD Inspection Surveys index &mdash; https://www.nmececd.org/child-care-services/child-care-licensed-and-registered-provider-inspection-surveys/
- ECECD Child Care Finder &mdash; https://childcare.ececd.nm.gov/search
- NewMexicoKids search &mdash; https://search.newmexicokids.org/
- ECECD Regulatory Oversight Unit &mdash; https://www.nmececd.org/child-care-licensing-and-registered-homes/
- ECECD IPRA request process &mdash; https://www.nmececd.org/inspection-of-public-records-act-ipra/
- NM Department of Justice IPRA guidance &mdash; https://nmdoj.gov/get-help/inspection-of-public-records-act/
- Searchlight New Mexico &mdash; UCC rollout coverage &mdash; https://searchlightnm.org/growing-pains-challenges-emerge-as-new-mexico-rolls-out-no-cost-child-care-for-all/
- Universal Child Care provider update (Oct 2025) &mdash; https://www.nmececd.org/wp-content/uploads/2025/10/UCC-Provider-Update-on-Final-Regulations_10.24.25.pdf
- 8.16.2 NMAC Child Care Licensing &mdash; https://www.nmececd.org/wp-content/uploads/2021/09/8.16.2-NMAC-0004.pdf
- ACF National Child Care Licensing Database &mdash; https://licensingregulations.acf.hhs.gov/licensing/states-territories/new-mexico
