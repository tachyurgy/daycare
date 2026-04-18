# Wisconsin — Lead Data Sources

**Date collected:** 2026-04-18

## Primary Source

- **URL:** https://dcf.wisconsin.gov/files/ccdir/lic/excel/LCC%20Directory.xlsx
- **Publisher:** Wisconsin Department of Children and Families (DCF), Bureau of Early Care Regulation
- **Format:** Microsoft Excel (.xlsx, ~730 KB)
- **Page/Index:** https://dcf.wisconsin.gov/cclicensing/lcc-directories
- **File freshness stamp in header:** "Last Refreshed Date : 4/17/26" (refreshed daily)
- **Raw rows in workbook:** 4,247 rows (header + data + trailing blanks)
- **Parsed unique providers:** 4,242 licensed programs statewide (centers + family + group homes)
- **Rows written to `wisconsin_leads.csv`:** 1,000 (capped per spec)
- **Fields captured:** business_name (Facility Name), city (City), state (WI), phone (Contact Phone normalized to `(XXX) XXX-XXXX`)
- **Fields NOT captured:** email, website (not in workbook)

## Data Columns Available (for potential enrichment)

The source workbook contains: Provider Number, Location Number, Application Type (LICENSED GROUP / LICENSED FAMILY / SCHOOL-BASED), County, Facility Name, Facility Number, Line Address 1, Line Address 2, City, Zip Code, Contact Name, Contact Phone, Licensed Date, Capacity, From Age, To Age, Hours, Months, Full Time (Y/N), Star Level (YoungStar rating).

## Secondary Sources Explored

- https://dcf.wisconsin.gov/cclicensing — main licensing hub
- https://childcarefinder.wisconsin.gov/ — consumer-facing directory (interactive, uses same underlying data)
- https://data.dhsgis.wi.gov/datasets/wisconsin-licensed-and-certified-childcare/about — WI DHS Open Spatial Data Portal (GIS layer; alternate bulk source)
- Per-county xlsx files: https://dcf.wisconsin.gov/files/ccdir/lic/excel/ccdir-lic-NN.%20COUNTY.xlsx — 72 individual county files (single LCC Directory.xlsx is their union)

## Limits / Notes

- Wisconsin publishes this Excel directory PUBLICLY and refreshes it daily — ideal for lead enrichment workflows
- "Certified" (vs "Licensed") providers use a separate pathway under DCF 202 (county/tribal-certified; <=3 children); they are NOT included in this LCC (Licensed Child Care) file. A separate certified-provider directory exists but is county-specific
- Phone numbers are published with the facility's designated contact person ("Contact Name" column also available in source but not captured in leads CSV per schema)
- Star Level column reflects YoungStar QRIS rating; ~60% of facilities are rated at 2 Stars or higher
- `Full Time` column: "Y" means full-time program (as opposed to part-time preschool)
