# West Virginia — Child Care Violations & Inspection Data Research

**State rank:** 39  
**Collection date:** 2026-04-18  
**Licensing authority:** West Virginia Department of Human Services (DoHS) — Bureau for Family Assistance (BFA), Division of Early Care and Education (ECE). Formerly WV DHHR Bureau for Children and Families (BCF) — 2024 reorganization.

## Violations / Inspection Data Source (URLs)

- **WVBCF WV Child Care Centers search (per-facility lookup):** https://www.wvdhhr.org/bcf/ece/cccenters/ecewvisearch.asp
- **Facility detail page (example):** http://www.wvdhhr.org/bcf/ece/cccenters/get_details.asp?q=30068285
- **Child Care Center Standards Violation Reporting Form confirmation:** https://www.wvdhhr.org/bcf/ece/earlycare/ccc_comp_confirm.asp
- **Chart of Open Providers (bulk PDF, 2021):** https://dhhr.wv.gov/bcf/Childcare/Documents/CHART%20of%20Open%20Providers%20010821_WEB%20ONLY.pdf
- **Chart of Registered Providers (PDF, 2020):** https://dhhr.wv.gov/bcf/Childcare/Documents/CHART%20of%20Registered%20Providers%2007302020_WEB%20ONLY.pdf
- **BFA Child Care Centers portal:** https://bfa.wv.gov/child-care-centers
- **Legacy BCF Child Care portal:** https://dhhr.wv.gov/bcf/Childcare
- **Child Care Policy:** https://dhhr.wv.gov/bcf/Childcare/Policy/Pages/default.aspx
- **Child Care Locator:** https://dhhr.wv.gov/bcf/Childcare/Pages/ChildCareSearch/Child-Care-Locator.aspx
- **Find a Childcare Provider:** https://dhhr.wv.gov/bcf/ece/pages/providersearch.aspx
- **Division of Early Care and Education:** https://dhhr.wv.gov/bcf/ece/Pages/default.aspx
- **2024 Child Care Services Data press release (contextual statistics):** https://dhhr.wv.gov/News/2024/Pages/West-Virginia-Department-of-Human-Services-Announces-Updated-Child-Care-Services-Data.aspx
- **Sample enforcement action (Oct 2024 Cross Lanes CC provisional license):** https://dhhr.wv.gov/News/2024/Pages/DoHS-Places-Cross-Lanes-Child-Care-and-Learning-Center-on-Provisional-License-Amid-Investigation.aspx
- **Office of Environmental Health Services &mdash; Child Care Centers:** https://oehs.wvdhhr.org/phs/general-environmental-health/child-care-centers/
- **WV Code &sect;49-2-113 (inspection / access):** https://code.wvlegislature.gov/49-2-113/
- **78 CSR 1 &mdash; Child Care Centers Licensure (rule text):** https://dhhr.wv.gov/bcf/Childcare/Documents/ChildCareCenterRegulationWeb.pdf
- **Connect CCR&amp;R (WV Child Care R&amp;R):** https://www.connectccrr.org/
- **TEAM for West Virginia Children &mdash; Mapping the Gap dashboard:** https://teamwv.org/team-launches-mapping-the-gap-child-care-availability-dashboard/
- **Monitoring-Visit checklist (Differential MV for Family Child Care Facilities 78-18):** https://www.wvdhhr.org/bcf/ece/cccenters/documents/Differential_MV_Facilities_78CSR_18.pdf

## Data Format

- **Per-facility search (`ecewvisearch.asp`)** &mdash; classic ASP web app. Returns a list of centers by name/city/county and a link to `get_details.asp?q={provider_number}`. Detail page shows facility data and a noncompliance history in tabular HTML form.
- **Chart of Open Providers (PDF)** &mdash; bulk enumeration. 27 pp, tabular. Most recent public version is dated **Jan 8, 2021**; WV 2024 DoHS press release indicates ~1,391 licensed providers today (so the PDF is ~85-90% current).
- **Enforcement actions announced ad hoc via DoHS press releases** (dhhr.wv.gov/News/{YYYY}/Pages/...). Individual PDFs per incident; no consolidated enforcement roster is published on a regular cadence.
- **Non-compliance history reports** for a specific center can be obtained in printed form by contacting the Licensing Specialist assigned to that center.
- **No API, no open-data CSV** published by DoHS/BFA for centers or enforcement.

## Freshness

- `ecewvisearch.asp` reflects current DoHS license status (live).
- `Chart of Open Providers` is **stale** (2021 vintage on the public server) &mdash; no newer bulk PDF has been republished as of 2026-04-18.
- Enforcement press releases are published sporadically, typically within days of action.
- 2024 DoHS reorganization (DHHR &rarr; DoHS) means some URLs transition between `dhhr.wv.gov` and `bfa.wv.gov`; monitor both.

