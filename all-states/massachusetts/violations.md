# Massachusetts — Violations & Inspection Data

**Date collected:** 2026-04-18

## Violations / Inspection Data Source (URLs)

- **Primary (consumer-facing):** https://childcare.mass.gov/findchildcare — EEC "Find Child Care" search. Each provider page displays license status, EEC inspection findings, corrective action plans (CAPs), and substantiated complaint summaries.
- **Provider/licensor portal:** https://childcare.mass.gov/providerlicensing — the LEAD (Licensing Education Analytic Database) front-end. Providers log in to view their own inspection history; public view is limited to the public search.
- **Bulk licensed/funded provider data (Socrata):** https://educationtocareer.data.mass.gov/Early-Education-and-Care-/Licensed-and-Funded-Child-Care-Providers/dn4d-tjbb — does NOT include per-facility inspection findings; only status, type, capacity, and refresh snapshots.
- **EEC Data, Research & Reports hub:** https://www.mass.gov/eec-reports-and-research — aggregate reports, workforce data, annual enforcement summaries.

Per EEC policy, inspection and investigation results are posted to the public findchildcare page within **90 days of case closure** and may remain visible for up to **5 years**.

## Data Format

| Channel | Format | Bulk? |
|---|---|---|
| findchildcare.mass.gov | HTML per-provider page (dynamic Salesforce Experience Cloud — `*.my.site.com`) with attached PDF reports | No — per-facility only |
| LEAD (eeclead.my.site.com) | Salesforce Lightning portal; auth-gated for providers/licensors | No bulk |
| educationtocareer.data.mass.gov (Socrata) | CSV/JSON/XML via SoDA | Yes — but facilities-only; no violations |
| Mass.gov PDF enforcement summaries | PDF (annual) | Aggregate counts |

There is **no public Socrata/ArcGIS/CSV feed of per-facility inspection findings or CAPs**. Violations data is per-facility HTML + PDF only.

## Freshness

- findchildcare: posted within 90 days of case closure; CAPs remain up to 5 years
- Socrata provider dataset: snapshotted monthly (most recent at time of writing: 2026-04-02)
- LEAD internal: real-time for logged-in users

## Key Fields Exposed Per Provider

- License number (EEC ID), legal name, program type (FCC / Small Group / Large Group / School Age)
- License status (Active, Provisional, Suspended, Revoked, Closed)
- License effective / expiration dates
- Capacity, age ranges, hours
- **Findings of non-compliance** (regulation citation, e.g., 606 CMR 7.10, and narrative description)
- **Corrective Action Plan (CAP)** — plan, due date, and resolution
- **Substantiated complaint summaries** (redacted)
- Program leadership / director name

## Scraping / Access Strategy

1. **Facility list:** Bulk-download the Socrata dataset (`dn4d-tjbb`) for the authoritative list of currently-licensed providers (EEC provider number is the primary key).
2. **Enrichment pass:** For each provider number, fetch the findchildcare detail page. The URL pattern is:
   - `https://eeclead.my.site.com/EEC_CCRRSearch/s/program-details?programId=<sfId>`
   - Salesforce Experience Cloud renders via Lightning components; HTTP GET returns a shell. Full content requires a Salesforce Aura POST (`/s/sfsites/aura?r=<n>&aura.token=...`) with action `ActionExecute` for the `ProgramDetailController.getProgram` class. Alternatively, render with a headless browser (Playwright/Puppeteer).
   - Expect Cloudflare + Salesforce bot detection; throttle to ~1 req/sec; rotate User-Agent; no IP bans observed below that threshold.
3. **PDF inspection reports** attached to detail pages are hosted at `https://eeclead.file.force.com/servlet/servlet.FileDownload?file=<contentId>` (public, no auth when linked from a public provider page).
4. **LEAD direct API:** Not publicly documented; authenticated providers/licensors see their own data.

