# Hawaii — Violations & Inspection Data Research

**Compiled:** 2026-04-18
**State slug:** hawaii

## Violations / Inspection Data Source (URLs)

- **Primary (consumer-facing):** Hawaii DHS Child Care Provider Search — https://childcareprovidersearch.dhs.hawaii.gov/
- **DHS Reporting Complaints & Investigations landing:** https://humanservices.hawaii.gov/bessd/child-care-program/child-care-licensing/reporting-child-care-complaints-and-investigations/
- **Statutory basis (records retention & disclosure):** HRS §346-153 / §346-153.5 and HRS Chapter 92F (UIPA, Hawaii's open-records act).
- **Federal oversight backdrop:** HHS-OIG audit of Hawaii's child care background check compliance (A-09-19-02006, 2020) — https://oig.hhs.gov/reports/all/2020/hawaiis-monitoring-generally-ensured-child-care-provider-compliance-with-state-criminal-background-check-requirements/

## Data Format

- **Bulk export:** None published. No ArcGIS/Socrata/JSON/CSV feed for inspection reports or deficiencies.
- **Per-facility, on-portal:** Hawaii's DHS Provider Search is a consumer-facing search UI. Per the Hawaii DHS public record policy (HRS §346-153), DHS must maintain 2 prior years plus current of inspection results, deficiency citations, corrective action, and complaint resolutions — and these are to be "available for the public to review." In practice, most of this data is **not exposed online**; retrieval requires contacting the island-specific licensing unit or filing a UIPA request.
- **Per Civil Beat (2024 reporting):** Hawaii was the only state in the U.S. out of compliance on three CCDBG transparency safety categories; DHS has not posted data on serious injuries or abuse at child care facilities online since 2016. The portal publishes **license status only, not inspection findings**.

## Freshness

- **License status** on the consumer portal: refreshed regularly by DHS licensing units (cadence unpublished; assume weekly-monthly).
- **Inspection/violation records:** retained for **current license year + 2 prior years** under HRS §346-153. Not published online; must be obtained through licensing units or UIPA.

## Key Fields (from DHS portal + UIPA-obtainable records)

From the public Provider Search UI:
- Provider/facility name
- License type (Family Child Care Home / Group Home / Group Center / Infant & Toddler Center)
- Island / area / ZIP
- Ages served
- Accreditation status
- Capacity, hours, weekend care, meals/snacks
- Current license status

Not published online (obtainable via licensing unit request):
- Inspection dates
- Deficiencies cited (rule reference)
- Corrective action plan text
- Complaint investigation findings (substantiated / unsubstantiated)
- Enforcement actions (license suspensions, revocations, conditional licenses)

## Scraping / Access Strategy

1. **Do not scrape** the consumer portal for compliance analytics — it does not expose violation history. Wasted cycles.
2. **For license-status enrichment only:** scrape the provider search (name/address/phone/type) to supplement the 2021-stale ArcGIS dataset in SOURCES.md. Low-volume; respect DHS terms of use.
3. **For inspection & violation history (the high-value asset):** file a **UIPA request** to DHS BESSD for a flat-file export of inspection reports and deficiencies for all licensed providers for a defined window (current + prior 2 years). DHS is required by HRS §346-153 to maintain these records. Response window under UIPA is typically 10 business days (§92F-11(d)).
4. **For per-facility reports before a sales call:** contact the appropriate licensing unit directly:
   - Oahu Unit 1 (Downtown Honolulu): (808) 587-5266
   - Oahu Unit 2 (Waipahu): (808) 675-0470
   - East Hawaii (Hilo): (808) 981-7290
   - West Hawaii, Maui, Kauai each have their own BESSD-reporting units.

## Known Datasets / Public Records

- **DHS Provider Search (license status only):** https://childcareprovidersearch.dhs.hawaii.gov/
- **ArcGIS Preschools dataset (PATCH, 2021-12):** https://opendata.hawaii.gov/dataset/preschools — no inspection fields.
- **HHS-OIG audit reports on Hawaii child care:** https://oig.hhs.gov/reports/all/2020/hawaiis-monitoring-generally-ensured-child-care-provider-compliance-with-state-criminal-background-check-requirements/ — aggregate compliance findings; not per-facility.
- **Civil Beat "Why Weren't Other Parents Told…" (2017):** https://www.civilbeat.org/2017/03/why-werent-other-parents-told-about-day-care-toddler-abuse/ — illustrative coverage of the transparency gap.

## FOIA / Open-Records Path

- **Statute:** Hawaii Uniform Information Practices Act (UIPA) — HRS Chapter 92F.
- **Records officer:** DHS BESSD Records Officer (via general DHS public-records portal).
- **Suggested request scope:** "Under HRS §92F-11, I request electronic copies of (a) all inspection reports, (b) all deficiency citations and corrective action plans, and (c) all complaint investigation outcomes for licensed and registered child care facilities in Hawaii, for the period [DATE] to [DATE], in structured format (CSV/Excel) where available. If CSV is unavailable, PDFs with facility identifiers are acceptable."
- **Response window:** UIPA standard is 10 business days with a 20-day extension available for "extraordinary circumstances."
- **Fees:** Hawaii UIPA allows search/review/segregation fees; waive-on-public-interest grounds is available for journalism/research.
- **Appeals path:** Office of Information Practices (OIP) — https://oip.hawaii.gov/

## Sources

- Hawaii DHS Child Care Licensing — https://humanservices.hawaii.gov/bessd/child-care-program/child-care-licensing/
- Hawaii Child Care Provider Search — https://childcareprovidersearch.dhs.hawaii.gov/
- Reporting Child Care Complaints and Investigations (DHS) — https://humanservices.hawaii.gov/bessd/child-care-program/child-care-licensing/reporting-child-care-complaints-and-investigations/
- HRS §346-153 (records retention & disclosure) — https://www.capitol.hawaii.gov/hrscurrent/Vol07_Ch0346-0398/HRS0346/HRS_0346-0153.htm
- Hawaii Uniform Information Practices Act (UIPA, HRS Chapter 92F) — https://www.capitol.hawaii.gov/hrscurrent/Vol02_Ch0046-0115/HRS0092F/
- Office of Information Practices — https://oip.hawaii.gov/
- HHS-OIG Hawaii background check audit (2020) — https://oig.hhs.gov/reports/all/2020/hawaiis-monitoring-generally-ensured-child-care-provider-compliance-with-state-criminal-background-check-requirements/
- PATCH Hawaii — https://www.patchhawaii.org/
- Honolulu Civil Beat — "Why Weren't Other Parents Told About Day Care Toddler Abuse?" (2017) — https://www.civilbeat.org/2017/03/why-werent-other-parents-told-about-day-care-toddler-abuse/
- National Database (ACF — Hawaii) — https://licensingregulations.acf.hhs.gov/licensing/states-territories/hawaii
