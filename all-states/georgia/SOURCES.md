# Georgia — Leads CSV Source Attribution

## CSV Source
- **File:** `/Users/magnusfremont/Desktop/daycare/georgia_leads.csv`
- **Primary URL:** https://families.decal.ga.gov/Provider/Data (Provider Data Export tool)
- **Publisher:** Georgia Department of Early Care and Learning (DECAL / Bright from the Start)
- **Source format:** CSV download obtained by programmatic POST to the ASP.NET form on the Provider Data Export page. The export endpoint returns a UTF-16 encoded `ProviderData_*.csv` file (converted to UTF-8). Filters used: all 9 program types checked (Child Care Learning Center, Family Child Care Learning Home, Exempt Only, Department of Defense, Local School System, GA Early Head Start, GA Head Start, Technical Schools, University); no county filter; no zip filter — i.e., statewide.

## Row Count
- **Rows written to CSV:** **7,914** licensed/approved Georgia child care providers
- **Raw export size:** ~6.0 MB UTF-16 CSV

## Columns Captured
`business_name,city,state,phone,email,website`
- Source fields mapped:
  - business_name ← `Location`
  - city ← `City`
  - state ← `State` (usually GA)
  - phone ← `Phone`
  - email ← `Email` (provided by DECAL for many providers)
  - website — blank (not published in Provider Data Export)

## Limitations
- DECAL's Provider Data Export does not include a website column
- Some providers decline to publish phone or email; those cells are blank
- Source also includes operational fields (License Capacity, hours of operation, age-band capacities, subsidy participation, Quality Rated star level, accreditations) — not captured here since the target schema is `business_name,city,state,phone,email,website`
- Data Dictionary: https://www.decal.ga.gov/Documents/Attachments/DataExportDataDictionary.pdf
- Includes CCLCs (licensed centers), FCCLHs (licensed homes), and Exempt Only programs — filter by `Program Type` column in the source if center-only targeting is required

## Date Fetched
**2026-04-18**