## Known Datasets / Public Records & Journalism

- **State audit (OSA, Nov 2024):** "Early Education and Care Audit Reveals Compromised Investigations, Lack of Background Checks and Training" — https://www.mass.gov/news/early-education-and-care-audit-reveals-compromised-investigations-lack-of-background-checks-and-training. Documents systemic lapses in investigation assignment and background-check review.
- **Boston 25 News "25 Investigates" series:**
  - "Some family childcare providers operating despite red flags, records show" — https://www.boston25news.com/news/local/25-investigates-some-family-childcare-providers-operating-despite-red-flags-records-show/KRNRXXGY45BBDF7OQNNWDL3LLU/
  - "Mass. daycare providers with heroin, assault charges pass background checks" — https://www.boston25news.com/news/25-investigates/25-investigates-mass-daycare-providers-with-heroin-assault-charges-pass-background-checks/VSBRGHKPHZCRXLTTOZLYFIW5SI/
  - "Areas of risk identified in audit of state childcare agency" — https://www.boston25news.com/news/local/areas-risk-identified-audit-state-childcare-agency/IXVSA5YWJFBD7JG4H62JFIXJHQ/
  - "Many Mass. day cares failing the children they are paid to keep safe" — https://www.boston25news.com/news/many-massachusetts-day-cares-failing-the-children-they-are-paid-to-keep-safe/923571581/
- **WBUR (Feb 2024):** "Mass. reviews day care license rules after owner's drug trafficking conviction" — https://www.wbur.org/news/2024/02/28/massachusetts-day-care-vicente-desoto-cocaine
- **Boston Globe:** DCF group-home oversight reporting (Nov 2025) — https://www.bostonglobe.com/2025/11/12/metro/massachusetts-dcf-group-homes-abuse-children/ — adjacent to EEC, not direct but establishes systemic-oversight narrative valuable for GTM.

## FOIA / Public Records Path

- **How to request:** https://www.mass.gov/how-to/file-a-public-record-request-with-eec
- **Portal:** https://www.mass.gov/eec-public-record-requests (EEC Records Center)
- **Email:** eec.rao@mass.gov
- **Mail:** Robert P. Orthman, Deputy General Counsel & Records Access Officer, EEC, 50 Milk Street, 14th Floor, Boston, MA 02109
- **Fees:** First 4 hours free; up to $25/hr thereafter. Mass. "Act to Improve Public Records" (effective 2016-06-03) sets a 10-business-day response deadline with extension possible.
- **Expected usable records:** Bulk LEAD extract of violations/CAPs by provider over a date range; investigation reports; enforcement action registers. These are NOT posted as bulk dataset but are routinely released under M.G.L. c. 66, § 10 with standard redactions (child identities, staff SSN, medical).

## Sources

- https://childcare.mass.gov/findchildcare
- https://childcare.mass.gov/providerlicensing
- https://eeclead.my.site.com/EEC_CCRRSearch
- https://www.mass.gov/eec-reports-and-research
- https://www.mass.gov/eec-public-record-requests
- https://www.mass.gov/how-to/file-a-public-record-request-with-eec
- https://www.mass.gov/news/early-education-and-care-audit-reveals-compromised-investigations-lack-of-background-checks-and-training
- https://educationtocareer.data.mass.gov/Early-Education-and-Care-/Licensed-and-Funded-Child-Care-Providers/dn4d-tjbb
- https://www.boston25news.com/news/local/25-investigates-some-family-childcare-providers-operating-despite-red-flags-records-show/KRNRXXGY45BBDF7OQNNWDL3LLU/
- https://www.boston25news.com/news/25-investigates/25-investigates-mass-daycare-providers-with-heroin-assault-charges-pass-background-checks/VSBRGHKPHZCRXLTTOZLYFIW5SI/
- https://www.wbur.org/news/2024/02/28/massachusetts-day-care-vicente-desoto-cocaine
