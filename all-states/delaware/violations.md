# Delaware — Violations & Inspection Data Research

**Compiled:** 2026-04-18
**State slug:** delaware

## Violations / Inspection Data Source (URLs)

- **Primary — Compliance Review Information (Socrata):** https://data.delaware.gov/Human-Services/Child-Care-Licensing-Compliance-Review-Information/wb83-pkcv
- **Primary — Complaint Reviews (Socrata):** https://data.delaware.gov/Human-Services/Child-Care-Licensing-Complaint-Reviews/pnbd-85r6
- **Provider roster (used for leads):** https://data.delaware.gov/Human-Services/Licensed-Child-Care-Providers-and-Facilities/iuzd-3dbt
- **STARS QRIS (segmentation):** https://data.delaware.gov/Human-Services/Child-Care-Providers-by-STARS-Level/ggpn-vz9t
- **Consumer search UI:** https://education.delaware.gov/families/birth-age-5/occl/search_for_licensed_child_care/
- **Make a Complaint:** https://education.delaware.gov/families/birth-age-5/occl/make_a_complaint/
- **Statutory open-records basis:** 29 Del. C. §10002 et seq. — Delaware Freedom of Information Act (FOIA).

## Data Format

**Delaware is a two-dataset gold mine via the Socrata Open Data API (SODA v2.1).**

### Dataset 1: Child Care Licensing Compliance Review Information (`wb83-pkcv`)

- **Rows (as of 2026-04-18):** ~12,428
- **CSV endpoint:** `https://data.delaware.gov/resource/wb83-pkcv.csv?$limit=50000`
- **JSON endpoint:** `https://data.delaware.gov/resource/wb83-pkcv.json?$limit=50000`
- **Fields:**
  - `license_number` — facility ID (joins to provider roster)
  - `provider_name` — facility name
  - `facility_regulation_status` — "Non-Compliance" / "Compliant"
  - `provider_action_type_of_action` — inspection classification
  - `provider_action_date_of_visit` — inspection date
  - `facility_visit_type` — monitoring type
  - `regulation_code` — DELACARE rule number (e.g., §53.0, etc.)
  - `regulation_short_desc` — violation category
  - `regulation_correction_due` — CAP deadline
  - `regulation_correction_status` — remediation status
  - `regulation_corrected_date` — when corrected
  - `regulation_how_corrected` — narrative method
  - `regulation_corrective_action` — action required

### Dataset 2: Child Care Licensing Complaint Reviews (`pnbd-85r6`)

- **Rows (as of 2026-04-18):** ~1,942
- **CSV endpoint:** `https://data.delaware.gov/resource/pnbd-85r6.csv?$limit=50000`
- **JSON endpoint:** `https://data.delaware.gov/resource/pnbd-85r6.json?$limit=50000`
- **Fields:**
  - `resource_id` — facility ID (joins to provider roster)
  - `investigation_type` — e.g., "OCCL Standards Complaint"
  - `investigation_completed` — ISO 8601 timestamp
  - `investigation_result` — "Substantiated" / "No Evidence to Substantiate" / "Unsubstantiated"
  - `investigation_conclusion` — narrative text (full investigator finding)

## Freshness

- **Retention:** Last 5 years of non-compliance findings, complaints, and enforcement actions are surfaced on the public OCCL search (longer than the typical 3-year CCDBG window).
- **Refresh cadence:** Socrata datasets are refreshed periodically by DOE OCCL; exact cadence unpublished but real-world drift appears to be days-to-weeks.
- **API is stable** — SODA v2.1 is a long-standing contract.

## Key Fields — Joined Analysis Potential

Because both violation datasets include `license_number` / `resource_id` as join keys to the provider roster (`iuzd-3dbt` / `jxu7-wnw2`), it is straightforward to build a per-facility compliance profile:

```
provider roster (1,250) ⟕ compliance reviews (12,428) ⟕ complaint reviews (1,942)
```

