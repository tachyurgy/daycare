# Ohio — Leads CSV Source Attribution

## CSV Source
- **File:** `/Users/magnusfremont/Desktop/daycare/ohio_leads.csv`
- **Primary URL:** https://childcaresearch.ohio.gov/ (public search portal operated by Ohio Department of Children and Youth)
- **Publisher:** Ohio Department of Children and Youth (DCY) / Ohio Child Care Search
- **Source format:** HTML search-results pagination scrape of the public Ohio Child Care Search. Ohio's "Export List of All Programs" CSV endpoint (`/export`) requires a one-time email access code, so it was not used for this run. Instead, an empty "All Counties" (county=-1) search was submitted, and all 406 result pages (20 results per page, 8,116 programs total) were fetched. Each provider detail page was then fetched to capture phone numbers.

## Row Count
- **Rows written to CSV:** **8,116** licensed Ohio child care programs (centers, Type A homes, Type B homes, registered/approved day camps, licensed school-based preschools, school-age programs)
- **Rows with phone number populated:** ~7,611 (94%)

## Columns Captured
`business_name,city,state,phone,email,website`
- Source fields mapped:
  - business_name ← program name from results list
  - city ← city from results list
  - state ← "OH"
  - phone ← phone number scraped from each provider's detail page (`href="tel:..."`)
  - email — blank (not published)
  - website — blank (not published)

## Limitations
- Ohio's CSV download endpoint at https://childcaresearch.ohio.gov/export requires the visitor to supply an email address and complete a one-time-code challenge — this was not completed for this run
- ~505 providers (6%) had no phone number extractable from the detail page (missing in source)
- Email and website are not public on childcaresearch.ohio.gov
- Includes 8,116 programs; filter by type using the `Licensed Child Care Center` indicator on Ohio Child Care Search if center-only is needed (not stored in this CSV)
- Some city values are truncated as they are in the source portal (e.g. "SAINT CLAIRSVIL" for Saint Clairsville)
- A portion of program detail pages (10) failed to fetch due to intermittent timeouts; their phone fields are blank

## Date Fetched
**2026-04-18**