## Key Fields

### Chart of Open Providers PDF
- Name, Provider Number, Facility Type, Capacity, Age Range, Hours, Days, County, City, ZIP, Licensee/Administrator Name, Facility Email.

### `get_details.asp` per-facility detail
- Provider name, number, status
- License expiration date
- Facility type, age range, capacity
- Address, city, county, ZIP
- Licensee / Administrator name
- Non-compliance history (per-date, per-rule)

### DoHS enforcement press releases
- Facility name, location
- Date of action, type (provisional license, capacity reduction, suspension, emergency action)
- Preliminary findings
- Appeal rights

## Scraping / Access Strategy

1. **Enumerate via the 2021 PDF** &mdash; baseline roster of ~1,255 facilities (our leads CSV). Complement with `ecewvisearch.asp` queries to fill in new entrants.
2. **Classic ASP scraping** is straightforward: no captcha, no JavaScript. `curl` with ASPSESSIONID cookie; GET `get_details.asp?q={provider_number}` for each number.
3. **Parse HTML tables** with BeautifulSoup; the DoHS detail page is plain HTML.
4. **Monitor press releases** &mdash; set up an RSS or polling job against `dhhr.wv.gov/News/{YYYY}/Pages/` to detect enforcement announcements.
5. **File records requests** for structured enforcement history (see FOIA section).

## Known Datasets / Public Records

- **Chart of Open Providers (2021 PDF)** &mdash; primary bulk roster with ~92% email coverage. Already used for `west_virginia_leads.csv` (1,255 rows).
- **TEAM for West Virginia Children Mapping the Gap dashboard** &mdash; aggregates child care availability data (capacity, gap by county), useful for sector context; not violation-bearing.
- **WV OEHS (Office of Environmental Health Services)** handles food-service / sanitation inspections &mdash; separate datasets.
- **2024 DoHS press release statistics:** 1,391 licensed providers, 128 new applications under review, 44,941 available slots.

## FOIA / Open-records Path

- **West Virginia Freedom of Information Act (FOIA)**, W. Va. Code &sect;29B-1-1 et seq.
- **Custodian:** DoHS Bureau for Family Assistance, Division of Early Care and Education, Charleston.
- **Response window:** 5 business days after receipt; extensions permissible with explanation.
- **Suggested request:** "All Child Care Center licensure records, non-compliance histories, and enforcement actions issued under 78 CSR 1, 2015-2026, in CSV or Excel format, including provider number keys." Ask also for the current 'Chart of Open Providers' as an Excel file to get fresh 2026 data.

## Sources

- WVBCF CC Centers search &mdash; https://www.wvdhhr.org/bcf/ece/cccenters/ecewvisearch.asp
- Sample provider detail page &mdash; http://www.wvdhhr.org/bcf/ece/cccenters/get_details.asp?q=30068285
- CC Violation Reporting Form &mdash; https://www.wvdhhr.org/bcf/ece/earlycare/ccc_comp_confirm.asp
- 2021 Chart of Open Providers (PDF) &mdash; https://dhhr.wv.gov/bcf/Childcare/Documents/CHART%20of%20Open%20Providers%20010821_WEB%20ONLY.pdf
- 2020 Chart of Registered Providers (PDF) &mdash; https://dhhr.wv.gov/bcf/Childcare/Documents/CHART%20of%20Registered%20Providers%2007302020_WEB%20ONLY.pdf
- 78 CSR 1 Rule (PDF) &mdash; https://dhhr.wv.gov/bcf/Childcare/Documents/ChildCareCenterRegulationWeb.pdf
- WV Code &sect;49-2-113 &mdash; https://code.wvlegislature.gov/49-2-113/
- BFA Child Care Centers &mdash; https://bfa.wv.gov/child-care-centers
- DoHS press release &mdash; Cross Lanes (Oct 2024) &mdash; https://dhhr.wv.gov/News/2024/Pages/DoHS-Places-Cross-Lanes-Child-Care-and-Learning-Center-on-Provisional-License-Amid-Investigation.aspx
- DoHS press release &mdash; 2024 Child Care Services Data &mdash; https://dhhr.wv.gov/News/2024/Pages/West-Virginia-Department-of-Human-Services-Announces-Updated-Child-Care-Services-Data.aspx
- WV OEHS Child Care Centers &mdash; https://oehs.wvdhhr.org/phs/general-environmental-health/child-care-centers/
- TEAM for WV Children &mdash; Mapping the Gap dashboard &mdash; https://teamwv.org/team-launches-mapping-the-gap-child-care-availability-dashboard/
- Connect CCR&amp;R &mdash; https://www.connectccrr.org/
- ACF National Licensing DB &mdash; https://licensingregulations.acf.hhs.gov/licensing/states-territories/west-virginia
