# Illinois — Leads CSV Source Attribution

## CSV Source
- **File:** `/Users/magnusfremont/Desktop/daycare/illinois_leads.csv`
- **Primary URL:** https://sunshine.dcfs.illinois.gov/Content/Licensing/Daycare/ProviderLookup.aspx (ASP.NET postback — built-in "Export" button returns `Daycare Providers.csv`)
- **Publisher:** Illinois Department of Children and Family Services (DCFS) Sunshine portal
- **Source format:** CSV download obtained by programmatic POST to the ASP.NET form (blank search → Export button) — emulating a browser session. The public portal exposes this Export natively to any visitor.

## Row Count
- **Rows written to CSV:** **8,586** active / pending-renewal licensed IL day care facilities
- **Raw export size:** 8,595 rows; a few with status "Revoked" / "Closed" / "Surrendered" / "Terminated" were filtered out

## Columns Captured
`business_name,city,state,phone,email,website`
- Source fields mapped:
  - business_name ← `DoingBusinessAs`
  - city ← `City`
  - state ← "IL"
  - phone ← `Phone` (re-formatted to `(XXX) XXX-XXXX`)
  - email — blank (not published)
  - website — blank (not published)

## Limitations
- The DCFS Sunshine portal only publishes: ProviderID, DoingBusinessAs, Street, City, County, Zip, Phone, FacilityType, DayAgeRange, NightAgeRange, Languages, DayCapacity, NightCapacity, Status. Email and website are **not** in the public dataset.
- Dataset reflects a live snapshot of currently-licensed facilities at time of fetch. Status values include "License issued (IL)" and "Pending renewal application (RN)".
- Types included: Day Care Centers (DCC), Day Care Homes (DCH), Group Day Care Homes (GDCH), Night Care Centers, etc. Filter by `FacilityType` if center-only is needed.

## Date Fetched
**2026-04-18**
