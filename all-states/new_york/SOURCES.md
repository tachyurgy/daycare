# New York — Leads CSV Source Attribution

## CSV Source
- **File:** `/Users/magnusfremont/Desktop/daycare/new_york_leads.csv`
- **Primary URL:** https://data.ny.gov/api/views/cb42-qumz/rows.csv?accessType=DOWNLOAD
- **Dataset landing page:** https://data.ny.gov/Human-Services/Child-Care-Regulated-Programs/cb42-qumz
- **Publisher:** NY State Office of Children and Family Services (OCFS), Division of Child Care Services (DCCS)
- **Source format:** Direct CSV download from Socrata-hosted data.ny.gov open data portal

## Row Count
- **Rows written to CSV:** **16,770** licensed/registered child care facilities
- **Raw dataset size:** ~5.9 MB / 16,770 records (active status filter applied — closed/surrendered/revoked excluded)

## Columns Captured
`business_name,city,state,phone,email,website`
- Source fields mapped:
  - business_name ← `Facility Name`
  - city ← `City`
  - state ← `State`
  - phone ← `Phone Number`
  - email — blank (not published in OCFS dataset)
  - website — blank (not published in OCFS dataset)

## Limitations
- OCFS publishes no email or website fields in its public dataset (these are considered non-public contact data); those columns are left blank
- Dataset includes all regulated program types (DCC, SDCC, GFDC, FDC, SACC). For marketing specifically to **centers**, filter by `Program Type = DCC` or `SDCC` in source data — current CSV includes all types
- Facilities marked "Closed", "Surrendered", "Terminated", or "Revoked" were excluded at transcription time; active enforcement-action licensees (on probation, etc.) are retained

## Date Fetched
**2026-04-18**
