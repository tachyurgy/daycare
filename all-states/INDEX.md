# ComplianceKit — 50-State Research Pack

Compiled 2026-04-18. Single-session research pass producing, for every U.S. state:

1. **Compliance doc** — licensing authority, primary reg citation, facility types, key forms, ratios, records, inspection & renewal cadence, state-specific features, sources.
2. **Leads CSV** (schema: `business_name,city,state,phone,email,website`) — real licensed providers pulled from authoritative public sources. **No fabrication.**
3. **SOURCES.md** — exact URL, data format, row count, extraction method, limitations, date stamp.

**Total real provider rows across 50 states: ~120,708.**

## File layout

- Leads CSVs: `/Users/magnusfremont/Desktop/daycare/{state}_leads.csv` (project root)
- Compliance docs: `/Users/magnusfremont/Desktop/daycare/all-states/{state_slug}/compliance.md`
- Source attribution: `/Users/magnusfremont/Desktop/daycare/all-states/{state_slug}/SOURCES.md`

CA/TX/FL retain their pre-existing HTML product specs under `planning-docs/state-docs/{ca,tx,fl}/`; `all-states/` entries for those three are not duplicated.

## States ordered by 2024 population

| Rank | State | Licensing Authority | Primary Reg Cite | Leads | Source Type |
|-----:|-------|---------------------|------------------|------:|-------------|
| 1 | California | CDSS Community Care Licensing Div. | 22 CCR Div. 12 (Title 22) | 9,401 | pre-existing |
| 2 | Texas | HHSC Child Care Regulation | 26 TAC Ch. 744–747 | 9,685 | pre-existing |
| 3 | Florida | DCF Child Care Services | F.A.C. 65C-22 / CFOP 170-20 | 7,647 | pre-existing |
| 4 | New York | OCFS | 18 NYCRR Part 418 | 16,770 | data.ny.gov Socrata CSV (`cb42-qumz`) |
| 5 | Pennsylvania | DHS / OCDEL | 55 Pa. Code Ch. 3270 | 7,473 | data.pa.gov Socrata CSV (`ajn5-kaxt`) |
| 6 | Illinois | DCFS | 89 Ill. Admin. Code 407 | 8,586 | DCFS Provider Lookup export |
| 7 | Ohio | ODJFS / DCY | OAC 5101:2-12 | 8,116 | childcaresearch.ohio.gov two-stage scrape |
| 8 | Georgia | Bright from the Start (DECAL) | Rules 591-1-1 | 7,914 | families.decal.ga.gov download |
| 9 | North Carolina | NCDHHS DCDEE | 10A NCAC 09 | 1,152 | childcarecenter.us aggregator (portal requires Telerik automation) |
| 10 | Michigan | MiLEAP / LARA BCHS | R 400.8101–8182 | 7,908 | statewide ArcGIS Feature Service |
| 11 | New Jersey | DCF Office of Licensing | N.J.A.C. 3A:52 | 4,093 | NJDEP/DCF monthly ArcGIS export |
| 12 | Virginia | VDOE Div. of Early Childhood | 8VAC20-780, -821 | 2,856 | dual ArcGIS Feature Services (centers + FDH) |
| 13 | Washington | DCYF | WAC 110-300 | 2,506 | DCYF Socrata (`was8-3ni8`) |
| 14 | Arizona | ADHS Bureau of Child Care Licensing | 9 A.A.C. 5 | 2,536 | ADHS GIS Hub FeatureServer layer 17 |
| 15 | Tennessee | TDHS Child Care Services | Rule 1240-04-01 | 4,178 | UT-SWORPS ArcGIS feed |
| 16 | Massachusetts | EEC | 606 CMR 7 | 1,000 | MA EEC LEAD Socrata (capped) |
| 17 | Indiana | FSSA / OECOSL | 470 IAC 3-4.7 | 752 | FSSA Carefinder PDF roster |
| 18 | Maryland | MSDE Office of Child Care | COMAR 13A.16 | 1,000 | CheckCCMD Open Provider Report PDF |
| 19 | Missouri | DESE Section for Child Care Regulation | 5 CSR 25-500 | 1,000 | childcarecenter.us (DESE ASP.NET returns 500) |
| 20 | Wisconsin | DCF Bureau of Child Care Regulation | DCF 250 / 251 | 1,000 | WI DCF `LCC Directory.xlsx` |
| 21 | Colorado | CDEC | 12 CCR 2509-8-7.702 | 1,000 | data.colorado.gov Socrata (`a9rr-k8mu`) |
| 22 | Minnesota | MN DHS Licensing | MN Rule 9503 | 1,000 | MN Geospatial Commons shapefile (8,571 available) |
| 23 | South Carolina | SC DSS Child Care Licensing | SC DSS CCL regs | 120 | childcarecenter.us (top-5 cities) |
| 24 | Alabama | Alabama DHR Child Care Services | Admin Code 660-5 | 100 | childcarecenter.us |
| 25 | Louisiana | LDE Licensing Division | LAC 28:CLXI (Bulletins 137/140) | 93 | childcarecenter.us |
| 26 | Kentucky | CHFS Division of Child Care | 922 KAR 2:120 | 68 | childcarecenter.us |
| 27 | Oregon | DELC / ELD / CCLD | OAR 414-305 | 98 | childcarecenter.us |
| 28 | Oklahoma | OKDHS Child Care Services | OAC 340:110 | 100 | OKDHS Child Care Locator |
| 29 | Connecticut | CT OEC | CGS 19a-79 / RCSA 19a-79-* | 77 | eLicense (portal) |
| 30 | Utah | DHHS DLBC | R381-100 | 100 | secondary directory (DLBC blocks bots) |
| 31 | Iowa | Iowa HHS Bureau of Child Care | IAC 441-109 | 140 | IA HHS compliance report page |
| 32 | Nevada | DSS Child Care Licensing | NRS/NAC 432A | 47 | secondary (state PDF list broken; reorg moved to DSS 7/1/24) |
| 33 | Arkansas | DHS-DCCECE | Rule 016.22.20-005 | 120 | secondary (Salesforce portal 403s bots) |
| 34 | Mississippi | MSDH Child Care Facilities Licensure | 15 Miss. Admin. Code 15-11-55 | 1,414 | MARIS / HIFLD shapefile (w/ phones) |
| 35 | Kansas | KDHE Child Care Licensing | K.A.R. 28-4-428 | 770 | childcarecenter.us (OIDS captcha-locked) |
| 36 | New Mexico | ECECD Licensing | 8.16.2 NMAC | 770 | childcarecenter.us (ECECD finder no bulk) |
| 37 | Nebraska | NE DHHS Child Care Licensing | Title 391 NAC Ch. 3 | 2,248 | DHHS weekly roster PDF |
| 38 | Idaho | ID HW Child Care Licensing | IDAPA 16.06.02 | 2,045 | idahochildcarecheck.org 208-page scrape |
| 39 | West Virginia | WVDHHR BCF | 78 CSR 1 | 1,255 | WVDHHR "Chart of Open Providers" PDF (with emails) |
| 40 | Hawaii | DHS / PATCH | HRS 346-151 et seq. | 469 | Hawaii Statewide GIS "Preschools" ArcGIS |
| 41 | New Hampshire | NH DHHS Child Care Licensing Unit | He-C 4002 | 114 | childcarecenter.us (portal = Salesforce LWC) |
| 42 | Maine | ME DHHS Office of Child & Family Svcs | 10-148 CMR Ch. 32 | 96 | childcarecenter.us (ASP.NET WebForms) |
| 43 | Montana | MT DPHHS Child Care Licensing | ARM 37.95 | 928 | SansWrite JSON API (full state) |
| 44 | Rhode Island | RI DHS / DCYF | DHS/DCYF CCL regs | 137 | childcarecenter.us (RISES = Salesforce) |
| 45 | Delaware | DE DOE Office of Child Care Licensing | 14 DE Admin Code 101 | 1,250 | data.delaware.gov Socrata (`jxu7-wnw2`), full state |
| 46 | South Dakota | SD DSS Office of Licensing & Accreditation | ARSD 67:42 | 153 | childcarecenter.us (OLA portal) |
| 47 | North Dakota | ND DHHS Early Childhood Licensing | NDCC 50-11.1 / NDAC 75-03 | 131 | childcarecenter.us (NDHHS CCL portal) |
| 48 | Alaska | DOH/DPA Child Care Program Office | 7 AAC 57 | 103 | childcarecenter.us (AKCCIS portal) |
| 49 | Vermont | DCF Child Development Division | CVR 13-171-004 / -005 | 87 | childcarecenter.us (BFIS portal) |
| 50 | Wyoming | WY DFS | W.S. 14-4-101, Ch. 5/6/7 | 102 | childcarecenter.us (WY DFS finder) |

