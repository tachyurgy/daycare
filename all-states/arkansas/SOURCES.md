# Arkansas — Data Sources Log

**Date compiled:** 2026-04-18
**Target state:** Arkansas (AR)
**Output file:** `/Users/magnusfremont/Desktop/daycare/arkansas_leads.csv`

## Primary sources attempted

| URL | Format | Usable? | Notes |
|-----|--------|---------|-------|
| https://ardhslicensing.my.site.com/elicensing/s/search-provider/find-providers?language=en_US&tab=CC | Salesforce-backed search | Blocked (403) | Arkansas DHS eLicensing portal; live record of all licensed/registered providers. No bulk export; requires JS to paginate. |
| https://portal.arkansas.gov/service/ar-child-care-provider-search/ | Landing | Redirect | Points to the eLicensing search above. |
| https://childcarear.com/ | Consumer search | Reference | Operated by AR Child Care Aware / CCR&R — no bulk download. |
| https://arbetterbeginnings.com/ | QRIS landing | Reference | Better Beginnings rating info. |
| https://dese.ade.arkansas.gov/offices/office-of-early-childhood | DESE OEC | Reference | Regulations + policy. |

**Conclusion:** Arkansas DHS-DCCECE does not publish a bulk CSV; the eLicensing portal is the live source but not scraper-friendly. Full statewide coverage would require an Arkansas FOIA request.

## Secondary (supplemental) source used

| URL | Format | Rows | Notes |
|-----|--------|------|-------|
| https://childcarecenter.us/arkansas/little_rock_ar_childcare | HTML | 20 | Little Rock (191 total listed). |
| https://childcarecenter.us/arkansas/north_little_rock_ar_childcare | HTML | 20 | North Little Rock. |
| https://childcarecenter.us/arkansas/fayetteville_ar_childcare | HTML | 20 | Fayetteville. |
| https://childcarecenter.us/arkansas/fort_smith_ar_childcare | HTML | 20 | Fort Smith. |
| https://childcarecenter.us/arkansas/springdale_ar_childcare | HTML | 20 | Springdale. |
| https://childcarecenter.us/arkansas/jonesboro_ar_childcare | HTML | 20 | Jonesboro. |

**Total rows:** ~120 verified records.

## Data quality

- Phones normalized to `(XXX) XXX-XXXX`.
- Email & website blank (not fabricated).
- Top 6 AR cities covered.
- Arkansas has ~2,200 licensed/registered child care providers (center + home + registered home + OST).

## Limits & caveats

- 2026-04-18 snapshot.
- Child care licensing in AR sits at DHS-DCCECE; Better Beginnings QRIS sits at DESE — records must be cross-referenced by facility name for accuracy.
- Secondary directory data may trail live state by weeks.
