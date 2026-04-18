# Vermont — Source URLs & Data Provenance

**Date collected:** 2026-04-18

## Regulatory sources
- https://dcf.vermont.gov/cdd — Child Development Division
- https://dcf.vermont.gov/cdd/families/find-care — Find Child Care (links BFIS)
- https://dcf.vermont.gov/cdd/providers/care/regs — Licensing Regulations index
- https://dcf.vermont.gov/cdd/laws-rules/licensing — Law & rules
- https://www.brightfutures.dcf.state.vt.us — BFIS provider & subsidy portal
- https://outside.vermont.gov/dept/DCF/Shared%20Documents/CDD/Licensing/CC-CenterBased-Regs.pdf — CBCCPP regs PDF
- https://outside.vermont.gov/dept/DCF/Policies%20Procedures%20Guidance/CDD-Guidance-CC-CBCCPP-Guidance-Manual.pdf — CBCCPP Guidance manual
- https://regulations.justia.com/states/vermont/agency-13/sub-agency-171/chapter-004/section-13-171-004/ — CVR 13-171-004
- https://www.law.cornell.edu/regulations/vermont/13-005-Code-Vt-R-13-171-005-X — CVR 13-171-005 Family
- https://www.law.cornell.edu/regulations/vermont/13-009-Code-Vt-R-13-162-009-X — CVR 13-162-009 Non-Recurring
- https://legislature.vermont.gov/statutes/section/33/035/03502 — 33 V.S.A. § 3502

## Provider list sources (leads CSV)

### Primary (attempted): Bright Futures Information System (BFIS)
- https://www.brightfutures.dcf.state.vt.us/vtcc/public.jsp
- **Limitation:** BFIS public search redirects to a session-protected process URL and requires interactive search (town, program type, age, STARS filter). No static bulk export published.

### Secondary (used): childcarecenter.us
- https://childcarecenter.us/vermont/burlington_vt_childcare (pages 1-2)
- https://childcarecenter.us/vermont/south_burlington_vt_childcare
- https://childcarecenter.us/vermont/essex_junction_vt_childcare (rendered as Essex)
- https://childcarecenter.us/vermont/montpelier_vt_childcare
- https://childcarecenter.us/vermont/rutland_vt_childcare

Format: HTML list with name + city + zip + phone. VT listings include family child care provider names (individual operators) along with center-based programs — reflects VT's heavy family-home prevalence.

## Leads CSV output
- File: `/Users/magnusfremont/Desktop/daycare/vermont_leads.csv`
- Rows: 87 providers across Burlington, South Burlington, Essex, Montpelier, Rutland
- Coverage: ~6-8% of VT's ~1,000-1,350 regulated programs. Chittenden County (the core market) densely covered; Rutland and Washington counties sampled. Other counties (Windham, Windsor, Franklin, Addison, Caledonia, Orange, Orleans, Grand Isle, Lamoille, Bennington, Essex) omitted.
- Email / website fields: blank.
- Note: Several entries marked as individual names (e.g., "Acebo Constantine, Barbara", "Batchelder, Janet", "Porter, Sheila") that appeared in the source as individual FCC operators were excluded from the final CSV as they represent individuals rather than business leads appropriate for B2B outreach.
