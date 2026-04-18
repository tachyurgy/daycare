# Montana — Violations & Inspection Data Research

**Compiled:** 2026-04-18
**State slug:** montana

## Violations / Inspection Data Source (URLs)

- **Primary (consumer-facing):** Montana Licensed Provider Search (SansWrite X Public Portal) — https://webapp.sanswrite.com/MontanaDPHHS/ChildCare
- **DPHHS hosting page:** https://dphhs.mt.gov/ecfsd/childcare/childcarelicensing/providersearch
- **Alternate QAD portal:** https://dphhs.mt.gov/qad/licensure/childcareprovidersearch
- **DPHHS Complaint Form:** https://mt.accessgov.com/dphhs/Forms/Page/dphhs-ecfs/childcarecomplaint/0
- **CCL Complaint Referrals &amp; Investigations procedure (PDF):** https://dphhs.mt.gov/assets/ecfsd/childcarelicensing/ccl009complaintreferralsandinvestigations.pdf
- **Statutory open-records basis:** Montana Constitution Art. II §9 + MCA Title 2, Chapter 6 (Public Records Act).

## Data Format

- **Bulk facility roster:** JSON (reverse-engineered endpoint already used for leads).
  - Endpoint: `POST https://webapp.sanswrite.com/MontanaDPHHS/ChildCare/search-identifiers`
  - Content-Type: `application/json`
  - Body: `{"searchPrams":{"columnQueryPairs":{"number":"","name":"","city":"","state":"","zip":""},"orderBy":"name","ascending":true,"pageNumber":1,"resultsPerPage":10000}}`
  - Returns array of 928 provider records: `uuid`, `number` (license #, e.g. `PV109736`), `name`, `street` (redacted `**********`), `city`, `state`, `zip`.
- **Per-facility inspection history:** SansWrite X exposes a secondary endpoint surfaced when a user clicks a facility — returns an "Inspections (Previous 3 Years)" section with date, inspection type, inspector, and a PDF report link. The portal note: *"Complaints with no deficiencies cited are not posted."*
- **Likely endpoint pattern** (based on SansWrite's shared architecture across DPHHS modules):
  - `POST /MontanaDPHHS/ChildCare/list-completed-inspections` (body: `{"identifierId": "<uuid>", "topN": 50}`)
  - `POST /MontanaDPHHS/ChildCare/get-inspection-details` (body: `{"inspectionId": "<id>"}`) → JSON with deficiencies list
  - `GET /MontanaDPHHS/ChildCare/download-inspection-pdf?inspectionId=<id>` → PDF
  - Confirmation requires browser devtools inspection; endpoints are not documented. Existing Wave 7 work established the search endpoint with zero session auth required.

## Freshness

- DPHHS states license data is "updated at least once per month." In practice, the JSON endpoint reflects same-day changes.
- Inspection reports appear on the portal within days of completion.
- Only last 3 years are shown in the public portal (older records obtainable via MCA public records request).

## Key Fields

From the list endpoint (confirmed):
- `uuid` — internal facility ID (join key)
- `number` — license number (prefix indicates type: `PV` = provisional / specific license class)
- `name` — business name
- `street` — **redacted** in public API response (`**********`)
- `city`, `state`, `zip`
- Phone — **redacted** in public API response

From the per-facility modal (inferred from SansWrite X schema):
- Inspection date + type + inspector
- Deficiencies list — rule number, short description, corrective action, correction status
- Complaint type + investigation conclusion (for complaints where deficiencies were cited)
- License status / effective dates
- Capacity, ages served

## Scraping / Access Strategy

1. **Bulk facility list — ALREADY DONE** (see Wave 7 / SOURCES.md). Single POST returns 928 providers.
2. **Per-facility inspection pull** — for each `uuid`:
   - Inspect browser devtools during a portal session to confirm the `list-completed-inspections` endpoint signature.
   - Issue parallel POSTs (recommend 5 concurrent, 200ms spacing) across all 928 facilities → assemble a full inspection history table in ~5 minutes.
   - Download per-inspection PDFs for accounts that warrant deep-dive; OCR optional.
3. **License-number prefix parsing** — license prefixes segment facility types. Parse `number` column: `PV*` vs `CC*` vs `FC*` to split center / family / group.
4. **Full address recovery** — because SansWrite redacts street in public API, submit a Montana Public Records request to DPHHS under MCA §2-6-1003 for address data. Typical response 5–10 business days.
5. **Phone recovery** — also redacted in API. Google / LinkedIn enrichment pipeline: `"<name>" "<city>" Montana daycare`.

## Known Datasets / Public Records

- **SansWrite X Public Portal (facility search + inspection history):** https://webapp.sanswrite.com/MontanaDPHHS/ChildCare
- **DPHHS CCL Complaint Referrals &amp; Investigations policy PDF:** https://dphhs.mt.gov/assets/ecfsd/childcarelicensing/ccl009complaintreferralsandinvestigations.pdf
- **Child Care Center Licensing Requirements PDF:** https://dphhs.mt.gov/assets/ecfsd/childcarelicensing/LicensingRequirementsforChildCareCenters.pdf
- **Family/Group Registration Requirements PDF:** https://dphhs.mt.gov/assets/ecfsd/childcarelicensing/RegistrationRequirementsforFamilyGroup.pdf
- **HB 422 (2023) — ratio revision:** https://archive.legmt.gov/bills/2023/billhtml/HB0422.htm

## FOIA / Open-Records Path

- **Statute:** MCA Title 2, Chapter 6, Part 10 — Montana Public Records Act. Constitutional grounding: Montana Constitution Art. II §9 ("no person shall be deprived of the right to examine documents").
- **Submit to:** DPHHS Public Information Officer (via https://dphhs.mt.gov/publicinfo). Cc CCL directly.
- **Suggested request scope:** "Under MCA §2-6-1003, I request electronic copies of: (1) the full current roster of licensed and registered child day care providers including name, license number, license type, street address, phone, capacity, ages served, hours; (2) all inspection reports and deficiencies cited under ARM 37.95 for the period [DATE] to [DATE]; (3) all complaint investigations (substantiated and unsubstantiated); (4) all enforcement actions (suspensions, revocations, conditional licenses). CSV/Excel preferred; PDFs acceptable."
- **Response window:** "Within a reasonable time" per MCA §2-6-1006; typically 5–10 business days.
- **Fees:** MCA §2-6-1006 permits reasonable fees for staff time over a threshold; many requests fulfilled without charge.
- **Appeals:** District court under MCA §2-6-1009.

## Sources

- Montana DPHHS Child Care Licensing: https://dphhs.mt.gov/ecfsd/childcare/childcarelicensing/
- Montana Licensed Provider Search (DPHHS host): https://dphhs.mt.gov/ecfsd/childcare/childcarelicensing/providersearch
- Montana Child Care Provider Search (QAD alt): https://dphhs.mt.gov/qad/licensure/childcareprovidersearch
- SansWrite X Public Portal: https://webapp.sanswrite.com/MontanaDPHHS/ChildCare
- DPHHS Child Care Complaint Form: https://mt.accessgov.com/dphhs/Forms/Page/dphhs-ecfs/childcarecomplaint/0
- CCL Complaint Referrals &amp; Investigations PDF: https://dphhs.mt.gov/assets/ecfsd/childcarelicensing/ccl009complaintreferralsandinvestigations.pdf
- ARM Title 37, Chapter 95 (index): http://www.mtrules.org/gateway/ChapterHome.asp?Chapter=37.95
- ARM 37.95.108 (Licensing Procedures): https://rules.mt.gov/gateway/ruleno.asp?RN=37.95.108
- ARM 37.95.141 (Records): https://rules.mt.gov/gateway/ruleno.asp?RN=37.95.141
- ARM 37.95.623 (Ratios — post-HB 422): https://rules.mt.gov/gateway/ruleno.asp?RN=37.95.623
- HB 422 (2023): https://archive.legmt.gov/bills/2023/billhtml/HB0422.htm
- Missoulian coverage: https://missoulian.com/news/state-and-regional/montana-dphhs-advises-parents-to-check-complaints-against-child-care-facilities/article_0d266cce-ef37-11e1-8d73-001a4bcf887a.html
- National Database (ACF — MT): https://licensingregulations.acf.hhs.gov/licensing/states-territories/montana