## Data-quality tiers (for the leads CSVs)

- **Gold** (authoritative state bulk dataset, phones & often emails): NY, PA, IL, GA, OH, MI, NJ, VA, WA, AZ, TN, MA, WI, MN, MS, NE, ID, MT, DE.
- **Silver** (official state bulk dataset, limited fields): CO, HI, IN, MD (emails, no phones), WV (emails).
- **Bronze** (state portal blocked or search-only — rows pulled from aggregator or top-N cities): NC, SC, AL, LA, KY, OR, OK, CT, UT, IA, NV, AR, KS, NM, NH, ME, RI, SD, ND, AK, VT, WY.

## Enrichment plan (next steps — not done here)

For **Bronze** states and any rows missing email/website:
1. Run Hunter/Apollo/Clearout against `business_name + phone + state` to recover emails.
2. Playwright-based scraping of portal states that have forms-auth blocking WebFetch (NC, CT, UT, AR).
3. Public-records requests for states without any bulk export (NV, KS, NM, NH, ME).

## Notable per-state flags for ComplianceKit product

- **NJ**: stricter license term (3 yr) + 20 hr/yr training — ratio engine defaults should adapt.
- **VA**: new 8VAC20-821 background-check rule effective **2026-02-01**.
- **AZ**: two regulators (ADHS for centers, DES for small/group homes). Targeting decides which list is correct.
- **LA**: 3-tier license (Type I/II/III); Type III carry Bulletin 140 academic/QRIS overlay.
- **AL**: Child Care Safety Act 2018 closed religious-exempt loophole for state/federally-funded programs.
- **MO**: 2024 reorg moved licensing to DESE; old DHSS routes still linked in stale Google results.
- **NV**: 2024 reorg moved licensing to DSS from DPBH.
- **KS**: 2026 transition to Office of Early Childhood pending.
- **VT**: tightest-in-nation 1:4 infant/toddler ratio + 90% direct-care rule.
- **ID**: 2025 HB 243 deregulation + unique point-based ratio (12 pts/staff max).
- **WY**: certification, not license.

## Methodology notes

- All web pulls on 2026-04-18.
- Phone normalized to `(XXX) XXX-XXXX` where published.
- Unavailable fields are blank (not `N/A`, not invented).
- Every row references a source documented in the corresponding `all-states/{state}/SOURCES.md`.
