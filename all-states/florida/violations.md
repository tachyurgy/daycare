# Florida — Violations &amp; Inspection Data

**Date collected:** 2026-04-18
**State rank (population):** 3

## Violations / Inspection Data Source

Florida publishes inspection reports per facility through the **CARES Public Search** operated by DCF. Every inspection result and any cited violation appears on the operation's CARES profile. Florida does not publish a Socrata / ArcGIS deficiency feed; access is (a) scrape CARES, or (b) file a Sunshine Law / Public Records request.

- **Primary source:** https://caressearch.myflfamilies.com/PublicSearch
- **Alternate entry:** https://cares.myflfamilies.com/PublicSearch
- **Landing:** https://caressearch.myflfamilies.com/

## Data Format

- **Per-facility HTML** — CARES search form → provider profile → inspection history + annual statements + background screening status.
- **PDF** — full inspection reports attached to each visit record.
- **No public Socrata / ArcGIS / JSON API.** CARES is a proprietary DCF web app.
- **State fatality dataset:** DCF publishes 5 years of continuously-updated child fatality data (separate from CARES routine inspection surface).

## Freshness

- **Minimum 2 unannounced inspections per year** per licensed facility (the most aggressive routine schedule of any major state).
- Licensed family and large family day care homes: **2 inspections per year**.
- Inspection reports posted on CARES within days-to-weeks of the visit.
- Fatality dataset maintained on a 5-year rolling window.

## Key Fields (per inspection)

- Provider name, license number, provider type (Licensed Child Care Facility / FDCH / LFCCH / Registered / School-Age / VPK)
- Address, phone, capacity, county
- Inspection date
- Inspection type (routine, complaint, re-inspection, renewal)
- Licensing Counselor
- **CF-FSP 5316 Standards Classification Summary** items scored:
  - 32 inspection categories for facilities
  - Each item marked compliant / non-compliant / not-applicable
- **Violation classification:**
  - **Class 1** — most serious, immediate risk
  - **Class 2** — serious (e.g., ratio violations per F.S. § 402.305(4))
  - **Class 3** — less serious administrative
- Handbook section referenced (Child Care Facility Handbook, Oct 2021)
- Corrective action + due date
- Status (corrected / outstanding / enforcement pending)
- Administrative sanctions (fine, probation, suspension, revocation)

## Scraping / Access Strategy

1. **Enumerate providers from `florida_leads.csv`** (7,648 rows). For each, search CARES by zip or license number to anchor to the authoritative provider record; capture license number if not already known.
2. **Per-provider scrape:** fetch profile → inspection history table → per-visit PDF report.
3. **PDF extraction:** text-extract full narratives; normalize to `(license_number, visit_date, visit_type, class_1_2_3, handbook_section, narrative, corrective_action, status, sanctions)`.
4. **Headless browser advised:** CARES has some dynamic rendering — Playwright robust. Standard HTTP with session cookies may suffice for initial directory crawl.
5. **Scale:** ~11,000-12,000 providers × 2+ inspections/year × multi-year history = large but tractable; plan by county.
6. **County-level variance** — five counties operate local licensing agencies (Hillsborough, Broward, Palm Beach, Pinellas, Sarasota). Their data surfaces through DCF's CARES but may have local-agency reference notes. Confirm coverage during extraction.

## Known Datasets / Public Records

- **CARES Public Search** (primary public surface): https://caressearch.myflfamilies.com/PublicSearch
- **DCF Child Fatality data** — 5-year rolling public dataset (typically published via DCF Office of Child Welfare / OCR portals).
- **Tampa Bay Times investigations:**
  - "Despite warnings, All Children's kept operating. Babies died." (2018, Heartbroken series) — https://projects.tampabay.com/projects/2018/investigations/heartbroken/all-childrens-heart-institute/ (pediatric hospital-specific, but illustrative of the outlet's investigative depth on child care and pediatric institutions)
  - "Transparency lost in reviews of Florida child abuse deaths" — https://www.tampabay.com/news/politics/stateroundup/transparency-lost-in-reviews-of-florida-child-abuse-deaths/2210984/
