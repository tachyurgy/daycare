# New Jersey — Data Sources (leads CSV)

**Date pulled:** 2026-04-18

## Primary dataset
- **Name:** Child Care Centers of New Jersey (Strc_DCF_childcare)
- **Publisher:** NJ Department of Environmental Protection (NJDEP) Site Remediation Waste Management Program, sourced monthly from NJ Department of Children and Families (NJDCF) Office of Licensing.
- **Landing page:** https://njogis-newjersey.opendata.arcgis.com/datasets/njdep::child-care-centers-of-new-jersey/about
- **ArcGIS item:** 0bc9fe070d4c49e1a6555c3fdea15b8a
- **REST endpoint used (Hub CSV downloads API):**
  `https://hub.arcgis.com/api/v3/datasets/0bc9fe070d4c49e1a6555c3fdea15b8a_4/downloads/data?format=csv&spatialRefId=4326`
- **Format:** CSV (~1.9 MB)
- **Fields present:** center_name, owner, director, address, city, county, zip, center_phone, center_email, licensed_capacity, age_range, months_operational, sessions, license_approval_date, license_renewal_date, foips flag, lat/long
- **Rows retrieved:** 4,287 rows in raw CSV → **4,093 rows** written to `new_jersey_leads.csv` after dropping blank-name rows.
- **Source refresh:** data in CSV reflects 2026/04/08 NJDCF Office of Licensing monthly export.

## Secondary / not used
- **data.nj.gov "Licensed Child Care Centers Explorer"** (pdn3-t238) — current but gated; Socrata API returns 403 (authentication required).
- **data.nj.gov "Licensed Child Care Centers"** (cru5-4rmm) — publicly downloadable (~4,163 rows) but **legacy, frozen as of May 6, 2019**. Not used.
- **Child Care Explorer** (https://childcareexplorer.njccis.com/portal/) — no bulk export API.

## Limitations
- Data set is scoped to active **licensed child care centers**; it does **not** include Registered Family Child Care providers (those are registered through the 22 county CCR&R agencies and are not in this statewide file).
- Email and phone are drawn from the DCF Office of Licensing provider submission; missing values left blank.
- Facilities Operating in Public Schools (FOIPS) are flagged but included — ~10% of rows. Treat these as lower-priority leads (they're public school programs, not traditional owner-operated daycares).
- No website field is provided by the source.
