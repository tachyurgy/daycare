# Colorado — Lead Data Sources

**Date collected:** 2026-04-18

## Primary Source

- **URL:** https://data.colorado.gov/Early-childhood/Colorado-Licensed-Child-Care-Facilities-Report/a9rr-k8mu
- **Publisher:** Colorado Department of Early Childhood (CDEC), via Colorado Information Marketplace (Socrata)
- **Format:** CSV (via Socrata Open Data API)
- **Bulk endpoint used:** `https://data.colorado.gov/resource/a9rr-k8mu.csv?$limit=5000`
- **Rows downloaded:** 4,544 unique licensed non-24-hour child care facilities statewide
- **Rows written to `colorado_leads.csv`:** 1,000 (capped per spec)
- **Refresh cadence:** twice monthly (per CDEC documentation)
- **Fields captured:** business_name (provider_name), city (city), state (CO), phone (blank — not in source), email (blank), website (blank)

## Data Columns Available in Source (for potential enrichment)

- provider_id, provider_name, provider_service_type (e.g., Child Care Center, Family Child Care Home, School-Age Child Care Center, NYO, Preschool, Infant Nursery), street_address, city, state, zip, county, ecc (Early Childhood Council), ccrr (Child Care Resource & Referral), school_district_operated_program, school_district, quality_rating (Colorado Shines level), award_date, expiration_date, total_licensed_capacity, licensed_infant/toddler/preschool/school_age_capacity, cccap_fa_status (subsidy agreement), cccap_authorization_status, governing_body, longitude, latitude

## Secondary Sources Explored

- https://www.coloradoshines.com/search — consumer Colorado Shines QRIS portal (interactive only)
- https://cdec.colorado.gov/for-families/find-child-care — CDEC find-care landing
- https://cdec.colorado.gov/resources/reports-and-data — CDEC reports & data hub
- https://data-cdphe.opendata.arcgis.com/datasets/ba8161673d734074a081006adc7ea496 — CDPHE ArcGIS layer (geo view)
- https://data.colorado.gov/stories/s/Colorado-Licensed-Child-Care-Facilities-County-Das/ukut-mhzu — county dashboard (reads same dataset)

## Limits / Notes

- Colorado is one of the cleanest states for bulk provider data — a single Socrata dataset covers all ~4,500 licensed facilities statewide, updated twice monthly
- The source does NOT publish phone numbers, email addresses, or websites — only the business name, physical address, capacity, quality rating, and subsidy agreement status
- For contact enrichment, combine with Colorado Secretary of State business registry or commercial B2B databases
- Colorado Child Care Facility Search (inspection reports) is a separate portal at https://reports.coloradoshines.com/ — provides inspection history per provider
- 2022 agency transition: licensing moved from CDHS to CDEC; dataset continuity preserved under CDEC ownership at same Socrata resource ID
- Provider types represented: Child Care Center (~40%), Family Child Care Home (~35%), School-Age Care (~15%), other (Experiential/NYO, Camps, Preschool nursery ~10%)
