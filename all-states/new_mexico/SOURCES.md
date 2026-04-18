# New Mexico — Lead Data Sources

**Collection date:** 2026-04-18
**Output file:** `/Users/magnusfremont/Desktop/daycare/new_mexico_leads.csv`
**Row count:** 770 facilities

## Bulk Dataset Status

**No publicly downloadable bulk dataset** located for New Mexico licensed child care providers as of 2026-04-18.

- **ECECD Child Care Finder** (https://childcare.ececd.nm.gov/search) returns results only via an interactive filtered search; no list-all export.
- **NewMexicoKids verification portal** (https://search.newmexicokids.org/) is designed to verify a single provider's registration status — its AJAX endpoint (`/mariosearch`) accepts `{fullname, zip}` inputs and returns yes/no, not a list.
- New Mexico does not store full address data centrally at NewMexicoKids ("we do _not_ store complete address information … only city, county, and zip code").
- data.nm.gov / NM state open data portals do not currently host an ECECD provider list.
- Inspection survey reports (last 3 yrs) are available at https://www.nmececd.org/child-care-services/child-care-licensed-and-registered-provider-inspection-surveys/ but require per-provider retrieval.
- IPRA (NM Inspection of Public Records Act) request route: https://www.nmececd.org/inspection-of-public-records-act-ipra/
- No HIFLD mirror located for New Mexico during this collection pass.

## Strategy Used

**Directory scrape of top 25 New Mexico cities** using `childcarecenter.us`, which aggregates state-licensed provider data.

Cities scraped:
Albuquerque, Las Cruces, Rio Rancho, Santa Fe, Roswell, Farmington, Hobbs, Clovis, Alamogordo, Carlsbad, Gallup, Los Lunas, Deming, Chaparral, Sunland Park, Las Vegas, Portales, Los Alamos, Lovington, Española, Silver City, Artesia, Bernalillo, Ruidoso, Corrales.

- URL pattern: `https://childcarecenter.us/new_mexico/{city_slug}_nm_childcare`
- Paginated using `?page=N`.
- Records parsed from `<a href="/provider_detail/...">NAME</a>` + `<span>City, NM ZIP | (XXX) XXX-XXXX</span>` pattern.

## Fields

- `business_name`: provider name
- `city`: parsed from source listing
- `state`: "NM"
- `phone`: `(XXX) XXX-XXXX` where available
- `email`: not available from this source — blank
- `website`: not available from this source — blank

## Limitations

- A subset of records show "(EMERG OPEN)" suffix in business names — these are COVID-era Emergency Child Care or subsidy-approved emergency operations; most remain licensed/operating. Retained in dataset but noted.
- Coverage urban-biased; smaller pueblo / reservation-based programs may be under-represented.
- Some entries may be registered home providers rather than licensed centers (both are valid ECECD-regulated programs).
- Phone numbers are pulled from the directory listing; recommend verification against ECECD Finder before outreach.

## Secondary Sources (for verification / augmentation)

- **ECECD Child Care Finder:** https://childcare.ececd.nm.gov/search
- **NewMexicoKids Search:** https://search.newmexicokids.org/
- **ECECD Regulatory Oversight Unit:** https://www.nmececd.org/child-care-licensing-and-registered-homes/
- **Inspection Surveys (last 3 yrs):** https://www.nmececd.org/child-care-services/child-care-licensed-and-registered-provider-inspection-surveys/
- **NM ECECD Child Care Services overview:** https://www.nmececd.org/child-care-services/

## Rows / Coverage

- 770 unique records (deduplicated by name + city + phone) across the top 25 New Mexico cities.
- Fields populated: `business_name` (100%), `city` (100%), `state` (100%), `phone` (~85%), `email` (0%), `website` (0%).
