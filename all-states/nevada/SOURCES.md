# Nevada — Data Sources Log

**Date compiled:** 2026-04-18
**Target state:** Nevada (NV)
**Output file:** `/Users/magnusfremont/Desktop/daycare/nevada_leads.csv`

## Primary sources attempted

| URL | Format | Usable? | Notes |
|-----|--------|---------|-------|
| https://www.dpbh.nv.gov/siteassets/content/reg/childcare/dta/providers/ChildCareFacilityList.pdf | Static PDF | 404 | URL was previously valid (NV used to publish a statewide PDF facility list); currently broken. |
| https://www.dpbh.nv.gov/globalassets/dpbh/regulatory/childcare/dta/providers/Facility_List_March_2016.pdf | Static PDF (archival) | Present but 2016 data | Not used — 10 years stale. |
| https://nvdpbh.aithent.com/Protected/LIC/LicenseeSearch.aspx?Program=HF&PubliSearch=Y | Search portal (Aithent) | Partial | State's searchable directory; no bulk export. |
| findchildcare.nv.gov | Search portal | Reference | Redirects to Aithent search. |
| https://www.dpbh.nv.gov/regulatory/child-care-facilities/ | Agency landing | Reference | Forms, statutes. |

**Conclusion:** Nevada previously published a PDF facility list but current link is broken; the state moved to an Aithent-hosted interactive directory with no bulk download. Clark County and Washoe County family-child-care lists are held at local levels and require separate records requests.

## Secondary (supplemental) source used

| URL | Format | Rows | Notes |
|-----|--------|------|-------|
| https://childcarecenter.us/nevada/las_vegas_nv_childcare | HTML | 20 | Las Vegas. |
| https://childcarecenter.us/nevada/henderson_nv_childcare | HTML | 20 | Henderson. |
| https://childcarecenter.us/nevada/reno_nv_childcare | HTML | 6 | Reno (small set on site). |
| https://childcarecenter.us/nevada/north_las_vegas_nv_childcare | HTML | 2 | North Las Vegas — directory returns very few. |
| https://childcarecenter.us/nevada/sparks_nv_childcare | HTML | 0 (nearby only) | No centers listed in Sparks; directory shows Reno spillover. |

**Total rows:** ~48 verified records.

## Data quality

- Phones normalized to `(XXX) XXX-XXXX`.
- Email & website blank (not fabricated).
- Top 4 NV metros covered (Las Vegas, Henderson, Reno, North Las Vegas).
- Nevada has ~1,400 licensed centers + homes statewide (concentration: Clark + Washoe counties).

## Limits & caveats

- 2026-04-18 snapshot.
- Nevada's 7/1/2024 consolidation of licensing under DSS (from DPBH + DWSS) means data URL structure is in flux.
- Sparks / Carson City / rural Nevada are undercovered in secondary directory; for full coverage contact DSS directly.
- Accommodation / casino-based child care (NV-specific facility type) is licensed but often not surfaced in consumer directories.
