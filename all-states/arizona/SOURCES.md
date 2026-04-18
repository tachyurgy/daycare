# Arizona — Data Sources (leads CSV)

**Date pulled:** 2026-04-18

## Primary dataset
- **Name:** State Licensed Medical & Child Care Providers, & Healthcare Facilities in Arizona — Layer 17 (Child Care Facility)
- **Publisher:** Arizona Department of Health Services (ADHS GIS Portal)
- **Landing page:** https://geodata-adhsgis.hub.arcgis.com/maps/5e764d6e640b4226ae7c0bba27f7b9f0
- **ArcGIS item:** 5e764d6e640b4226ae7c0bba27f7b9f0 (service: `AZLicensedFacilities`; the parent service exposes 7 layers — layer ID 17 is **"Child Care Facility"**)
- **REST endpoint used:**
  `https://services1.arcgis.com/mpVYz37anSdrK4d8/arcgis/rest/services/AZLicensedFacilities/FeatureServer/17/query?where=1%3D1&outFields=*&f=json`
- **Format:** Esri FeatureServer JSON (paginated via resultOffset)
- **Source system:** ADHS Salesforce Datamart (`Datamart.vw_SF_CC_Active_Providers`); records reflect Active license status at time of ADHS export (RUN_DATE ≈ Feb 2, 2025 per record attribute).
- **Rows retrieved:** **2,536**

## Key fields used
- `FACILITY_NAME` → business_name
- `CITY` (fallback `N_CITY`) → city
- `Telephone` (10-digit) → phone (formatted `(XXX) XXX-XXXX`)
- Additional attributes available in raw JSON: Capacity, LICENSE_NUMBER, License_Effective, license_expiration, COUNTY, LICENSE_TYPE, CSA (Community Service Area), lat/long

## Also considered / not used
- **ADHS Licensed Child Care Facilities 2024** (item `2c511697221f476fad85d95354c39ec7`): returned 0 features in public query — authentication-gated.
- **ADHS Licensed Child Care Facilities 2022** (item `8b51fd7531114db083ddef0c5caec8c4`): stale.
- **DES certified family child care homes** (subsidy-participating homes regulated by DES, not ADHS): distinct universe, not present in the ADHS licensed-facility feed; would require a separate DES public records request.

## Limitations
- Only ADHS-licensed **Child Care Centers**. DES-certified group homes (5–10 children) and DES-certified family homes (≤4 children) are **not** included.
- No email or website field.
- Data snapshot RUN_DATE is ADHS's February 2025 Salesforce extract; the hub-exposed feature layer is the most recent publicly available but may trail real-time ADHS status by weeks.
- CAPACITY stored as string; data cleaning will be needed if downstream analysis requires integer math.
