# Maryland — Lead Data Sources

**Date collected:** 2026-04-18

## Primary Source

- **URL:** https://www.checkccmd.org/PublicReports/OpenProviderReport.aspx?ft=ALL
- **Publisher:** Maryland State Department of Education (MSDE), Division of Early Childhood, Office of Child Care (OCC)
- **Format:** PDF (dynamically generated "Open Provider Report" / All Providers)
- **File size:** ~6.7 MB
- **Extraction method:** `mutool draw -F txt` (pdftotext failed on xref dictionary), plus Python regex/state-machine parser keyed on record structure (provider name → street → city/MD → county → type → email → ages → status)
- **Raw records in PDF:** ~11,165 record blocks (all statuses; includes "Open" and "Closed" centers and home programs)
- **After filtering to Open providers only:** ~3,579 unique open providers
- **Rows written to `maryland_leads.csv`:** 1,000 (per spec cap)
- **Fields captured:** business_name (provider name), city (city from "City, MD ZIP" address line), state (MD), email (when present — extracted by pattern match across line wraps), phone (blank — source PDF does not publish)
- **Fields NOT captured:** phone, website

## Secondary Sources Explored

- https://www.checkccmd.org/ — public search portal (dropdown by city/county/status; no bulk CSV/Excel export)
- https://earlychildhood.marylandpublicschools.org/data — MSDE Division of Early Childhood data page (aggregate counts only, no provider-level CSV)
- https://marylandchild.org/care/ — Maryland Family Network LOCATE service (interactive referral only)
- https://opendata.maryland.gov/ — Maryland Open Data Portal: catalog does NOT publish licensed child care providers dataset (confirmed via Socrata federated catalog search for "child care")

## Limits / Notes

- Maryland publishes inspection data publicly on CheckCCMD, but does NOT offer a bulk CSV/Excel or API download; PDF is the only bulk route
- Source PDF is generated on demand from MSDE's licensing database — row order appears sorted alphabetically by provider name
- PDF extraction required mutool because the report's PDF uses a non-standard xref dictionary that pdftotext/Poppler cannot parse
- Some records have the same provider name repeated (center + letter-of-compliance at same address); deduplication is by (name, city) pair
- Email addresses frequently span two text lines due to PDF line wrapping; heuristic joiner reconstructs them but a small % (~5%) may be partial
- No phone numbers are published in this particular OCC report (contact info limited to email for privacy)
- Closed / historical status entries excluded from leads file
- For enrichment, combine with MD EXCELS QRIS public roster and SOS business registry