This enables ComplianceKit-grade segmentation:
- Providers with any non-compliance finding in last 12 months (high-intent ICP)
- Providers with substantiated complaints (urgent ICP)
- Providers with >3 regulation_corrected_late records (chronic ICP — core buyer)
- Providers with zero findings (pristine; segment out — don't need the tool)

## Scraping / Access Strategy

1. **NO scraping required.** Delaware publishes three machine-readable datasets via Socrata that cover providers, compliance reviews, and complaint outcomes.
2. **Recommended pipeline:**
   ```
   GET https://data.delaware.gov/resource/iuzd-3dbt.csv?$limit=50000       (provider roster)
   GET https://data.delaware.gov/resource/wb83-pkcv.csv?$limit=50000       (compliance findings)
   GET https://data.delaware.gov/resource/pnbd-85r6.csv?$limit=50000       (complaints)
   GET https://data.delaware.gov/resource/ggpn-vz9t.csv?$limit=50000       (STARS rating)
   ```
3. **Socrata filters** (SoQL) enable targeted pulls:
   - `$where=provider_action_date_of_visit > '2025-01-01'` — recent findings only
   - `$where=investigation_result='Substantiated'` — substantiated complaints
   - `$where=regulation_correction_status != 'Corrected'` — open deficiencies
4. **No API key needed** for anonymous use; rate-limited to ~1,000 req/hour. For higher throughput, register a free app token at https://dev.socrata.com.
5. **Quarterly (at minimum) re-pull** — DE's 5-year retention + active publishing cadence means the dataset is live enough to be a weekly asset.

## Known Datasets / Public Records

- **Licensed Child Care Providers and Facilities (roster):** https://data.delaware.gov/Human-Services/Licensed-Child-Care-Providers-and-Facilities/iuzd-3dbt
- **…sorted by County & Capacity (alt roster):** https://data.delaware.gov/Human-Services/Licensed-Child-Care-Providers-and-Facilities-sorte/jxu7-wnw2
- **Compliance Review Information:** https://data.delaware.gov/Human-Services/Child-Care-Licensing-Compliance-Review-Information/wb83-pkcv
- **Complaint Reviews:** https://data.delaware.gov/Human-Services/Child-Care-Licensing-Complaint-Reviews/pnbd-85r6
- **STARS QRIS Level:** https://data.delaware.gov/Human-Services/Child-Care-Providers-by-STARS-Level/ggpn-vz9t
- **By Age Group:** https://data.delaware.gov/Human-Services/Licensed-Child-Care-Provider-Facility-by-Age-Group/b2xx-x2v9
- **OCCL Public Search (UI):** https://education.delaware.gov/families/birth-age-5/occl/search_for_licensed_child_care/

## FOIA / Open-Records Path

(Not strictly necessary given the Socrata coverage — but useful as backstop for datasets older than 5 years, for raw inspection PDFs, and for enforcement-action details not surfaced in Socrata.)

- **Statute:** 29 Del. C. §10002 et seq. — Delaware FOIA.
- **Submit to:** DOE FOIA Coordinator (see https://education.delaware.gov). Cc OCCL.
- **Suggested request scope:** "Pursuant to 29 Del. C. §10003, I request electronic copies of: (1) all inspection reports and enforcement actions (suspensions, revocations, conditional licenses) for Delaware-licensed child care providers from [DATE] to [DATE]; (2) any records older than five years not currently published on data.delaware.gov; (3) any aggregated compliance trend reports produced internally by OCCL. CSV/Excel preferred."
- **Response window:** 15 business days (§10003(h)(1)).
- **Fees:** Copy fees per §10003(m); 4 hours of search time free for non-commercial requests.
- **Appeals:** Delaware Attorney General under 29 Del. C. §10005.

## Sources

- DOE Office of Child Care Licensing: https://education.delaware.gov/families/birth-age-5/occl/
- OCCL Regulations and Exemptions: https://education.delaware.gov/families/birth-age-5/occl/regulations_and_exemptions/
- Search for Licensed Child Care: https://education.delaware.gov/families/birth-age-5/occl/search_for_licensed_child_care/
- About the Search for Child Care: https://education.delaware.gov/families/birth-age-5/occl/about_the_search_for_child_care/
- Make a Complaint: https://education.delaware.gov/families/birth-age-5/occl/make_a_complaint/
- DELACARE Center Regulations (2020 PDF): https://education.delaware.gov/wp-content/uploads/2020/11/occl_delacare-regulations-center_2020.pdf
- DELACARE FCCH/LFCCH Regulations (Aug 2022 PDF): https://education.delaware.gov/wp-content/uploads/2022/08/DELACARE-FCCH-LFCCH-Regulations-August-2022.pdf
- 14 DE Admin. Code 101: https://regulations.delaware.gov/AdminCode/title9/Division%20of%20Family%20Services%20Office%20of%20Child%20Care%20Licensing/100/101.shtml
- Delaware Open Data Portal — childcare tag: https://stateofdelaware.data.socrata.com/browse?tags=childcare
- 29 Del. C. §10002 (FOIA): https://delcode.delaware.gov/title29/c100/index.html
- Socrata SODA 2.1 docs: https://dev.socrata.com/docs/endpoints.html
- My Child DE: https://mychildde.org/
- Public Health Law Center — DE: https://www.publichealthlawcenter.org/resources/healthy-child-care/de
- National Database (ACF — DE): https://licensingregulations.acf.hhs.gov/licensing/states-territories/delaware
