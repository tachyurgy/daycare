# Oregon — Violations, Inspections & Facility Licensing Reports

> How Oregon publishes compliance history, valid findings, complaint investigations, and enforcement actions for certified centers, certified family homes, and registered family homes.

## Violations / Inspection Data Source

Primary public-facing systems:

- **Find Child Care Oregon** — https://findchildcareoregon.org/
  Parent-facing discovery portal; also acts as the unified skin on top of the Child Care Safety Portal since Feb 2024.
- **Child Care Safety Portal** (legacy URL still live) — https://childcaresafetyportal.ode.state.or.us/portal/
- **CCLD WorkLife Systems compliance search** — https://stage.worklifesystems.com/Login/LoginGuest?AgencyId=34&activetab=SearchCompliances
  The underlying WorkLife Systems web app that powers the Safety Portal (guest login, no account needed).
- **DELC "Monitoring" for providers** — https://www.oregon.gov/delc/providers/pages/monitoring.aspx
  Explains the CCLD-0093 Child Care Facility Contact Report used for each visit.
- **DELC "Child Care Safety" for families** — https://www.oregon.gov/delc/families/pages/child-care-safety.aspx
  Describes what's on the Safety Portal.
- **DELC CCLD Program Data Dashboard** — aggregate quarterly counts (deaths, serious injuries, substantiated abuse, total children served) — published annually by March 15 per federal CCDBG rule.

## Data Format

| Item | Format |
|---|---|
| Safety Portal search | HTML, WorkLife Systems SaaS; guest-login web app |
| Provider compliance detail | HTML + linked PDFs (Contact Reports CCLD-0093, non-compliance letters) |
| Inspection summaries | Rolling windows: **"valid findings within the last 5 years"** and **"unable to substantiate within the last 2 years"** |
| Serious injury / death counts | Numeric; aggregated per-provider and statewide |
| Enforcement activity | Listed per-provider with status |
| Aggregate annual report | PDF, published by March 15 each year |
| Bulk export | **Not published** as downloadable CSV/JSON |

**Terminology:**
- **Valid Finding** = noncompliance a reasonable person could conclude occurred
- **Unable to Substantiate** = conflicting evidence or insufficient information
- **Serious Injury** = surgery, hospitalization, concussion, poisoning, broken bone, severe burn, etc. (CCLD-defined list)
- **Noncompliance** = documented in a letter sent to the facility; posted at the facility for 12 months and on the Safety Portal

## Freshness

- **Valid findings** appear on the portal within **7-30 days** of investigation closure.
- **5-year rolling window** for valid findings; 2-year window for unsubstantiated complaints.
- **Aggregate counts** updated **quarterly** (CCLD Program Data dashboard); the full annual report by March 15.

## Key Fields (Safety Portal / WorkLife Systems)

- Provider name, address, phone, email (if provided)
- License type (Certified Child Care Center [CC], Certified School-Age Center [SC], Certified Family Home [CF], Registered Family Home [RF])
- License number and status
- Capacity, age ranges
- Spark quality rating (if 3-5 stars)
- **Inspection summaries (last 5 years)** — date, type (Annual announced, Unannounced monitor, Complaint), valid findings with rule citation (OAR 414-305-xxxx / 414-307-xxxx / 414-350-xxxx), corrective-action status
- **Serious injuries, deaths, substantiated abuse** — counts with dates
- **Enforcement** — civil penalty, conditional license, suspension, revocation

## Scraping / Access Strategy

1. **Seed providers** — search Find Child Care Oregon by county (36 OR counties) and license type. Pagination via WorkLife Systems' SaaS backend; each result row links to a provider compliance page.
2. **Fetch** — the guest-login WorkLife Systems endpoint at `stage.worklifesystems.com` supports search + detail GETs after initial guest session cookie. A simple Requests session with cookie handling works.
3. **Parse** — compliance pages are HTML; Contact Reports are native PDFs.
4. **Refresh** — monthly is sufficient; quarterly for the aggregate dashboard.
5. **Alternate seed** — Oregon Spark (QRIS) rated-provider list at https://oregonspark.org/ . 211info has a referral database (1-866-698-6155).

**Advantage for compliance SaaS:** Oregon's Safety Portal exposes **far richer structured data per facility than any of MN, AL, KY, SC, LA** — specifically the separation of "valid" vs "unable to substantiate" and 5-year rolling history. Ideal for lead scoring.

## Known Datasets / Public Records

