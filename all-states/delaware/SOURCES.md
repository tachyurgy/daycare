# Delaware — Data Sources & Lead Provenance

**Compiled:** 2026-04-18
**State slug:** delaware
**Leads CSV:** `/Users/magnusfremont/Desktop/daycare/delaware_leads.csv`

## Primary Data Source (used for leads)

**Delaware Open Data Portal — "Licensed Child Care Providers and Facilities sorted by County and Capacity" (Socrata).**

- Dataset landing page (alternate ID): https://data.delaware.gov/Human-Services/Licensed-Child-Care-Providers-and-Facilities/iuzd-3dbt/data
- Dataset landing page (county/capacity sort): https://data.delaware.gov/Human-Services/Licensed-Child-Care-Providers-and-Facilities-sorte/jxu7-wnw2
- Direct CSV endpoint used: `https://data.delaware.gov/resource/jxu7-wnw2.csv?$limit=50000`
- Format: CSV via Socrata Open Data API (SODA); JSON variant available at same root with `.json`
- Total rows in dataset: 1,250
- Rows in leads CSV: **1,250** (all rows retained)
- Fields in source: resource_id, site_county, resource_name, resource_name_reversed, resource_type, enforcement_action, intent_to_revoke, site_street_address, site_city, site_state, site_zip_code, phone_number, age_range, capacity, site_opens_at, site_closes_at, special_conditions, financial_arrangements, count
- Fields mapped into leads CSV: business_name (resource_name — title-cased from all-caps), city (title-cased), state (`DE`), phone_number

## Why this source is gold-tier

- **Authoritative.** Data is published by the State of Delaware via its Socrata open-data portal.
- **Full coverage.** Every licensed provider in Delaware appears — both centers and family homes.
- **Includes phone numbers.** Uncommon at this level of completeness among U.S. states.
- **Includes capacity, hours, age range, and enforcement action flags.** Rich enough for multi-dimensional ICP segmentation (child-care center vs. large family vs. family; capacity tiers; whether any enforcement action is pending).
- **Live / near-live.** Socrata dataset is refreshed periodically by DOE OCCL.
- **Stable API.** Socrata SODA v2.1 is a long-established contract.

## Breakdown by Resource Type (source)

| Type | Approx. count |
|---|---|
| Licensed Child Care Center | ~540 |
| Licensed Large Family Child Care | ~80 |
| Licensed Family Child Care | ~630 |

## Regulatory / Compliance Sources

- **DOE Office of Child Care Licensing (landing):** https://education.delaware.gov/families/birth-age-5/occl/
- **OCCL Regulations and Exemptions:** https://education.delaware.gov/families/birth-age-5/occl/regulations_and_exemptions/
- **DELACARE Regulations for Centers (Nov 2020 PDF):** https://education.delaware.gov/wp-content/uploads/2020/11/occl_delacare-regulations-center_2020.pdf
- **DELACARE Regulations for Family and Large Family Child Care Homes (Aug 2022 PDF):** https://education.delaware.gov/wp-content/uploads/2022/08/DELACARE-FCCH-LFCCH-Regulations-August-2022.pdf
- **14 DE Admin. Code 101 (Centers):** https://regulations.delaware.gov/AdminCode/title9/Division%20of%20Family%20Services%20Office%20of%20Child%20Care%20Licensing/100/101.shtml
- **Search for Licensed Child Care (public search):** https://education.delaware.gov/families/birth-age-5/occl/search_for_licensed_child_care/
- **National Database (ACF — DE):** https://licensingregulations.acf.hhs.gov/licensing/states-territories/delaware
- **Public Health Law Center — DE:** https://www.publichealthlawcenter.org/resources/healthy-child-care/de

## Supplementary Open Datasets (not used in this pass, valuable for future enrichment)

- **"Licensed Child Care Provider/Facility by Age Group":** https://data.delaware.gov/Human-Services/Licensed-Child-Care-Provider-Facility-by-Age-Group/b2xx-x2v9 — same provider universe, faceted by age groups served.
- **"Child Care Providers by STARS Level":** https://data.delaware.gov/Human-Services/Child-Care-Providers-by-STARS-Level/ggpn-vz9t — QRIS star rating per provider. High ICP signal.

## Sources Considered but Not Used

- **childcarecenter.us:** Redundant with the state open data. Skipped.
- **DOE OCCL public search UI:** Same data as the Socrata feed, with richer complaint history per facility — viable for deep enrichment but overkill for bulk ingest.
- **My Child DE (mychildde.org):** Family-facing portal, no bulk.

## Known Limitations

- **No email addresses** — DE does not publish them. Use Hunter.io / Apollo / LinkedIn for enrichment.
- **No websites** in the dataset — the provider's own domain (if any) must be enriched separately.
- **Capacity field not mapped** into leads CSV in this pass (left in source dataset for later segmentation).
- **Phone numbers for family child care homes are provider's personal cell** in many cases — respect TCPA and DE telemarketing rules; prefer email/SMS opt-in before outbound dialing.
- **Enforcement-action / intent-to-revoke flags** are present in source but not filtered or surfaced in leads CSV — worth filtering to exclude providers under active revocation from outreach.

## Refresh Strategy

1. **Monthly** re-pull the Socrata CSV — cost is trivial, and Delaware's churn is material (openings, closures, license suspensions).
2. **Supplement with the STARS Level dataset** for segmentation; programs at STARS 3+ are more sophisticated buyers and closer to ComplianceKit's ICP.
3. **Exclude rows with `enforcement_action != null` or `intent_to_revoke == true`** before outbound — these providers are in active crisis and not a clean ICP fit.
4. **Enrich** via web scraping provider websites (where they exist) for email and additional contact paths.
