# Arizona — Violations, Inspection Data & Public Records Research

**Last updated:** 2026-04-18
**Agency:** Arizona Department of Health Services (ADHS), Bureau of Child Care Licensing (BCCL). DES-certified group homes and family homes sit outside ADHS jurisdiction and must be pulled separately.

## Violations / Inspection Data Source

Arizona publishes a comprehensive per-facility inspection and enforcement archive through **AZ Care Check**, ADHS's Salesforce-Lightning portal (public since 2023; replaced prior hsapps.azdhs.gov archive).

1. **AZ Care Check:** https://azcarecheck.azdhs.gov/s/ — ADHS-maintained, daily-refresh searchable database. "Primary Source Verified" branding per ADHS. Every licensed child care facility has:
   - Facility detail page: `/s/facility-details?facilityId=<sf_id>`
   - Inspection details page: `/s/inspection-details?inspectionId=<sf_id>&facilityId=<sf_id>`
   - Enforcement action details: `/s/enforcement-action-details` and `/s/enforcement-details`
   - Printable inspection view: `/s/inspection-print-view?facilityId=<sf_id>`
2. **ADHS Child Care Facilities Licensing (agency page):** https://www.azdhs.gov/licensing/childcare-facilities/index.php — directs to AZ Care Check for inspection history.
3. **DES Child Care Provider Search (certified homes — separate universe):** https://azchildcareprovidersearch.azdes.gov/ — subsidy locator; does not publish deficiency reports.
4. **ADHS Complaint Tracker:** https://app3.azdhs.gov/PROD-AZHSComplaint-UI/Complaint/GetFAQ?bureau=ChildCareLicensing&subbureau=CcChildCareCenters — status of specific complaints for BCCL.

## Data Format

| Source | Format | Bulk? |
|---|---|---|
| AZ Care Check facility pages | Salesforce Lightning Experience (Lightning Web Components) — data via Apex/Aura endpoints; print-view renders to static HTML with PDF-ready layout | No public bulk export; scrape per-facility via Playwright |
| AZ Care Check enforcement pages | Same substrate, dedicated records for each enforcement action | Per-action scrape |
| Legacy HSAPPS CCSurveyProcess docs | HTML/PDF static | Background reference only |
| ADHS CareCheck search query | Supports name / license number / address / status / facility type / program type filters via URL params | Enumerate by license number e.g. `CDC-<nnnn>` |

## Freshness

- AZ Care Check is **updated daily** by ADHS staff per ADHS documentation. When a surveyor uploads a Statement of Deficiencies, it becomes public within 24–48 hours of supervisor approval.
- **Three-year rolling archive** is the statutory minimum public retention per A.R.S. § 36-883 / Office of Child Care Licensing public-file rule; older records via FOIA.
- Plans of Correction are posted alongside their corresponding SODs once ADHS has accepted them (10-day response window from provider).

## Key Fields on Arizona Statements of Deficiencies

- Survey/inspection date
- Surveyor name and region (Phoenix / Tucson / Flagstaff)
- Survey type: **Annual (monitoring) / Complaint / Initial / Follow-up / Revisit**
- **Rule citation**: 9 A.A.C. 5 (e.g., `R9-5-404` ratios, `R9-5-402` staff records, `R9-5-509` safe sleep, `R9-5-507` medication)
- Scope & severity matrix (ADHS borrows the CMS-style scope/severity grid for certain facility types; child care centers use a lighter "Isolated / Pattern / Widespread" × "No harm / Potential harm / Actual harm / Jeopardy" rubric)
- Observation text
- **Plan of Correction**: provider-submitted written document of how deficiency was corrected; 10-day deadline
- Revisit disposition (cleared / repeat / escalated)
- Enforcement-action linkage if escalated

## Scraping / Access Strategy

### AZ Care Check (primary)

- Base: `https://azcarecheck.azdhs.gov/s/`
- Facility URL: `facility-details?facilityId=<18char_sf_id>&activeTab=details&facilityType=All&licenseType=All&programType=Child+Care+Facilities&searchQuery=CDC-<license>&licenseStatus=Active`
- Inspection URL: `inspection-details?inspectionId=<id>&facilityId=<id>`
- Print view URL: `inspection-print-view?facilityId=<id>` — use for clean HTML → text pipeline
- Everything is rendered via Lightning Web Components; static `fetch` requests generally return skeleton HTML. Use **Playwright** (Chromium) with the `domcontentloaded` wait strategy, then extract from the rendered DOM.
- Alternative: intercept network to catch the Aura RPC posts (URLs contain `/aura?r=<n>&other.ContentController.getAllReports=1`), mirror them directly for significantly faster extraction after session bootstrap.
- License-number enumeration: ADHS uses `CDC-<number>` (for day care centers), `CDH-<number>` for certified homes. License numbers are sequential and visible in the leads CSV (`LICENSE_NUMBER` field).
- Rate: ADHS Salesforce tolerates ≤2 req/sec. CSS errors on direct WebFetch are expected — Salesforce Sites anti-crawl heuristics; Playwright bypasses.

