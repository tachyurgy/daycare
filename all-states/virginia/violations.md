# Virginia — Violations, Inspection Data & Public Records Research

**Last updated:** 2026-04-18
**Agency:** Virginia Department of Education (VDOE), Division of Early Childhood Care and Education, Office of Child Care Licensing (OCCL). Licensing was transferred from VDSS to VDOE effective **July 1, 2021** (HB 2299). The public inspection tool still lives on the legacy `dss.virginia.gov` domain.

## Violations / Inspection Data Source

Virginia publishes one of the most comprehensive per-facility inspection archives in the country. Every licensed center, licensed family day home, voluntarily-registered home, religious-exempt center, and certified preschool has a **compliance history page** with every inspection since July 1, 2003.

1. **Search for Child Day Care (primary public tool, still at legacy dss.virginia.gov):** https://dss.virginia.gov/facility/search/cc2.cgi
2. **Child Care VA finder (consumer front door, feeds same data):** https://www.childcare.virginia.gov/find-care
3. **Fairfax County CCMSIS (county-level, NOVA local ordinance homes):** https://www.fairfaxcounty.gov/ofcsearch/standardsearch/childcaresearch — not in state feed.

## Data Format

| Source | Format | Bulk? |
|---|---|---|
| `cc2.cgi` facility record | HTML rendering of a CGI form with GET parameters `ID=<facility_id>`, `Inspection=<inspection_id>`, `rm=Inspection` | Not officially bulk — but URLs are enumerable and stable since ~2003 |
| Inspection report | HTML table + narrative; can be printed to PDF; **no separate PDF endpoint** | HTML scrape only |
| Child Care VA finder | JavaScript SPA that proxies to VDOE backend; JSON under the hood | No documented public API |
| VDOE enforcement letters (adverse actions) | Posted as PDFs on VDOE press / "Latest Updates" page | Press-release cadence |

## Freshness

- Inspection reports post to `cc2.cgi` typically **within 10 business days** of the inspector's close-out meeting.
- Public data covers **post-July-1-2003** only; pre-2003 compliance history must be obtained from the assigned Licensing Inspector or via FOIA to VDOE.
- Adverse-action orders (sanction, provisional license, denial) are announced on VDOE Early Childhood press updates; the cc2 page for the facility carries the revised license type.

## Key Fields in Virginia Inspection Reports

Per VDOE's risk-matrix framework (introduced 2013, modernized under 8VAC20-820 and the new 8VAC20-821 effective Feb 1, 2026):

- Inspection date and inspector name
- Inspection type: **Initial / Renewal / Monitoring (announced) / Monitoring (unannounced) / Complaint / Technical Assistance / Self-Reported Incident**
- **Standard citation**: 8VAC20-780-XXX (centers) or 8VAC20-790-XXX (family day homes)
- Plain-language description of violation
- **Risk rating**: Virginia classifies each citation on a **Risk Matrix** — typically scored as:
  - **Low** (e.g., posting, minor documentation)
  - **Medium** (training lapse, record incompleteness)
  - **High** (supervision, ratio, medication, background-check gaps)
  - **Key / Core** (risk of serious harm; listed in VDOE "key health and safety standards" roster)
- Corrective action plan text
- Corrected-by date + verifier initials
- Narrative summary of the day's observations (for complaint investigations, includes allegation text redacted for complainant identity)

## Scraping / Access Strategy

### cc2.cgi (the core target)

- Base search: `GET https://dss.virginia.gov/facility/search/cc2.cgi` (form). The form POSTs against itself; the useful state transitions travel via GET querystrings — highly scraper-friendly.
- Facility landing page: `cc2.cgi?ID=<facility_id>` — shows demographics, capacity, current license, **list of inspections** (each is a link to `cc2.cgi?ID=<facility_id>&Inspection=<inspection_id>&rm=Inspection`).
- Inspection report: `cc2.cgi?ID=<facility_id>&Inspection=<inspection_id>&rm=Inspection` returns a static HTML page with a `<table>` of citations and a narrative block.
- `facility_id` range observed: ~20000 – ~50000 (sparse); `inspection_id` range: 1 – ~140000+ as of 2026.
- Throttle: CGI is served from legacy VDSS infrastructure; **keep ≤1 req/sec with retries and back-off**. Long user-agent strings are tolerated; captcha not observed.
- Minor wrinkle: some inspection pages return mid-century character-encoding; force `cp1252` decode with Unicode normalization to avoid mojibake.

