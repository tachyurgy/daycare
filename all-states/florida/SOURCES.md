# Florida — Source URLs &amp; Data Provenance

**Date collected:** 2026-04-18

## Pre-existing product spec (reference)
- `/Users/magnusfremont/Desktop/daycare/planning-docs/state-docs/florida/florida-compliancekit-product-spec.html` — 2,233-line authoritative HTML product spec for FL. Facts cross-referenced for this compliance.md, including 65C-22 rule, Handbook incorporation by reference, inspection category structure, and form catalog.
- Supporting PDFs at the same path:
  - `child-care-facility-handbook.pdf` — the Handbook (Oct 2021) incorporated by reference into 65C-22
  - `school-age-child-care-handbook.pdf` — School-Age companion
  - `child-care-programs-inspections-guide.pdf` — DCF inspector-process explainer
  - `desk-reference-guide-cfop-170-20.pdf` — DCF desk reference (CFOP 170-20)
  - `health-safety-checklist-cf-fsp-5274.pdf` — CF-FSP 5274 Health &amp; Safety Checklist
  - `standards-classification-summary-cf-fsp-5316.pdf` — CF-FSP 5316 inspection form

## Regulatory sources
- https://www.myflfamilies.com/services/licensing/child-care-licensure — DCF Child Care Licensure
- https://www.myflfamilies.com/services/child-family/child-care-resources — Child Care Resources
- https://caressearch.myflfamilies.com/PublicSearch — CARES Public Search (primary public surface)
- https://caressearch.myflfamilies.com/ — CARES landing
- https://caressearch.myflfamilies.com/PublicSearch/Search — CARES search form
- https://cares.myflfamilies.com/PublicSearch — alternate CARES entry
- https://www.myflfamilies.com/sites/default/files/2023-07/Child-Care-Programs-and-Inspections-Guide.pdf — Child Care Programs &amp; Inspections Guide (Mar 2023)
- https://www.myflfamilies.com/public-records — DCF Public Records request
- https://www.flrules.org/gateway/ChapterHome.asp?Chapter=65c-22 — 65C-22 rule
- http://www.leg.state.fl.us/Statutes/index.cfm?App_mode=Display_Statute&amp;URL=0400-0499/0402/0402.html — Florida Statutes Ch. 402
- https://oppaga.fl.gov/ProgramSummary/ProgramDetail?programNumber=5011 — OPPAGA CCR program summary
- https://licensingregulations.acf.hhs.gov/licensing/contact/florida-department-children-and-families — ACF entry
- https://www.childcare.gov/state-resources/florida — federal Childcare.gov FL hub
- https://www.fldoe.org/schools/early-learning/parents/ccr-r.stml — FL DOE Early Learning / CCR&amp;R
- https://www.elcgateway.org/families/134-dcf-myflfamilies-provider-search/ — Early Learning Coalition explainer

## Provider list / leads CSV

### Primary (used): `florida_leads.csv`
- File: `/Users/magnusfremont/Desktop/daycare/florida_leads.csv`
- Rows: **7,648** (including header)
- Data rows: ~7,647 providers
- **Coverage:** strong coverage of Florida metros. FL has ~11,000-12,000+ licensed providers overall; this CSV represents ~64-70% of the market and is well distributed across major MSAs (Miami/Fort Lauderdale, Orlando, Tampa/St. Pete, Jacksonville).
- Fields: name, city, zip, phone (standard leads schema)
- Email / website fields: largely blank

### Authoritative enrichment
- **CARES Public Search** at caressearch.myflfamilies.com is the per-provider public surface. Inspection reports available; bulk structured export requires scraping or public-records request.
- Florida does **not** publish a Socrata / ArcGIS machine-readable deficiency feed like Texas does; the CARES search is the authoritative interface.
- **County-level variance:** 5 counties operate local licensing agencies (Hillsborough, Broward, Palm Beach, Pinellas, Sarasota) — their data pipes through DCF but may carry local enhancements.

## Florida Sunshine Law / Public Records Path
- **Statute:** Florida Public Records Law — **F.S. Chapter 119** + Article I, § 24 of the Florida Constitution ("Sunshine Law"). One of the strongest state public-records regimes in the US.
- **Custodian:** DCF Office of Public Records.
- **Response window:** no statutory deadline, but courts require a "reasonable time" — DCF published processing time of 5-10 business days for standard requests.
- Detailed request phrasing in violations.md.

## Leads CSV output
- File: `/Users/magnusfremont/Desktop/daycare/florida_leads.csv`
- Rows: 7,648 (including header)
- Note: Florida's Sunshine Law gives a strong statutory lever for bulk extract if scraping is too slow. The CARES per-provider data surface is rich but requires per-page fetches.
