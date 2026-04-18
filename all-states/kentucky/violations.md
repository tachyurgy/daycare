# Kentucky — Violations, Inspections & Citations

> How Kentucky publishes compliance history, non-compliances (citations), abuse/injury data, and enforcement actions for licensed child-care centers and certified homes.

## Violations / Inspection Data Source

Primary public-facing systems:

- **kynect Child Care Provider Search** — https://kynect.ky.gov/benefits/s/child-care-provider
  Salesforce Lightning-based UI; search by address, provider name, or license/certificate number.
- **kynect Child Care Provider Details page** — https://kynect.ky.gov/benefits/s/child-care-provider-details
  Single-provider detail page with inspection history, All STARS rating, non-compliance citations, and plan-of-correction documents.
- **CHFS Division of Child Care — Child Care Inspection and Abuse/Injury Data** — https://www.chfs.ky.gov/agencies/dcbs/dcc/Pages/abuseinjurydataandinspection.aspx
  Landing page that hosts the annual Injury/Abuse PDF report and narrative explanation of inspection workflow.
- **CHFS OIG Division of Regulated Child Care** — https://www.chfs.ky.gov/agencies/os/oig/drcc/Pages/default.aspx
  The licensing authority; publishes the annual KY Child Care Providers Resource Guide.

## Data Format

| Item | Format |
|---|---|
| Provider search | Salesforce Lightning SPA — JS-rendered. Not directly GET-parseable. Requires a headless browser (Playwright/Puppeteer) |
| Provider detail | Salesforce record page; fields rendered client-side via Aura/LWC |
| Inspection reports | PDF, downloadable from the provider detail page |
| Plans of Correction (POC) | PDF |
| Annual Injury/Abuse Report | PDF (single statewide aggregate PDF) |
| Bulk export | **Not published** |

**Language:** Kentucky refers to violations as **"non-compliances"** in the inspection reports posted on kynect.

## Freshness

- Inspection reports posted typically within **2-4 weeks** of the monitoring visit.
- **All STARS rating** updated quarterly; reflects latest regulatory compliance + quality indicators.
- **Injury/Abuse data** updated annually (federal CCDBG requirement; report refreshed on the CHFS page each fall).

## Key Fields (kynect provider detail page)

- Provider name, address, phone
- License type (Type I, Type II, Certified Family Home)
- License / certification number
- License status (regular / preliminary / probationary / suspended / revoked)
- Capacity
- Hours of operation
- **All STARS level** (1-5)
- **Inspection history** — date, type (annual, monitoring, complaint, follow-up), summary, PDF link to full report
- **Non-compliances (citations)** — 922 KAR 2:090 / 2:110 / 2:120 regulation number, description, compliance status, plan of correction
- **Serious Incident Reports** (count / status)

## Scraping / Access Strategy

1. **Seed provider IDs** — the kynect provider search is a Salesforce Lightning app. A headless browser (Playwright recommended) loading the search page with `language=en_US` param and iterating through facets (county, program type) will populate results. Extract each provider's kynect record ID.
2. **Fetch provider detail** — each detail URL takes a record ID (observed in live network requests; exposed in the shareable link after opening a provider). Use `kynect.ky.gov/benefits/s/child-care-provider-details?id={record_id}`.
3. **Parse** — extract inspection table rows; download PDFs for full non-compliance text.
4. **OCR PDFs** — plans of correction are native PDF text (not scanned); use `pypdf` or `pdfplumber` for extraction.
5. **Alternate seed** — ChildCare Aware KY referrals (1-877-316-3552) and https://www.childcareawareky.org/ provide overlapping roster data.
6. **Refresh cadence** — monthly. Non-compliance rates rise sharply during annual-inspection cycles (typically spring and fall per region).

**Warning:** Kentucky's Salesforce portal has aggressive anti-bot fingerprinting. Use residential proxies and moderate the crawl rate.

## Known Datasets / Public Records

