# Montana — Data Sources & Lead Provenance

**Compiled:** 2026-04-18
**State slug:** montana
**Leads CSV:** `/Users/magnusfremont/Desktop/daycare/montana_leads.csv`

## Primary Data Source (used for leads)

**Montana DPHHS Licensed Provider Search (via SansWrite X Public Portal) — reverse-engineered JSON endpoint.**

- Public UI (iframe): https://webapp.sanswrite.com/MontanaDPHHS/ChildCare
- DPHHS hosting page: https://dphhs.mt.gov/ecfsd/childcare/childcarelicensing/providersearch
- API endpoint used: `POST https://webapp.sanswrite.com/MontanaDPHHS/ChildCare/search-identifiers` with JSON body `{"searchPrams":{"columnQueryPairs":{"number":"","name":"","city":"","state":"","zip":""},"orderBy":"name","ascending":true,"pageNumber":1,"resultsPerPage":10000}}`
- Content-Type: `application/json`
- Format returned: JSON with `data: [...]` array of provider records
- **Total rows returned: 928**
- Rows in leads CSV: **928**
- Fields captured: business_name (name), city, state, phone (empty — SansWrite redacts phone in public portal), website (empty)
- Fields returned but unused: uuid (facility UUID), number (license number e.g., `PV109736`), street (redacted to asterisks), state, zip

## Why this source is high quality

- **Authoritative.** The data comes directly from DPHHS's licensing system of record (SansWrite is the vendor DPHHS uses for inspections and licensing).
- **Full state coverage.** Every currently licensed or registered child care provider in Montana appears.
- **Fresh.** The portal states license data is "updated at least once a month."
- **Captured in one API call.** No pagination loop required.

## Regulatory / Compliance Sources

- **Montana DPHHS Child Care Licensing:** https://dphhs.mt.gov/ecfsd/childcare/childcarelicensing/
- **ARM Chapter 37.95 index:** http://www.mtrules.org/gateway/ChapterHome.asp?Chapter=37.95
- **ARM 37.95.108 (Registration & Licensing Procedures):** https://rules.mt.gov/gateway/ruleno.asp?RN=37.95.108
- **ARM 37.95.141 (Records):** https://rules.mt.gov/gateway/ruleno.asp?RN=37.95.141
- **ARM 37.95.623 (Child-to-Staff Ratios):** https://rules.mt.gov/gateway/ruleno.asp?RN=37.95.623
- **Child Care Center Licensing Requirements PDF:** https://dphhs.mt.gov/assets/ecfsd/childcarelicensing/LicensingRequirementsforChildCareCenters.pdf
- **Family/Group Registration Requirements PDF:** https://dphhs.mt.gov/assets/ecfsd/childcarelicensing/RegistrationRequirementsforFamilyGroup.pdf
- **HB 422 (2023):** https://archive.legmt.gov/bills/2023/billhtml/HB0422.htm
- **Public Health Law Center — MT:** https://www.publichealthlawcenter.org/resources/healthy-child-care/mt
- **National Database (ACF — MT):** https://licensingregulations.acf.hhs.gov/licensing/states-territories/montana

## Sources Considered but Not Used

- **childcarecenter.us:** Redirect issues on bulk pages; unused.
- **DPHHS Child Care Providers Dashboard:** Tableau-style aggregated dashboard, not provider-level.
- **Montana KIDS COUNT:** Aggregated counts only.

## Known Limitations

- **No phone numbers.** SansWrite's public portal redacts street address and phone (replaces with `**********`). Names and cities are publicly visible.
- **No email / website.** These must be enriched via Google / LinkedIn / provider's own site.
- **No facility type breakdown in the CSV.** The API returns a license number (prefix varies by type — e.g., `PV` for one type, others for centers/homes) but we did not parse. For segmentation, pull the license-number prefix in the next refresh.
- **No capacity or status fields in the CSV.** The API returns those in the per-facility modal (`identifierModal.addInfo`) via a separate call (`list-completed-inspections`) — not included here to stay within scope.

## Refresh Strategy

1. **Monthly re-pull of the JSON endpoint** — zero cost, high reliability. The dataset is small (~928 rows) so a full refresh is trivial.
2. **Enrichment pipeline:** For each facility, run a lightweight Google search (`"<name>" "<city>" Montana`) to recover phone, website, and (sometimes) email. Dedupe aggressively — some facilities have multiple licenses (summer vs. year-round) that show as separate rows.
3. **License-number prefix parsing** for ICP segmentation (centers vs. family homes vs. group homes).
4. **For street addresses** (needed for geo-segmentation and mailing): submit a public records request to DPHHS under MCA §2-6-1003; response typically 5–10 business days.
