# Alabama — Sources & Data Pull Log

**Researched:** 2026-04-18
**Lead file:** `/Users/magnusfremont/Desktop/daycare/alabama_leads.csv`
**Lead row count:** 99 (plus header)

## Data Source Strategy

Alabama DHR publishes a live, county-searchable directory at https://apps.dhr.alabama.gov/daycare/daycare_search (centers) and https://apps.dhr.alabama.gov/Child_Care_Services/Lic_Day_Care_Homes (homes). The directory requires an interactive county dropdown + POST submission — no bulk CSV/Excel/JSON export is publicly offered. WebFetch against the search endpoint returned the search form only, not result pages.

Used **childcarecenter.us** (which aggregates DHR licensee data) for the top 5 cities in Alabama by population. All records include name, city, state, and phone. ~2,031 total Alabama centers are listed in the aggregator — a subset is captured here focused on the biggest metros.

## Cities Captured

| City | Records |
|---|---|
| Birmingham | 20 (of 200+) |
| Huntsville | 20 (of 104) |
| Montgomery | 20 (of 169) |
| Mobile | 20 (of 129) |
| Tuscaloosa | 20 (of 52) |
| **TOTAL** | **100** (99 unique rows after dedup) |

Directory URLs used:
- https://childcarecenter.us/alabama/birmingham_al_childcare
- https://childcarecenter.us/alabama/huntsville_al_childcare
- https://childcarecenter.us/alabama/montgomery_al_childcare
- https://childcarecenter.us/alabama/mobile_al_childcare
- https://childcarecenter.us/alabama/tuscaloosa_al_childcare

## Limits

- **Portal-only pull.** State does not publish bulk data; this is the best available without a FOIA.
- **Coverage:** ~100 records ≈ 5% of Alabama's ~2,031 centers. Heaviest coverage is in the top-5 metros.
- **Phone, email, website:** only phone was uniformly available. Email and website left blank — must be enriched via per-record scrape or commercial enrichment.
- **Zip codes** are visible on the aggregator tables (35242, 35216, etc.) but were not added to the CSV because the header schema did not include a zip column. Easy to re-run if desired.
- **Address** likewise skipped by the required schema.
- **Freshness:** aggregator refresh cadence is irregular; ~5-15% of rows may reflect slightly stale license statuses. Verify status against DHR before outbound sales contact.

## Alternate / Future Sources

- **FOIA to Alabama DHR Child Care Services** (Karen Anderson, Child Care Services Division, (334) 242-1425) for the full licensee roster.
- **Alabama Family Central** interactive map: https://alabamafamilycentral.org/service/alabama-dhr-statewide-daycare-map/
- **Alabama Quality STARS** participating-provider list — subset with higher quality signals.

## Regulatory / Compliance Source URLs

- Alabama DHR Child Care Services: https://dhr.alabama.gov/child-care/
- DHR Licensing Overview: https://dhr.alabama.gov/child-care/licensing-overview/
- DHR Day Care Center License Requirements: https://dhr.alabama.gov/child-care/day-care-center-license-requirements/
- Minimum Standards — Day Care Centers (PDF): https://dhr.alabama.gov/wp-content/uploads/2020/01/No-Highlighted-MS-for-CENTERS-revised.pdf
- Minimum Standards — Family Day Care Homes (PDF): https://dhr.alabama.gov/wp-content/uploads/2020/01/Sr-No-Highlighted-Home-Standards-10-3-19.pdf
- Proposed updated Center Performance Standards (2021 draft): https://dhr.alabama.gov/wp-content/uploads/2021/06/PROPOSED-Centers-Child-Care-Licensing-and-Performance-Standards.pdf
- License-Exempt Day Care Facilities: https://dhr.alabama.gov/child-care/license-exempt-day-care-facilities/
- Ala. Admin. Code r. 660-5-20-.04 (Justia/Cornell LII): https://www.law.cornell.edu/regulations/alabama/Ala-Admin-Code-r-660-5-20-.04
- Alabama Childcare Facts — Minimum Standards summary: https://alabamachildcarefacts.com/minimum-standards/
- Public Health Law Center — AL Chapter 660-5-25: https://www.publichealthlawcenter.org/sites/default/files/resources/X_Alabama%20Chapter%20660-5-25.pdf
- DHR Day Care Directory (official, search): https://apps.dhr.alabama.gov/daycare/daycare_search
- DHR Licensed Day Care Homes (official, by county): https://apps.dhr.alabama.gov/Child_Care_Services/Lic_Day_Care_Homes
- Alabama Family Central map: https://alabamafamilycentral.org/service/alabama-dhr-statewide-daycare-map/
- Ala. Code Title 38, Chapter 7 (Child Care Act): https://alisondb.legislature.state.al.us/alison/codeofalabama/1975/38-7-1.htm
- Act 2018-390 (Child Care Safety Act): https://alison.legislature.state.al.us/files/pdf/search/alison_2018RS/PublicActs/2018-390.htm
- Minimum Day Care Staff Ratios for Alabama (summary): https://www.hellosubs.co/childcare-resources/minimum-day-care-staff-ratios-for-alabama
