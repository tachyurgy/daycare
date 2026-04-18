# Tennessee — Violations, Inspection Data & Public Records Research

**Last updated:** 2026-04-18
**Agency:** Tennessee Department of Human Services (TDHS), Child Care Licensing (T.C.A. § 71-3-501 et seq.; rules at 1240-04-01, Nov 20 2025 revision). Public-school-run child care is licensed separately by Tennessee Department of Education (TDOE).

## Violations / Inspection Data Source

Tennessee publishes per-facility compliance history online — an initiative that began in July 2014 following legislative pressure and has since been expanded to include star-quality report cards and monitoring inspections.

1. **TDHS Find Child Care / Child Care Locator Map (public):** https://www.tn.gov/humanservices/for-families/child-care-services/find-child-care.html → redirects to the ServiceNow-backed locator at https://onedhs.tn.gov/csp?id=tn_cc_prv_maps — search by name / county / address; each result links to a **Compliance History** column ("Click Here" button).
2. **SWORPS-backed TN Child Care Helpdesk (data operator):** https://tnchildcarehelpdesk.sworpswebapp.sworps.utk.edu/child-care-desert-map/ — the same dataset via the SWORPS ArcGIS FeatureServer (already captured in our roster pull).
3. **Star-Quality Evaluation Report Cards (SWORPS/UTK):** https://starquality.sworpswebapp.sworps.utk.edu/evaluation-report-cards/ — per-agency annual evaluation; tied to subsidy reimbursement.
4. **Digital Tennessee child-care aggregate reports (Secretary of State library):** https://digitaltennessee.tnsos.gov/child_care_data/ — **annual** statistical rollups (serious injuries, substantiated child abuse, fatalities) by agency type, by fiscal year. Not per-facility but authoritative and citable.
5. **Child Care Complaint Hotline:** 1-800-462-8261 / 615-313-4820.

## Data Format

| Source | Format | Bulk? |
|---|---|---|
| Find Child Care / ServiceNow CSP portal | ServiceNow Customer Service Portal (UI widget); backing data via REST `?id=tn_cc_prv_maps` action | No bulk export exposed in the UI; SWORPS ArcGIS backend is the authoritative feed |
| SWORPS ArcGIS FeatureServer | Esri JSON, paginated | **Yes** — `dbaa58403dc042f8949a943c22b0f4f3` FeatureServer already used for roster |
| Compliance-history "Click Here" | Opens a facility-specific **HTML page** listing monitoring visits, violations cited, correction status | Per-facility scrape |
| Star-Quality Report Card | **PDF** per agency per evaluation year | Per-facility PDF fetch |
| Digital Tennessee aggregate | HTML pages + CSV exports for FFY rollups | Yes (small, aggregate only) |

## Freshness

- TDHS licensing consultants conduct **four visits per year** (3 unannounced, 1 annual evaluation) per 1240-04-01-.06 — so every active facility gets fresh compliance data quarterly.
- Compliance-history pages post within ~2 weeks of a visit.
- Star-Quality Report Cards refresh **annually** after the annual evaluation closes.
- Digital Tennessee aggregate refreshes **annually** (FFY boundary, Sep 30).

## Key Fields in Tennessee Compliance History

- Visit date
- Visit type: **Monitoring (unannounced) / Annual Evaluation / Complaint Investigation / Technical Assistance / Follow-up**
- Observation instrument score (for star evaluations)
- **Rule citation**: 1240-04-01-.XX (e.g., `.22` center requirements, `.10` personnel file, `.05` director qualifications, `.13` supervision)
- **Risk classification**: TDHS uses a Low / Medium / **High Risk** rubric; high-risk violations require a 5-day follow-up revisit per 1240-04-01-.06
- Plan of Corrective Action + provider signature
- Corrected-by date
- Star rating (for annual evaluation)
- Report Card score (if Star-Quality participant)

## Scraping / Access Strategy

### Find Child Care / ServiceNow CSP (primary)

- Base: `https://onedhs.tn.gov/csp?id=tn_cc_prv_maps`
- Implementation: ServiceNow Customer Service Portal widget. Under the hood it calls `/api/now/...` for map markers. Not a classic REST API, but a scriptable interface via Playwright is straightforward.
- Each marker carries a facility reference (TDHS agency code). Click-through opens an agency drawer that includes:
  - Basic info (name, address, capacity)
  - **"Compliance History" button** — opens a secondary TDHS-hosted page listing recent monitoring visits, each with rule citations
  - "Report Card" button — links to the SWORPS-hosted PDF
- For bulk extraction, prefer the SWORPS ArcGIS endpoint (already in inventory) for roster + identifiers, then Playwright against Find Child Care for per-facility compliance detail.

