# Idaho — Child Care Violations & Inspection Data Research

**State rank:** 38  
**Collection date:** 2026-04-18  
**Licensing authority:** Idaho Department of Health and Welfare (IDHW) — Division of Family and Community Services (Child Care Licensing); inspections by 7 regional public health districts.

## Violations / Inspection Data Source (URLs)

- **idahochildcarecheck.org &mdash; public-facing inspection records (primary):** https://www.idahochildcarecheck.org/
- **Provider search:** https://www.idahochildcarecheck.org/search
- **Per-provider URL pattern:** `https://www.idahochildcarecheck.org/provider/{id}` (integer ID, appears to span ~1 to 15000+)
- **Staging environment (rare):** https://stage.idahochildcarecheck.org/provider/5233
- **idcctracker.org &mdash; internal incident tracker (public URL, limited content):** https://www.idcctracker.org/
- **GovWebworks project page (technical background):** https://www.govwebworks.com/work/childcare-incident-tracker/
- **IDHW Find Quality Child Care:** https://healthandwelfare.idaho.gov/services-programs/children-families/find-quality-child-care
- **IDHW File a Child Care Complaint:** https://healthandwelfare.idaho.gov/services-programs/children-families-older-adults/file-child-care-complaint
- **Idaho 211 CareLine (complaint intake):** tel:211
- **Central District Health &mdash; CC Inspections:** https://www.cdhd.idaho.gov/eh-childcare-inspections.php
- **Southwest District Health &mdash; CC Program:** https://swdh.id.gov/licensing-permitting/child-care-program/
- **Eastern Idaho Public Health &mdash; 2025 Guidelines:** https://eiph.id.gov/wp-content/uploads/2025/07/EIPH-CC-Guidelines-2025.pdf
- **North Central District Public Health:** https://idahopublichealth.com/child-care/

## Data Format

- **Idaho Child Care Check (public site):** Drupal 8 application with per-provider pages. Data renders as:
  - `Inspections Conducted` aggregate count (e.g. "13 Inspections Conducted: 10 passed 3 failed")
  - Per-inspection detail: **date, pass/fail, type (Annual / Investigation / Follow-Up), resolution status**
  - **31 numbered inspection criteria** (supervision, CPR, ratios, food safety, emergency planning, etc.) with per-criterion findings
  - **Inspector comments** with narrative ("Corrected on 8/27/24 &ndash; At time of follow up&hellip;")
  - **Substantiated Incidents** section (category, date, description, resolution)
- **Search page is paginated:** ~208 pages of 10 providers each (already used for our leads CSV). URL: `?page={0..207}`.
- **No public JSON API or open data endpoint** published by GovWebworks or IDHW.
- **Start date of public data:** October 2017 (IDHW began publishing inspections).
- **Retention:** minimum 3 years on the public site.

## Freshness

- Inspections are published **as they are conducted** &mdash; rolling updates (no batch schedule).
- Facilities receive approximately **one unannounced inspection per year** from the regional public health district + follow-ups.
- Critical violations must be corrected immediately or trigger a follow-up visit scheduled by the inspector.

## Key Fields (per facility)

- Provider name, provider ID, contact name
- Address, city, state, ZIP
- Phone number
- Aggregate counts: total inspections, passes, fails
- Per-inspection: date, pass/fail, type, resolution status
- Per-criterion: criterion #, compliance status, inspector comment
- Substantiated incidents: category, date, description, resolution

## Scraping / Access Strategy

1. **Enumerate via pagination:** `https://www.idahochildcarecheck.org/search?page={N}` for N in [0, 207] &mdash; yields ~2,080 provider cards (the method already used for `idaho_leads.csv`).
2. **Expand to per-provider detail:** iterate provider IDs from search results; fetch `https://www.idahochildcarecheck.org/provider/{id}`.
3. **Parse HTML** for the per-provider inspection table (Drupal `views-field` CSS classes are stable anchors).
4. **No captcha, no auth**. Curl with `-A "Mozilla/5.0"` works. Conservative rate: 1-2 req/sec + exponential backoff on 5xx.
5. **Incremental sync:** store last-seen inspection date per provider; re-crawl weekly for net-new inspections.
6. **Incident cross-check:** combine Idaho Child Care Check incidents with local press (e.g., Idaho Statesman, Post Register) for narrative context.

## Known Datasets / Public Records

- **idahochildcarecheck.org** is the gold-standard source &mdash; Wave 6 research confirmed it exposes violation counts per facility in a stable, scrapable HTML format. Already used for the 2,045-row leads CSV.
- **idcctracker.org** is the internal staff-facing tracker for ~20 investigators / caseworkers / admins &mdash; no public content beyond the title page.
- **Regional public health districts** (7 districts: CDHD, EIPH, SWDH, SCDH, PHD, NCDPH, PHD3) conduct on-the-ground inspections. Some publish monthly inspection summaries on their sites but not in a standard format across all 7.
- **No HIFLD mirror** was used for Idaho.

## FOIA / Open-records Path

- **Idaho Public Records Act** (Idaho Code &sect;74-101 et seq.). IDHW is subject.
- Written request to IDHW (child care licensing); response deadline 3-10 business days (standard). Can request:
  - Full roster + license details in CSV
  - Historical inspection data (including pre-October 2017)
  - Substantiated incident records redacted per Idaho Code &sect;74-106
- Delegated public health districts are separately subject &mdash; e.g., EIPH, CDHD can also be FOIA'd for their raw inspection forms.

## Sources

- Idaho Child Care Check &mdash; https://www.idahochildcarecheck.org/
- Idaho Child Care Check search &mdash; https://www.idahochildcarecheck.org/search
- Sample provider page &mdash; https://www.idahochildcarecheck.org/provider/11796
- Idaho Complaint Tracker &mdash; https://www.idcctracker.org/
- GovWebworks project summary &mdash; https://www.govwebworks.com/work/childcare-incident-tracker/
- IDHW Find Quality Child Care &mdash; https://healthandwelfare.idaho.gov/services-programs/children-families/find-quality-child-care
- IDHW File a Complaint &mdash; https://healthandwelfare.idaho.gov/services-programs/children-families-older-adults/file-child-care-complaint
- Central District Health &mdash; https://www.cdhd.idaho.gov/eh-childcare-inspections.php
- Southwest District Health &mdash; https://swdh.id.gov/licensing-permitting/child-care-program/
- Eastern Idaho Public Health 2025 Guidelines &mdash; https://eiph.id.gov/wp-content/uploads/2025/07/EIPH-CC-Guidelines-2025.pdf
- North Central District PH &mdash; https://idahopublichealth.com/child-care/
- IdahoSTARS (QRIS partner) &mdash; https://idahostars.org/
- IDAPA 16.06.02 (Child Care Licensing rules) &mdash; https://adminrules.idaho.gov/rules/current/16/160602.pdf
- HB 243 (2025) &mdash; https://legislature.idaho.gov/wp-content/uploads/sessioninfo/2025/legislation/H0243E1.pdf
