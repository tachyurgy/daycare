# New Hampshire — Violations & Inspection Data Research

**Compiled:** 2026-04-18
**State slug:** new_hampshire

## Violations / Inspection Data Source (URLs)

- **Primary (consumer-facing):** NH Child Care Search — https://new-hampshire.my.site.com/nhccis/NH_ChildCareSearch
- **CCLU landing:** https://www.dhhs.nh.gov/programs-services/childcare-parenting-childbirth/child-care-licensing
- **CCLU News & Updates (enforcement announcements):** https://www.dhhs.nh.gov/programs-services/childcare-parenting-childbirth/child-care-licensing/cclu-news-and-updates
- **Inspection process explainer (PDF):** https://www.dhhs.nh.gov/sites/g/files/ehbemt476/files/documents/2021-11/holu-child-care-licensing-inspections.pdf
- **Statutory basis:** RSA 170-E and He-C 4002 (public-disclosure provisions); RSA 91-A (NH Right-to-Know Law).

## Data Format

- **Bulk export:** None published. NH does not expose a CSV or JSON feed of facilities, inspections, or enforcement actions.
- **Per-facility, on-portal:** NH Child Care Search is a **Salesforce Experience Cloud / Visualforce community**. Detail pages expose:
  - License/permit status
  - Provider-supplied contact details, hours, age groups, services
  - "Licensing history" card with the last 3 years of monitoring and inspection reports (typically linked as PDFs or rendered inline)
  - Any open Statement of Findings / Corrective Action Plan (CAP) once the CAP due date has passed (per He-C 4002 these are public)
- **Backend:** `Visualforce.remoting` remote actions — `fetchAccountList`, `fetchProviderList`, `retrieveAccountRecords`. Session-scoped anti-CSRF tokens required; no anonymous bulk endpoint.

## Freshness

- Per He-C 4002, Statements of Findings and CAPs become public "on or after the corrective action plan due date" — typically 30–45 days after issuance.
- Monitoring reports are posted for the **last 3 years** (rolling). Older reports fall off the public portal but remain obtainable under RSA 91-A.
- No standing public enforcement-actions list exists (unlike states where a monthly bulletin is published). Enforcement announcements appear sporadically in the CCLU News & Updates page.

## Key Fields (per-facility on NH Child Care Search)

- Account/provider record: name, DBA, license number, license type, address, phone
- License status (active / conditional / suspended / revoked) and effective dates
- Program type (center / family / family group / preschool / infant-toddler / school-age / night care)
- Critical-rule violation flags — He-C 4002 marks certain rules "critical"; any violation of a critical rule triggers a CAP and is flagged in the licensing history.
- Administrative fines (He-C 4002 explicitly authorizes monetary penalties — unusual among NE states)

## Scraping / Access Strategy

1. **Not reasonably scrapeable at scale without session handling.** The Salesforce Experience Cloud app renders data client-side; a curl fetch returns only Aura bootstrap scripts. Bulk access requires Puppeteer/Playwright with Salesforce session cookies or a DHHS partnership.
2. **For per-facility enrichment:** headless browser visit → extract license number, status, and latest inspection PDF URL. Cost-per-lookup is high (~2–4 seconds + 1 Salesforce session cycle); reserve for high-value accounts.
3. **For bulk:** file an **RSA 91-A request** (NH Right-to-Know) to DHHS CCLU for a flat-file export of (a) all currently licensed programs, (b) all Statements of Findings for the past 3 years, (c) all CAPs, (d) all administrative fines. NH agencies have 5 business days to respond with either records or a written extension; extensions must cite reasons.
4. **CCLU direct contact** (responsive to provider questions and sometimes public-records inquiries):
   - Phone: (603) 271-9025 (main) / (603) 271-4624 (licensing)
   - Email: CCLUoffice@dhhs.nh.gov

## Known Datasets / Public Records

- **NH Child Care Search (per-facility licensing history, last 3 yrs):** https://new-hampshire.my.site.com/nhccis/NH_ChildCareSearch
- **CCLU News and Updates page (enforcement announcements & rule updates):** https://www.dhhs.nh.gov/programs-services/childcare-parenting-childbirth/child-care-licensing/cclu-news-and-updates
- **He-C 4002 adopted rule (2025-08-26) PDF:** https://www.dhhs.nh.gov/sites/g/files/ehbemt476/files/documents2/he-c-4002-formatted.pdf
- **HoLu Child Care Licensing Inspections explainer (PDF):** https://www.dhhs.nh.gov/sites/g/files/ehbemt476/files/documents/2021-11/holu-child-care-licensing-inspections.pdf
- **Child Care Aware of NH licensing summary:** https://nh.childcareaware.org/child-care-licensing/

## FOIA / Open-Records Path

- **Statute:** RSA 91-A — New Hampshire Right-to-Know Law.
- **Submit to:** DHHS Public Information Officer or CCLU direct (CCLUoffice@dhhs.nh.gov) with cc to DHHS records custodian.
- **Suggested request scope:** "Under RSA 91-A, I request electronic copies of: (1) the current roster of licensed child care programs including license number, license type, address, phone, capacity, and license status; (2) all Statements of Findings and Corrective Action Plans issued in the last 36 months; (3) all administrative fines assessed under He-C 4002; (4) any enforcement actions (suspensions, revocations, conditional licenses). CSV/Excel preferred; PDFs acceptable."
- **Response window:** 5 business days (extensions require written explanation).
- **Fees:** Reasonable reproduction costs only; agencies may not charge for search/review time absent statute.
- **Appeals:** Superior Court under RSA 91-A:7 (attorney's fees recoverable for wrongful denial).

## Sources

- NH DHHS — Child Care Licensing: https://www.dhhs.nh.gov/programs-services/childcare-parenting-childbirth/child-care-licensing
- NH Child Care Licensing Unit: https://www.dhhs.nh.gov/child-care-licensing-unit
- CCLU News and Updates: https://www.dhhs.nh.gov/programs-services/childcare-parenting-childbirth/child-care-licensing/cclu-news-and-updates
- NH Child Care Search portal: https://new-hampshire.my.site.com/nhccis/NH_ChildCareSearch
- He-C 4002 rule (PDF): https://www.dhhs.nh.gov/sites/g/files/ehbemt476/files/documents2/he-c-4002-formatted.pdf
- Child Care Licensing Inspections explainer: https://www.dhhs.nh.gov/sites/g/files/ehbemt476/files/documents/2021-11/holu-child-care-licensing-inspections.pdf
- RSA 170-E (statute): https://www.gencourt.state.nh.us/rsa/html/NHTOC/NHTOC-XII-170-E.htm
- RSA 91-A (Right-to-Know): https://www.gencourt.state.nh.us/rsa/html/VI/91-A/91-A-mrg.htm
- Child Care Aware of NH: https://nh.childcareaware.org/child-care-licensing/
- National Database (ACF — NH): https://licensingregulations.acf.hhs.gov/licensing/states-territories/new-hampshire
