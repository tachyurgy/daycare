# Virginia — Data Sources (leads CSV)

**Date pulled:** 2026-04-18

## Primary datasets (two combined)
The Virginia Department of Education (Child Care Aware of Virginia mapping project, `Grace2014` ArcGIS Online owner) publishes bi-annual updates of the full licensed provider roster as ArcGIS Feature Services. We combined the two most recent (December 2025) layers:

### Dataset A — VA Licensed Child Care Centers December 2025
- ArcGIS item: `4bfba163369843338d731fdd4a8aabd0`
- REST endpoint:
  `https://services3.arcgis.com/PJoVv2u1K1SOrkmR/arcgis/rest/services/VA_Licensed_Child_Care_Centers_December_2025/FeatureServer/0/query?where=1%3D1&outFields=*&f=json`
- Rows retrieved: **1,531**
- Fields: Business_Name, Address, City, State, Zip, Latitude, Longitude, ProgramType, License_Type, Capacity, Accreditation, Infants, School_Age, Child_Care_Subsidy, Special_Needs, Region, HeadStart, VPI

### Dataset B — VA Licensed Family Day Homes December 2025
- ArcGIS item: `5f155519e0fb46bb894f63b29fda9eaf`
- REST endpoint:
  `https://services3.arcgis.com/PJoVv2u1K1SOrkmR/arcgis/rest/services/VA_Licensed_Family_Day_Homes_December_2025/FeatureServer/0/query?where=1%3D1&outFields=*&f=json`
- Rows retrieved: **1,325**
- Fields: same schema as Dataset A plus ProviderType.

## Combined output
- **virginia_leads.csv:** 2,856 rows (1,531 centers + 1,325 family day homes).
- Format: CSV (Esri FeatureServer JSON paginated to 2,000 per page then flattened).

## Source publisher/curator
- **Curator:** Grace Reef, *Child Care Aware of Virginia / Child Care VA mapping project* (ArcGIS Online owner: `Grace2014`) — a VDOE-affiliated initiative cross-referenced to the VDOE licensing roster.
- **Authoritative registry:** VDOE Office of Child Care Licensing. Public search tool at https://dss.virginia.gov/facility/search/cc2.cgi.
- Datasets are published alongside related layers (Head Start, CACFP, VPI, subsidy, religious exempt) — we used the two license-category layers only.

## Not included
- **Religious Exempt centers, Voluntary-Registered family day homes, Local Ordinance-approved homes (NOVA), Head Start, Certified Preschools:** these have separate feature services. If you want the broader "regulated child care" universe in VA, add:
  - `3a4d97faf182486e82367652471350aa` Virginia Religious Exempt Child Care Centers May 2025
  - `8c37db08f15147b298c1ccc754350d1d` VA Voluntary Registered Family Day Homes December 2025
  - `9987caa671ac4f1b989c99cfd5d4d474` VA Local Permits and Ordinances NOVA December 2025

## Limitations
- **No phone, email, or website fields** in the VDOE publication layer. All three fields are blank in the CSV.
- Dataset is published semi-annually (May and December); therefore inter-cycle licensure changes (openings/closings/change of ownership) may lag by up to 6 months.
- Religious-exempt facilities are NOT in these two layers and represent ~15-25% of VA non-profit ECE capacity.
- Business_Name field sometimes truncated at 60 chars by source export (observed on 2 records).
