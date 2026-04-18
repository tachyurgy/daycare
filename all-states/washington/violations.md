# Washington — Violations, Inspection Data & Public Records Research

**Last updated:** 2026-04-18
**Agency:** Washington State Department of Children, Youth, and Families (DCYF), Licensing Division. Prior to July 2018, licensing lived at Department of Early Learning (DEL); DCYF absorbed DEL.

## Violations / Inspection Data Source

Washington publishes complaint outcomes, monitoring inspection reports, and licensing-action history for every licensed child care provider through a single public-facing portal built on Salesforce.

1. **Child Care Check (findchildcarewa.org):** https://www.findchildcarewa.org — DCYF's public provider-lookup site, built on the Salesforce Sites platform. Each provider detail page exposes:
   - Current licensing status and capacity
   - **Valid complaints** (DCYF-verified; invalid / unfounded complaints are not shown)
   - **Licensing actions** — suspension, summary suspension, revocation, denial, non-renewal, probationary license
   - Monitoring inspection reports (PDF)
   - Early Achievers (QRIS) rating
   - Phone: 1-866-482-4325 (for operator-assisted lookup)
2. **DCYF Early Learning Complaints page:** https://dcyf.wa.gov/safety/child-care-complaints — explains intake → investigation → posting workflow (5-day first action, ~45-day close target).
3. **DCYF Policy 3.20.80 "Licensing Investigations"** and **3.20.90 "Adverse Actions"** — documented workflow each licensing consultant follows.

## Data Format

| Source | Format | Bulk? |
|---|---|---|
| findchildcarewa.org facility page | Salesforce Visualforce/Lightning render; each inspection is a clickable PDF | No official bulk export — but driven by an Apex Remoting endpoint (`/apexremote`) that returns structured JSON |
| DCYF Licensed Childcare dataset (Socrata) | CSV/JSON via `was8-3ni8` | Roster only — no violations; already pulled for `washington_leads.csv` |
| data.wa.gov (Socrata) | JSON/CSV via SODA | No child-care-violations dataset identified (April 2026) |
| DCYF press / news | HTML | Adverse-action announcements |

## Freshness

- Child Care Check updates complaints **after DCYF investigation closes with a "valid" finding** (45-day median); providers with invalid complaints are not annotated.
- Monitoring reports typically appear within 2–3 weeks of the inspector's visit.
- Roster (Socrata `was8-3ni8`) refreshes monthly to near-real-time.

## Key Fields on Washington Inspection Reports

- Inspection/visit date
- Inspector (licensor) name and region code
- Type: Monitoring / Re-licensing / Complaint Investigation / Compliance Agreement Review
- **WAC citation** (e.g., `WAC 110-300-0100` qualifications; `110-300-0285` safe sleep; `110-300-0356` capacity/ratio)
- **Severity level** (DCYF uses a differential monitoring rubric — High / Medium / Low risk flags against each WAC)
- Corrective action required (yes/no) and due date
- Facility Licensing Compliance Agreement (FLCA) — issued when a pattern of non-compliance triggers a written plan with expedited follow-up
- Enforcement action outcome: No Action / Technical Assistance / Compliance Agreement / Probationary / Summary Suspension / Revocation / Denial / Non-Renewal

## Scraping / Access Strategy

### findchildcarewa.org (primary target)

