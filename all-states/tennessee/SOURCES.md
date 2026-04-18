# Tennessee — Data Sources (leads CSV)

**Date pulled:** 2026-04-18

## Primary dataset
- **Name:** Licensed Tennessee Child Care Providers List 2024
- **Publisher:** University of Tennessee / Southeastern Workforce Research and Policy Studies (SWORPS) on behalf of TDHS Child Care Licensing — backs the official TDHS Child Care Locator Map.
- **Landing page (portal):** https://tnchildcarehelpdesk.sworpswebapp.sworps.utk.edu/child-care-desert-map/
- **ArcGIS item:** `dbaa58403dc042f8949a943c22b0f4f3` (owner: `Mack.Swiney` at UTK)
- **REST endpoint used:**
  `https://services6.arcgis.com/SmO2MQiJaDmO20rD/arcgis/rest/services/Licensed_Tennessee_Child_Care_Providers_List_2024/FeatureServer/0/query?where=1%3D1&outFields=*&f=json`
- **Format:** Esri FeatureServer JSON (paginated via resultOffset)
- **Rows retrieved:** **4,178**

## Fields present in source
- Agency_Name, Street, Street_address_2, City, State, ZIP, Address, Coordinates, Latitude, Longitude
- Agency_Phone (10 digits, unformatted) → normalized to `(XXX) XXX-XXXX`
- Provider_Type (Child Care Center, Family Child Care Home, Group Child Care Home, Drop-In, School-Administered, etc.)
- Capacity, Regulatory_Agency (TDHS or TDOE), Regulatory_Status (Licensed, etc.), Star_Rating
- Certificate_Program_Participant, Discounts, Approved_For_Transportation, Wheel_Chair_Accessible, Child_and_Adult_Care_Food_Program

## Other sources considered
- **TDHS Find Child Care** (tn.gov) — fronts the same data via a JS map; no public bulk-export button.
- **TDHS Provider Portal (ServiceNow)** — provider-only, gated.
- **Digital Tennessee child-care data** (https://digitaltennessee.tnsos.gov/child_care_data/) — fiscal-year aggregate tables (abuses, injuries, deaths) rather than a facility list.

## Limitations
- Dataset title says "2024"; the feature service has been updated with newer records (last modification late 2025 per observation), but the name has not been versioned. Treat Regulatory_Status and Star_Rating as point-in-time.
- Includes both TDHS-licensed providers **and** TDOE school-administered programs. Filter on `Regulatory_Agency == 'TDHS'` to restrict to private/nonprofit daycare universe (~2,000 of 4,178 rows). We left all rows in the CSV so downstream filtering is possible.
- Email and website fields are **not** published by TDHS in this feed — blank in CSV.
- Some records have partial address data (missing street_address_2). No rows dropped for this reason.
- TDHS-reported capacity > 2,000 licensed agencies in press materials; the 4,178 count here includes school-administered programs and multiple license types.
