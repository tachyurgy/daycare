# Minnesota — Sources & Data Pull Log

**Researched:** 2026-04-18
**Lead file:** `/Users/magnusfremont/Desktop/daycare/minnesota_leads.csv`
**Lead row count:** 1,000 (plus header)

## Bulk Dataset Used

**Minnesota Geospatial Commons — Family and Child Care Centers, Minnesota**

- Dataset page: https://gisdata.mn.gov/dataset/econ-child-care
- Direct download (Shapefile ZIP, 801 KB): https://resources.gisdata.mn.gov/pub/gdrs/data/pub/us_mn_state_mngeo/econ_child_care/shp_econ_child_care.zip
- Format: ESRI Shapefile + DBF (also available: FGDB, GPKG)
- Source update date on dataset page: April 3, 2023 (state continues to mirror DHS licensing data)
- Total records in dataset: **8,571**
- Records after filtering to center-class facilities (excludes "Family Child Care"): **2,376**
  - 2,376 of 8,571 are `Child Care Center` or `Certified Child Care Center`
  - Remainder are `Family Child Care` (home-based)
- Schema (DBF fields): `License_Nu`, `License_Ty`, `Name_of_Pr`, `AddressLin`, `AddressL_1`, `City`, `State`, `Zip`

Extraction performed with Python + `dbfread`. First 1,000 centers (sorted with Child Care Centers first, then Certified, alphabetical by name) were transcribed to the leads CSV.

## Limits

- **Phone, email, website** are blank in the dataset and in MN's licensing lookup — DHS/DCYF does not publish licensee phone numbers or emails in the downloadable file. To fill these columns, either scrape each Licensing Information Lookup detail page (`licensinglookup.dhs.state.mn.us/Details.aspx?l={License_Nu}`) or cross-reference commercial directories (ChildCareCenter.us, Yelp, Google Business). Not done in this pass to avoid fabrication.
- **Address fields** (AddressLin / AddressL_1) are present in the dataset but were not required by the leads CSV header, so they were omitted. Re-run if needed.
- Dataset last geocoded in April 2023; a small percentage of facilities may have closed or moved. The DHS Licensing Information Lookup is the source of truth for real-time status.

## Public Search Tools

- DHS Licensing Information Lookup (real-time): https://licensinglookup.dhs.state.mn.us/
- DCYF inspections / corrections: https://dcyf.mn.gov/licensing-inspections-child-care-centers
- Parent Aware (QRIS provider search): https://www.parentaware.org/

## Regulatory / Compliance Source URLs

- Minnesota Rules Chapter 9503: https://www.revisor.mn.gov/rules/9503/
- Minnesota Rule 9503.0040 (Staff Ratios & Group Size): https://www.revisor.mn.gov/rules/9503.0040/
- Minnesota Rule 9503.0075 (Drop-in and School-Age programs): https://www.revisor.mn.gov/rules/9503.0075/
- MN DHS Ratio and Group Size Standards (PDF summary): https://mn.gov/dhs/assets/ratio-and-group-size-standards-for-licensed-child-care_tcm1053-340437.pdf
- ACF Licensing Regulations Database — MN Chapter 9503 (Oct 2021): https://licensingregulations.acf.hhs.gov/sites/default/files/licensing_regulation/MN_CENTER_OCT_2021_508.pdf
- DCYF (new licensing authority) — https://dcyf.mn.gov/
- DCYF Forms for Licensed Child Care Centers: https://dcyf.mn.gov/forms-licensed-child-care-centers
- DCYF Phases of Application: https://dcyf.mn.gov/phases-application-process-child-care-center-certification
- Minn. Stat. 245A (Human Services Licensing Act): https://www.revisor.mn.gov/statutes/cite/245A
- Minn. Stat. 245C (Background Studies): https://www.revisor.mn.gov/statutes/cite/245C
