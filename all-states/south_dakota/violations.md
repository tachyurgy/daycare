# South Dakota — Violations & Inspection Data

**Date collected:** 2026-04-18
**State rank (population):** 46

## Violations / Inspection Data Source

South Dakota publishes inspection results, compliance plans, corrective-action plans, and stipulation/consent agreements through the **OLA Constituent Portal (Office of Licensing and Accreditation)**. Records are tied to the facility-level provider profile; there is no statewide bulk export.

- Public portal (search): https://olapublic.sd.gov/child-care-provider-search/
- Example provider profile: https://olapublic.sd.gov/child-care-program-profile/80035
- DSS monitoring process (centers): https://dss.sd.gov/childcare/licensing/dccmonitoring.aspx
- DSS monitoring process (family day care): https://dss.sd.gov/childcare/licensing/fdcmonitoring.aspx
- DSS child care data hub: https://dss.sd.gov/childcare/licensing/childcaredata.aspx

## Data Format

- **Per-facility only**, accessed via the constituent portal. No Socrata feed, no ArcGIS layer, no JSON API, no bulk CSV.
- Each provider's profile page carries a "Inspection and Compliance/Corrective Action plans" section near the bottom.
- Reports are rendered as HTML tables linking to **PDF attachments** for full inspection narratives and corrective-action documents.
- The portal is an ASP.NET / JavaScript-rendered application; WebFetch returns a blank shell. Scraping requires a headless browser (Playwright/Puppeteer) or Selenium.

## Freshness

- The DSS documentation states records from **the past four (4) years** are publicly displayed on provider profiles.
- Historical records older than 4 years are removed from the public view; full history available via public-records request to DSS.
- New inspections appear on the portal within days of the licensor finalizing the visit.

## Key Fields (per inspection record)

- Provider name / license number
- Inspection type (initial, annual monitoring, unannounced, complaint)
- Inspection date
- Inspector
- Findings / cited rule (ARSD 67:42 citation)
- Corrective action plan (provider-submitted) with due date
- Stipulation / consent agreement (if applicable)
- Attached PDF(s) with inspector narrative

## Scraping / Access Strategy

1. **Provider enumeration:** the search form at `/child-care-provider-search/` filters by name/city/county/zip/type. Programmatically iterate through all ZIPs or counties to build a master provider-id list.
2. **Profile scrape:** each provider has a stable URL of the form `/child-care-program-profile/{id}`. Fetch HTML, parse the inspection table, follow PDF links.
3. **PDF extraction:** OCR / text-extract each inspection PDF for rule citations, severity classifications, correction status. Persist to a normalized table: `(provider_id, inspection_id, date, type, finding, rule_cited, corrected_by)`.
4. **Rate limits:** no documented throttling, but respectful scraping (1 req/sec, honor robots.txt) recommended to avoid IP bans from the state portal.
5. **Change detection:** poll profiles weekly; diff inspection tables; fire enrichment jobs only on new rows.

## Known Datasets / Public Records

- No third-party academic or journalistic dataset aggregates SD child care inspections. Small state (~700-750 programs) means the OLA portal itself is the definitive source.
- DSS Child Care Data page (`childcaredata.aspx`) publishes **annual aggregate statistics** (provider counts, subsidy utilization) as PDFs, not per-facility detail.
- KELOLAND has published explanatory coverage of the portal ("Parents can search SD day care complaints, inspections through DSS site") confirming public accessibility.

## FOIA / Open-Records Path

- **South Dakota has no general-purpose FOIA-style statute** equivalent to the federal FOIA. Records access is governed by **SDCL 1-27** ("Open Records" provisions), which makes government records presumptively open unless specifically exempted.
- Requests go to: **SD Department of Social Services, Office of Licensing and Accreditation**, 700 Governors Drive, Pierre, SD 57501 | Phone: (605) 773-4766.
- Practical mechanism: written request letter or DSS public-records form. Child welfare / abuse investigation records may be withheld under SDCL 26-8A-13.
- **Useful request:** "All inspection reports, corrective action plans, and enforcement actions for all licensed child care providers for the preceding 7 years, in machine-readable format (CSV/Excel) if available."

## Sources

- https://olapublic.sd.gov/child-care-provider-search/ — OLA Constituent Portal
- https://olapublic.sd.gov/child-care-program-profile/80035 — sample provider profile
- https://olaprovider.sd.gov/ — OLA Provider Portal (provider-facing)
- https://dss.sd.gov/childcare/licensing/dccmonitoring.aspx — center monitoring process
- https://dss.sd.gov/childcare/licensing/fdcmonitoring.aspx — family day care monitoring
- https://dss.sd.gov/childcare/licensing/childcaredata.aspx — DSS child care data hub (aggregate)
- https://dss.sd.gov/childprotection/licensing.aspx — Child Protection licensing page
- https://www.keloland.com/keloland-com-original/parents-can-search-sd-day-care-complaints-inspections-through-dss-site/ — KELOLAND explainer on portal
- https://sdlegislature.gov/Statutes/1-27 — SDCL 1-27 open-records statute
