# Ohio — Violations / Inspections / Enforcement Research

_Updated 2026-04-18. Covers Ohio DCY / OCLQS per-facility inspection and non-compliance reports._

## Violations / Inspection Data Source
Ohio consolidates per-facility inspection data on a single public portal. Licensing transitioned from ODJFS to the Ohio Department of Children and Youth (DCY) in January 2025, but the public-facing URL has remained stable.

- **Portal:** https://childcaresearch.ohio.gov/
- **Per-facility inspection tab:** each provider record exposes a Current Inspections and Past Inspections view, e.g. https://childcaresearch.ohio.gov/inspections/407706 (pattern: `/inspections/{programId}`)
- **Provider portal (internal):** OCLQS — https://oclqs.my.site.com/ — **Salesforce Experience Cloud**, gated; not directly scrapable.
- **DCY Licensing Compliance Overview (SRNC definitions, process):** https://childrenandyouth.ohio.gov/for-providers/licensing-compliance

## Data Format
- **Public portal HTML search** with paginated results (20 per page; ~8,100 active licensed programs).
- **Inspection reports published as individual PDFs** following the URL pattern:
  ```
  https://childcaresearch.ohio.gov/pdf/{programId}_{YYYY-MM-DD}_{type}.pdf
  ```
  Example: `https://childcaresearch.ohio.gov/pdf/002240030332_2026-01-05_MONITOR.pdf`
  - `{type}` values observed: `MONITOR`, `COMPLAINT`, `INSPECTION`, `RENEWAL`, `INITIAL`
- **Bulk CSV endpoint:** `https://childcaresearch.ohio.gov/export` exists but requires the visitor to enter an email and answer a one-time-code challenge before downloading — no authentication/key needed beyond that OTC. Documented in existing SOURCES.md as the reason bulk-export wasn't used for the lead list.
- **Non-compliance severity tiers** (Ohio-specific):
  - **SRNC — Serious Risk Non-Compliance** (6 points; written parent notice required within 15 business days)
  - **MRNC — Moderate Risk Non-Compliance** (3 points)
  - **Low-risk** (1 point)
- The point value feeds the program's compliance score visible on the search portal.

## Freshness
- OCLQS → public portal sync: within 24 hours of inspection closure, per DCY documentation.
- SRNC notices to parents: required within 15 business days of agency determination.
- Per-facility PDF report URLs appear immediately after the inspection is closed in OCLQS.

## Key Fields (from the public inspection PDF)
- Program Name, License Number, Address
- Inspection Date
- Inspection Type (Monitor / Complaint / Renewal / Initial)
- Inspector Name
- Non-compliance rule citation (e.g., `OAC 5180:2-12-16(A)(3)`)
- Risk tier (SRNC / MRNC / Low)
- Description / narrative
- Point value
- Corrective Action Plan
- Due date
- Verified-corrected date
- Inspector and reviewer signatures

## Scraping / Access Strategy
### Option A — drive the `/export` endpoint (cleanest)
1. GET `https://childcaresearch.ohio.gov/export` — fills a form asking for email.
2. Submit email; receive one-time code via email.
3. POST the one-time code; receive a CSV of all currently-licensed programs. The CSV includes program ID, type, address, phone, and compliance score but **not** per-inspection rows.
4. Combine with per-inspection PDF scraping (below) to get violation-level detail.

### Option B — paginated HTML scrape (what the existing ohio_leads.csv did)
- Search with empty filters (`?county=-1`), walk all 406 pages, pull program cards.
- Follow each `/inspections/{programId}` link.
- Extract PDF links from the inspection table and batch-download them.

### Option C — target the inspection PDFs directly
- Once you have a list of `programId`s, the inspection PDFs follow the strict URL pattern above. No authentication required.
- PDFs can be OCR'd to extract rule citations, risk tier, and correction-action data.
- Rate limit to 1-2 req/sec; Ohio portal has not blocked in observed runs.

### Hot-leads query
- After pulling the OCLQS compliance score for every program (in the `/export` CSV), filter programs with:
  - Compliance score below the state median
  - An SRNC in the last 90 days (parse PDF dates)
  - Status ≠ "Active"
- These are the intent signals.

## Known Datasets / Public Records
- **childcaresearch.ohio.gov:** authoritative portal.
- **data.ohio.gov:** as of 2026-04 there is **no** dedicated child-care-violations dataset. The state has promised a public API as part of the DCY reorganization but has not published one.
- **Ohio Department of Children and Youth annual reports:** statewide aggregate only.
- **Journalism:**
  - Graham Law "How Safe is Your Child's Daycare?" (2024): https://grahamlpa.com/blog/ohio-childcare-safety-crisis/ — references a specific SRNC case.
  - Dispatch/Cleveland.com have done periodic ODJFS/DCY safety investigations using the same PDFs.
- **Sample inspection PDFs** observed at fixed URLs:
  - https://childcaresearch.ohio.gov/pdf/002240030332_2026-01-05_MONITOR.pdf
  - https://childcaresearch.ohio.gov/pdf/000000305302_2026-01-06_MONITOR.pdf
- **Historic ODJFS "Grandma's Red Saddlebag" complaint report** (2018, since deleted from ODJFS but mirrored at): https://nxstrib-com.go-vip.net/wp-content/uploads/sites/12/2018/04/grsg-inspection-report-3-26-18-1.pdf — useful format reference.

## FOIA / Open-records Path
- **Statute:** Ohio Public Records Act, ORC § 149.43.
- **DCY records:** https://childrenandyouth.ohio.gov/about-us/contact — general inbox for records requests. In practice, e-mailing the Office of Child Care Licensing with a specific program number gets inspection records within 5-10 business days.
- **Useful for:** full complaint investigation files (often redacted on the public portal), historical pre-2020 inspection reports that may have fallen off the public portal, and SRNC parent notices (which facility must keep for 1 year).

## Sources
- Ohio Child Care Search: https://childcaresearch.ohio.gov/
- Ohio DCY: https://childrenandyouth.ohio.gov/
- DCY Licensing Compliance Overview (SRNC/MRNC definitions): https://childrenandyouth.ohio.gov/for-providers/licensing-compliance
- OCLQS provider portal: https://oclqs.my.site.com/
- OAC 5180:2-12-03 (compliance inspections): https://codes.ohio.gov/ohio-administrative-code/rule-5180:2-12-03
- OAC 5180:2-12-18 (ratios): https://codes.ohio.gov/ohio-administrative-code/rule-5180:2-12-18
- ORC Chapter 5104: https://codes.ohio.gov/ohio-revised-code/chapter-5104
- Sample inspection PDF #1: https://childcaresearch.ohio.gov/pdf/002240030332_2026-01-05_MONITOR.pdf
- Sample inspection PDF #2: https://childcaresearch.ohio.gov/pdf/000000305302_2026-01-06_MONITOR.pdf
- Sample complaint inspection report (historic): https://nxstrib-com.go-vip.net/wp-content/uploads/sites/12/2018/04/grsg-inspection-report-3-26-18-1.pdf
- "Ohio Childcare Crisis" commentary (Graham Law): https://grahamlpa.com/blog/ohio-childcare-safety-crisis/
- "What to expect during a center licensing inspection": https://dam.assets.ohio.gov/image/upload/jfs.ohio.gov/ofam/What%20to%20expect%20during%20a%20center%20licensing%20inspection%20UPDATED%20082023.pdf
- Cuyahoga County Child Care Licensing context: https://hhs.cuyahogacounty.gov/programs/detail/child-care-licensing
