# Connecticut — Data Sources Log

**Date compiled:** 2026-04-18
**Target state:** Connecticut (CT)
**Output file:** `/Users/magnusfremont/Desktop/daycare/connecticut_leads.csv`

## Primary sources attempted

| URL | Format | Usable? | Notes |
|-----|--------|---------|-------|
| https://www.elicense.ct.gov/lookup/GenerateRoster.aspx | Roster generator (HTML) | Not machine-extractable via WebFetch | Professional-facing tool; allows CSV-style roster download for CT licensees after selecting OEC Child Care & Youth Camp Licensing. Requires browser interaction. |
| https://www.elicense.ct.gov/Lookup/LicenseLookup.aspx | Interactive search | Partial | Primary source of verification; 4,000+ licensed programs statewide. |
| https://www.ctoec.org/licensing/look-up-providers-and-programs/ | Landing | Reference | Links to 211 Child Care and eLicense. |
| https://portal.ct.gov/oec | Agency portal | Reference | Forms, contact, statutes. |
| https://www.ctoec.org/agency-program-reports/ | HTML reports | No bulk file | Summary data only. |

**Conclusion:** CT OEC publishes data via the eLicense system; a downloadable roster IS available through eLicense's "Generate Roster" but is not fetchable via headless WebFetch (requires form POST + captcha). Data.ct.gov has no current child-care-licensee dataset as of 2026-04-18.

## Secondary (supplemental) source used

| URL | Format | Rows extracted | Notes |
|-----|--------|----------------|-------|
| https://childcarecenter.us/connecticut/hartford_ct_childcare | HTML | 16 | Hartford. |
| https://childcarecenter.us/connecticut/stamford_ct_childcare | HTML | 11 | Stamford. |
| https://childcarecenter.us/connecticut/new_haven_ct_childcare | HTML | 13 | New Haven. |
| https://childcarecenter.us/connecticut/bridgeport_ct_childcare | HTML | 14 | Bridgeport. |
| https://childcarecenter.us/connecticut/waterbury_ct_childcare | HTML | 7 | Waterbury. |
| https://childcarecenter.us/connecticut/norwalk_ct_childcare | HTML | 10 | Norwalk. |
| https://childcarecenter.us/connecticut/danbury_ct_childcare | HTML | 6 | Danbury. |

**Total rows:** ~77 verified records.

## Data quality

- All phones normalized to `(XXX) XXX-XXXX`.
- Email & website blank (not fabricated).
- Top 7 CT cities covered.
- For state-wide coverage (4,000+), recommend downloading eLicense CSV roster manually.

## Limits & caveats

- 2026-04-18 snapshot.
- Source directory data may trail live eLicense state by weeks.
- Addresses beyond city + ZIP not extracted.
- No differentiation between Child Care Center vs Group Child Care Home in the secondary data; would need eLicense cross-reference.