### Child Care VA finder (backup / confirmation)

- SPA at https://www.childcare.virginia.gov/find-care. Intercept its fetch calls to discover a VDOE-hosted JSON endpoint returning facility attributes. Use as a confirmation layer for `cc2.cgi` rows.

### Fairfax/NOVA local ordinance

- Fairfax operates a separate search (see CCMSIS link). Prince William, Arlington, Alexandria, and Falls Church each publish their own local-ordinance rosters and should be pulled per-jurisdiction for NOVA coverage.

## Known Datasets / Public Records

- **VDOE/ChildCare VA mapping layers** (ArcGIS Online, owner `Grace2014`) — already catalogued in `SOURCES.md`. These give the facility identifiers needed to cross-reference to `cc2.cgi` pages.
- **WTVR-TV / Richmond media** has published per-facility investigative pieces (e.g., "Fortress of God" repeated violations letter, Feb 2025) — treat as sanity check on adverse actions list: https://www.wtvr.com/news/local-news/fortress-of-god-vdoe-letter-feb-25-2025
- No statewide journalism-curated CSV of violations exists for Virginia as of April 2026. The `cc2.cgi` HTML archive is the canonical source.

## FOIA / Open-Records Path

- Statute: **Virginia Freedom of Information Act, Va. Code § 2.2-3700 et seq.** — 5 working days initial response, up to 7 additional days for extension.
- VDOE FOIA coordinator: https://www.doe.virginia.gov/about-vdoe/open-government/freedom-of-information-act
- Child Care Licensing FOIA contact: generally routed through the VDOE Office of the General Counsel.
- Reasonable bulk request: *"All inspection reports, special investigation reports, and enforcement orders for licensed child day centers, licensed family day homes, voluntarily registered family day homes, and religious exempt child day centers issued between <start> and <end>, in electronic format."*
- VDOE historically fulfills bulk licensing-history requests by directing requesters to `cc2.cgi`; structured CSV exports may require articulating statutory basis and paying nominal processing fees.

## Sources

- VDOE Early Childhood: https://www.doe.virginia.gov/teaching-learning-assessment/early-childhood-care-education
- Search for Child Day Care (cc2.cgi): https://dss.virginia.gov/facility/search/cc2.cgi
- Example facility-view URL pattern: https://dss.virginia.gov/facility/search/cc2.cgi?ID=38205&Inspection=130833&rm=Inspection
- Child Care VA (consumer finder): https://www.childcare.virginia.gov/find-care
- Finding Child Care (help page): https://www.childcare.virginia.gov/families/finding-child-care
- 8VAC20-780 (center standards): https://law.lis.virginia.gov/admincode/title8/agency20/chapter780/
- 8VAC20-820 (general procedures, enforcement): https://law.lis.virginia.gov/admincodefull/title8/agency20/chapter820/
- 8VAC20-821 (combined background checks, effective 2026-02-01): https://register.dls.virginia.gov/details.aspx?id=9691
- VDOE press / "Latest Updates": https://www.childcare.virginia.gov/providers/what-s-new
- WTVR — Fortress of God violations letter: https://www.wtvr.com/news/local-news/fortress-of-god-vdoe-letter-feb-25-2025
- Fairfax County CCMSIS local search: https://www.fairfaxcounty.gov/ofcsearch/standardsearch/childcaresearch
- Virginia FOIA law: https://www.oag.state.va.us/programs-initiatives/foia
- Assisted-Living Directory write-up on how to use cc2.cgi (documentation quality): https://www.assisted-living-directory.com/blog/look-up-virginia-facility-inspections-citations-and-violations/
