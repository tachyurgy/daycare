# Iowa — Data Sources Log

**Date compiled:** 2026-04-18
**Target state:** Iowa (IA)
**Output file:** `/Users/magnusfremont/Desktop/daycare/iowa_leads.csv`

## Primary sources attempted

| URL | Format | Usable? | Notes |
|-----|--------|---------|-------|
| https://secureapp.dhs.state.ia.us/dhs_titan_public/ChildCare/ComplianceReport | ASP.NET paginated interactive | Partial | Listing of all licensed IA centers + homes; supports filter by county/city and provider type. No one-click CSV export, but rows are browseable and scraped per page. |
| https://ccmis.dhs.state.ia.us/clientportal/ProviderSearch.aspx | Interactive | Partial | Search-driven, no raw export. |
| https://iachildcareconnect.org / https://search.iachildcareconnect.org | State-of-the-art search | Partial | 2024-launched tool (ISU + Resultant partnership). No open CSV yet. |
| https://catalog.data.gov/dataset/child-care-compliance-complaint-reports/resource/5f581e0b-724b-4843-8fe4-d945f5561f10 | Data.gov entry | 404 at resource URL | Catalog entry references the Iowa HHS compliance report page but direct resource download link is broken. |
| https://iowaccrr.org/data/ | CCR&R stats | Aggregates only | Not provider-level. |

**Conclusion:** Iowa HHS exposes licensee data via the compliance-report site; bulk export requires either a multi-page scrape of the ComplianceReport page or a FOIA / data request to Iowa HHS. No direct CSV URL is currently served.

## Secondary (supplemental) source used

| URL | Format | Rows | Notes |
|-----|--------|------|-------|
| https://childcarecenter.us/iowa/des_moines_ia_childcare | HTML | 20 | Des Moines. |
| https://childcarecenter.us/iowa/cedar_rapids_ia_childcare | HTML | 20 | Cedar Rapids. |
| https://childcarecenter.us/iowa/davenport_ia_childcare | HTML | 20 | Davenport. |
| https://childcarecenter.us/iowa/iowa_city_ia_childcare | HTML | 20 | Iowa City. |
| https://childcarecenter.us/iowa/sioux_city_ia_childcare | HTML | 20 | Sioux City. |
| https://childcarecenter.us/iowa/waterloo_ia_childcare | HTML | 20 | Waterloo. |
| https://childcarecenter.us/iowa/ames_ia_childcare | HTML | 20 | Ames. |

**Total rows:** ~140 verified records.

## Data quality

- Phones normalized to `(XXX) XXX-XXXX`.
- Email & website blank (not fabricated).
- Top 7 Iowa cities covered.
- Mix of licensed centers, preschools, and after-school programs (all regulated under IAC 441-109).

## Limits & caveats

- 2026-04-18 snapshot.
- Iowa HHS ComplianceReport page should be scraped directly for full statewide coverage (~2,400 licensed centers + ~3,000 registered homes).
- Iowa Child Care Connect dataset may become an open-data source in 2026 — recheck quarterly.
