# Nebraska — Child Care Violations & Inspection Data Research

**State rank:** 37  
**Collection date:** 2026-04-18  
**Licensing authority:** Nebraska DHHS — Division of Public Health, Licensure Unit, Office of Children's Services Licensing

## Violations / Inspection Data Source (URLs)

- **Disciplinary Actions Against Health Care Professionals and Child Care Providers (landing):** https://dhhs.ne.gov/licensure/pages/disciplinary-actions-against-health-care-professionals-and-child-care-providers.aspx
- **Nebraska HHS License Search (per-licensee disciplinary record):** https://www.nebraska.gov/LISSearch/search.cgi
- **DHHS Child Care Licensing landing:** https://dhhs.ne.gov/licensure/pages/child-care-licensing.aspx
- **Weekly Roster of Licensed Child Care and Preschool Programs (PDF, weekly update):** https://dhhs.ne.gov/licensure/Documents/ChildCareRoster.pdf
- **Find a Child Care Provider:** https://dhhs.ne.gov/Pages/Search-for-Child-Care-Providers.aspx
- **10-year archive of CC negative actions (Mar 2016 &ndash; Mar 2026, rolling):** https://dhhs.ne.gov/licensure/Documents/Mar16-26ccnegactions.pdf
- **Monthly CC negative actions PDFs:**
  - March 2026 &mdash; https://dhhs.ne.gov/licensure/Documents/03-26ccnegactions.pdf
  - February 2026 &mdash; https://dhhs.ne.gov/licensure/Documents/02-26ccnegactions.pdf
  - January 2026 &mdash; https://dhhs.ne.gov/licensure/Documents/01-26ccnegactions.pdf
  - Aug 14 2024 cumulative &mdash; https://dhhs.ne.gov/licensure/Documents/Aug14-24ccnegactions.pdf
- **Neb. Rev. Stat. &sect;71-1919 (grounds for disciplinary action):** https://nebraskalegislature.gov/laws/statutes.php?statute=71-1919
- **Contact:** DHHS.LicensureUnit@nebraska.gov
- **Office of Inspector General of Nebraska Child Welfare monitoring report (2024-2025):** https://nebraskalegislature.gov/pdf/reports/oversight/child_care_monitoring_report_2024-2025.pdf
- **GovDelivery bulletin (announcements of updates):** https://content.govdelivery.com/accounts/NESTATE/bulletins/3e8572c

## Data Format

- **Monthly PDF bulletins** of "Negative and Disciplinary Actions Against Child Care Providers," posted around the **5th of each month** to a predictable URL pattern: `MM-YY-ccnegactions.pdf`.
- **Cumulative 10-year archive PDF** consolidating actions back to March 2016.
- **Weekly roster PDF** (`ChildCareRoster.pdf`) updated every week with the full active-license directory (~2,248 facilities); already used for our leads CSV. Fields: name, license #, owner, license type, effective date, county, address, city, ZIP, phone, capacity, days/hours, subsidy Y/N, Step Up to Quality level, accreditation.
- **HHS License Search** (`nebraska.gov/LISSearch/search.cgi`) &mdash; CGI web app that returns full licensee record including "Disciplinary / Non-Disciplinary Information" section. Per-licensee lookup only.
- **No open JSON / CSV endpoint** for either the monthly negative-actions PDF or the roster PDF.

## Freshness

- Monthly negative-actions PDFs: **posted around the 5th of each month** (explicit DHHS policy on the landing page).
- Weekly roster PDF: updated every week (the current version is dated 4/17/2026 on the page).
- HHS License Search: live data.
- Effective URL pattern means static monitoring job can check `{MM}-{YY}-ccnegactions.pdf` on the 6th of each month for the latest file.

## Key Fields (negative-action PDFs)

- Licensee name (facility / provider), license number, license type
- Date of action
- Action type (provisional license, suspension, emergency suspension, revocation, voluntary surrender, probation, denial, fine)
- Grounds (tied to Neb. Rev. Stat. &sect;71-1919 / Title 391 NAC)
- Effective date
- County / city
- Licensee address (where applicable)

## Scraping / Access Strategy

1. **Monitor monthly URL pattern** `https://dhhs.ne.gov/licensure/Documents/{MM}-{YY}ccnegactions.pdf` (zero-padded month, 2-digit year &mdash; e.g. `03-26ccnegactions.pdf`). Automated curl on the 6th of each month.
2. **Parse PDFs** with `pdftotext -layout` + regex. Tables are consistent: license # column anchors records.
3. **For comprehensive history**, download and parse the 10-year archive PDF `Mar16-26ccnegactions.pdf` (one-shot).
4. **Weekly roster**: re-run the existing parser (documented in `nebraska/SOURCES.md`) weekly to catch new entrants / closures.
5. **HHS License Search**: per-licensee lookup as needed for detailed disciplinary context; ASP-style CGI with predictable query string (no captcha).

## Known Datasets / Public Records

- **Weekly roster PDF** (primary licensed-provider directory).
- **NebraskaMAP &mdash; DHHS Licensed Child Care** geospatial dataset: https://www.nebraskamap.gov/datasets/dhhs-licensed-child-care &mdash; ArcGIS-hosted, lat/lon + license metadata; not violation-bearing.
- **Nebraska Office of Inspector General of Child Welfare** publishes annual monitoring reports: https://nebraskalegislature.gov/pdf/reports/oversight/child_care_monitoring_report_2024-2025.pdf
- **Step Up to Quality (NE QRIS) provider search:** https://www.nebraskachildcare.org/

## FOIA / Open-records Path

- **Nebraska Public Records Statute** (Neb. Rev. Stat. &sect;84-712 et seq.).
- DHHS Licensure Unit contact: **DHHS.LicensureUnit@nebraska.gov**. Many records (rosters, negative actions) are already publicly posted &mdash; records request typically only needed for structured CSV exports or older than 10 years.
- Suggested request: "Roster of licensed child care / preschool programs and all negative / disciplinary actions 2015-2026 in CSV format, including grounds citation mapped to Title 391 NAC." Expect to receive an Excel export if the Licensure Unit has it, or a PDF dump otherwise.

## Sources

- DHHS Disciplinary Actions &mdash; https://dhhs.ne.gov/licensure/pages/disciplinary-actions-against-health-care-professionals-and-child-care-providers.aspx
- 10-year CC negative actions archive &mdash; https://dhhs.ne.gov/licensure/Documents/Mar16-26ccnegactions.pdf
- DHHS Child Care Licensing &mdash; https://dhhs.ne.gov/licensure/pages/child-care-licensing.aspx
- Weekly Roster PDF &mdash; https://dhhs.ne.gov/licensure/Documents/ChildCareRoster.pdf
- HHS License Search &mdash; https://www.nebraska.gov/LISSearch/search.cgi
- Neb. Rev. Stat. &sect;71-1919 &mdash; https://nebraskalegislature.gov/laws/statutes.php?statute=71-1919
- Title 391 NAC Chapter 3 (Child Care Centers) &mdash; https://dhhs.ne.gov/licensure/Documents/CCC391-3.pdf
- OIG Child Welfare monitoring report 2024-2025 &mdash; https://nebraskalegislature.gov/pdf/reports/oversight/child_care_monitoring_report_2024-2025.pdf
- NebraskaMAP &mdash; https://www.nebraskamap.gov/datasets/dhhs-licensed-child-care
- Letter to Child Care Providers on LB460 &mdash; https://dhhs.ne.gov/licensure/Documents/LetterToChildCareProviders.pdf
- GovDelivery NE bulletin &mdash; https://content.govdelivery.com/accounts/NESTATE/bulletins/3e8572c
