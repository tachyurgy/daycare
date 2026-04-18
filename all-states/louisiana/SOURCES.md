# Louisiana — Sources & Data Pull Log

**Researched:** 2026-04-18
**Lead file:** `/Users/magnusfremont/Desktop/daycare/louisiana_leads.csv`
**Lead row count:** 94 (plus header)

## Data Source Strategy

LDE Licensing does **not publish** a bulk CSV/Excel export of licensed Early Learning Centers. The Louisiana School & Center Finder (https://louisianaschools.com/) is search-based — by name, city, parish, performance rating — and does not offer a "list all centers" or CSV export. The legacy DCFS Care Facility search (https://webapps.dcfs.la.gov/carefacility/index) timed out in testing (April 2026).

Used **childcarecenter.us** (aggregates LDE Early Learning Center data) for the top 5 cities by population. Each record has name, city, state, and phone.

## Cities Captured

| City | Records |
|---|---|
| New Orleans | 20 (of 258) |
| Baton Rouge | 19 (of 270) |
| Shreveport | 20 (of 131) |
| Lafayette | 20 (of 96) |
| Lake Charles | 15 (of 70) |
| **TOTAL** | **94** |

Directory URLs used:
- https://childcarecenter.us/louisiana/new_orleans_la_childcare
- https://childcarecenter.us/louisiana/baton_rouge_la_childcare
- https://childcarecenter.us/louisiana/shreveport_la_childcare
- https://childcarecenter.us/louisiana/lafayette_la_childcare
- https://childcarecenter.us/louisiana/lake_charles_la_childcare

Noteworthy: Louisiana's city-level listings include many public-school Head Start centers and school-district after-school programs (e.g., "Lake Charles" includes named elementary schools). These are included because they are licensed Early Learning Centers under LDE, but they are **low-probability sales prospects** for a private compliance SaaS — filter for private operators before outreach.

## Limits

- **Portal-only pull**; no public bulk feed exists.
- **Coverage:** 94 records against a universe of ~1,800 licensed LA Early Learning Centers (≈5%).
- **Phone only** reliably present. No emails or websites without per-record scraping.
- **Zip / parish / address** available on aggregator but not required by the leads CSV schema; can be enriched on request.
- Louisiana records show some entries that are **public-school elementaries operating pre-K**, which may be Type III licensed but not ideal SaaS ICPs. Pre-outreach filter recommended (exclude public school system names, elementary schools, Head Start sites).

## Alternate / Future Sources

- **Louisiana School Finder** API (unofficial): https://louisianaschools.com/searchresults — can be scraped per parish if needed.
- **LDE Licensing Consultant** direct: 225-342-9905 / ldelicensing@la.gov — can often provide a provider list on formal request.
- **Bulletin 139 CCDF subsidy directory** — smaller universe but all Type III.
- **KIDS COUNT Data Center — Licensed Early Learning Centers by parish**: https://datacenter.aecf.org/data/tables/1444-licensed-early-learning-centers — count-only.
- **LA Quality Start Performance Profile** publicly-rated centers.

## Regulatory / Compliance Source URLs

- LDE Child Care Facility Licensing: https://doe.louisiana.gov/early-childhood/child-care-facility-licensing
- Bulletin 137 (current; ACF 508, July 2024): https://licensingregulations.acf.hhs.gov/sites/default/files/licensing_regulation/LA_CENTER_JUL_2024_508.pdf
- Bulletin 137 (2021 BESE — LA SOS): https://sbp.sos.la.gov/rules/2021-06%20BESE%20Louisiana%20Early%20Learning%20Center%20Licensing%20Regulations.pdf
- LAC 28 Part CLXV consolidated BESE rules: https://www.doa.la.gov/media/xlpa5i53/28v165.pdf
- LAC 28:CLXI-1711 (Ratios): https://www.law.cornell.edu/regulations/louisiana/La-Admin-Code-tit-28-SS-CLXI-1711
- LAC 28:CLXI-307 (Types of Licenses): https://www.law.cornell.edu/regulations/louisiana/La-Admin-Code-tit-28-SS-CLXI-307
- Bulletin 137 Hot Topics 2024: https://doe.louisiana.gov/docs/default-source/early-childhood/bulletin-137-hot-topics-ecc2024.pdf
- Louisiana Child-to-Staff Ratios & Group Sizes PDF: https://doe.louisiana.gov/docs/default-source/covid-19-resources/child-to-staff-ratios-and-maximum-group-sizes.pdf
- Teacher/Child Ratios (LDE): https://doe.louisiana.gov/docs/default-source/early-childhood/teacher-child-ratios.pdf
- Louisiana School and Center Finder: https://louisianaschools.com/
- DCFS legacy Care Facility search (partial/slow): https://webapps.dcfs.la.gov/carefacility/index
- La. R.S. 17:407.31 et seq. (Early Learning Center Licensing Act): https://law.justia.com/codes/louisiana/revised-statutes/title-17/
- Bulletin 139 (CCDF Programs): https://www.boarddocs.com/la/bese/Board.nsf/files/9U23TH80D1B6/$file/AGII%205.4.%20B139.CCDF%20Programs.pdf
- Public Health Law Center — LA Child Care Center: https://www.publichealthlawcenter.org/sites/default/files/LA%20Child%20Care%20Center.pdf
- KIDS COUNT — Licensed Early Learning Centers by state: https://datacenter.aecf.org/data/tables/1444-licensed-early-learning-centers
