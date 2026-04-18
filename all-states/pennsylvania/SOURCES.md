# Pennsylvania — Leads CSV Source Attribution

## CSV Source
- **File:** `/Users/magnusfremont/Desktop/daycare/pennsylvania_leads.csv`
- **Primary URL:** https://data.pa.gov/api/views/ajn5-kaxt/rows.csv?accessType=DOWNLOAD
- **Dataset landing page:** https://data.pa.gov/Services-Near-You/Child-Care-Providers-including-Early-Learning-Prog/ajn5-kaxt
- **Publisher:** PA Department of Human Services (DHS), Office of Child Development and Early Learning (OCDEL); dataset title: "Child Care Providers including Early Learning Programs Listing Current Monthly Facility County Human Services"
- **Source format:** Direct CSV download from Socrata-hosted PA Open Data Portal

## Row Count
- **Rows written to CSV:** **7,473** licensed PA child care providers (all current in source dataset)
- **Raw dataset size:** ~3.9 MB

## Columns Captured
`business_name,city,state,phone,email,website`
- Source fields mapped:
  - business_name ← `Facility Name`
  - city ← `Facility City`
  - state ← Pennsylvania → "PA"
  - phone ← `Facility Phone`
  - email ← `Facility Email` (many rows are blank in source)
  - website — blank (not published in dataset)

## Limitations
- Source provides `Facility Email` but a majority of rows are blank — email coverage ~20-30%
- `Facility Phone` also has many blanks in the source dataset
- Website field is not included in the dataset
- The dataset includes Child Care Centers, Group Child Care Homes, Family Child Care Homes, Part-day programs, Early Head Start, Head Start, and PA Pre-K Counts sites — filter by `Provider Type` if center-only targeting is needed
- All rows in source dataset are exported; downstream filters for legal entity vs. location may be required

## Date Fetched
**2026-04-18**
