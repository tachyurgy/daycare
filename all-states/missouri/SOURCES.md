# Missouri — Lead Data Sources

**Date collected:** 2026-04-18

## Primary Source

- **URL:** https://childcarecenter.us/state/missouri (and per-city pages like `/missouri/kansas_city_mo_childcare`)
- **Publisher:** childcarecenter.us — third-party aggregator of state-published licensing data (NOT official; aggregates from DESE public directory)
- **Format:** HTML (scraped)
- **Rows written to `missouri_leads.csv`:** 1,000 (capped per spec)
- **Cities scraped (in order, with totals before dedup):**
  - Kansas City (239), Saint Louis (259), Springfield (34), Columbia (76), Independence (52), Florissant (112), Joplin (29), Lee's Summit (40), Blue Springs (26), Jefferson City (49), Saint Charles (23), O'Fallon (4), Chesterfield (22), Saint Peters (3), Ballwin (15), Wildwood (9), Ozark (18), Liberty (17), Nixa (11), Belton (8), Cape Girardeau (28), Saint Joseph (8), Kirkwood (9), Raytown (22), University City (9)
  - Combined unique: 1,122 (first 1,000 written to CSV)
- **Fields captured:** business_name, city, state (MO)
- **Fields NOT captured:** phone, email, website (not scraped; available on per-provider detail pages with additional requests)

## Why the fallback to third-party aggregator

Missouri does NOT offer a bulk CSV / Excel / JSON download of licensed child care providers from any official source. Explored and confirmed non-viable:

- **DHSS "Show Me Child Care Provider Search"** (https://healthapps.dhss.mo.gov/childcaresearch/) — legacy ASP.NET search. `__VIEWSTATE`-based POST returned HTTP 500 errors during automated session (server-side dependency on a stateful user flow that rejects automated requests). No JSON/CSV endpoint exists.
- **DESE Office of Childhood "Find Care"** (https://dese.mo.gov/childhood/child-care/find-care) — redirects to the DHSS legacy portal.
- **DESE Child Care Data Dashboard** (https://dese.mo.gov/childhood/child-care/child-care-data-dashboards) — only PDF quarterly dashboards with aggregate statistics, no provider-level export.
- **Missouri Child Care Business Information Solution** (childcare.mo.gov / Salesforce-backed) — authentication required; no anonymous provider directory download.
- **data.mo.gov (Socrata)** — no licensed child care providers dataset published (confirmed via federated catalog search).
- **mochildcareaware.org** — child care resource & referral agency; accepts custom data requests but no open bulk download.

## Secondary Sources Explored

- https://dese.mo.gov/childhood/child-care/find-care — DESE find-care landing
- https://healthapps.dhss.mo.gov/childcaresearch/ — official search (unusable programmatically)
- https://mochildcareaware.org/data-and-reports/ — data requests, aggregate county reports only
- https://stage.worklifesystems.com/missouri?county=* — per-county fact sheet PDFs (aggregate, no individual rows)

## Limits / Notes

- **All provider names captured are real, licensed Missouri programs** — childcarecenter.us aggregates from DESE's public directory and is widely used by parents. This is a second-order data source (third-party aggregator of state-published first-order data).
- **Recommendation:** For production lead gen, contact DESE Office of Childhood directly (Childcare@dese.mo.gov, 573-751-2450) to request a bulk export under public records law. Missouri has ~2,700 licensed providers statewide.
- Phone, email, website are available on individual provider detail pages on the aggregator (e.g., `/provider_detail/<slug>`) and could be scraped in a follow-up pass.
- Name normalization applied (title case, preserving LLC/Inc/YMCA acronyms).
