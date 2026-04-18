# South Carolina — Sources & Data Pull Log

**Researched:** 2026-04-18
**Lead file:** `/Users/magnusfremont/Desktop/daycare/south_carolina_leads.csv`
**Lead row count:** 117 (plus header)

## Data Source Strategy

SC DSS does **not publish** a bulk CSV / shapefile / JSON feed of licensed centers. The public search at https://www.scchildcare.org/search.aspx is name/city search only and lacks a city-level "list all" view. ABC Quality (https://abcquality.org/families/find-a-provider/) is similarly search-based and tied to subsidy participation. Consequently, a **portal-only** pull was required.

Used **childcarecenter.us** as the aggregator for top-city pulls (data originates from DSS licensee rosters; widely used by referral agencies). Cross-checked against known Columbia SC listings (e.g., SC Child Care Services main office at 1535 Confederate Ave, Columbia). All records include name, city, state, and phone. Email/website blank (site does not surface those fields without per-record crawl).

## Cities Captured

| City | Records Transcribed |
|---|---|
| Columbia | 40 |
| Charleston | 20 |
| Greenville | 20 |
| Rock Hill | 20 |
| Myrtle Beach | 20 |
| **TOTAL** | **120** (after dedup → ~117 unique names; minor inter-city duplicates kept where they represent distinct physical locations) |

Directory URLs used:
- https://childcarecenter.us/south_carolina/columbia_sc_childcare (page 1 + page 2 = 40 of 117)
- https://childcarecenter.us/south_carolina/charleston_sc_childcare (20 of 89)
- https://childcarecenter.us/south_carolina/greenville_sc_childcare (20 of 87)
- https://childcarecenter.us/south_carolina/rock_hill_sc_childcare (20 of 45)
- https://childcarecenter.us/south_carolina/myrtle_beach_sc_childcare (20 of listing)

## Limits

- **Format per record:** name, city, phone only. Address, zip, email, website are partially available on per-facility detail pages but NOT transcribed this pass (would require 117 additional fetches). Zip codes are visible in the listing tables and can be added if needed.
- **Coverage:** ~117 records is ~2% of SC's ~5,500 licensed child-care facilities. Covers the 5 largest metros by population.
- **Freshness:** childcarecenter.us refreshes periodically from DSS lists. Live status (license in force, suspended, revoked) must be verified against DSS directly for any sales lead before outreach.
- **No fabrication:** phone numbers were as displayed; ambiguous multi-phone records (e.g., Open Arms Child Support Center showed two numbers) were collapsed to the first number listed.

## Alternate / Future Sources

- **FOIA request to SC DSS Division of Early Care and Education** for the full licensee export (typical turnaround: 2-4 weeks). Recommended for a production lead pull.
- **ABC Quality** (QRIS participants — smaller subset but higher quality signals).
- **USDA CACFP sponsor lists** for SC — available via SC Department of Education School Food Services.

## Regulatory / Compliance Source URLs

- SC Child Care Services: https://www.scchildcare.org/
- DSS Child Care landing page: https://dss.sc.gov/child-care/
- Licensed Center Regulations PDF: https://www.scchildcare.org/media/t3yfftje/licensed-centers-regulations.pdf
- 2018 CCC Regulations (PDF): https://www.scchildcare.org/media/59009/2018-CCC-regulations-updated.pdf
- 2018 Side-by-Side Companion Guide to Center Regulations: https://www.scchildcare.org/media/60243/Side-by-Side-Companion-Guide-to-the-2018-Center-Regulations.pdf
- SC Code of Regulations, Chapter 114 (DSS): https://www.scstatehouse.gov/coderegs/Chapter%20114.pdf
- SC Code, Title 63, Chapter 13 (Child Care Licensing Law): https://www.scstatehouse.gov/code/t63c013.php
- Staff-to-Child Ratios PDF (DSS 2966): https://dss.sc.gov/resource-library/forms_brochures/files/2966.pdf
- SC Child Care Licensing Law handbook (DSS 2955): https://dss.sc.gov/resource-library/forms_brochures/files/2955.pdf
- DSS Application Form 2902: https://dss.sc.gov/resource-library/forms_brochures/files/2902.pdf
- Issue Brief 501: https://dss.sc.gov/media/dtypqqif/dss-brochure-501.pdf
- ACF Licensing Regulations Database — SC Centers (June 2018): https://licensingregulations.acf.hhs.gov/sites/default/files/licensing_regulation/SC_Center_June_2018_0.pdf
- Justia — Regulation 114-524 (Ratios, group homes): https://regulations.justia.com/states/south-carolina/chapter-114/article-5/subarticle-1/
- Justia — Regulation 114-514 (Supervision): https://regulations.justia.com/states/south-carolina/chapter-114/article-5/subarticle-1/regulations-for-the-licensing-of-group-child-care-homes/section-114-514/
- ABC Quality QRIS: https://abcquality.org/
