# Rhode Island — Data Sources & Lead Provenance

**Compiled:** 2026-04-18
**State slug:** rhode_island
**Leads CSV:** `/Users/magnusfremont/Desktop/daycare/rhode_island_leads.csv`

## Primary Data Source (used for leads)

**childcarecenter.us — third-party national directory**

- Portal root: https://childcarecenter.us/state/rhode_island
- Cities scraped (top 3 by facility count):
  - Providence: https://childcarecenter.us/rhode_island/providence_ri_childcare (pages 1–4 — 73 centers)
  - Warwick: https://childcarecenter.us/rhode_island/warwick_ri_childcare (pages 1–2 — 39 centers)
  - Cranston: https://childcarecenter.us/rhode_island/cranston_ri_childcare (pages 1–3 — 48 centers)
- Format: HTML (manual transcription from paged listings, 20 per page)
- Rows in leads CSV: **137**
- Fields captured: business_name, city, state, phone (all rows), website (1 row with own domain)

## Why the "top 3 cities" approach (and not bulk)

Rhode Island's official provider search — **RISES Family portal** at https://earlylearningprograms.dhs.ri.gov/ — is a **Salesforce Experience Cloud (Lightning / LWC)** community:

- The DOM is populated by Salesforce Aura framework at runtime.
- API calls are routed through `ridhsrises.my.salesforce.com` with session-scoped authentication.
- No public JSON / CSV export is exposed.
- No bulk data endpoint is published.
- A direct curl fetch of the page returns only the Aura bootstrap scripts; data is not server-rendered.

Scraping the RISES portal would require a headless browser (Puppeteer/Playwright), tolerance for Salesforce rate-limiting, and ongoing maintenance as the LWC app changes. Out of scope for this pass.

**Historical RI data:** A 2018 Child Care Market Rate Survey documented 479 family child care homes + 426 licensed centers = 905 total licensed providers. RI is a small state so the top 3 cities (Providence, Warwick, Cranston) contain a high share of the licensed centers.

## Regulatory / Compliance Sources

- **RI DHS — Child Care Providers:** https://dhs.ri.gov/programs-and-services/child-care/child-care-providers
- **RI DHS — Regulations:** https://dhs.ri.gov/regulations
- **218-RICR-70-00-1 (Center & School-Age) — SOS text:** https://rules.sos.ri.gov/Regulations/part/218-70-00-1
- **218-RICR-70-00-1 full PDF:** https://dhs.ri.gov/sites/g/files/xkgbur426/files/2022-02/218-ricr-70-00-1-child-care-center-and-school-age-program-regulations-for-licensure.pdf
- **218-RICR-70-00-2 (Family Child Care Home):** https://rules.sos.ri.gov/regulations/part/218-70-00-2
- **218-RICR-70-00-7 (Group Family Child Care Home) PDF:** http://risos-apa-production-public.s3.amazonaws.com/DHS/REG_10927_20191206131704.pdf
- **RI DCYF Licensing:** https://dcyf.ri.gov/services/licensing
- **RISES Early Learning Programs portal:** https://earlylearningprograms.dhs.ri.gov/
- **RI DHS Office of Child Care (ACF contact):** https://licensingregulations.acf.hhs.gov/licensing/contact/rhode-island-department-human-services-office-child-care
- **RI AirCare Immunization Data Hub:** https://ricair-data-rihealth.hub.arcgis.com/pages/child-care (RI DOH immunization reporting for licensed programs; a secondary source useful for cross-referencing)

## Sources Considered but Not Used

- **RISES Family portal (earlylearningprograms.dhs.ri.gov):** Salesforce LWC, no public API. Future: scrape via headless browser.
- **childcareaware.org (RI page):** State-level aggregates only.
- **Yelp / Care.com:** Unreliable for licensing status.

## Known Limitations

- **No emails.** Source does not publish.
- **Websites nearly absent.** Only 1 row has a confirmed site.
- **Coverage ≈ 137 of ~426 licensed centers (~32%)** — heavily weighted to Providence metro. Pawtucket, Woonsocket, East Providence, Newport, North Providence are notable absences.
- **Family Child Care Homes not included** (a separate rule type; RI has ~479 of these).
- **Point-in-time.** Aggregator may lag actual licensing status; verify via RISES before contracting with any lead.

## Refresh Strategy

1. **Next 30 days:** Scrape childcarecenter.us for Pawtucket, Woonsocket, East Providence, North Providence, Newport, Coventry — should add ~150–200 rows.
2. **Within 60 days:** File an APRA (RI Access to Public Records Act — R.I. Gen. Laws §38-2) request with DHS Office of Child Care for a flat-file export of currently licensed Child Care Centers. Cite the statute; response is typically 10 business days.
3. **Quarterly:** Re-pull childcarecenter.us top 5 cities to catch openings/closures.
4. **Stretch:** Build a Playwright scraper against the RISES portal to get live capacity + BrightStars rating data (high-value segmentation signal).
