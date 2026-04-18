# Utah — Violation / Inspection-Failure Data Sources

_Compiled 2026-04-18 for ComplianceKit. Companion to `compliance.md` and `SOURCES.md` (provider/lead sourcing)._

## Violations / Inspection Data Source

- **Primary — Utah DLBC "Find a Facility" + CCL program search.** Every DLBC-licensed child care program has a public compliance record with current license status, inspection reports, and confirmed findings of rule non-compliance for the **prior 36 months**.
  - Find-a-Facility landing: `https://dlbc.utah.gov/information-for-the-public/find-a-facility/`
  - Public search + per-facility detail: `https://ccl.utah.gov/` (unified portal for the 3 DLBC program types — child care, health care, human services)
  - Public inspection checklist (per inspection): `https://ccl.utah.gov/ccl/public/checklist/{CHECKLIST_ID}` — e.g. `https://ccl.utah.gov/ccl/public/checklist/632272`
- **Enforcement / Corrective Actions:** DLBC publishes the "OL Guidelines for Corrective Actions and Civil Money Penalties" framework (the formal noncompliance escalation ladder: written notice &rarr; corrective action plan &rarr; CMP &rarr; conditional / denial / revocation).
- **Inspection checklist masters (what the licensor is grading against):**
  - Centers (R381-100): `https://dlbc.utah.gov/wp-content/uploads/CENTER-Inspection-Checklist-7_2_2025.pdf`
  - Licensed Family (R430-90): `https://dlbc.utah.gov/wp-content/uploads/LICENSED-FAMILY-Inspection-Checklist-MASTER-1.pdf`
  - Licensed Family 5/2025 master: `https://dlbc.utah.gov/wp-content/uploads/LF-05.2025-MASTER-1.pdf`

## Data Format

- **Per-facility, HTML + static-hosted checklist pages.** Each inspection renders at `ccl.utah.gov/ccl/public/checklist/{ID}` with provider name, facility ID, inspection date, licensor signature block, and every checklist item graded against its R381 / R430 subrule.
- **No Socrata, no ArcGIS, no bulk CSV.** opendata.utah.gov has no child-care licensee dataset as of 2026-04-18. DLBC's Find-a-Facility page returns 403 to headless clients.
- Per-facility profile: license type, current status, capacity, director, expiration date, inspection log (last 36 months), confirmed non-compliance findings with rule citation.

## Freshness

- **Annual announced inspection** at every facility for license renewal; **additional unannounced inspections** for complaints / follow-up. Record updated within days of licensor filing.
- **Public window: last 36 months.** Anything older requires a Utah **GRAMA** (Government Records Access & Management Act) request.
- Rule-set moves with **R381-100** / **R381-60** / **R381-70** revisions — last major refresh 7/2025 (centers) and 5/2025 (licensed family).

## Key Fields (per inspection)

| Field | Example |
|-------|---------|
| Facility ID | `632272` |
| Provider Name | Free-text |
| Inspection date | YYYY-MM-DD |
| Inspection type | Announced / Unannounced / Follow-up / Complaint |
| Rule type | R381-100 (Center) / R381-60 (Hourly) / R381-70 (Residential) |
| Checklist item | Rule number + text (e.g. "R381-100-10(3) Infant ratio") |
| Status | Met / Not Met / Not Applicable / Not Reviewed |
| Finding narrative | Free-text |
| Corrective action required | Yes/No + due date |
| Civil money penalty | $ amount (if assessed) |
| Licensor signature block | Name + title + date |

Provider-level fields:

- License type (Center / Hourly / Licensed Family / Residential Cert. Family)
- License status (Active / Conditional / Provisional / Denied / Revoked / Surrendered)
- Capacity
- Director
- License expiration date
- Care About Childcare (CAC) QRIS level (if participating)

## Scraping / Access Strategy

