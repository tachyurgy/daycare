# New Hampshire — Data Sources & Lead Provenance

**Compiled:** 2026-04-18
**State slug:** new_hampshire
**Leads CSV:** `/Users/magnusfremont/Desktop/daycare/new_hampshire_leads.csv`

## Primary Data Source (used for leads)

**childcarecenter.us — third-party national directory**

- Portal root: https://childcarecenter.us/state/new_hampshire
- Cities scraped (top 3 by facility count):
  - Manchester: https://childcarecenter.us/new_hampshire/manchester_nh_childcare (pages 1–3 — ~47 centers)
  - Nashua: https://childcarecenter.us/new_hampshire/nashua_nh_childcare (pages 1–2 — ~40 centers)
  - Concord: https://childcarecenter.us/new_hampshire/concord_nh_childcare (pages 1–2 — ~31 centers)
- Format: HTML (manual transcription from paged listings, 20 per page)
- Rows in leads CSV: **114**
- Fields captured: business_name, city, state, phone (all rows), website (rows where provider had own domain in web-search results — minority)

## Why the "top 3 cities" approach (and not bulk)

New Hampshire's official child care provider search — **NH Child Care Search** at https://new-hampshire.my.site.com/nhccis/NH_ChildCareSearch — is a **Salesforce Lightning / Visualforce** community powered by `Visualforce.remoting` remote actions (`fetchAccountList`, `fetchProviderList`, `retrieveAccountRecords`). The endpoints require session tokens, anti-CSRF headers, and authenticated bearer tokens that are scoped to a user session.

This is not reasonably scrapeable without a browser automation session or a DHHS partnership. The unit confirmed by email (per public comms) that data exports are available on request but require a formal data-use agreement.

**Bulk dataset status:** No open-data bulk CSV exists as of 2026-04-18. NH does not publish its licensed-provider list via data.nh.gov or any open-data portal.

**Approach used:** Top-3-cities transcription per the assignment rubric. Manchester, Nashua, and Concord are confirmed as NH's top 3 population centers (and therefore license density).

## Regulatory / Compliance Sources

- **NH DHHS — Child Care Licensing:** https://www.dhhs.nh.gov/programs-services/childcare-parenting-childbirth/child-care-licensing
- **He-C 4002 — adopted rule (2025-08-26) PDF:** https://www.dhhs.nh.gov/sites/g/files/ehbemt476/files/documents2/he-c-4002-formatted.pdf
- **He-C 4002.02 (Licensure & Renewal) via Cornell LII:** https://www.law.cornell.edu/regulations/new-hampshire/N-H-Admin-Code-SS-He-C-4002.02
- **He-C 4002.37 (Infant/Toddler Program) via Cornell LII:** https://www.law.cornell.edu/regulations/new-hampshire/N-H-Admin-Code-SS-He-C-4002.37
- **RSA 170-E (statute):** https://www.gencourt.state.nh.us/rsa/html/NHTOC/NHTOC-XII-170-E.htm
- **NH Child Care Licensing Unit:** https://www.dhhs.nh.gov/child-care-licensing-unit
- **National Database of Child Care Licensing Regulations (ACF — NH):** https://licensingregulations.acf.hhs.gov/licensing/states-territories/new-hampshire

## Sources Considered but Not Used

- **nh-connections.org (NH-CCR&R):** Referral service with warm lists but no bulk data download.
- **childcareaware.org (NH page):** Aggregated at state level only; no provider list.
- **Yelp / Google Maps:** Dense but unreliable for licensing status; unused.

## Known Limitations

- **No email addresses** — childcarecenter.us does not publish email and NH DHHS does not either. Email enrichment requires scraping provider websites or Hunter.io-style lookup.
- **Website URLs are sparse** — only centers with their own consumer-facing domain that surfaced in supplementary web searches are linked.
- **Cities outside top 3 are not covered** — Dover, Rochester, Portsmouth, Salem, Derry, Keene collectively hold ~150 additional centers not in this file. Next pull should expand.
- **The third-party aggregator is point-in-time** — centers that closed since last index update may still appear; verify license status against NH Child Care Search before high-value outreach.

## Refresh Strategy

1. Short-term: Expand childcarecenter.us scrape to next 5 cities (Dover, Rochester, Portsmouth, Salem, Derry).
2. Medium-term: Submit a public-records request to NH DHHS CCLU (cclunit@dhhs.nh.gov) for a flat-file export of currently licensed programs under RSA 91-A. Response typically within 10 business days.
3. Long-term: If volume justifies it, build a Puppeteer/Playwright scraper against the NH Child Care Search Visualforce endpoints (rotating sessions, respecting robots.txt).
