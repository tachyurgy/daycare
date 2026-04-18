# Oklahoma — Violation / Inspection-Failure Data Sources

_Compiled 2026-04-18 for ComplianceKit. Companion to `compliance.md` and `SOURCES.md` (provider/lead sourcing)._

## Violations / Inspection Data Source

- **Primary:** Oklahoma Child Care Locator — per-facility "Monitoring Visits" and "Licensing History" pages, maintained by OKDHS Child Care Services (OCCS).
  - Facility profile: `https://childcarefind.okdhs.org/providers/{LICENSE_ID}`
  - Alternate host (same backend): `https://ccl.dhs.ok.gov/providers/{LICENSE_ID}`
  - Per-visit licensing history: `https://childcarefind.okdhs.org/licensing-history/{LICENSE_ID}/{VISIT_DATE_YYYY-MM-DD}`
- **Restricted Registry ("Joshua's List")** — public disqualification list of individuals barred from licensed child care (different grain — people, not facilities). `https://ccrrpublicjl.okdhs.org/ccrrpublicjl/public/`
- **Agency landing:** `https://oklahoma.gov/okdhs/services/child-care-services/child-care-licensing.html`

## Data Format

- **Per-facility, HTML (no bulk export).** OKDHS does not publish a Socrata, ArcGIS, or CSV/PDF roster of inspection results.
- Each provider page contains structured sections:
  - Program metadata (capacity, hours, Reaching-for-the-Stars rating, subsidy contract number)
  - "Monitoring Visits in the past 3 years" — list of visits with date, full/partial type, and a compliance count ("X of Y areas in compliance")
  - Links into `/licensing-history/{ID}/{DATE}` for the detailed per-visit checklist
  - "Substantiated Complaint Summary Since {DATE}" — free-text narrative of findings + corrective action plans
- Per-visit detail page renders a 35–36-item checklist with statuses **C** (Compliant), **NC** (Non-compliant), **NR** (Not Reviewed), plus ratios by age band, fire-extinguisher expiration, fire-inspection date, health-inspection date, insurance expiration, and equipment inventory date.

## Freshness

- Updated within days of each monitoring visit (OKDHS field staff enter directly to Titan backend).
- Visits are **unannounced, ≥1× annually** per OAC 340:110-3; most centers see 2–4 visits/yr.
- History window shown publicly: **last 3 years** + substantiated complaints since a fixed start date.
- Records older than 3 years available via OKDHS in-person file inspection per OAC 340:110-1 Part 14 ("Public inspection of licensing files").

## Key Fields (per monitoring visit)

| Field | Example |
|-------|---------|
| License ID | `K830025060` |
| Visit date | `2026-01-07` |
| Visit type | Full / Partial |
| Visit purpose | Monitoring / Follow-Up / Complaint |
| Ratio observed (by age) | Infant 1:4, Toddler 1:5, etc. |
| Compliance count | "35 of 35 Areas in compliance" |
| Non-compliance items | List of cited rule numbers (e.g., "340:110-3-287.1 CPR current") |
| Corrective action plan | Narrative + due date |
| Fire/Health inspection dates | Calendar dates |
| Insurance expiration | Date |
| Equipment inventory date | Date |
| Substantiated complaints | Free-text summary, redacted of PII |

## Scraping / Access Strategy

- **No anti-bot protections on `childcarefind.okdhs.org`** — HTML is server-rendered, crawlable with a polite rate limit (suggest ≤1 req/sec).
- Known entry points for enumeration:
  - `https://childcarefind.okdhs.org/` — search by ZIP / city / name
  - Internally addressable via license-ID sequence — license IDs prefix `K8300XXXXX` (6-digit tail) follow an issuance sequence; a wide-net sweep from `K830000001` upward would catch most active + historical licenses (many 404 for closed programs, which is signal).
- Alternate host `ccl.dhs.ok.gov` serves identical content and may be used if rotating hostnames.
- No JSON/API endpoint; an **HTML scrape + BeautifulSoup (or Playwright for the per-visit checklist render)** is the path.
- Licensing-history detail URL requires both license ID and a valid YYYY-MM-DD visit date; enumerate visits from the profile page first, then fetch each detail.
- **Rate-limit risk:** modest. The portal is lightly trafficked; OKDHS has not been observed to block scrapers historically. Identify the agent ("ComplianceKit research crawler; contact: {email}") and cache aggressively.

## Known Datasets / Public Records

- **No data.ok.gov dataset** for child care licensing or inspections as of 2026-04-18.
- **No HHS ACF National Inspection Dashboard** entry for OK — CCS does not publish to the ACF CCDBG federal aggregated reporting page at provider granularity.
- The closest structured public dataset is **Joshua's List** (people, not facilities), downloadable as a searchable web tool (`ccrrpublicjl.okdhs.org`) — scrapeable, but restricted use (personal / screening purpose only per OAC 340:110-1-10.1).

## FOIA / Open-Records Path

- **Oklahoma Open Records Act, 51 O.S. §§ 24A.1 et seq.** — file with OKDHS General Counsel.
- **Child-specific rule:** OAC 340:110-1 Part 14 opens **licensing files** (facility monitoring + non-compliance records) to public inspection at the Human Service Center where the facility is located. Complaint narratives are confidential per 10 O.S. § 405.3 except for de-identified summaries.
- Request mechanics:
  - OKDHS Open Records Request Form: `https://oklahoma.gov/okdhs/library/policy/current/oac-340/chapter-2/subchapter-1.html`
  - Email: `OpenRecords@okdhs.org`
  - Expect 5–10 business day turnaround for facility rosters; 30+ days for bulk inspection exports.
- Advocates have historically obtained statewide inspection CSV dumps this way (cost: clerical + copying fees).

## Sources

- OK Child Care Locator FAQ: https://childcarefind.okdhs.org/faq
- OK Child Care Locator (search): https://childcarefind.okdhs.org/
- OK Child Care Locator (alt host): https://ccl.dhs.ok.gov/
- Sample provider page: https://ccl.dhs.ok.gov/providers/K830000229
- Sample licensing-history page: https://childcarefind.okdhs.org/licensing-history/K830025060/2026-01-07
- OAC 340:110-1 Part 14 (Public inspection of licensing files): https://oklahoma.gov/okdhs/library/policy/current/oac-340/chapter-110/subchapter-1/parts-1/public-inspection-of-licensing-files.html
- Complaint FAQ: https://oklahoma.gov/okdhs/services/cc/complaintfaq.html
- Joshua's List Restricted Registry: https://ccrrpublicjl.okdhs.org/ccrrpublicjl/public/
- OAC Title 340 Restricted Registry rule (10.1): https://oklahoma.gov/okdhs/library/policy/current/oac-340/chapter-110/subchapter-1/parts-1/restricted-registry.html
- OKC-County Health Dept. (local child care inspections): https://occhd.org/childcare/
- Oklahoma Open Records Act (51 O.S. §§ 24A): https://oksenate.gov/sites/default/files/2019-12/os51.pdf
