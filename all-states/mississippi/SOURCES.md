# Mississippi — Lead Data Sources

**Collection date:** 2026-04-18
**Output file:** `/Users/magnusfremont/Desktop/daycare/mississippi_leads.csv`
**Row count:** 1,414 facilities (OPEN status)

## Primary Bulk Dataset

**MARIS (Mississippi Automated Resource Information System) — Licensed Child Care Facilities (2023)**

- Landing page: https://maris.mississippi.edu/HTML/DATA/data_Education/LicensedChildCareFacilities.html
- Shapefile download: https://maris.mississippi.edu/MARISdata/Education/MS_LicensedChildcareFacilities_2023.zip
- REST endpoint: https://gis.mississippi.edu/server/rest/services/Education/MS_LicensedChildcareFacilities_2023/MapServer
- **Format:** ESRI Shapefile (.shp/.dbf/.shx). Attribute table extracted via `dbfread` Python library.
- **Source provenance:** Compiled from Mississippi State Department of Health child care provider search (https://www.msdh.provider.webapps.ms.gov/ccsearch.aspx) and contributed to the federal Homeland Infrastructure Foundation-Level Data (HIFLD) program.
- **Fields available in source:** OBJECTID, ID, NAME, ADDRESS, CITY, STATE, ZIP, ZIP4, TELEPHONE, TYPE (CENTER BASED / HOME), STATUS (OPEN), POPULATION, COUNTY, COUNTYFIPS, LATITUDE, LONGITUDE, NAICS_CODE, NAICS_DESC, SOURCE, SOURCEDATE, VAL_METHOD, VAL_DATE, WEBSITE, ST_SUBTYPE.
- **Filtering:** Only records with STATE=MS and STATUS=OPEN included.
- **Known limitations:**
  - WEBSITE and EMAIL fields in the source are mostly "NOT AVAILABLE"; website column in our CSV is blank for essentially all records.
  - Source data has a SOURCEDATE of 2021–2022; records may include closures or relocations since then.
  - Phone numbers carried over directly from the source; formatting is `(XXX) XXX-XXXX`.
  - Family child care homes (≤ 12 children in operator's home) may be under-represented relative to centers because the source aggregator focused on centers.

## Secondary / Verification Sources

- **MSDH Child Care Facility Search (live):** https://www.msdh.provider.webapps.ms.gov/
- **MSDH Facility Search (alternate URL):** https://msdh.ms.gov/page/30,332,183,438.html
- **MSDH Child Care Facilities Licensure (program page):** https://msdh.ms.gov/page/30,0,183.html
- **Mississippi Department of Human Services (MDHS) ECCD find-a-provider:** https://www.mdhs.ms.gov/eccd/parents/find/

## Transcription Notes

- Conversion from SHAPEFILE DBF → CSV performed with a custom Python script using `dbfread`.
- Names converted from source `UPPERCASE` to Title Case, preserving acronyms (LLC, INC, YMCA, II, III, MS, USA, DBA).
- Blank phone/website fields preserved as empty cells per spec (no fabrication).
- Deduplicated on (name, city, phone) tuple.
- Output sorted by city, then business name.

## Rows / Coverage

- 1,414 unique OPEN-status licensed child care facilities across Mississippi.
- Fields populated: `business_name` (100%), `city` (100%), `state` (100%), `phone` (most, ~95%), `email` (0% — not in source), `website` (0% — not in source).
