# Wyoming — Source URLs & Data Provenance

**Date collected:** 2026-04-18

## Regulatory sources
- https://dfs.wyo.gov/providers/child-care-2/ — WY DFS Child Care hub
- https://dfs.wyo.gov/providers/child-care-2/licensing-rules/ — Licensing rules index (403'd to WebFetch but loadable manually)
- https://dfs.wyo.gov/services/family-services/child-care/ — Parent / assistance side
- https://childcare.dfs.wyo.gov/home/ — Facility finder (current)
- https://findchildcarewy.org/maps/index.cfm — legacy redirect to the current finder
- https://www.wyoleg.gov/ARules/2012/Rules/ARR16-058.pdf — Chapter 5 (FCCH)
- https://www.publichealthlawcenter.org/sites/default/files/resources/Wyoming_Child%20Care%20Regulations.pdf — consolidated regulations
- https://www.publichealthlawcenter.org/sites/default/files/WY%20Family%20Child%20Care%20Centers.pdf — FCCC rules
- https://licensingregulations.acf.hhs.gov/licensing/contact/wyoming-department-family-services — ACF entry

## Provider list sources (leads CSV)

### Primary (attempted): WY DFS Facility Finder
- https://childcare.dfs.wyo.gov/home/ — interactive search + map; no bulk export. WebFetch on the legacy findchildcarewy.org URL followed the 301 to the DFS subdomain but the underlying result set is rendered only after querying by zip/county/city.

### Secondary (used): childcarecenter.us
- https://childcarecenter.us/wyoming/cheyenne_wy_childcare
- https://childcarecenter.us/wyoming/casper_wy_childcare
- https://childcarecenter.us/wyoming/laramie_wy_childcare
- https://childcarecenter.us/wyoming/gillette_wy_childcare
- https://childcarecenter.us/wyoming/rock_springs_wy_childcare
- https://childcarecenter.us/wyoming/sheridan_wy_childcare
- https://childcarecenter.us/wyoming/jackson_wy_childcare

Format: HTML list; name + city + zip + phone per row.

## Leads CSV output
- File: `/Users/magnusfremont/Desktop/daycare/wyoming_leads.csv`
- Rows: 100 providers across Cheyenne, Casper, Laramie, Gillette, Rock Springs, Sheridan, Jackson
- Coverage: ~15-20% of Wyoming's ~500-650 certified providers (centers + family homes + FCCC). All seven largest population centers covered. Frontier counties (Campbell, Fremont, Park, Big Horn, Johnson, Platte, Uinta, Sublette, Teton, Washakie, Hot Springs, Converse) have smaller numbers of providers not captured here.
- Email / website fields: blank (source did not publish).
- Note: "Silly Bear Academy LLC" appears twice at different zip codes (82007 and 82005). Kept as distinct rows since multi-site operators are legitimate separate compliance units.