- **OPPAGA Program Summary** — https://oppaga.fl.gov/ProgramSummary/ProgramDetail?programNumber=5011 — oversight / performance review of Child Care Regulation.
- **Child Care Programs and Inspections Guide (2023)** — https://www.myflfamilies.com/sites/default/files/2023-07/Child-Care-Programs-and-Inspections-Guide.pdf — DCF's public explainer of the inspection process.
- **Early Learning Coalition** network (`elcgateway.org`, other regional coalitions) — subsidy-side data useful for enrichment.
- **FL DOE Early Learning / CCR&amp;R** — https://www.fldoe.org/schools/early-learning/parents/ccr-r.stml — subsidy + VPK data.

## FOIA / Sunshine Law Path

- **Florida's Sunshine Law is one of the strongest state public-records regimes in the country.** Art. I, § 24 Fla. Const. + F.S. Chapter 119.
- Presumption of openness; narrow exemptions (primarily active CPS / abuse investigations).
- **Custodian:** DCF Office of Public Records.
- **Submit via:** https://www.myflfamilies.com/public-records
- **Response window:** no statutory deadline but "reasonable time" — DCF published ~5-10 business days.
- **Useful request:** "Complete database extract of all inspection records, violations cited, and administrative enforcement actions against any DCF-licensed Child Care Facility, Family Day Care Home, Large Family Child Care Home, Registered Family Day Care Home, and School-Age Child Care Program from January 1, 2019 through the date of this request. Fields requested: license number, provider name, provider type, address, county, visit date, visit type, CF-FSP 5316 Standards Classification Summary item scores, Class 1/2/3 classification, Handbook section, narrative, corrective action, due date, completion status, administrative sanctions (fines, probations, suspensions, revocations). Requested in CSV, Excel, or direct database export format. Please include any data dictionary or schema documentation."
- **Supplementary request to local licensing agencies** for Hillsborough, Broward, Palm Beach, Pinellas, and Sarasota counties for any county-level enhancements or reports not surfaced to DCF.

## Sources

- https://caressearch.myflfamilies.com/PublicSearch — CARES Public Search (primary)
- https://cares.myflfamilies.com/PublicSearch — CARES alternate entry
- https://caressearch.myflfamilies.com/ — CARES landing
- https://caressearch.myflfamilies.com/PublicSearch/Search — CARES search form
- https://www.myflfamilies.com/services/licensing/child-care-licensure — DCF Child Care Licensure
- https://www.myflfamilies.com/services/child-family/child-care-resources — DCF Child Care Resources
- https://www.myflfamilies.com/sites/default/files/2023-07/Child-Care-Programs-and-Inspections-Guide.pdf — Child Care Programs &amp; Inspections Guide (2023)
- https://www.myflfamilies.com/public-records — DCF Public Records request portal
- https://www.flrules.org/gateway/ChapterHome.asp?Chapter=65c-22 — 65C-22
- http://www.leg.state.fl.us/Statutes/index.cfm?App_mode=Display_Statute&amp;URL=0400-0499/0402/0402.html — F.S. Chapter 402
- https://oppaga.fl.gov/ProgramSummary/ProgramDetail?programNumber=5011 — OPPAGA CCR summary
- https://www.elcgateway.org/families/134-dcf-myflfamilies-provider-search/ — Early Learning Coalition explainer
- https://www.fldoe.org/schools/early-learning/parents/ccr-r.stml — FL DOE Early Learning
- https://projects.tampabay.com/projects/2018/investigations/heartbroken/all-childrens-heart-institute/ — Tampa Bay Times Heartbroken series (pediatric institution accountability)
- https://www.tampabay.com/news/politics/stateroundup/transparency-lost-in-reviews-of-florida-child-abuse-deaths/ — Tampa Bay Times child-abuse-death transparency coverage
- https://www.childcare.gov/state-resources/florida — Childcare.gov FL resources
- https://licensingregulations.acf.hhs.gov/licensing/contact/florida-department-children-and-families — ACF Licensing DB
- `/Users/magnusfremont/Desktop/daycare/planning-docs/state-docs/florida/florida-compliancekit-product-spec.html` — pre-existing FL product spec
