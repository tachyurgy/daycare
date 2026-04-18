# North Dakota — Violations & Inspection Data

**Date collected:** 2026-04-18
**State rank (population):** 47

## Violations / Inspection Data Source

North Dakota publishes monitoring results and correction orders through the **DHHS Early Childhood Services online child care search tool** (part of the Child Care Licensing (CCL) System that went live in 2023 to replace the prior paper process).

- DHHS Child Care Licensing: https://www.hhs.nd.gov/cfs/early-childhood-services/child-care-licensing
- CCL System (launch announcement): https://www.hhs.nd.gov/news/nd-health-and-human-services-launches-new-online-child-care-licensing-system
- Public provider search (linked from DHHS CCL page)
- Governing statute for correction orders: NDCC Chapter 50-11.1 and NDAC Chapter 75-03

## Data Format

- **Per-facility only** — each provider's page displays monitoring visit results and any correction orders. No aggregate bulk export has been published by DHHS.
- HTML + PDF: the licensing report renders in the CCL search UI; full correction orders and monitoring reports are linked PDFs.
- No known Socrata, ArcGIS, or JSON API endpoint. The CCL System is a custom web application (JavaScript-rendered client).

## Freshness

- DHHS publicly displays records from the **preceding 3 years**. Older records remain in state custody but are not surfaced via the public tool.
- Correction orders take effect on the date of receipt by the provider; corresponding public posting follows DHHS internal processing (typically days to a few weeks).
- The CCL System is live / in production as of 2024; expect ongoing schema changes in 2026.

## Key Fields (per monitoring event)

- Provider name, address, license number
- License type (Family / Group / Center / Self-Declared / School-Age / Pre-School)
- Monitoring visit date
- Visit type (announced / unannounced / complaint / initial)
- Findings (cited NDAC section, e.g., 75-03-10-08)
- Correction order issued? (yes / no)
- Correction deadline
- Status (corrected / outstanding / referred for enforcement)
- PDF attachment of full report

## Scraping / Access Strategy

1. **Provider enumeration:** iterate the CCL System search tool by license type and by county. ND has 53 counties — low-cardinality sweep.
2. **Profile fetch:** each provider has a license-number-keyed detail page. Use Playwright / headless Chrome since the CCL app relies on client-side JS.
3. **PDF parsing:** text-extract correction order PDFs → normalize to `(provider, date, citation, deadline, resolution)`.
4. **Alternate path:** for high-confidence bulk need, file an **open-records request** (below) for the underlying licensing dataset — faster and more complete than scraping.
5. **Rate-limit:** respect state portal; 1-2 req/sec max. No stated terms; stay polite.

## Known Datasets / Public Records

- **ACF Licensing Regulations Database** (federal) publishes ND's regulatory text but not facility-level inspection records.
- Prior to the 2023 CCL System rollout, monitoring data was kept in a paper / internal-database system and was not public-facing. There is no known third-party aggregator (academic, journalistic) publishing ND child care inspection data today.
- **Child Care Aware of North Dakota** (ndchildcare.org) publishes provider training resources but not compliance records.
- Legislative Council study `27.9080.01000.pdf` is the 2020 study of ND child care licensing — contextual, not record-level.

## FOIA / Open-Records Path

- ND's open-records law is **NDCC Chapter 44-04** (Open Meetings and Records). The presumption is public access unless explicitly exempted.
- Requests go to: **ND DHHS, Early Childhood Services — Early Childhood Licensing Unit**, 600 E. Boulevard Avenue, Dept. 325, Bismarck, ND 58505-0250 | (701) 328-3541 | toll-free 800-472-2622.
- State form: DHHS open-records request (also acceptable via written letter / email).
- **Useful request:** "Full extract of all monitoring visit records, correction orders, and enforcement actions for all licensed and self-declared early childhood providers for the preceding 7 years, in CSV or database export format. Please identify fields and schema."
- Child abuse / CPS investigation records are exempt (NDCC 50-25.1-11) — the monitoring / correction dataset requested should not overlap with those exempt records.

## Sources

- https://www.hhs.nd.gov/cfs/early-childhood-services/child-care-licensing — DHHS Early Childhood Licensing
- https://www.hhs.nd.gov/cfs/early-childhood-services/providers/child-care-licensing-system — CCL System (provider portal)
- https://www.hhs.nd.gov/news/nd-health-and-human-services-launches-new-online-child-care-licensing-system — 2023 system launch
- https://cavaliercountyhealth.com/child-care-licensing-system — local-agency mirror describing the system
- https://ndlegis.gov/prod/acdata/html/75-03.html — NDAC 75-03 index
- https://ndlegis.gov/cencode/t44c04.pdf — NDCC 44-04 (open records)
- https://licensingregulations.acf.hhs.gov/licensing/contact/north-dakota-department-health-human-services-early-childhood-services — ACF contact
- https://ndlegis.gov/sites/default/files/resource/committee-memorandum/27.9080.01000.pdf — Legislative Council study on ND licensing
