# Alabama — Violations, Inspections & Substantiated Reports

> How Alabama publishes compliance history, deficiency reports, and enforcement actions against licensed day-care centers and homes.

## Violations / Inspection Data Source

Alabama's transparency footprint for day-care violations is **materially weaker than peer states**. Primary public-facing systems:

- **DHR Day Care Directory (centers)** — https://apps.dhr.alabama.gov/daycare/daycare_search
  County/zip/name-search directory. Returns facility name, address, phone, license number, status — **no inspection history, no deficiency data** in the directory itself.
- **DHR Licensed Day Care Homes directory** — https://apps.dhr.alabama.gov/Child_Care_Services/Lic_Day_Care_Homes — same limited surface.
- **License-Exempt Day Care Facilities list** — https://dhr.alabama.gov/child-care/license-exempt-day-care-facilities/ — static PDF/HTML list.
- **Deficiency reports must be posted at the facility** — per Minimum Standards rule; individual parents can view in person, but the state does not publish them online.
- **Alabama Quality STARS** participating-provider list — https://qualitystars.alabama.gov/ — higher-quality subset; no deficiency detail.

**Bottom line:** Alabama does not host a public, per-facility inspection-history portal analogous to SC's `scchildcare.org/provider/*/` or Oregon's Child Care Safety Portal. Compliance history is primarily available via **FOIA request** to DHR Child Care Services.

## Data Format

| Item | Format |
|---|---|
| Directory search results | HTML, ASP.NET PostBack form; no CSV export |
| Per-facility "detail" | Not exposed — click-through only returns contact info |
| Deficiency reports | PDF, **posted only at the facility** and in DHR internal records |
| Corrective action plans | PDF, internal |
| Substantiated CA/N reports | Internal — summary data subject to Ala. Code § 26-14; placement on central registry |
| Bulk export | **Not published** |

## Freshness

- Directory listings reflect current license status (updated when DHR issues / revokes / suspends).
- Annual inspections are conducted; deficiency reports are dated but not broadcast publicly.
- Enforcement actions (revocation, probation, fine) are maintained internally; the only reliable public channel is the state-government news-release / press channel and news media.

## Key Fields (publicly visible)

- Facility name
- Address, city, county, zip
- Phone
- License type (Day Care Center, Family / Group Day Care Home, Nighttime Center / Home)
- License number
- License status (active / probationary / exempt)
- **Not shown:** inspection dates, violations cited, deficiencies, corrective actions, complaint investigations, enforcement actions

## Scraping / Access Strategy

Minimal scraping opportunity for violations; for **roster** scraping:

1. **Iterate counties** on the directory search (67 AL counties). Each POST returns a paged results table.
2. **Parse** facility table rows: name, address, phone, license number, license type.
3. For violations, use the license number to submit a targeted FOIA request per facility batch (see below).

Third-party aggregators:

- **childcarecenter.us** (used in the leads CSV pull) — surfaces only roster data.
- **Alabama Family Central map** — https://alabamafamilycentral.org/service/alabama-dhr-statewide-daycare-map/ — visualizes the directory; no violations.

## Known Datasets / Public Records

- **Alabama Childcare Facts — Minimum Standards summary** — https://alabamachildcarefacts.com/minimum-standards/ — advocacy site summarizing DHR rules; useful secondary.
- **Proposed updated Center Performance Standards (2021 draft)** — https://dhr.alabama.gov/wp-content/uploads/2021/06/PROPOSED-Centers-Child-Care-Licensing-and-Performance-Standards.pdf — includes deficiency-report templates and corrective-action protocol.
- **Act 2018-390 (Child Care Safety Act)** — https://alison.legislature.state.al.us/files/pdf/search/alison_2018RS/PublicActs/2018-390.htm — mandated that previously-exempt church-operated centers receiving federal/state funds (CCDBG subsidies) be subject to licensing and publicly registered.
- **Alabama Voices / reform advocacy** — VOICES for Alabama's Children (https://alavoices.org/) and Alabama Partnership for Children (https://smartstart.org/) — published analyses that cite DHR deficiency statistics.
- **Media coverage:** AL.com has run multiple investigations (e.g., the 2018 "child care exempt" reporting that preceded the 2018 Child Care Safety Act) referencing DHR records obtained via FOIA.

## FOIA / Open-Records Path

Alabama Open Records Act (Ala. Code § 36-12-40) governs public access to state records. Ala. Code § 38-2-6(8) also makes DHR licensing records public subject to confidentiality exceptions for children and families named in reports.

- **Submit to:** Alabama DHR Child Care Services, Attn: Open Records / FOIA Officer, 50 Ripley Street, Montgomery, AL 36130. Phone: (334) 242-1425 or toll-free (866) 528-1694. Licensing intake email: childcarelicensingintake@dhr.alabama.gov.
- **Turnaround:** Ala. Code § 36-12-40 requires "reasonable time." In practice DHR takes **30-60 business days** for batch compliance data.
- **Cost:** per-page copy fees; staff-time fee for large extracts. Electronic production often free.
- **Recommended scope:** "For all licensed day care centers, family day care homes, group day care homes, nighttime centers, and nighttime homes active at any point between 2022-01-01 and present, produce in machine-readable format (CSV/Excel): facility name, license number, license type, address, county, all annual and complaint-inspection dates, deficiency citations under Ala. Admin. Code Chapter 660-5-26 and 660-5-27, corrective action plan dates, and any enforcement actions (probation, suspension, revocation, fine) issued during the period."
- **Redactions:** DHR will typically redact names of children, specific home addresses of family-home providers, and any details identifying the subject of a CA/N report.

## Sources

- DHR Day Care Directory (centers): https://apps.dhr.alabama.gov/daycare/daycare_search
- DHR Licensed Day Care Homes: https://apps.dhr.alabama.gov/Child_Care_Services/Lic_Day_Care_Homes
- DHR Child Care Services landing: https://dhr.alabama.gov/child-care/
- DHR Licensing Overview: https://dhr.alabama.gov/child-care/licensing-overview/
- License-Exempt Day Care Facilities: https://dhr.alabama.gov/child-care/license-exempt-day-care-facilities/
- FAQ — how do I file a complaint?: https://dhr.alabama.gov/faq/how-do-i-file-a-complaint-against-a-provider/
- Act 2018-390 (Child Care Safety Act): https://alison.legislature.state.al.us/files/pdf/search/alison_2018RS/PublicActs/2018-390.htm
- Ala. Code § 36-12-40 (Open Records): https://alison.legislature.state.al.us/files/pdf/search/alison_2018RS/PublicActs/2018-390.htm
- Alabama Family Central statewide map: https://alabamafamilycentral.org/service/alabama-dhr-statewide-daycare-map/
- Alabama Childcare Facts (advocacy summary): https://alabamachildcarefacts.com/minimum-standards/
- Proposed Center Performance Standards (2021 draft): https://dhr.alabama.gov/wp-content/uploads/2021/06/PROPOSED-Centers-Child-Care-Licensing-and-Performance-Standards.pdf
- DHR FAQs: https://dhr.alabama.gov/faqs-dhr/
- Child Abuse/Neglect Reporting: https://dhr.alabama.gov/child-protective-services/child-abuse-neglect-reporting/
- Child Abuse/Neglect Administrative Reviews: https://dhr.alabama.gov/child-protective-services/child-abuse-neglect-administrative-reviews/