### ADHS Complaint Tracker

- The BCCL complaint tracker is presented as a FAQ + per-complaint status ID. Ingest is by complaint number, not facility number — useful only if a specific complaint ID is already known.

### DES (certified homes)

- The DES provider search at `https://azchildcareprovidersearch.azdes.gov/` is subsidy-oriented and does NOT publish deficiency data. For DES-certified home deficiencies, public-records request to DES Child Care Administration is required.

## Known Datasets / Public Records

- **ADHS AZLicensedFacilities ArcGIS service** — roster only (layer 17 is the child care layer; 2,536 facilities). Already captured in `SOURCES.md`.
- **Arizona Republic / azcentral investigative reporting** on child-care incidents has been published but no standing open dataset accompanies it; their reporting is typically a one-off request-driven extraction from AZ Care Check data.
- **data.az.gov** — Arizona's emerging open-data portal does not yet host a child-care-violations dataset.

## FOIA / Open-Records Path

- Statute: **Arizona Public Records Law, A.R.S. § 39-121 et seq.** — "promptly" (no fixed day count; typically 5–15 business days for ADHS depending on scope).
- ADHS public records request: https://www.azdhs.gov/documents/about/public-records-request-form.pdf
- Contact: ADHS Office of Administrative Counsel & Rules; BCCL supervisors at Phoenix 602-364-2539 / Tucson 520-628-6540 / Flagstaff 928-774-2707.
- Reasonable ask: *"All Statements of Deficiency, Plans of Correction, and enforcement orders (revocation, suspension, civil money penalty) for all licensed child care facilities between <start> and <end>, in electronic format."*
- Arizona Ombudsman-Citizens' Aide can assist on appeals: https://www.azoca.gov/

## Sources

- ADHS Child Care Facilities Licensing: https://www.azdhs.gov/licensing/childcare-facilities/index.php
- AZ Care Check portal: https://azcarecheck.azdhs.gov/s/
- AZ Care Check facility detail example: https://azcarecheck.azdhs.gov/s/facility-details?facilityId=0018y000005T5SVAA0
- AZ Care Check inspection detail example: https://azcarecheck.azdhs.gov/s/inspection-details?inspectionId=a1Ics00000KAgthEAD&facilityId=0018y000004X7ULAA0
- AZ Care Check enforcement action: https://azcarecheck.azdhs.gov/s/enforcement-action-details
- AZ Care Check print view: https://azcarecheck.azdhs.gov/s/inspection-print-view?facilityId=0018y000005T5FYAA0
- ADHS Survey Process (HSApps legacy): https://hsapps.azdhs.gov/ls/childcare/sod/Includes/CCSurveyProcess.htm
- ADHS director blog — AZ Care Check announcement: https://directorsblog.health.azdhs.gov/online-portal-improves-licensing-of-arizona-child-care-facilities/
- AZ Public Health Association — AzCareCheck 2.0: https://azpha.org/2025/04/07/azcarecheck-2-0/
- BCCL FAQ: https://www.azdhs.gov/documents/licensing/childcare-facilities/bccl-faqs.pdf
- ADHS Complaint FAQ (Child Care Centers): https://app3.azdhs.gov/PROD-AZHSComplaint-UI/Complaint/GetFAQ?bureau=ChildCareLicensing&subbureau=CcChildCareCenters
- DES Child Care Provider Search: https://azchildcareprovidersearch.azdes.gov/
- DES complaint form: https://des.az.gov/services/child-and-family/child-care/file-complaint-des-child-care-provider
- 9 A.A.C. 5 rule (2024 rewrite): https://www.azdhs.gov/documents/policy-intergovernmental-affairs/administrative-counsel-rules/rules/rulemaking/child-care/9-aac-5-draft-july-2024.pdf
- A.R.S. Title 36, Chapter 7.1: https://www.azleg.gov/arsDetail/?title=36
- Arizona Public Records Law A.R.S. § 39-121: https://www.azleg.gov/ars/39/00121.htm
