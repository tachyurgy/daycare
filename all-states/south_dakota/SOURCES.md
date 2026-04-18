# South Dakota — Source URLs & Data Provenance

**Date collected:** 2026-04-18

## Regulatory sources
- https://dss.sd.gov/childcare/licensing/ — DSS licensing landing page
- https://dss.sd.gov/childcare/ — Child Care Services hub
- https://olapublic.sd.gov/child-care-provider-search/ — Office of Licensing & Accreditation public portal (authoritative provider registry)
- https://sdlegislature.gov/Rules/Administrative/67:42 — ARSD Chapter 67:42 full text
- https://www.law.cornell.edu/regulations/south-dakota/ARSD-67-42-07-03 — staff-child ratio
- https://www.law.cornell.edu/regulations/south-dakota/ARSD-67-42-15-14 — before/after school ratio
- https://www.law.cornell.edu/regulations/south-dakota/ARSD-67-42-17-18 — supervision & group size (center, school-age)
- https://www.law.cornell.edu/regulations/south-dakota/ARSD-67-42-17-19 — center/school-age ratio
- https://www.law.cornell.edu/regulations/south-dakota/ARSD-67-42-17-21 — family day care supervision, ratio, group size
- https://licensingregulations.acf.hhs.gov/licensing/states-territories/south-dakota — ACF licensing regulations database (cross-reference)

## Provider list sources (leads CSV)

### Primary: OLA Constituent Portal
- URL: https://olapublic.sd.gov/child-care-provider-search/
- Format: JavaScript-rendered ASP.NET search form; results paginated on form submit
- **Limitation:** no bulk download or open data export; results only populated after running a query. Page rendered blank to WebFetch (requires client-side JS execution).
- Outcome: Did not supply rows directly; used as the regulatory source of truth for facility type categories.

### Secondary (used for leads CSV): childcarecenter.us
- https://childcarecenter.us/south_dakota/sioux_falls_sd_childcare (pages 1-4)
- https://childcarecenter.us/south_dakota/rapid_city_sd_childcare (pages 1-2)
- https://childcarecenter.us/south_dakota/aberdeen_sd_childcare
- https://childcarecenter.us/south_dakota/brookings_sd_childcare
- https://childcarecenter.us/south_dakota/watertown_sd_childcare
- Format: HTML listing pages, name / city / zip / phone per provider.
- **Note:** childcarecenter.us sources its data from state licensing feeds but caches them; entries and phone numbers should be validated against the OLA portal before outbound contact. No fabrication — rows transcribed verbatim.

## Leads CSV output
- File: `/Users/magnusfremont/Desktop/daycare/south_dakota_leads.csv`
- Rows: 152 providers across Sioux Falls, Rapid City, Aberdeen, Brookings, Watertown
- Coverage: ~20% of estimated SD licensed providers. Two dominant MSAs (Sioux Falls, Rapid City) captured densely; smaller towns (Pierre, Mitchell, Yankton, Vermillion, Huron, Madison, Spearfish) omitted due to time budget.
- Email / website fields: blank (source did not include; email/web enrichment would require secondary research per lead).
