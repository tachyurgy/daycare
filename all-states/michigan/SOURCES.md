# Michigan — Data Sources (leads CSV)

**Date pulled:** 2026-04-18

## Primary dataset
- **Name:** Child Care (Licensed Child Care Providers, statewide)
- **Publisher:** State of Michigan / MiLEAP via Michigan GIS Open Data (michigan_admin)
- **Landing page:** https://gis-michigan.opendata.arcgis.com/datasets/child-care/about
- **ArcGIS item:** a79c3b0caedf412599085941e2af91d4
- **REST endpoint used:**
  `https://utility.arcgis.com/usrsvcs/servers/a79c3b0caedf412599085941e2af91d4/rest/services/CSS/CSS_LARA/MapServer/5/query?where=1%3D1&outFields=*&f=json`
- **Format:** Esri FeatureServer/MapServer JSON (paginated via resultOffset)
- **Fields used:** FacilityName, City, stdCity, State, ZIPCode, FacilityType, Capacity, Latitude, Longitude, LicenseNumber
- **Rows retrieved:** 7,908 (all records)

## Secondary/validation
- **CCHIRP public search:** https://cclb.my.site.com/micchirp/s/statewide-facility-search (not bulk-exportable; used only for spot verification)

## Limitations
- Dataset contains facility name, license number, address, capacity, facility type (DF/DG/DC/Center), and lat/long — **no phone, no email, no website**. All phone/email fields in the CSV are blank because the authoritative statewide feed does not expose them.
- FacilityType is encoded; rows include both child care centers and family/group homes. If segmentation is needed downstream, use FacilityType codes: `DC` = center, `DG` = group home (7–12), `DF` = family home (1–6).
- Records reflect snapshot at time of pull; dataset refreshes daily from LARA/MiLEAP source-of-truth.
