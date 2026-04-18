# Nebraska — Lead Data Sources

**Collection date:** 2026-04-18
**Output file:** `/Users/magnusfremont/Desktop/daycare/nebraska_leads.csv`
**Row count:** 2,248 facilities

## Primary Bulk Dataset

**Nebraska DHHS — Roster of Licensed Child Care and Preschool Programs**

- Direct PDF URL: https://dhhs.ne.gov/licensure/Documents/ChildCareRoster.pdf
- Landing page: https://dhhs.ne.gov/licensure/Pages/Child-Care-Licensing.aspx
- Date of printing on PDF: 4/17/2026 (updated weekly)
- 453 pages; organized by ZIP code (ascending).
- **Format:** Native PDF (text-based, not scanned). Extracted via `pdftotext -layout` then parsed with a custom Python script.
- **Fields present in source:** Provider name, license number, owner name, license type (Child Care Center / Family Child Care Home I / Family Child Care Home II / Preschool / School-Age-Only), effective date, county, street address, city, ZIP, phone, capacity, days of week open, ages served, hours of operation, currently accepts subsidy Y/N, willing-to-accept subsidy Y/N, Step Up to Quality (QRIS) level, accreditation status.
- **Updated:** weekly.

## Supplementary Bulk Dataset (Geospatial)

**NebraskaMAP — DHHS Licensed Child Care**

- Landing page: https://www.nebraskamap.gov/datasets/dhhs-licensed-child-care
- Open data portal alternate: https://www.nebraskamap.gov/datasets/nebraska::dhhs-licensed-child-care
- ArcGIS-based; provides lat/lon, full record, and exports in multiple formats.
- Not directly used in this collection (the DHHS roster PDF had more up-to-date data and richer fields), but recommended for GIS / mapping use cases.

## Transcription Notes

- Python parser walks the PDF's layout blocks (each record spans 5–6 lines due to PDF column layout).
- License-type whitelist applied: "Family Child Care Home II", "Family Child Care Home I", "Child Care Center", "Preschool", "School Age Only Center".
- City captured from `"City NE 68###"` pattern; owner-name noise stripped.
- Phone regex `\(\d{3}\)\s*\d{3}-\d{4}`; blank when source shows `() -`.
- Title-case normalization; preserved acronyms (YMCA, LLC, INC, II, III, ST, etc.).
- Trailing suffixes like "Owned By …", "Ob …" and orphan "dba" cleaned.
- Deduplicated on (name, city).

## Limitations

- Street address, capacity, and step-up-to-quality fields were captured during parsing but not retained in the final CSV (schema is fixed: business_name, city, state, phone, email, website).
- **Email** field is not part of the source roster — all rows show blank `email`.
- **Website** field is not part of the source — all rows show blank `website`.
- Some records with complex multi-line names in the PDF layout may have truncation edge-cases (< 1% of records visually checked).
- Records without a valid phone number (`() -` in source) are retained but phone is blank.

## Secondary Sources (verification)

- **Nebraska Title 391 DHHS license detail search** (per-facility disciplinary history): https://www.nebraska.gov/LISSearch/search.cgi
- **Nebraska DHHS find a provider search:** https://dhhs.ne.gov/Pages/Search-for-Child-Care-Providers.aspx
- **Step Up to Quality provider search:** https://www.nebraskachildcare.org/
- **Roster landing page:** https://dhhs.ne.gov/licensure/Pages/Child-Care-Licensing.aspx

## Rows / Coverage

- 2,248 unique licensed child care / preschool programs statewide.
- Fields populated: `business_name` (100%), `city` (~98%), `state` (100%), `phone` (~95%), `email` (0%), `website` (0%).
- Includes Family Child Care Home I, Family Child Care Home II, Child Care Center, Preschool, and School-Age-Only Center types.
