# Utah — Data Sources Log

**Date compiled:** 2026-04-18
**Target state:** Utah (UT)
**Output file:** `/Users/magnusfremont/Desktop/daycare/utah_leads.csv`

## Primary sources attempted

| URL | Format | Usable? | Notes |
|-----|--------|---------|-------|
| https://dlbc.utah.gov/information-for-the-public/find-a-facility/ | Landing | Reference only | Returns 403 for automated clients. |
| https://ccl.utah.gov | Interactive portal | Partial | Used for facility name / license type / location lookup; no bulk export endpoint surfaced. |
| https://provider.dlbc.utah.gov/ | Provider portal | Login-only | Not public. |
| https://opendata.utah.gov | Open data | No matching dataset | No child-care licensee dataset as of 2026-04-18. |

**Conclusion:** Utah DHHS does not publish a bulk CSV of licensed child care facilities. Find-a-Facility tool is the primary citizen-facing resource; data is only available through the interactive interface.

## Secondary (supplemental) source used

| URL | Format | Rows | Notes |
|-----|--------|------|-------|
| https://childcarecenter.us/utah/salt_lake_city_ut_childcare | HTML | 20 | SLC (256 total listed on site). |
| https://childcarecenter.us/utah/west_valley_city_ut_childcare | HTML | 12 | West Valley City. |
| https://childcarecenter.us/utah/ogden_ut_childcare | HTML | 20 | Ogden. |
| https://childcarecenter.us/utah/provo_ut_childcare | HTML | 20 | Provo. |
| https://childcarecenter.us/utah/west_jordan_ut_childcare | HTML | 20 | West Jordan. |
| https://childcarecenter.us/utah/sandy_ut_childcare | HTML | 18 | Sandy. |

**Total rows:** ~110 verified records.

## Data quality

- Phones normalized to `(XXX) XXX-XXXX`.
- Email & website blank (not fabricated).
- Top 6 UT cities covered.
- ChildCareCenter.us marks providers as licensed centers, home daycares, or both — this CSV mixes the two; filter on facility_type is recommended before outreach.

## Limits & caveats

- 2026-04-18 snapshot.
- Secondary directory may lag live DLBC state.
- Addresses beyond city + ZIP not extracted.
- Utah recently (2022-2024) reorganized licensing under DHHS (formerly DOH); some provider records may still reference old agency name.
