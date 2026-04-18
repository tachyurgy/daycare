# Idaho — Lead Data Sources

**Collection date:** 2026-04-18
**Output file:** `/Users/magnusfremont/Desktop/daycare/idaho_leads.csv`
**Row count:** 2,045 facilities

## Primary Bulk Dataset

**Idaho Child Care Check** — public-facing safety, inspections, and incidents directory operated by the Idaho Department of Health and Welfare and IdahoSTARS.

- Landing page: https://www.idahochildcarecheck.org/
- Search page: https://www.idahochildcarecheck.org/search
- Paginated: 208 pages of 10 providers each (≈ 2,080 listings).
- URL pattern: `https://www.idahochildcarecheck.org/search?page={N}` where `{N}` ∈ [0, 207].
- **Format:** HTML; provider cards in Drupal "views-row" divs with structured `<div class="views-field views-field-...">` sub-elements.
- **Fields available in source:** Provider Name, Contact Name, Address Line 1, City/State/ZIP, Phone Number, Inspections Conducted count, Most recent inspection date, Pass/Fail history, Substantiated Incidents.
- No login or captcha required; plain HTML scraping with `curl -A "Mozilla/5.0"`.

## Transcription Notes

- All 208 pages downloaded in parallel (batches of 10) via `curl`.
- Python parser uses regex on the per-card HTML to extract provider_name, city, state (validated as "Idaho" or "ID"), and phone.
- Phone numbers normalized from various source formats (`208-9159886`, `2089159886`, `(208) 915-9886`) to `(208) 915-9886` format.
- Cities parsed from "City, Idaho ZIP" and "City, ID ZIP" patterns.
- Deduplicated on (name, city, phone).
- Output sorted by city, then business name.

## Limitations

- Idaho Code §39-1102 exempts **Family Daycare Homes (≤ 6 children)** from state licensure; some small home-based providers listed on Idaho Child Care Check may be voluntarily licensed or operating under **local (city)** licensure only. All ~2,045 entries are in some form of regulatory relationship with the state and/or local jurisdiction.
- **Email** field is not present in the source — all rows show blank `email`.
- **Website** field is not present in the source — all rows show blank `website`.
- Address (street-level) captured during parsing but not retained in the final CSV (schema: name, city, state, phone, email, website only).
- Some providers in the source have Contact name shown in SHOUTY CAPS — retained as-is in the scrape but not included in the output CSV (owner name is not a CSV field).

## Secondary Sources (verification)

- **IdahoSTARS** (quality rating & referral): https://idahostars.org/
- **IDHW Child Care program overview:** https://healthandwelfare.idaho.gov/services-programs/child-care
- **IDHW Find Quality Child Care:** https://healthandwelfare.idaho.gov/services-programs/children-families/find-quality-child-care
- **Becoming a Child Care Provider:** https://healthandwelfare.idaho.gov/providers/child-care-providers/becoming-child-care-provider
- **Eastern Idaho Public Health Child Care:** https://eiph.id.gov/ (regional health district inspections)
- **Southwest District Health Child Care:** https://swdh.id.gov/licensing-permitting/child-care-program/

## Rows / Coverage

- 2,045 unique child care providers statewide.
- Fields populated: `business_name` (100%), `city` (~99%), `state` (100%), `phone` (~98%), `email` (0%), `website` (0%).
- Covers daycare centers (≥ 13 children), group daycare facilities (7–12), and voluntarily-licensed family daycare homes (≤ 6).
