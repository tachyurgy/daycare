# Washington — Data Sources (leads CSV)

**Date pulled:** 2026-04-18

## Primary dataset
- **Name:** DCYF Licensed Childcare Center and School Age Program Providers
- **Publisher:** Washington State Department of Children, Youth, and Families (DCYF), via Washington Open Data Portal (Socrata).
- **Landing page:** https://data.wa.gov/education/DCYF-Licensed-Childcare-Center-and-School-Age-Prog/was8-3ni8
- **Socrata dataset ID:** `was8-3ni8`
- **Bulk CSV endpoint used:**
  `https://data.wa.gov/api/views/was8-3ni8/rows.csv?accessType=DOWNLOAD`
- **Format:** CSV (~1.0 MB)
- **Rows retrieved:** **2,563** rows in raw CSV → **2,506 rows** written to `washington_leads.csv` after dropping rows with no business name.
- **Source refresh cadence:** DCYF reports monthly / near-real-time via Socrata; dataset was last updated February 2026 at time of pull.

## Fields present
- WacompassId, FamLinkId, SSPSProviderNumber, ProviderName, DoingBusinessAs, FacilityTypeGeneric, FacilityTypeAuthorityDesc, LatestOperatingStatus, LicenseCertificateTypeDesc, InitialLicenseDate, LatestLicenseStartDate, LicenseExpirationDate, LicenseCapacity, StartingAge, EndingAge, PrimaryContactPersonName, PrimaryContactPhoneNumber, PrimaryContactEmail, PhyscialLatitude, PhysicalLongitude, GeoCodedPhysicalAddress, PhysicalStreetAddress, PhysicalCity, PhysicalState, PhysicalZip, PhysicalCounty, PrimaryLicensor, Region, EaParticipation, EaRating

## Mapping to leads CSV
- `DoingBusinessAs` (fallback `ProviderName`) → business_name
- `PhysicalCity` → city
- `PrimaryContactPhoneNumber` → phone (formatted)
- `PrimaryContactEmail` → email

## Limitations
- Dataset covers **centers and school-age programs**. Family home providers are in a companion dataset; we limited scope to centers per the DCYF feed.
- Phone field is empty for the majority of records (DCYF does not require providers to publish contact phone in this feed). Email is present for a substantial minority.
- `LatestOperatingStatus` should be filtered to "Active" downstream if you want only currently-operating providers (we retained all statuses to avoid pre-filtering).
- `LatestLicenseStartDate` vs. `LicenseExpirationDate` fields let you compute license term; standard WA term is ~3 years.
- Outdoor Nature-Based Programs appear with `FacilityTypeGeneric = OUTDOOR NATURE BASED PROGRAM` — WA is the only state with these in the licensed feed.

## Reference materials in repo
- `planning-docs/state-docs/washington/` contains DCYF policy PDFs (WAC 110-300 rules, background-check checklists, feasibility checklist, overnight care planning form, etc.) that informed the compliance.md.
