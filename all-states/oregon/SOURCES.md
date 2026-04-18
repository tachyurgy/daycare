# Oregon — Sources & Data Pull Log

**Researched:** 2026-04-18
**Lead file:** `/Users/magnusfremont/Desktop/daycare/oregon_leads.csv`
**Lead row count:** 98 (plus header)

## Data Source Strategy

DELC (Department of Early Learning and Care) / CCLD does **not publish** a bulk CSV, JSON, or shapefile of licensed child-care centers. The **Child Care Safety Portal** / Find Child Care Oregon (https://findchildcareoregon.org/) is a search tool with per-provider licensing history; no bulk export. Phone request line: 1-800-556-6616.

Used **childcarecenter.us** (aggregator backed by CCLD licensee roster) for the top 5 cities in Oregon. Each record has name, city, state, and phone.

## Cities Captured

| City | Records |
|---|---|
| Portland | 20 (of 581) |
| Salem | 20 (of 147) |
| Eugene | 20 (of 126) |
| Beaverton | 20 (of 89) |
| Hillsboro | 18 (of 52) |
| **TOTAL** | **98** |

Directory URLs used:
- https://childcarecenter.us/oregon/portland_or_childcare
- https://childcarecenter.us/oregon/salem_or_childcare
- https://childcarecenter.us/oregon/eugene_or_childcare
- https://childcarecenter.us/oregon/beaverton_or_childcare
- https://childcarecenter.us/oregon/hillsboro_or_childcare

## In-Repo Reference Material (extensive)

This repo already contains the authoritative Oregon rule PDFs and sample inspection checklists at `/Users/magnusfremont/Desktop/daycare/planning-docs/state-docs/oregon/`:

- `CCLD-0084-Rules-for-Certified-Child-Care-Centers.pdf` (105 pages — full Division 305 rules; ratios on pp. 42-45)
- `CCLD-0084-Rules-Certified-Centers-ALT.pdf`
- `CCLD-0090-CC-Health-and-Safety-Review-Checklist-SAMPLE.pdf`
- `CCLD-0093-Contact-Report-SAMPLE.pdf`
- `CCLD-0105-Guide-to-Certified-Center-Child-Care.pdf`
- `CCLD-0108-Planning-and-Zoning-Occupancy-Building-Codes.pdf`
- `CCLD-0109-CC-Sanitation-Inspection-Checklist-Fillable.pdf`
- `CCLD-0515-Monitor-Visit-Checklist-SAMPLE.pdf`
- `CCLD-0615-SC-Health-and-Safety-Review-Checklist-SAMPLE.pdf`
- `CCLD-0731-General-Rules-for-All-Child-Care-Facilities.pdf`
- `CEN-0001-CBR-Application.pdf`
- `CEN-0005-CBR-FAQs.pdf`
- `CEN-0006-CBR-Rules.pdf`
- `PR-0185-Child-Enrollment-Form.pdf`
- `PTA-0948-Documents-Available-on-DELC-Website.pdf`
- `UnL-0222-RS-Health-and-Safety-Review-Checklist-Center-SAMPLE.pdf`
- `oregon-compliancekit-product-spec.html` (internal product spec)

Table 3A and 3B ratios in `compliance.md` were verified directly from page 44-45 of `CCLD-0084-Rules-for-Certified-Child-Care-Centers.pdf` via Python `pypdf`.

## Limits

- **Portal-only pull** for leads; ~98 records against ~4,000+ Oregon licensed centers (<3%). Concentrated in top-5 metros (Portland metro dominates).
- **Phone only** reliably present.
- **Gresham, Bend, Medford, Tigard, Lake Oswego** not captured — easy 5-minute follow-up pass to add 100+ more rows if needed.
- Hillsboro row count smaller (18) because aggregator page 1 only exposed 18 items; next page would add ~30+.
- Several records (YMCAs at schools, Boys & Girls Clubs) are licensed but run centrally by a national franchise; outreach should target center directors or state-level franchise leads.

## Alternate / Future Sources

- **DELC public-records request**: ccld.customerservice@delc.oregon.gov for full licensee roster.
- **Find Child Care Oregon** — can scrape per-provider records for inspection history (useful for lead scoring).
- **Oregon Spark / QRIS** participating providers: https://oregonspark.org/
- **211info** (1-866-698-6155) — referral-service database; handles DELC data downstream.

## Regulatory / Compliance Source URLs

- DELC — Providers landing: https://www.oregon.gov/delc/providers/Pages/become-a-provider.aspx
- DELC — Child Care Rules: https://www.oregon.gov/delc/providers/pages/child-care-rules.aspx
- DELC — Certified Child Care Center page: https://www.oregon.gov/delc/providers/pages/certified-center.aspx
- DELC — Certified Family page: https://www.oregon.gov/delc/providers/pages/certified-family.aspx
- DELC — Registered Family page: https://www.oregon.gov/delc/providers/Pages/registered-family.aspx
- DELC — Child Care Safety (family-facing): https://www.oregon.gov/delc/families/pages/child-care-safety.aspx
- Find Child Care Oregon (public portal): https://findchildcareoregon.org/
- CCLD-0084 Rules for Certified Child Care Centers (current): https://www.oregon.gov/delc/providers/CCLD_Library/CCLD-0084-Rules-for-Certified-Child-Care-Centers-EN.pdf
- CCLD-0084 (alt URL): https://www.oregon.gov/delc/providers/OCC%20Forms/CCLD-0084%20Rules%20for%20Certified%20Child%20Care%20Centers%20EN.pdf
- CCLD-0542 Rules for Certified School-Age Centers: https://www.oregon.gov/delc/providers/CCLD_Library/CCLD-0542-Rules-for-Certified-School-Age-Child-Care-Centers-EN.pdf
- PR-0203 Training Requirements (Centers): https://www.oregon.gov/delc/providers/CCLD_Library/PR-0203-Training-Requirements-for-Early-Educators-in-Center-Settings-EN.pdf
- PTA-0703 Summary of CC Rule Changes: https://www.oregon.gov/delc/providers/CCLD_Library/PTA-0703-Summary-of-CC-Rule-Changes.pdf
- PTA-0732 Mixed-Age Ratio Table: https://www.oregon.gov/delc/providers/CCLD_Library/PTA-0732-Mixed-Age-Ratio-Table-EN.pdf
- OAR 414-300-0130 (Staff/Child Ratios & Group Size): https://oregon.public.law/rules/oar_414-300-0130
- OAR 414-305-0400 (Certified Center Ratios): https://regulations.justia.com/states/oregon/chapter-414/division-305/section-414-305-0400/
- OAR 414-350-0120 (Registered Family Ratios): https://oregon.public.law/rules/oar_414-350-0120
- OAR 414-300-0030 (General Requirements): https://oregon.public.law/rules/oar_414-300-0030
- OAR 414-300-0360 (Night Care): https://oregon.public.law/rules/oar_414-300-0360
- Public Health Law Center — OR Rules for Certified Child Care Centers: https://www.publichealthlawcenter.org/sites/default/files/OR_Rules%20For%20Certified%20Child%20Care%20Centers_H_FINAL.pdf
- ORS Chapter 329A (Child Care Act): https://oregon.public.law/statutes/ors_chapter_329a
- Oregon Secretary of State OAR portal: https://secure.sos.state.or.us/oard/viewSingleRule.action?ruleVrsnRsn=251292
