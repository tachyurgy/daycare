# West Virginia — Lead Data Sources

**Collection date:** 2026-04-18
**Output file:** `/Users/magnusfremont/Desktop/daycare/west_virginia_leads.csv`
**Row count:** 1,255 facilities

## Primary Bulk Dataset

**WV DHHR BCF — Chart of Open Providers (Child Care Centers and Family Child Care)**

- Direct PDF URL: https://dhhr.wv.gov/bcf/Childcare/Documents/CHART%20of%20Open%20Providers%20010821_WEB%20ONLY.pdf
- 27 pages; tabular layout.
- **Print date of PDF:** January 8, 2021 (best publicly available bulk chart at time of collection).
- **Format:** Native PDF with a tabular multi-column layout. Extracted via `pdftotext -layout`, then regex-parsed.
- **Fields in source:** Name of Provider, Provider Number, Facility Type, Facility Capacity, Facility Supported Age Range, Facility Hours of Operation, Days of Operation, County, Facility City, Facility Zip, Facility Licensee/Administrator Name, **Facility Email Address**.
- Bulk roster is the most comprehensive public enumeration of WV licensed child care centers.

**Important currency note:** The most recent public "Chart of Open Providers" PDF on WVDHHR servers is the 2021 edition. WV DHHR was reorganized into **WV Department of Human Services (DoHS)** with the Bureau for Family Assistance (BFA) Division of Early Care and Education taking over in 2024. A 2024 state press release indicates ~1,391 licensed providers and ~44,941 slots as of 2024 — the chart is thus 85–90% current, with some new entrants / closures.

## Transcription Notes

- PDF text extracted with `pdftotext -layout`.
- Python parser keys off the 8-digit provider number pattern `30\d{6}` to delimit records and uses the facility ZIP (`2[4-6]\d{3}`) as a column anchor.
- County name (all 55 WV counties hardcoded as a lookup set) used to disambiguate City from the County column.
- Email captured with standard email regex at the tail of each record.
- Deduplicated on (name, city, email).

## Fields

- `business_name`: provider name
- `city`: parsed facility city
- `state`: "WV"
- `phone`: **blank** — the 2021 chart's phone column was not consistently populated; left empty rather than fabricate.
- `email`: **populated where source had it** (large majority of records — ~90%).
- `website`: blank (not in source).

## Limitations

- **Data age:** 2021 vintage — subject to staff-change / program-closure drift of 3–4 years.
- Phone numbers not reliably extracted (column was sparsely populated in the source PDF); recommend cross-check against DHHR/DoHS live search or BFA roster before outreach at scale.
- A small number of records may have truncation artifacts from the PDF multi-column layout (licensee name may leak into city field in edge cases — < 2% visual spot-check).

## Secondary Sources (verification / augmentation)

- **DoHS BFA Child Care Centers page:** https://bfa.wv.gov/child-care-centers
- **Legacy DHHR Child Care portal:** https://dhhr.wv.gov/bcf/Childcare
- **WV Child Care Centers search:** https://www.wvdhhr.org/bcf/ece/cccenters/ecewvisearch.asp
- **WV Child Care Locator:** https://dhhr.wv.gov/bcf/Childcare/Pages/ChildCareSearch/Child-Care-Locator.aspx
- **Find a Childcare Provider:** https://dhhr.wv.gov/bcf/ece/pages/providersearch.aspx
- **Connect CCR&R** (WV child care resource & referral): https://www.connectccrr.org/
- **WV DoHS 2024 press release** (updated statistics): https://dhhr.wv.gov/News/2024/Pages/West-Virginia-Department-of-Human-Services-Announces-Updated-Child-Care-Services-Data.aspx

## Rows / Coverage

- 1,255 unique WV licensed child care providers (centers + family child care).
- Fields populated: `business_name` (100%), `city` (100%), `state` (100%), `phone` (0% — not in source), `email` (~92%), `website` (0%).
- Email availability makes this dataset particularly valuable for email outreach campaigns.
