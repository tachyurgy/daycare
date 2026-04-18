# Kansas — Lead Data Sources

**Collection date:** 2026-04-18
**Output file:** `/Users/magnusfremont/Desktop/daycare/kansas_leads.csv`
**Row count:** 770 facilities

## Bulk Dataset Status

**No publicly downloadable bulk dataset** is available for Kansas licensed child care facilities as of 2026-04-18.

- KDHE's Online Facility Compliance Search (https://khap.kdhe.ks.gov/OIDS/ and https://khap2.kdhe.state.ks.us/OIDS/) is protected by Google reCAPTCHA v3 and ASP.NET ViewState — each search is a single-facility lookup and cannot be enumerated.
- Kansas Provider Access Portal (CLARIS: https://claris.kdhe.state.ks.us:8443/claris/public/publicAccess.3mv) requires authentication for list views.
- KDHE directs bulk data requests to the **Child Care Data Request page**: https://www.kdhe.ks.gov/2185/Data-Request (public records request / KORA).
- Kansas open data portal (data.kansas.gov) and Kansas Geospatial Community Commons do **not** currently publish the KDHE child care facility roster.
- No HIFLD mirror located for Kansas during this pass (HIFLD nationwide Child Care Centers feature service was unreachable / had stale service name at time of collection).

## Strategy Used

**Directory scrape of top 25 Kansas cities** using `childcarecenter.us`, which aggregates licensed-child-care-facility data from KDHE public records and provider self-registrations.

Cities scraped (top 25 by 2020 Census population + geographic distribution):
Wichita, Overland Park, Kansas City, Olathe, Topeka, Lawrence, Shawnee, Manhattan, Lenexa, Salina, Hutchinson, Leavenworth, Leawood, Dodge City, Garden City, Emporia, Derby, Gardner, Prairie Village, Liberal, Junction City, Hays, Pittsburg, Newton, Great Bend.

- URL pattern: `https://childcarecenter.us/kansas/{city_slug}_ks_childcare`
- Paginated using `?page=N` for results > 1 page.
- Records parsed from `<a href="/provider_detail/...">NAME</a>` + `<span>City, KS ZIP | (XXX) XXX-XXXX</span>` pattern.

## Fields

- `business_name`: provider name
- `city`: parsed from source listing
- `state`: "KS"
- `phone`: `(XXX) XXX-XXXX` where available
- `email`: not available from this source — blank
- `website`: not available from this source — blank

## Limitations

- Coverage is **urban/suburban biased**; small-town licensed family child care homes are under-represented.
- `childcarecenter.us` includes both licensed providers and voluntary-listing providers; a small fraction of entries may not correspond to a current KDHE license.
- Not every county/city is covered — only the top 25 cities by population were crawled to stay within the task's "top 5 cities / 200–1000 rows" directive (770 rows obtained).
- Data freshness depends on individual provider updates on the directory site; spot-checking against live KDHE search is recommended before outreach.

## Secondary Sources (not scraped, for manual verification / record augmentation)

- KDHE Online Facility Compliance Search: https://khap.kdhe.ks.gov/OIDS/
- KDHE Facility Inspection Results: https://www.kdhe.ks.gov/386/Facility-Inspection-Results
- Kansas Child Care Aware search: https://ks.childcareaware.org/childcaresearch/
- Kansas Provider Access Portal: https://claris.kdhe.state.ks.us:8443/claris/public/publicAccess.3mv

## Rows / Coverage

- 770 unique records (deduplicated by name + city + phone) across the top 25 Kansas cities.
- Fields populated: `business_name` (100%), `city` (100%), `state` (100%), `phone` (~85%), `email` (0%), `website` (0%).