- **CCLD-0093 Contact Report (sample)** — https://www.oregon.gov/delc/providers/CCLD_Library/CCLD-0093-Contact-Report-SAMPLE.pdf — in-repo at `planning-docs/state-docs/oregon/CCLD-0093-Contact-Report-SAMPLE.pdf`
- **CCLD-0090 CC Health & Safety Review Checklist (sample)** — in-repo at `planning-docs/state-docs/oregon/CCLD-0090-CC-Health-and-Safety-Review-Checklist-SAMPLE.pdf`
- **CCLD-0109 CC Sanitation Inspection Checklist** — in-repo PDF
- **CCLD-0515 Monitor Visit Checklist (sample)** — in-repo PDF
- **CCLD-0615 SC Health & Safety Review Checklist (sample)** — in-repo PDF
- **UnL-0222-RS Health & Safety Review Checklist — Center (sample)** — in-repo PDF
- **Oregon CCDF Plan** — FY 2025-2027 plan submitted to ACF (OR DELC site); includes monitoring workflow and transparency commitments.
- **PDX Parent — "Is your child care up to code?"** — https://pdxparent.com/child-care-may16/ — consumer primer that references Safety Portal usage.
- **Family Forward (Portland) Safety Portal overview (2022)** — https://fhpdx.org/wp-content/uploads/2022/04/Child-Safety-Portal-2022.pdf
- **Oregon Early Learning Child Care Safety Portal Overview** — https://oregonearlylearning.com/parents-families/child-care-safety-portal-overview

## FOIA / Open-Records Path

Oregon Public Records Law — ORS 192.311 – 192.478.

- **Submit to:** DELC CCLD Customer Service — ccld.customerservice@delc.oregon.gov / 1-800-556-6616. Formal public-records requests: DELC Records Officer (listed on https://www.oregon.gov/delc/ contact page). Mailing address: DELC, 700 Summer St NE, Salem, OR 97301.
- **Turnaround:** ORS 192.329 requires acknowledgement within **5 business days**, with completion "as soon as practicable and without unreasonable delay."
- **Cost:** actual cost of preparation; electronic production often free or minimal.
- **Recommended scope:** "For all certified child care centers (CC), certified school-age centers (SC), certified family homes (CF), and registered family homes (RF) active at any point between 2023-01-01 and present, produce in machine-readable format (CSV/Excel): provider name, license number, license type, address, county, every inspection visit date and type, every valid finding with OAR citation and narrative, every unable-to-substantiate complaint, every serious injury / death / substantiated abuse count, and every enforcement action (civil penalty, conditional, suspension, revocation) with effective date."
- DELC regularly produces annotated extracts for researchers and state oversight committees.

## Sources

- Find Child Care Oregon: https://findchildcareoregon.org/
- Child Care Safety Portal (legacy URL): https://childcaresafetyportal.ode.state.or.us/portal/
- WorkLife Systems compliance search: https://stage.worklifesystems.com/Login/LoginGuest?AgencyId=34&activetab=SearchCompliances
- DELC Monitoring for Providers: https://www.oregon.gov/delc/providers/pages/monitoring.aspx
- DELC Child Care Safety for Families: https://www.oregon.gov/delc/families/pages/child-care-safety.aspx
- DELC Compliance for Providers: https://www.oregon.gov/delc/providers/pages/compliance.aspx
- DELC Report a Concern: https://www.oregon.gov/delc/pages/report-concern.aspx
- CCLD-0093 Contact Report (sample): https://www.oregon.gov/delc/providers/CCLD_Library/CCLD-0093-Contact-Report-SAMPLE.pdf
- CCLD-0090 Health & Safety Checklist: https://www.oregon.gov/delc/providers/CCLD_Library/CCLD-0090-CC-Health-and-Safety-Review-Checklist-SAMPLE.pdf
- Oregon Early Learning Safety Portal Overview: https://oregonearlylearning.com/parents-families/child-care-safety-portal-overview
- Family Forward Safety Portal 2022 guide: https://fhpdx.org/wp-content/uploads/2022/04/Child-Safety-Portal-2022.pdf
- PDX Parent — Is your child care up to code?: https://pdxparent.com/child-care-may16/
- Oregon Spark (QRIS): https://oregonspark.org/
- ORS Chapter 192 (Oregon Public Records Law): https://oregon.public.law/statutes/ors_chapter_192
- DELC CCLD email: ccld.customerservice@delc.oregon.gov
