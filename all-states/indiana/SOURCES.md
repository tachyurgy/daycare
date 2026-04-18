# Indiana — Lead Data Sources

**Date collected:** 2026-04-18

## Primary Source

- **URL:** https://www.in.gov/fssa/carefinder/files/Indiana_Licensed_Child_Care_Center_Listing.pdf
- **Publisher:** Indiana Family and Social Services Administration (FSSA), Office of Early Childhood and Out-of-School Learning (OECOSL) / Bureau of Child Care
- **Format:** PDF (90 pages, run date July 25, 2025 per the file header)
- **File size:** ~11.1 MB
- **Extraction method:** `pdftotext -layout` + Python column-position parser (columns: Facility Number, Facility Name, Address, City, State, Zip, County, Provider Type, PTQ Level, CCDF, Pre-K, Phone, Capacity, Ages, Hours)
- **Raw records in PDF:** ~748 unique licensed centers (center-based only; not homes)
- **Rows written to `indiana_leads.csv`:** 752 (under 1,000 cap)
- **Fields captured:** business_name (Facility Name), city (City), state (IN), phone (Phone Number)
- **Fields NOT captured:** email, website (not published in source)

## Secondary Sources Explored

- https://www.in.gov/fssa/carefinder/family-resources/forms/child-care-provider-listings/ — index page linking PDFs
- https://www.in.gov/fssa/carefinder/files/Indiana_Licensed_Child_Care_Home_Listing.pdf — homes PDF (intentionally NOT scraped: Indiana Code 12-17.2-2-1(9) prohibits publication of physical addresses for licensed homes)
- https://secure.in.gov/apps/fssa/providersearch/home/category/ch — FSSA Carefinder search portal (interactive only, no JSON/CSV feed exposed)
- https://www.in.gov/fssa/childcarefinder/ — consumer Child Care Finder
- https://hub.mph.in.gov/ — Indiana Data Hub (no licensed child care dataset published)

## Limits / Notes

- Indiana does NOT publish a CSV/Excel/JSON feed of licensed providers — only PDF listings
- Licensed child care HOMES are in a separate PDF but addresses are redacted by statute (IC 12-17.2-2-1(9)); we did not scrape those
- Registered Child Care Ministries (RCCMs) are a third category, faith-based, exempt from licensing; separate PDF exists if needed
- Column-position PDF parsing has a ~1-2% error rate where long multi-word center names or multi-word cities (e.g., "South Anthony Fort Wayne") get mis-split; names containing street direction words (e.g., "FORT") in address may leak into city field in rare cases
- All 748+ captured are center-based providers; homes (~2,500 more) could be obtained with an additional scrape respecting address redaction
- Run date of source PDF: July 25, 2025 (FSSA refreshes quarterly)
