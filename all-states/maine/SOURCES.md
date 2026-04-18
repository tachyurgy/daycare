# Maine — Data Sources & Lead Provenance

**Compiled:** 2026-04-18
**State slug:** maine
**Leads CSV:** `/Users/magnusfremont/Desktop/daycare/maine_leads.csv`

## Primary Data Source (used for leads)

**childcarecenter.us — third-party national directory**

- Portal root: https://childcarecenter.us/state/maine
- Cities scraped (top 3 by facility count):
  - Portland: https://childcarecenter.us/maine/portland_me_childcare (pages 1–3 — 43 centers)
  - Bangor: https://childcarecenter.us/maine/bangor_me_childcare (pages 1–2 — 25 centers)
  - Lewiston: https://childcarecenter.us/maine/lewiston_me_childcare (pages 1–2 — 29 centers)
- Format: HTML (manual transcription from paged listings, 20 per page)
- Rows in leads CSV: **96**
- Fields captured: business_name, city, state, phone (all rows), website (2 rows with confirmed domains from supplementary search)

## Why the "top 3 cities" approach (and not bulk)

Maine OCFS publishes an interactive search portal at **search.childcarechoices.me** (backed by asp.net MS Ajax page methods, Google Maps) — but:

- No "list all" affordance; queries require city/zip/address + radius.
- No bulk export (CSV/JSON) is exposed.
- Backend uses ASP.NET WebForms with ViewState tokens; scraping requires session handling but is feasible.
- OCFS will provide a flat file on FOAA (Freedom of Access Act — 1 M.R.S. Chapter 13) request, typically 10–20 business days.

Maine is a low-density state (~952 licensed centers + a larger number of family providers per childcarecenter.us). The top 3 cities (Portland, Bangor, Lewiston/Auburn area) contain a concentrated share of facilities and are the highest-value ICP match for ComplianceKit.

## Regulatory / Compliance Sources

- **Maine OCFS — Child Care Licensing:** https://www.maine.gov/dhhs/ocfs/provider-resources/child-care-licensing
- **10-148 CMR Ch. 32 — full rule PDF (eff. 2021-09-27):** https://www.maine.gov/dhhs/sites/maine.gov.dhhs/files/inline-files/Rules-for-the-Licensing-of-Child-Care-Facilities-10-148-Ch-32.pdf
- **10-148 CMR Ch. 32 §4 — Inspections (Justia):** https://regulations.justia.com/states/maine/10/148/chapter-32/section-148-32-4/
- **10-148 CMR Ch. 32 §5 — Record Management (Justia):** https://regulations.justia.com/states/maine/10/148/chapter-32/section-148-32-5/
- **10-148 CMR Ch. 32 §7 — Ratios (Cornell LII):** https://www.law.cornell.edu/regulations/maine/10-148-C-M-R-ch-32-SS-7
- **22 M.R.S. §8301-A — Statute:** https://www.mainelegislature.org/legis/statutes/22/title22sec8301-a.html
- **Maine Licensed Child Care Search:** https://search.childcarechoices.me/
- **National Database (ACF — ME):** https://licensingregulations.acf.hhs.gov/licensing/contact/maine-department-health-and-human-services-office-child-and-family-services

## Sources Considered but Not Used

- **search.childcarechoices.me** — Interactive search only, no bulk. Future candidate for a targeted scraper.
- **fccamaine.com** — Family Child Care Association of Maine trade group; advocacy content, no directory.
- **Maine Trades Directory** — Paid listings, unreliable for license status.
- **KIDS COUNT Data Center (annie e. casey)** — Aggregated counts only; no provider-level data.

## Known Limitations

- **No emails.** childcarecenter.us does not publish and OCFS does not release.
- **Websites sparse** (only 2 of 96 rows include website).
- **Coverage is ~96 of ~950 Maine centers** — representative of the top metros but not statewide. Smaller towns (Augusta, Brunswick, Sanford, Biddeford, Saco, Auburn, Waterville) collectively account for the majority of the remaining facilities.
- **Capacity information** (valuable for segmenting ICP) is present on the aggregator's provider-detail pages but was not captured in the current CSV schema.
- **Family Child Care providers are not included** — those are a different rule (10-148 Ch. 33) and would require a separate pull.

## Refresh Strategy

1. **Next 30 days:** Scrape 10 more cities on childcarecenter.us (Auburn, Augusta, Brunswick, South Portland, Biddeford, Saco, Waterville, Gorham, Scarborough, Westbrook) for ~250–400 additional leads.
2. **Within 60 days:** Submit a Maine FOAA request to OCFS CLIS for a flat-file export of all currently licensed Child Care Facilities. Template: cite 22 M.R.S. §8301-A and 1 M.R.S. §408-A; request CSV with name, address, city, phone, license number, capacity, status.
3. **Quarterly:** Re-pull childcarecenter.us top cities to catch new openings / closures.