- **Annual Injury/Abuse Report** — aggregate statewide counts of serious injuries and deaths in licensed child care (posted on https://www.chfs.ky.gov/agencies/dcbs/dcc/Pages/abuseinjurydataandinspection.aspx).
- **KY Child Care Providers Resource Guide (12/10/2025 edition)** — https://www.chfs.ky.gov/agencies/os/oig/drcc/Documents/KY%20Child%20Care%20Providers%20Resource%20Guide%2012.10.25.pdf — compliance and enforcement workflow.
- **Division of Child Care Consumer Education Statement** — https://www.chfs.ky.gov/agencies/dcbs/dcc/Documents/consumereducationstatement.pdf — what parents can expect to see in public data.
- **ChildCare Aware KY Health & Safety tools** — https://www.childcareawareky.org/health-and-safety-tips-and-tools/ — cites DRCC data.
- **Public Health Law Center — KY Child Care Laws** — https://www.publichealthlawcenter.org/resources/healthy-child-care/ky — regulatory text plus enforcement summaries.

## FOIA / Open-Records Path

Kentucky Open Records Act — KRS 61.870 – 61.884.

- **Submit to:** CHFS Open Records / Office of Legal Services. For child-care specific records: CHFS Office of Inspector General, Division of Regulated Child Care, chfsoigrccportal@ky.gov (preferred) or fax (502) 564-9350. Address: 275 East Main Street, Frankfort, KY 40621. General CHFS open-records: https://chfs.ky.gov/agencies/dcbs/dos/Pages/ora.aspx
- **Turnaround:** KRS 61.872 requires a response within **5 business days**. Production time depends on volume; large extracts typically **30-60 days**.
- **Cost:** 10¢/page for paper; electronic production usually free; may charge programming / extract fees for large exports.
- **Recommended scope:** "For all Type I and Type II licensed child-care centers and certified family child-care homes active at any time between 2023-01-01 and present, produce in machine-readable format (CSV/Excel): provider name, license number, license type, county, address, every inspection date and type, every non-compliance citation (922 KAR citation, description, compliance status, plan-of-correction acceptance date and resolution date), serious incident reports filed, and any enforcement action (probationary license, suspension, revocation, fine) with effective date. Include All STARS rating history if available."

## Sources

- kynect Child Care Provider Search: https://kynect.ky.gov/benefits/s/child-care-provider
- kynect Child Care Provider Details (entry): https://kynect.ky.gov/benefits/s/child-care-provider-details
- kynect Child Care Provider Search FAQ: https://www.chfs.ky.gov/agencies/dms/kynect/kbFAQChildCareSearch.pdf
- CHFS Child Care Inspection and Abuse/Injury Data: https://www.chfs.ky.gov/agencies/dcbs/dcc/Pages/abuseinjurydataandinspection.aspx
- CHFS OIG Division of Regulated Child Care: https://www.chfs.ky.gov/agencies/os/oig/drcc/Pages/default.aspx
- CHFS DCBS Division of Child Care: https://www.chfs.ky.gov/agencies/dcbs/dcc/Pages/find-care.aspx
- Division of Child Care Consumer Education Statement: https://www.chfs.ky.gov/agencies/dcbs/dcc/Documents/consumereducationstatement.pdf
- KY Child Care Providers Resource Guide (Dec 2025): https://www.chfs.ky.gov/agencies/os/oig/drcc/Documents/KY%20Child%20Care%20Providers%20Resource%20Guide%2012.10.25.pdf
- ChildCare Aware KY Health & Safety: https://www.childcareawareky.org/health-and-safety-tips-and-tools/
- CHFS Open Records Request (general): https://chfs.ky.gov/agencies/dcbs/dos/Pages/ora.aspx
- KRS Chapter 61.870 – 61.884 (Open Records): https://apps.legislature.ky.gov/law/statutes/chapter.aspx?chapter=61
- Public Health Law Center — KY Child Care: https://www.publichealthlawcenter.org/resources/healthy-child-care/ky
- ACF Licensing DB — KY contact (DRCC): https://licensingregulations.acf.hhs.gov/licensing/contact/kentucky-cabinet-health-and-family-services-division-child-care
