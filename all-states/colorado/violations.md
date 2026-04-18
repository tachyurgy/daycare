# Colorado — Violations & Inspection Data

**Date collected:** 2026-04-18

## Violations / Inspection Data Source (URLs)

- **Primary (consumer-facing):** https://www.coloradoshines.com/search — **Colorado Shines** quality-rating search. Each program detail page includes "annual inspection report and licensing history" back to prior years, including noted rule violations and correction status.
- **Per-provider detail URL pattern:** `https://www.coloradoshines.com/program_details?id=<salesforceId>` — Colorado Shines runs on a Salesforce Experience Cloud (`*.my.salesforce-sites.com`) platform
- **File Review / CORA quick link:** https://decl.my.salesforce-sites.com/apex/OEC_File_Review_Request (Salesforce Apex page for requesting full inspection file)
- **Licensing Actions / Public Notice Information:** https://cdec.colorado.gov/resources/public-notice-information — closed, revoked, or enforcement-action facilities (403 to our fetch but listed in CDEC navigation)
- **Safe Child Care Tools (CDEC):** https://cdec.colorado.gov/for-providers/safe-child-care-tools
- **CDEC Child Care Licensing:** https://cdec.colorado.gov/for-providers/child-care-licensing-and-administration
- **Reports and Data (CDEC):** https://cdec.colorado.gov/resources/reports-data-and-cora (canonical reports/CORA landing)
- **Raising Colorado Kids — "Check the Safety of a Program":** https://raisingcoloradokids.com/en/finding-child-care/how-do-i-find-child-care/check-the-safety-of-a-program/

## Data Format

| Channel | Format | Bulk? |
|---|---|---|
| coloradoshines.com/search | Salesforce Lightning HTML; detail page AJAX-loads inspection & violation sub-panels | No |
| Inspection report | PDF attachment per visit (OEC report template) | Per-inspection |
| Facilities dataset (Socrata) | CSV/JSON at `data.colorado.gov/resource/a9rr-k8mu.csv` | Yes — facilities only; no violations |
| CDPHE ArcGIS layer | REST JSON / feature service | Yes — facility locations only |
| Public Notice / enforcement actions | HTML list on cdec.colorado.gov | Yes — facility closures |
| Aggregate CDEC reports | PDF / Tableau | Aggregate only |

**No bulk CSV of per-facility violations is published.** The facilities Socrata dataset (`a9rr-k8mu`) is excellent for provider-universe enumeration but does NOT include inspection findings. `data.colorado.gov` catalog search confirms no `child care violations` or `child care inspections` dataset.

## Freshness

- Colorado Shines detail pages: inspection posted after licensing specialist signs report — typically within 30 days of visit
- Facilities dataset on Socrata: refreshed twice monthly per CDEC documentation
- CDEC Public Notice of enforcement actions: posted within 10 business days of final action
- Licensing cycle shifted to **continuous licensure** in Colorado — providers don't face periodic renewal; compliance is monitored via annual unannounced inspections

## Key Fields Exposed Per Provider

- Provider ID (CDEC), name, service type (Center, FCCH, Large FCCH, School-Age, Infant Nursery, Preschool, NYO, Resident Camp)
- Address, phone (if published), county
- Early Childhood Council (ECC), Child Care Resource & Referral (CCR&R)
- Capacity (total + by age band: infant/toddler/preschool/school-age)
- Colorado Shines quality rating (Levels 1–5)
- CCCAP (subsidy) agreement status
- License award date / expiration / status
- **Inspection history** — date, type (Routine / Complaint / Follow-up / Monitoring), inspector
- **Rule violations** — cited 12 CCR 2509-8 section (7.702 centers, 7.707/7.708 FCCH, 7.712 school-age, 7.701 general)
- **Complaint outcomes** — substantiated / unsubstantiated with narrative
- **Enforcement actions** — notices, probationary status, revocation
- Lat/long

## Scraping / Access Strategy

