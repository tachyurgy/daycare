# Alaska — Source URLs & Data Provenance

**Date collected:** 2026-04-18

## Regulatory sources
- https://health.alaska.gov/en/division-of-public-assistance/child-care-program-office/ — CCPO landing
- https://akccis.com/client/home — AKCCIS provider portal & provider search
- https://dpaworks.dhss.alaska.gov/FindProviderVS8/zSearch.aspx — legacy ICCIS provider search
- https://www.law.cornell.edu/regulations/alaska/title-7/part-4/chapter-57 — 7 AAC 57 chapter
- https://regulations.justia.com/states/alaska/title-7/part-4/chapter-57/article-5/section-7-aac-57-505/ — 7 AAC 57.505 ratios
- https://akrules.elaws.us/aac/7.57.5 — Article 5 Care & Services
- https://health.alaska.gov/media/qxto12xo/cc61-parents-guide-to-licensed-care-teddy-bear-letter.pdf — CC-61 Parent Guide
- https://www.muni.org/Departments/health/childcare/Pages/Regulations.aspx — Municipality of Anchorage regs
- https://licensingregulations.acf.hhs.gov/licensing/regulation/alaska-admin-code-title-7-aac-57-child-care-licensing-regulation — ACF index

## Provider list sources (leads CSV)

### Primary (attempted): AKCCIS + legacy ICCIS search
- AKCCIS: https://akccis.com/client/home — requires client-side JS and search interaction; no bulk export available to the public
- Legacy ICCIS: https://dpaworks.dhss.alaska.gov/FindProviderVS8/zSearch.aspx — WebFetch ECONNREFUSED on attempt, likely deprecated or IP-restricted
- **Outcome:** no direct bulk dataset available. Search-only, per-query results.

### Secondary (used): childcarecenter.us
- https://childcarecenter.us/alaska/anchorage_ak_childcare (pages 1-2)
- https://childcarecenter.us/alaska/fairbanks_ak_childcare
- https://childcarecenter.us/alaska/juneau_ak_childcare
- https://childcarecenter.us/alaska/wasilla_ak_childcare
- https://childcarecenter.us/alaska/eagle_river_ak_childcare

Format: HTML list, name + city + zip + phone per row.

## Leads CSV output
- File: `/Users/magnusfremont/Desktop/daycare/alaska_leads.csv`
- Rows: 102 providers across Anchorage, Eagle River, Wasilla, Fairbanks, Juneau
- Coverage: ~20-25% of Alaska's estimated 500-700 licensed facilities. Five major population centers densely covered. Remote / bush / rural programs not captured.
- Email / website fields: blank.
- Note: Several "Camp Fire Alaska SAP" (school-age program) entries share an operator but are separate licensed sites — each is a legitimate lead for a site-level compliance tool.
