# Kentucky — Sources & Data Pull Log

**Researched:** 2026-04-18
**Lead file:** `/Users/magnusfremont/Desktop/daycare/kentucky_leads.csv`
**Lead row count:** 68 (plus header)

## Data Source Strategy

Kentucky CHFS publishes the **kynect Child Care Provider Search** (https://kynect.ky.gov/benefits/s/child-care-provider) with per-provider inspection reports and All STARS ratings, but the portal is JavaScript-rendered (Salesforce) and does not expose a bulk CSV or simple GET endpoint for export. The CHFS DRCC directly does not publish a downloadable list either.

Used **childcarecenter.us** (~1,783 KY centers aggregated from CHFS licensee roster) for the top 4 cities.

## Cities Captured

| City | Records |
|---|---|
| Louisville | 20 (of 340) |
| Lexington | 20 (of 151) |
| Bowling Green | 20 (of listing) |
| Owensboro | 8 (of 37) |
| **TOTAL** | **68** |

Directory URLs used:
- https://childcarecenter.us/kentucky/louisville_ky_childcare
- https://childcarecenter.us/kentucky/lexington_ky_childcare
- https://childcarecenter.us/kentucky/bowling_green_ky_childcare
- https://childcarecenter.us/kentucky/owensboro_ky_childcare

## Limits

- **Portal-only pull**; CHFS does not publish a bulk dataset.
- **Coverage:** 68 records against ~1,783 KY centers (≈4%). Concentrated in top-4 metros.
- **Phone only** universally present. Email and website blank.
- **Owensboro** was lighter (only 8 clean rows shown on the aggregator's first page) — a second-page fetch would add more.
- Kentucky data intermixes **Type I (center)** and **Type II (home-based, 7-12 children)** — no license-type column was added. Both are ICPs for ComplianceKit, but home-based Type II will likely self-identify differently in outreach.
- **Large share of after-school programs** in Lexington/Bowling Green (elementary-school-based) — these are licensed but often run by school districts with district compliance already handled. Filter before outbound sales.

## Alternate / Future Sources

- **kynect API / scrape**: would need a browser-based crawler (Salesforce Lightning) — feasible but slow. Could capture ratings, inspection history, hours.
- **Open records request to CHFS Office of Inspector General** (fax (502) 564-9350 or chfsoigrccportal@ky.gov) for a full licensee roster.
- **Kentucky All STARS** participating-provider list (subset with quality ratings, higher-intent): https://www.chfs.ky.gov/agencies/dcbs/dcc/Pages/all-stars.aspx
- **Child Care Aware of Kentucky** referrals: (877) 316-3552.

## Regulatory / Compliance Source URLs

- CHFS Office of Inspector General — Division of Regulated Child Care: https://www.chfs.ky.gov/agencies/os/oig/drcc/Pages/default.aspx
- CHFS — Division of Child Care (DCBS): https://www.chfs.ky.gov/agencies/dcbs/dcc/Pages/find-care.aspx
- kynect Child Care Provider Search: https://kynect.ky.gov/benefits/s/child-care-provider
- 922 KAR 2:090 (Licensure): https://apps.legislature.ky.gov/law/kar/titles/922/002/090/
- 922 KAR 2:090 (2025 update via LII): https://www.law.cornell.edu/regulations/kentucky/922-KAR-2-090_v2
- 922 KAR 2:110 (Provider Requirements): https://www.publichealthlawcenter.org/sites/default/files/KY_922%20KAR%202.110%20Child%20Care%20Facility%20Provider%20Requirements_H_FINAL.pdf
- 922 KAR 2:120 (Health & Safety): https://apps.legislature.ky.gov/law/kar/titles/922/002/120/
- 922 KAR 2:100 (Certification of Family Homes): https://regulations.justia.com/states/kentucky/title-922/chapter-2/100/
- 922 KAR 2:270 (KY All STARS QRIS): https://www.law.cornell.edu/regulations/kentucky/922-KAR-2-270
- OIG-DRCC-01 Initial License Application PDF: https://www.chfs.ky.gov/agencies/dcbs/dcc/Documents/oigdrcc01.pdf
- DCC-112 Looking for Quality Child Care: https://www.chfs.ky.gov/agencies/dcbs/dcc/Documents/dcc112.pdf
- Staff-to-Child Ratio Posting (Child Care Aware KY): https://www.childcareawareky.org/wp-content/uploads/2019/09/Section-12-Forms-and-Postings-4-Licensed-Child-Care-Staff-to-Child-Ratio.pdf
- KY Child Care Providers Resource Guide (12/10/2025): https://www.chfs.ky.gov/agencies/os/oig/drcc/Documents/KY%20Child%20Care%20Providers%20Resource%20Guide%2012.10.25.pdf
- kynect Provider Search FAQ: https://www.chfs.ky.gov/agencies/dms/kynect/kbFAQChildCareSearch.pdf
- ACF Licensing Regulations Database — KY Centers (June 2021): https://licensingregulations.acf.hhs.gov/sites/default/files/licensing_regulation/KY_CENTER_JUNE_2021_508.pdf
- Public Health Law Center — KY Child Care Laws: https://www.publichealthlawcenter.org/resources/healthy-child-care/ky
