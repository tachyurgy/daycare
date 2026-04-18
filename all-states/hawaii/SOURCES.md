# Hawaii — Data Sources & Lead Provenance

**Compiled:** 2026-04-18
**State slug:** hawaii
**Leads CSV:** `/Users/magnusfremont/Desktop/daycare/hawaii_leads.csv`

## Primary Data Source (used for leads)

**Hawaii Statewide GIS — Preschools dataset (ArcGIS Hub)**
- Dataset landing page: https://opendata.hawaii.gov/dataset/preschools
- Direct CSV endpoint: https://prod-histategis.opendata.arcgis.com/api/download/v1/items/9c29d1a0e812454980ff133cac944611/csv?layers=6
- Format: CSV (ArcGIS Feature Service export)
- Rows in source: 521
- Rows used in leads CSV: **469** (filtered to `type` starting with "Licensed" — excludes DOE public schools and charters)
- Fields available: X/Y coords, objectid, name, address, city, zip, island_dist, type, source
- Source attribution within dataset: PATCH Hawaii (2021-12)
- Limits: Dataset is "as of December 2021"; does NOT include provider phone numbers, email, or website URLs. Fresher live data is behind the interactive DHS provider search portal (no bulk export).

## Regulatory / Compliance Sources

- **Hawaii DHS — Child Care Licensing:** https://humanservices.hawaii.gov/bessd/child-care-program/child-care-licensing/
- **Hawaii Child Care Provider Search:** https://childcareprovidersearch.dhs.hawaii.gov/
- **HAR 17-892.1 (Group Child Care Centers/Homes) full text PDF:** https://humanservices.hawaii.gov/bessd/files/2013/01/HAR_17-892.1-Group-Child-Care-Center-and-Group-Child-Care-Home-Rules.pdf
- **HAR 17-895.1 (Infant/Toddler Child Care Centers) full text PDF:** https://humanservices.hawaii.gov/wp-content/uploads/2013/11/HAR_17-895-Infant-and-Toddler-Child-Care-Center-Rules.pdf
- **HAR 17-892.1-18 (Ratios) on Cornell LII:** https://www.law.cornell.edu/regulations/hawaii/Haw-Code-R-SS-17-892-1-18
- **PATCH — DHS Early Childhood Registry:** https://patchhawaii.org/programs/dhs-hawaii-early-childhood-registry/
- **National Database of Child Care Licensing Regulations (ACF — HI):** https://licensingregulations.acf.hhs.gov/licensing/states-territories/hawaii

## Sources Considered but Not Used

- **DHS Child Care Provider Search Portal (childcareprovidersearch.dhs.hawaii.gov):** Public search UI, filters by island/age/type, but no bulk export or public API. Not suitable for bulk lead ingest.
- **childcarecenter.us:** Third-party directory aggregator. State-level page redirected to homepage on fetch and could not return county/city pages reliably. Unused.
- **Yelp / Yellow Pages:** Contain marketing listings (many unlicensed or not currently operating). Risk of noise; not used.

## Known Limitations

- **No phone / email / website** in the primary CSV — leads must be enriched via targeted scraping or manual lookup before outbound calling.
- **Dataset is ~4 years stale (2021-12)**. Hawaii has had meaningful churn since — expect a double-digit-percent error rate on whether a given facility is still operating.
- **Family Child Care Homes are under-represented** in the GIS dataset (it's largely centers + licensed group homes). Hawaii registers ~650 FCCHs that are not in this file.
- **Address-level phone numbers should be obtained** from the live DHS Provider Search before outreach. The addresses in the CSV are reliable; PATCH's own referral team is also a good enrichment channel.

## Refresh Strategy

Re-pull the CSV quarterly (ArcGIS endpoint is stable). For full live data (FCCHs, current phone), build a targeted scraper against the DHS Provider Search portal or request a flat file from DHS via public records request (HRS Chapter 92F).