### SWORPS FeatureServer (bulk-friendly for roster)

- `https://services6.arcgis.com/SmO2MQiJaDmO20rD/arcgis/rest/services/Licensed_Tennessee_Child_Care_Providers_List_2024/FeatureServer/0/query?where=1%3D1&outFields=*&f=json` — 4,178 rows; contains Star_Rating and Regulatory_Status but not granular violations.

### Star-Quality Report Cards

- Cards are PDFs indexed from the SWORPS Star-Quality site; URL pattern is agency-ID-based within the SWORPS webapp. Access via a two-step Playwright flow: browse index → click agency → download PDF.

### Digital Tennessee aggregate

- Simple HTML scrape against `https://digitaltennessee.tnsos.gov/child_care_data/<n>/` for each FFY report (8 = FFY 2022, 9 = FFY 2023, 10 = FFY 2024 observed).

## Known Datasets / Public Records

- **SWORPS Licensed TN Child Care Providers List 2024** — roster with Star_Rating, already in leads CSV.
- **Digital Tennessee FFY rollups** — FFY 2022, 2023, 2024 published; capacity, serious injuries, substantiated abuse, child fatalities by child care type.
- **TN Lookout / local journalism** has reported on TDHS enforcement gaps (WSMV 2024, WBIR coverage); no standalone dataset release found.
- **TN Open Data Portal** (data.tn.gov) — does not host a child-care-violations dataset as of April 2026.

## FOIA / Open-Records Path

- Statute: **Tennessee Public Records Act, T.C.A. § 10-7-503 et seq.** — "promptly" and within 7 business days for a written acknowledgment of the request.
- TDHS Office of General Counsel / FOIA liaison: https://www.tn.gov/humanservices/for-families/report-child-abuse-or-neglect.html (hub page; formal requests via the TDHS records custodian).
- Email: dhs.customerservice@tn.gov (TDHS front door) — for formal requests, confirm records custodian routing.
- Reasonable ask: *"All Child Care Licensing monitoring visit reports, annual evaluation reports, complaint investigation reports, and enforcement orders (probation, civil penalty, suspension, denial, revocation per T.C.A. § 71-3-509) for all licensed child care agencies between <start> and <end>, in electronic format."*
- Office of Open Records Counsel (oversight / dispute resolution): https://comptroller.tn.gov/office-functions/open-records-counsel.html

## Sources

- TDHS Child Care Services: https://www.tn.gov/humanservices/for-families/child-care-services.html
- Find Child Care portal hub: https://www.tn.gov/humanservices/for-families/child-care-services/find-child-care.html
- Locator map (ServiceNow): https://onedhs.tn.gov/csp?id=tn_cc_prv_maps
- SWORPS child care desert map / helpdesk: https://tnchildcarehelpdesk.sworpswebapp.sworps.utk.edu/child-care-desert-map/
- Star-Quality Evaluation Report Cards: https://starquality.sworpswebapp.sworps.utk.edu/evaluation-report-cards/
- Star-Quality Program home: https://starquality.sworpswebapp.sworps.utk.edu/star-quality-program/
- Child Care Violations / Complaints (TDHS): https://www.tn.gov/humanservices/for-families/child-care-services/child-care-report-child-care-violations-complaints.html
- Provider Monitoring and Inspections (TDHS): https://www.tn.gov/humanservices/for-families/child-care-services/child-care-resources-for-providers/child-care-provider-monitoring-and-inspections.html
- Digital Tennessee index: https://digitaltennessee.tnsos.gov/child_care_data/
- Digital Tennessee FFY 2024: https://digitaltennessee.tnsos.gov/child_care_data/10/
- Digital Tennessee FFY 2023: https://digitaltennessee.tnsos.gov/child_care_data/8/
- Digital Tennessee FFY 2022: https://digitaltennessee.tnsos.gov/child_care_data/9/
- 1240-04-01 rules (Nov 20 2025): https://publications.tnsosfiles.com/rules/1240/1240-04/1240-04-01.20251120.pdf
- T.C.A. § 71-3-509 (enforcement): https://law.justia.com/codes/tennessee/title-71/chapter-3/part-5/section-71-3-509/
- Tennessee Public Records Act: https://www.tn.gov/comptroller/office-functions/open-records-counsel/information-for-citizens/the-public-records-act.html
- Office of Open Records Counsel: https://comptroller.tn.gov/office-functions/open-records-counsel.html
- Tennessee Lookout coverage: https://tennesseelookout.com/2024/07/02/deaths-of-tennessee-children-from-suspected-abuse-or-neglect-rose-nearly-30-in-2023/