1. **Facility universe:** Already harvested via Socrata (`GET /resource/a9rr-k8mu.csv?$limit=5000` — ~4,544 providers).
2. **Violation enrichment path:** Each facility row includes `provider_id`. Map to Colorado Shines Salesforce ID by searching the `/search` API:
   - `POST https://www.coloradoshines.com/search` (Aura endpoint) with action `SearchController.findPrograms` — returns programs with Salesforce `Id` values
   - Alternative: use the `program_details?id=<sfId>` pattern if IDs are known
3. **Detail fetch:** Salesforce Experience Cloud uses the `aura?r=<n>&aura.token=undefined` POST convention. Construct the request with actions `ProgramDetailController.getProgramInspections` and `getProgramViolations`. A headless browser session is significantly simpler than forging Aura requests.
4. **PDF inspection reports:** Linked from detail pages under a `servlet.FileDownload?file=<contentId>` URL pattern on `*.file.force.com` — direct GETs work for public documents.
5. **Rate:** Salesforce rate-limits aggressive Aura traffic; ~1 req/sec is safe. Expect occasional 429 during peaks.
6. **Public Notice / Enforcement Actions:** Scrape `cdec.colorado.gov/resources/public-notice-information` as HTML. 403 to automated fetches suggests User-Agent filtering; set a browser UA string.
7. **CDEC "File Review Request":** For the full inspection file of a given provider (beyond what the Shines portal displays), file a public-file review request via the Salesforce form — this is faster than a CORA request for individual-facility deep history.

## Known Datasets / Public Records & Journalism

- **Chalkbeat Colorado** on quality rating: https://www.chalkbeat.org/colorado/2023/10/16/23919301/colorado-shines-preschool-child-care-quality-rating-system/
- **Colorado Shines Program Guide (2015, foundational doc):** https://www.coloradoshines.com/resource/1440607605000/asset_pdfs1/asset_pdfs1/ColoradoShinesProgramGuide.pdf
- **2022 agency transition:** licensing moved from CDHS to the newly-created CDEC; older enforcement records still cite CDHS in metadata but are accessible through CDEC.
- **Opendatanetwork.com federated view** of CO dataset: https://www.opendatanetwork.com/dataset/data.colorado.gov/a9rr-k8mu

## FOIA / Public Records Path

- **Colorado Open Records Act (CORA, C.R.S. § 24-72-201 et seq.)**
- **CDEC CORA landing:** https://cdec.colorado.gov/colorado-open-records-act-cora
- **Fees:** First hour free; $41.37/hour thereafter (including attorney privilege review)
- **Response:** 3 working days; extension up to 7 additional working days (10 total)
- **Before formal request:** CDEC legal team encourages an email discussion first — often faster than a formal CORA for routine violation extracts
- **Expected records:** Statewide violation extract with CCR citations and facility crosswalk; inspection narratives; substantiated complaint summaries; enforcement-action letters. CDEC's Public File Review Request page offers per-facility full files at no hourly charge.

## Sources

- https://www.coloradoshines.com/
- https://www.coloradoshines.com/search
- https://www.coloradoshines.com/program_details?id=001o000000JBEVoAAP
- https://www.coloradoshines.com/families?p=Review-Child-Care-Options
- https://cdec.colorado.gov/for-providers/child-care-licensing-and-administration
- https://cdec.colorado.gov/for-providers/safe-child-care-tools
- https://cdec.colorado.gov/resources/public-notice-information
- https://cdec.colorado.gov/resources/reports-data-and-cora
- https://cdec.colorado.gov/colorado-open-records-act-cora
- https://data.colorado.gov/Early-childhood/Colorado-Licensed-Child-Care-Facilities-Report/a9rr-k8mu
- https://data-cdphe.opendata.arcgis.com/datasets/ba8161673d734074a081006adc7ea496
- https://decl.my.salesforce-sites.com/apex/OEC_File_Review_Request
- https://raisingcoloradokids.com/en/finding-child-care/how-do-i-find-child-care/check-the-safety-of-a-program/
- https://www.chalkbeat.org/colorado/2023/10/16/23919301/colorado-shines-preschool-child-care-quality-rating-system/
- https://licensingregulations.acf.hhs.gov/licensing/contact/colorado-department-early-childhood
