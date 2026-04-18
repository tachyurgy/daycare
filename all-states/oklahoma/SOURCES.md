# Oklahoma — Data Sources Log

**Date compiled:** 2026-04-18
**Target state:** Oklahoma (OK)
**Output file:** `/Users/magnusfremont/Desktop/daycare/oklahoma_leads.csv`

## Primary sources attempted

| URL | Format | Usable? | Notes |
|-----|--------|---------|-------|
| https://childcarefind.okdhs.org/ | Interactive JS search portal | Partial | Browseable list of all 3,728 programs, but no bulk CSV export; individual details require per-provider clicks. |
| https://ccl.dhs.ok.gov/providers | Same portal (alt URL) | Partial | Shows 190 OKC / 176 Tulsa results but phone/address only on detail pages. |
| https://oklahoma.gov/okdhs/services/child-care-services.html | HTML landing | Contact info only | No downloadable dataset. |
| https://licensingregulations.acf.hhs.gov/licensing/contact/oklahoma-department-human-services-child-care-services | HHS directory | Reference | Contact info and regs. |

**Conclusion:** OKDHS does not publish a CSV/Excel export of licensed providers; data is only available through the interactive Child Care Locator. No open-data portal (data.ok.gov) entry exists for child care as of 2026-04-18.

## Secondary (supplemental) source used

| URL | Format | Rows extracted | Notes |
|-----|--------|----------------|-------|
| https://childcarecenter.us/oklahoma/oklahoma_city_ok_childcare | HTML (paginated) | 20 verified names + phones + ZIPs | Directory site, publishes data on licensed OK centers. |
| https://childcarecenter.us/oklahoma/tulsa_ok_childcare | HTML | 20 | Same source, Tulsa. |
| https://childcarecenter.us/oklahoma/norman_ok_childcare | HTML | 20 | Norman. |
| https://childcarecenter.us/oklahoma/edmond_ok_childcare | HTML | 20 | Edmond. |
| https://childcarecenter.us/oklahoma/broken_arrow_ok_childcare | HTML | 20 | Broken Arrow. |

**Total rows:** ~100 verified records in `oklahoma_leads.csv` (business_name, city, state, phone, email, website — emails/websites left blank, not fabricated).

## Data quality

- All phones normalized to `(XXX) XXX-XXXX`.
- Email & website intentionally **blank** — source did not publish; not fabricated.
- Only top 5 cities by licensed-provider count covered due to portal constraints.
- For full coverage of all 3,728 OK programs, a bulk request would need to be made via OKDHS public-records / FOIA, or via scraping the locator's per-provider API (out of scope for this 2026-04-18 pass).

## Limits & caveats

- 2026-04-18 snapshot; OK licensing status can change weekly.
- Addresses beyond city + ZIP not extracted — would require per-provider page fetch.
- Source childcarecenter.us may not reflect centers that opened/closed in the last 6 months.
- No sales-lead provenance tracker included — downstream enrichment recommended before outreach.
