# Vermont — Violations & Inspection Data

**Date collected:** 2026-04-18
**State rank (population):** 49

## Violations / Inspection Data Source

Vermont's **Bright Futures Information System (BFIS)** is the single source of truth for licensing visits, violations, and corrective-action plans. Federal legislation (CCDBG Act of 2014 as reauthorized) **requires** public posting of regulatory non-compliance, and DCF's Child Development Division implements this through the BFIS public provider profile.

- BFIS public portal: https://www.brightfutures.dcf.state.vt.us
- Find Child Care: https://dcf.vermont.gov/cdd/families/find-care
- DCF Public Records request page: https://dcf.vermont.gov/contacts/public-records

## Data Format

- **Per-facility** — each program's BFIS profile lists licensing visit dates; clicking a date reveals violation facts and required corrective action.
- HTML rendered dynamically (BFIS is a session-protected ASP.NET-style app); WebFetch receives a redirect / blank shell on first-hit.
- No public Socrata, ArcGIS, or JSON feed published by DCF.
- STARS quality ratings are surfaced on the same profile but are distinct from compliance data.

## Freshness

- **Minimum 5 years** of violation / corrective-action history posted on the BFIS public site per DCF policy.
- Recent (March 2026) Vermont State Auditor report flagged that temporarily closed programs were sometimes out of compliance with the minimum 3-year posting requirement — expect partial gaps for closed facilities.
- Visits are added to the profile after the licensor finalizes the report (typically within weeks of the visit).

## Key Fields

- Provider name, license number, license type (CBCCPP, RFCCH, LFCCH, AFSP, Non-Recurring)
- License status (active / conditional / suspended / revoked / surrendered)
- Visit date
- Visit type (initial / monitoring / complaint / follow-up)
- Violation text (mapped to CVR 13-171-004 / 005 / 006 / 162-009 citations)
- Severity classification (per 2026 auditor findings, VT DCF uses a "serious" vs. "standard" classification — with identified inconsistency in application)
- Required corrective action + deadline
- STARS level (1-5)

## Scraping / Access Strategy

1. **Provider enumeration:** BFIS public search accepts filters (town, program type, ages, STARS). Iterate by town (Vermont has ~250 towns / cities) to build a master provider list.
2. **Session handling:** BFIS assigns a session on landing and appends a process-token query parameter; scrape tooling must accept + pass cookies and follow redirects.
3. **Compliance extraction:** for each provider, fetch the licensing-history view; iterate each dated visit; record violation text + corrective action.
4. **Headless browser required:** JS-rendered results, moderate anti-bot (not CAPTCHA-gated but session-strict). Use Playwright with throttling (1-2 req/sec).
5. **Supplement via journalism:** VTDigger's child-care beat is active and publishes named violations with enforcement outcomes — useful for validating the BFIS normalized data set.

## Known Datasets / Public Records

- **VTDigger investigations:**
  - "South Burlington child care faces state violations" (Apr 2025) — Little Beginnings Early Learning Center license degradation
  - "Barre Town child care center partially shuttered, staff member criminally cited" (Aug 2023)
  - "Audit finds gaps in Vermont child care oversight pose risks to children, threaten federal dollars" (Mar 2026) — cited 11 of 40 "standard" citations should have been "serious"
  - "Vermont's child care, early education administration is 'fundamentally broken,' report finds" (Jul 2022)
- **Vermont State Auditor — CCD Final Report (2026)** — the authoritative recent document on BFIS data-quality gaps. PDF: https://auditor.vermont.gov/sites/auditor/files/CCD%20Final%20Report.pdf
- **Vermont Public (radio/TV):** "Vt. child care inspectors undercount 'serious' violations, audit finds" (Mar 2026).
- **WCAX:** "Background check delays, data glitches raise child care safety concerns in Vermont" (Mar 2026).
- **Northern Lights Career Development Center registry** — staff training / credential coverage; complements but does not duplicate facility inspection data.

## FOIA / Open-Records Path

- Statute: **1 V.S.A. §§ 315-320** — Vermont's Public Records Act. Presumption of openness; narrow exemptions.
- Process: **DCF Public Records** page details the submission workflow. Response window: **2 business days** for acknowledgement, with production on a reasonable-time basis.
- Portal: https://dcf.vermont.gov/contacts/public-records
- Email route: use the DCF-listed records officer address.
- **Useful request:** "Full CSV / Excel extract of BFIS licensing visit records, violation classifications (standard vs. serious), corrective-action plans, and enforcement actions for all regulated child care programs for the preceding 7 years. Include license number, program type, STARS level at time of visit, visit date, citation, outcome, and closure date if applicable."
- **Supplementary request to the State Auditor's office:** the audit dataset underlying the March 2026 report may be separately releasable.

## Sources

- https://www.brightfutures.dcf.state.vt.us — BFIS public portal
- https://dcf.vermont.gov/cdd — Child Development Division
- https://dcf.vermont.gov/cdd/families/find-care — Find Child Care
- https://dcf.vermont.gov/contacts/public-records — DCF public-records request
- https://auditor.vermont.gov/sites/auditor/files/CCD%20Final%20Report.pdf — Vermont State Auditor CCD Final Report (2026)
- https://vtdigger.org/2025/04/03/south-burlington-child-care-faces-state-violations/ — South Burlington case
- https://vtdigger.org/2026/03/09/audit-finds-gaps-in-vermont-child-care-oversight-pose-risks-to-children-threaten-federal-dollars/ — 2026 audit coverage
- https://vtdigger.org/2023/08/18/barre-town-child-care-center-partially-shuttered-staff-member-criminally-cited/ — Barre Town case
- https://vtdigger.org/2022/07/07/vermonts-child-care-early-education-administration-is-fundamentally-broken-report-finds/ — 2022 structural report
- https://www.vermontpublic.org/local-news/2026-03-09/vermont-child-care-inspectors-undercount-serious-violations-audit-finds — Vermont Public coverage
- https://www.wcax.com/2026/03/20/systemic-issues-state-child-care-programs-are-endangering-vermont-children/ — WCAX coverage
- https://legislature.vermont.gov/statutes/chapter/01/005 — 1 V.S.A. Public Records Act