- **`dlbc.utah.gov` returns 403 to standard WebFetch / headless requests** — Akamai / Cloudflare edge filtering. Path: Playwright with a real browser UA and ≥2 s delay; or stealth plugin.
- **`ccl.utah.gov/ccl/public/checklist/{ID}`** is the checklist URL pattern — publicly served and less aggressively filtered. Enumerate integer IDs from observed range (~600k–700k as of April 2026) with exponential back-off.
- Facility search backs a JSON endpoint that returns JSON rows when invoked from a proper browser session; intercept with DevTools network tab to confirm the endpoint path (`ccl.utah.gov/ccl/public/search/...`).
- DLBC page layout changed under DHHS reorg (2022 move from DOH to DHHS): older blog/media links may still use `childcarelicensing.utah.gov` — that host still redirects to DLBC.
- **Rate-limit hygiene:** scrape at ≤1 req/sec, cache HTML to S3, respect `Retry-After`. Ship scraped dataset through a 3rd-party validation step before treating as source of truth.

## Known Datasets / Public Records

- **No open-data release.** opendata.utah.gov has no child-care licensee dataset as of 2026-04-18.
- Inspection-checklist master PDFs (provider-facing) published at `dlbc.utah.gov/wp-content/uploads/...` — machine-readable standards (useful for building ComplianceKit's self-assessment simulator).
- **Care About Childcare** professional-development registry at `careaboutchildcare.utah.gov` — per-provider QRIS level + staff credential roster (login required for staff detail; program-level public).
- **National DB — Utah:** `https://licensingregulations.acf.hhs.gov/licensing/states-territories/utah`

## FOIA / Open-Records Path

- **Utah GRAMA — Utah Code §§ 63G-2-101 et seq.** File request via the state GRAMA portal or directly to DHHS.
- DLBC explicitly states: "To request access to compliance history records more than 36 months old, you must submit a GRAMA request."
- Response window: **10 business days** (extendable with written notice).
- Fees: clerical + copying; may be waived on public-interest showing.
- GRAMA request email contact (DHHS Records Officer): verify at `https://dhhs.utah.gov` prior to filing; Utah uses agency-specific records officers rather than a central intake.
- Bureau of Criminal ID handles background-check-related GRAMA separately: `https://bci.utah.gov/grama-requests/`

## Sources

- Utah DLBC home: https://dlbc.utah.gov/
- DLBC Child Care page: https://dlbc.utah.gov/home/office-of-licensing/child-care/
- Find-a-Facility landing: https://dlbc.utah.gov/information-for-the-public/find-a-facility/
- CCL unified public portal: https://ccl.utah.gov/
- Sample inspection checklist page: https://ccl.utah.gov/ccl/public/checklist/632272
- Another sample: https://ccl.utah.gov/ccl/public/checklist/622289
- Child Care Center Inspection Checklist (7/2/2025 master): https://dlbc.utah.gov/wp-content/uploads/CENTER-Inspection-Checklist-7_2_2025.pdf
- Licensed Family Inspection Checklist (R430-90 master): https://dlbc.utah.gov/wp-content/uploads/LICENSED-FAMILY-Inspection-Checklist-MASTER-1.pdf
- Licensed Family (LF) 5/2025 master: https://dlbc.utah.gov/wp-content/uploads/LF-05.2025-MASTER-1.pdf
- DLBC News / Legislative updates: https://dlbc.utah.gov/news/
- DLBC rules index: https://dlbc.utah.gov/home/office-of-licensing/child-care/rules/
- R381-100 current rules: https://adminrules.utah.gov/public/rule/R381-100/Current%20Rules
- R381-100 LII mirror: https://www.law.cornell.edu/regulations/utah/health/title-R381/rule-R381-100
- R381-100 § 10 Ratios: https://regulations.justia.com/states/utah/health/title-r381/rule-r381-100/section-r381-100-10/
- R381-60 § 10 Ratios: https://regulations.justia.com/states/utah/health/title-r381/rule-r381-60/section-r381-60-10/
- DLBC Interim legislative report (2024): https://le.utah.gov/interim/2024/pdf/00002340.pdf
- Utah GRAMA reference (State Auditor): https://auditor.utah.gov/news/grama/
- KUTV Check Your Health (consumer-facing how-to): https://kutv.com/features/health/check-your-health/check-your-health-searching-for-licensed-daycare-assisted-living-etc-compliance
- ACF National DB — UT: https://licensingregulations.acf.hhs.gov/licensing/states-territories/utah
