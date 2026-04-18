# Massachusetts — Lead Data Sources

**Date collected:** 2026-04-18

## Primary Source

- **URL:** https://educationtocareer.data.mass.gov/Early-Education-and-Care-/Licensed-and-Funded-Child-Care-Providers/dn4d-tjbb
- **Publisher:** Massachusetts Department of Early Education and Care (EEC), via Education-to-Career (E2C) Research and Data Hub (Socrata platform)
- **Format:** CSV (Socrata Open Data API)
- **Bulk endpoint used:** `https://educationtocareer.data.mass.gov/api/views/dn4d-tjbb/rows.csv?accessType=DOWNLOAD`
- **Alternative API:** `https://educationtocareer.data.mass.gov/resource/dn4d-tjbb.csv?$limit=N`
- **Source data system:** EEC Licensing Education Analytic Database (LEAD) — published quarterly
- **Raw dataset size:** 413,043 rows (contains historical snapshots — monthly/quarterly)
- **Current-snapshot rows extracted:** ~8,345 unique currently-Licensed providers (snapshot date 2026-04-02)
- **Rows written to `massachusetts_leads.csv`:** 1,000 (capped per spec)
- **Fields captured:** business_name (PROGRAM_NAME), city (PROGRAM_CITY), state (MA), phone (PROGRAM_PHONE), email (blank — not in dataset), website (blank — not in dataset)
- **Data freshness in file:** snapshots monthly; latest in file is 04/02/2026

## Secondary/Reference Sources

- https://www.mass.gov/lists/data-on-licensed-and-funded-child-care-programs — mass.gov landing page for EEC data publications
- https://childcare.mass.gov/findchildcare — public-facing directory (geographic search, no bulk download)
- https://www.mass.gov/guides/find-a-licensed-family-group-or-school-age-child-care-program — search guidance

## Limits / Notes

- The dataset does not publish email addresses or phone numbers for family child care (FCC) homes in all cases, per privacy policy. Center-based phones are included.
- Both Licensed and Funded (subsidy contract) programs appear; `LICENSED_FUNDED` column distinguishes.
- Filter applied: `LICENSED_PROVIDER_STATUS = 'Current'` and latest snapshot date to drop closed/historical rows.
- Deduplication by PROVIDER_NUMBER.
- CSV was capped at 1,000 rows per task spec; ~7,345 additional current licensed providers remain available from the same feed.
