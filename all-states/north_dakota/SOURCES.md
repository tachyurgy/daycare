# North Dakota — Source URLs & Data Provenance

**Date collected:** 2026-04-18

## Regulatory sources
- https://www.hhs.nd.gov/cfs/early-childhood-services/child-care-licensing — DHHS Early Childhood Licensing
- https://www.hhs.nd.gov/cfs/early-childhood-services/providers — Provider hub
- https://www.hhs.nd.gov/cfs/early-childhood-services/providers/child-care-licensing-system — CCL portal
- https://www.hhs.nd.gov/cfs/early-childhood-services/programs/regulations — Regulation index
- https://www.hhs.nd.gov/cfs/early-childhood-services/providers/provider-forms — Forms library
- https://ndlegis.gov/prod/acdata/html/75-03.html — NDAC 75-03 full article
- https://ndlegis.gov/information/acdata/pdf/75-03-10.pdf — Child Care Center (75-03-10) PDF
- https://ndlegis.gov/information/acdata/pdf/75-03-09.pdf — Group Child Care (75-03-09) PDF
- https://licensingregulations.acf.hhs.gov/sites/default/files/licensing_regulation/ndfcchjuly2020508.pdf — Family Child Care (75-03-08)
- https://regulations.justia.com/states/north-dakota/title-75/article-75-03/chapter-75-03-10/section-75-03-10-08/ — staffing/group size
- https://licensingregulations.acf.hhs.gov/licensing/contact/north-dakota-department-health-human-services-early-childhood-services — ACF entry

## Provider list sources (leads CSV)

### Primary: DHHS public search tool
- Linked via the Early Childhood Licensing page; displays monitoring results / correction orders for past 3 years.
- **Limitation:** no public bulk export. The DHHS portal is a per-query search, not a downloadable dataset.

### Secondary (used for leads CSV): childcarecenter.us
- https://childcarecenter.us/north_dakota/fargo_nd_childcare (pages 1-2)
- https://childcarecenter.us/north_dakota/bismarck_nd_childcare
- https://childcarecenter.us/north_dakota/grand_forks_nd_childcare
- https://childcarecenter.us/north_dakota/minot_nd_childcare
- https://childcarecenter.us/north_dakota/west_fargo_nd_childcare
- https://childcarecenter.us/north_dakota/mandan_nd_childcare
- https://childcarecenter.us/north_dakota/williston_nd_childcare

Format: HTML listing pages. Name + city + zip + phone per row.

## Leads CSV output
- File: `/Users/magnusfremont/Desktop/daycare/north_dakota_leads.csv`
- Rows: 118 providers across Fargo, West Fargo, Bismarck, Mandan, Grand Forks, Minot, Williston
- Coverage: ~12-15% of ND's ~900-1,100 licensed center/group providers (1,400+ if including all self-declared + family home). Major MSAs densely captured; small-town coverage omitted.
- Email / website fields: blank (secondary source does not publish).