- Base: `https://www.findchildcarewa.org/`
- Search URL (human form): `PSS_Search?ft=Child+Care+Center%3BFamily+Child+Care+Home&p=DEL+Licensed`
- Provider detail URL: `PSS_Provider?id=<salesforce_account_id>` (e.g., `001t000000DzJU3AAN`)
- Under the hood, the page uses **Salesforce Apex Remoting** — the site exposes a controller `PSS_SearchController.queryProviders` at `/apexremote` which returns JSON. This endpoint can be called directly by first loading the page to pick up a valid `csrf_token` / session cookie.
- Third-party scraper prior art: `fulldecent/findchildcarewa.org-scraper` on GitHub (https://github.com/fulldecent/findchildcarewa.org-scraper) — demonstrates the Apex Remoting call structure.
- Recommended automation: Playwright-driven session opens a search page, captures session + CSRF, then calls `/apexremote` in parallel for the list of provider IDs; per-provider PDFs are hosted on `*.force.com` / `*.salesforce-sites.com` and can be fetched directly once authenticated.
- Polite rate: ≤1 req/sec is plenty; DCYF's Salesforce org tolerates modest burstiness.

### DCYF Licensed Childcare Socrata (complementary)

- `https://data.wa.gov/api/views/was8-3ni8/rows.csv?accessType=DOWNLOAD` — 2,563 rows; roster only. Join to `findchildcarewa` records via `FamLinkId` / `SSPSProviderNumber`.

### Tribal and certified-not-licensed

- Tribal providers that have opted into state licensing appear in the DCYF feed. Tribal providers operating only under tribal authority are NOT in either Child Care Check or the Socrata roster — exclude or source separately.

## Known Datasets / Public Records

- **DCYF Licensed Childcare Provider (Socrata `was8-3ni8`)** — roster, no violations.
- **data.wa.gov broad catalog** — https://data.wa.gov/ — no child-care-specific violations dataset as of April 2026.
- **Child Care Aware of Washington dashboards** — https://data.childcareaware.org/ — aggregate only; no per-facility violations.
- **Seattle Times / InvestigateWest** have run investigative reporting on DCYF child-care closures; no CSV dataset has been published alongside these pieces that we could locate.
- **DCYF news feed:** https://dcyf.wa.gov/news — useful for tracking high-profile enforcement actions as they are announced.

## FOIA / Open-Records Path

- Statute: **Washington Public Records Act (PRA), RCW 42.56** — 5-business-day initial response required; reasonable estimate for fulfillment.
- DCYF public records request portal: https://dcyf.wa.gov/practice/public-records
- Template ask: *"All child care licensing investigation reports, compliance agreements, summary suspensions, revocations, denials, and non-renewal orders for licensed child care centers, school-age programs, and family home child care issued between <start> and <end>, in electronic format."*
- DCYF has been generally responsive to PRA requests for aggregate investigation data but typically requires narrowing by date range / region.
- Appeals: Office of the Attorney General Open Government Ombuds.

## Sources

- DCYF early learning overview: https://dcyf.wa.gov/services/early-learning-providers
- Child Care Check (consumer-facing explainer): https://www.dcyf.wa.gov/services/earlylearning-childcare/child-care-check
- findchildcarewa.org search page: https://www.findchildcarewa.org/
- findchildcarewa.org search URL pattern: https://www.findchildcarewa.org/PSS_Search?ft=Child+Care+Center%3BFamily+Child+Care+Home&p=DEL+Licensed
- findchildcarewa.org provider URL pattern example: https://www.findchildcarewa.org/PSS_Provider?id=001t000000DzJU3AAN
- Child Care Aware of WA (third-party front door): https://ccawa.my.salesforce-sites.com/onlinesearch/
- DCYF Child Care Complaints process: https://dcyf.wa.gov/safety/child-care-complaints
- DCYF Policy 3.20.80 Licensing Investigations: https://dcyf.wa.gov/dcyf-policies/3-20-80-licensing-investigations
- DCYF Policy 3.20.90 Adverse Actions: https://dcyf.wa.gov/dcyf-policies/3-20-90-adverse-actions-foster-home-licenses-and-group-care-facility-licenses
- findchildcarewa scraper (third-party reference): https://github.com/fulldecent/findchildcarewa.org-scraper
- DCYF Licensed Childcare dataset (Socrata): https://data.wa.gov/education/DCYF-Licensed-Childcare-Center-and-School-Age-Prog/was8-3ni8
- WAC 110-300 (licensing rules): https://app.leg.wa.gov/wac/default.aspx?cite=110-300
- Washington Public Records Act (RCW 42.56): https://app.leg.wa.gov/rcw/default.aspx?cite=42.56
- DCYF public records request: https://dcyf.wa.gov/practice/public-records
