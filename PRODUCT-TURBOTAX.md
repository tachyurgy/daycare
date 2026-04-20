# ComplianceKit — The TurboTax of Daycare Compliance

**Status:** product vision doc. Single source of truth for what we're actually building.
**Owner:** Magnus · **Updated:** 2026-04-20

---

## 1. The Product Promise

**Problem:** A daycare owner in Fresno or Fort Worth or Fort Lauderdale has a 300-page state handbook, a file cabinet of paper, two expired CPR cards she didn't know about, and an inspector coming in 37 days. She is terrified. She uses spreadsheets and a wall calendar. If she fails inspection, she can lose her license and her business.

**Solution:** One app that does for daycare compliance what TurboTax does for taxes. She never reads the handbook. She never touches a form number. She answers plain-English questions. The app handles her state.

**The one-liner:** *"Be inspection-ready every single day."*

**What TurboTax actually gets right (and we copy 1:1):**
1. **You never see the actual forms.** TurboTax hides the 1040. We hide Title 22 / Chapter 746 / 65C-22.
2. **You answer facts about your life, not tax questions.** We ask: "Do you serve infants? Do you transport kids? Did you hire anyone this month?"
3. **One big number on the home screen.** TurboTax: refund meter. Us: **Compliance Score (0–100)** and **days-until-inspection-window-opens**.
4. **The app picks the state automatically.** You don't configure CA vs. TX. You tell us your zip code on day one. Done.
5. **"Check my return" before you file.** We have a self-inspection simulator that runs your state's actual inspector checklist against your data.
6. **E-file / print-and-mail.** Inspection day: one button → the exact document pack the inspector will ask for, in the order they will ask.

**What this document is:** the universal product shell, the state-cartridge pattern, and the cartridge filled out for **all 50 states**.

---

## 2. The Universal Shell — 6 Screens, Same Everywhere

Every user in every state sees these six screens. The state only changes the *content* inside them, never the *structure*.

### Screen 1 — "Tell us about your program" (90-second interview)

The ONLY screen the user sees on day one. Never more than one question on screen at a time. Progress bar at the top.

Universal questions (asked in every state):
1. **Zip code.** (Determines state + county + any local licensing agency overlay.)
2. **Facility type.** "Is this a center, a home-based program, or a school-age program?" (Our branching is state-cartridge-driven — see §3.)
3. **Licensed capacity.** One number.
4. **Age groups served.** Checkboxes: Infant (0–12mo), Toddler (12–24mo), Twos, Preschool (3–5), School-age (5+). State cartridge picks the exact age bands.
5. **Services.** Checkboxes: Serve meals? Serve infant formula? Transport? Outdoor playground? Swimming/water? Field trips? Overnight?
6. **Staff count.** "How many adults work with children, including you?"
7. **Program status.** "Brand new and applying" / "Currently licensed" / "Under corrective action".
8. **Special programs.** Subsidy (CCDF/CCDBG)? QRIS/quality rated? Head Start? Faith-based? School-age only?
9. **License number, if you have one.** (We use this to auto-pull public inspection history where the state makes it available — CARES for FL, childcare.hhs.texas.gov for TX, CCLD Facility Search for CA.)

**Then state-specific branches fire.** Each cartridge adds 2–5 more questions (see §3).

Output of Screen 1: a **compliance plan** scoped to this program in this state.

### Screen 2 — "Here's your compliance plan"

One scrollable list, grouped into four buckets:
- **Child files** — one card per enrolled child.
- **Staff files** — one card per adult.
- **Facility** — postings, drills, checklists, ratios, playground inspection, emergency prep.
- **Operations** — handbook, plan of operation (if state-required), insurance, licensure fees.

Each card has three visual states:
- **Green** = compliant, no action.
- **Yellow** = expiring in next 30/60/90 days.
- **Red** = missing, expired, or failed.

Tap a card → **sub-wizard** that fixes it ("Upload immunization", "Record drill", "Sign parental consent", "Print new posting").

### Screen 3 — "The Score"

The home screen every day after onboarding.

- **Giant circle: Compliance Score 0–100.** Weighted by state violation classifications (CA Type A, TX deficiency weights High→Low, FL Class 1/2/3).
- **Countdown:** "Next routine inspection window opens in 47 days."
- **Traffic-light domain breakdown:** Child Files · Staff Files · Facility · Operations · Postings · Drills.
- **One CTA:** "Today's 3 things" — the three actions that raise the score the most.

No other chrome. No tabs. No menu. Just: score, countdown, three things.

### Screen 4 — "Today's 3 things"

Ruthlessly prioritized. Example for a TX center:
1. "Sign in 4 kids who arrived without a signature on Form 2941. Tap to fix."
2. "Sarah's CPR expires in 17 days. Book her into the Saturday class — $45. Tap to pay."
3. "You haven't logged a fire drill this month (required monthly). Tap to log one right now."

Everything else is hidden behind "See all items (47)".

### Screen 5 — "Self-Inspection Simulator"

A button on the home screen: **"Run a mock inspection"**.

Walks the user through their state's actual inspector checklist, in the inspector's order, using the inspector's words. Not our words. The state's.
- CA: the 9-domain CARE Tools framework.
- TX: the Form 7259/7260/7261 records-evaluation triad + Form 1100 daily walk.
- FL: the 32-category CF-FSP 5316 Standards Classification Summary.

The sim tells her: "If the LPA walked in today, you'd have 6 deficiencies. Here's each one, with the Title 22 citation and how to fix it in the next 72 hours."

This is the **killer feature**. Nobody else does this.

### Screen 6 — "Inspector Is Here" (the Panic Button)

Big red button on the home screen: **"Inspector is at my door."**

One tap:
1. Full screen collapses to a tablet-friendly **live checklist** in the state's inspector order.
2. Generates and queues to the printer the exact document pack that inspector will ask for (staff files, child files, drill logs, checklists, postings, insurance cert, fire/health clearances).
3. Starts a stopwatch + silent note-capture so the owner can log who the inspector was, what they asked, what they cited.
4. Records everything to the LIC 9213 / CF-FSP 5025 / equivalent state visit-log form — our copy of the official visit record.

That is the moment the product becomes irreplaceable.

---

## 3. The State Cartridge — What Makes a State "Work"

Every state is a pluggable config. Engineering builds the shell once, then fills one cartridge per state. Each cartridge has the same 10 fields:

```yaml
state_code: CA
regulator:
  name: "CDSS Community Care Licensing Div."
  url: "..."
  inspector_title: "Licensing Program Analyst (LPA)"
  local_overlays: ["San Francisco", "Berkeley"]   # county/city rules that stack

statute_and_code:
  statute: "CA Health & Safety § 1596.70 et seq."
  admin_code: "22 CCR Div. 12 (Title 22)"
  handbook_or_field_ref: "CARE Tools framework"

facility_types:
  - code: CCC
    label: "Child Care Center (13+ kids)"
    chapter: "Title 22 Div. 12 Ch. 1 & 2"
  - code: FCCH-S
    label: "Small Family Child Care Home (up to 8)"
  - code: FCCH-L
    label: "Large Family Child Care Home (up to 14)"
  # etc

onboarding_branches:        # extra questions Screen 1 adds for this state
  - "Do you operate an Infant Center (0–2)?"
  - "Do you have a Toddler Component (18mo–3yr)?"

ratios:                      # the app's ratio engine enforces these at roster-entry time
  infant_0_2: "1:4"
  toddler_preschool_2_6: "1:12"
  school_age_6_14: "1:15"

records_checklist:
  child: [LIC 700, LIC 701, LIC 702, immunizations, TB, LIC 9227 (if infant)]
  staff: [LIC 508, Live Scan, CACI, CPR/First Aid, mandated reporter, permit docs]
  facility: [fire clearance, health clearance, Title 22 handbook, disaster plan]

wall_posting_pack:           # one-click PDF bundle auto-generated on day 1
  - "LIC 9213 Notice of Site Visit (after first visit)"
  - "License certificate"
  - "Earthquake/fire/disaster plan"
  - "Daily menu (if meals served)"
  - "Staff list + qualifications"
  - "Parent rights / LIC 613A"

inspection_cadence:
  routine: "Minimum once every 3 years (HSC § 1597.09), risk-based escalation"
  renewal: "Biennial"
  complaint: "Unannounced; 10 business days routine response"

top_violation_nags:          # the 3 highest-signal push/email nudges for this state
  - trigger: "ratio_math_breach"
    copy: "Heads up — your 3pm nap-transition ratio just went 1:14 with Ana on break. Title 22 cap is 1:12. Tap to fix."
  - trigger: "live_scan_rolling"
    copy: "Maria was hired 6 days ago. Live Scan must clear BEFORE client contact. Pull her from ratio until Live Scan clears."
  - trigger: "infant_sleeping_plan_missing"
    copy: "You just added a 4-month-old. LIC 9227 Individual Infant Sleeping Plan is required before day one. Tap to fill it (takes 90 seconds)."

inspection_day_pack:         # exact document pack the panic button generates
  - "License certificate"
  - "LIC 311A Records to Maintain checklist (pre-filled)"
  - "LIC 9213 Notice of Site Visit (blank, ready for LPA signature)"
  - "Current staff roster + permit status"
  - "Current child roster + emergency info (LIC 700s)"
  - "Last 90 days of attendance"
  - "Last 90 days of incident reports"
  - "Fire + health clearance certs"
  - "Disaster/earthquake plan"
  - "Last 12 months of drill logs"

quirks:
  - "21 Regional Offices — inspector style varies by region. We geolocate and show regional FAQ."
  - "San Francisco + Berkeley stack municipal rules on top of Title 22 — cartridge adds local overlay."
  - "Title 22 CARE framework = 9 inspection domains. Self-inspection sim mirrors them 1:1."
```

**That's the whole pattern.** Shell is universal; cartridges are the 50 files plugged in.

---

## 4. Tier-1 ICP State Cartridges (Deep)

These three states are ~80,000 licensed facilities combined and our initial GTM focus. Full narrative cartridges below.

### California

**Regulator:** CDSS Community Care Licensing Div. (CCLD), 21 Regional Offices · **Inspector title:** Licensing Program Analyst (LPA) · **Statute:** CA H&SC § 1596.70 et seq. · **Admin Code:** 22 CCR Div. 12 (Title 22) · **Public inspection portal:** https://www.ccld.dss.ca.gov/carefacilitysearch/ (April 2015–present)
**Facility types:** Child Care Center (CCC) · Infant Center · Toddler Component · School-Age Center · Small FCCH (≤8) · Large FCCH (≤14)
**Ratios:** Infant 1:4 · Toddler/Preschool 1:12 · School-Age 1:15
**Inspection cadence:** Minimum once every 3 years (HSC § 1597.09); risk-based escalation; complaint visits always unannounced.
**Renewal:** Biennial (2-year cycle).

**State-specific onboarding questions (on top of the universal interview):**
- Do you operate an Infant Center (0–24 months)? *(Triggers the LIC 9227 infant sleeping plan + quarterly infant needs/services plan sub-module.)*
- Do you have a Toddler Component (18 months–3 years)? *(Adds Title 22 toddler sub-ratios.)*
- Is your facility in San Francisco or Berkeley? *(Adds municipal health + business-license overlay on top of Title 22.)*
- Are you a Trustline-registered in-home caregiver receiving subsidy? *(License-exempt flow — different product path.)*
- Which Child Development Permit does your director hold? *(Pulls the CTC Permit Matrix to validate qualifications.)*

**Day-1 auto-generated forms (pre-filled from the interview):**
- **LIC 700** — Identification & Emergency Information — one per enrolled child, parent-portal-link prefilled with center name, director, address, phone.
- **LIC 701** — Physician's Report — one per child, sent as a parent-portal task the app emails to the pediatrician.
- **LIC 702** — Emergency Medical Consent — one per child, e-signable by parent.
- **LIC 9227** — Individual Infant Sleeping Plan — auto-generated for every child under 12 months.
- **LIC 508** — Criminal Record Statement + Live Scan request packet for every staff member on the roster.
- **LIC 9221** — Parent medication consent — generated when a family uploads a prescription.

**Wall-posting auto-print pack (one PDF, ships day 1):**
- License certificate (user uploads, we reformat to 8.5×11 poster).
- LIC 9213 Notice of Site Visit (blank, posted after every inspection).
- LIC 613A — Personal Rights form in English + Spanish.
- Daily menu (if meals served) — week-at-a-glance template.
- Staff list with permit levels (auto-generated from roster).
- Disaster/earthquake plan + evacuation map (user uploads floor plan, we drop symbols).
- Child abuse reporting poster (CA mandated reporter).

**Top 3 inspection-killer nags (push/email copy the app actually sends):**
1. **"Ratio breach at 3:12 PM. Ana clocked out for break; toddler room now 1:14 (Title 22 cap is 1:12). Pull Maria from the 2s or end the break. Tap for one-tap fix."**
2. **"Marcus started 6 days ago. Live Scan must clear *before* client contact (HSC § 1596.871). Remove him from the room until DOJ + FBI clear. We'll alert you the minute results hit."**
3. **"You added Baby Rosa (4 months) yesterday. LIC 9227 Individual Infant Sleeping Plan is required before day one. 90-second wizard — tap now."**

**Inspection-day one-tap pack (in LPA walk-through order):**
- License certificate.
- LIC 311A Records to Maintain checklist, pre-filled.
- Current staff roster with Child Development Permit level, Live Scan date, CACI date, CPR/First Aid expiry, TB clearance, mandated-reporter cert.
- Current child roster with LIC 700/701/702 status + immunization matrix.
- Last 12 months of LIC 9213 visit notices (prior inspections).
- Last 90 days attendance + sign-in/out.
- Last 90 days incident/injury reports.
- Disaster/earthquake plan + last 12 months of drill logs (quarterly drills).
- Fire clearance + health clearance certificates.
- LIC 421 civil penalty history (if any) + all closed CAPs.

**State quirks (what breaks a generic product):**
- **CARE Tools = 9 inspection domains.** Our self-inspection simulator mirrors all 9; no generic checklist will map.
- **21 Regional Offices.** Inspector style + wait times vary dramatically (Bay Area ≠ Inland Empire). We geolocate the user's LPA region and show regional FAQs + avg. response times.
- **SF + Berkeley municipal overlays** stack on top of Title 22 (SF DPH inspection, business license). Cartridge activates local sub-checklist when zip is in SF County or Berkeley.
- **CTC Child Development Permit Matrix** maps every staff role to a permit level. We validate quals directly against the matrix at hire.
- **LIC 421 civil penalties** can hit before a citation is resolved and must be posted at the facility. Our app detects a posted penalty and auto-generates the facility-posting PDF.
- **CCLD Transparency Website** exposes every prior deficiency publicly. We show the owner her own public record and score her against state averages.

---

### Texas

**Regulator:** HHSC Child Care Regulation (CCR, transferred from DFPS 2017) · **Inspector title:** CCR Inspector · **Statute:** Tex. Human Resources Code Ch. 42 · **Admin Code:** 26 TAC Chs. 744–749 (746 = centers, 747 = homes, 744 = school-age) · **Public inspection portal:** https://childcare.hhs.texas.gov/ (deficiencies posted within 14 days — the most transparent state in the country)
**Facility types:** Licensed Child-Care Center (13+) · Licensed Child-Care Home (7–12) · Registered Child-Care Home (≤6) · Listed Family Home (1–3) · School-Age Program
**Ratios (Ch. 746 centers):** 0–11mo **1:4** (group ≤10) · 12–17mo 1:5 · 18–23mo 1:9 · 2yr 1:11 · 3yr 1:15 · 4yr 1:18 · 5yr 1:22 · 6–12yr 1:26
**Inspection cadence:** Full-day routine annual + complaint unannounced + follow-ups; inspectors on tablets using HHSC CLASS system.
**Renewal:** No fixed renewal cycle — continuous monitoring + annual fees.

**State-specific onboarding questions:**
- What's your operation type — center, LCCH, RCCH, Listed Family Home, or school-age program? *(Each maps to a different chapter + form set.)*
- Do you have a current **Plan of Operation (Form 2948)**? *(TX-unique comprehensive operational doc, updated annually.)*
- Do you use the **Daily Building & Grounds Checklist (Form 1100)** today? *(24-item daily Mon–Fri — our app replaces it.)*
- How many background checks are currently "pending" on your roster? *(Ch. 745 Subchapter F is one of strictest in the US.)*
- Do you participate in **Texas Rising Star (TRS)** QRIS?

**Day-1 auto-generated forms:**
- **Form 2948** — Plan of Operation — 40-field wizard that writes the full doc; we pre-fill from interview.
- **Form 1100** — Daily Building & Grounds Checklist — digital version, one-tap daily, auto-archives.
- **Form 2935** — Admission Information — one per child, parent-portal task.
- **Form 2941** — Sign-In/Sign-Out Log — native tablet mode; replaces the paper clipboard at the door.
- **Form 7239** — Incident/Illness Report — triggered from the attendance screen.
- **Form 7263** — Emergency Practices — fill-in-the-blanks wizard.

**Wall-posting auto-print pack:**
- License certificate.
- Form 2948 Plan of Operation summary (public-facing).
- Emergency evacuation map (user uploads floor plan).
- Fire drill log summary (rolling 12 months, auto-updated).
- Menu (if meals served) — week view.
- Child abuse reporting poster (Texas Family Code).
- SIDS prevention poster (if serving infants).
- "Notice of Deficiency" area (blank, to be filled by inspector).

**Top 3 inspection-killer nags:**
1. **"Form 1100 Daily Building & Grounds Checklist not completed today. This is a High-weight deficiency if the inspector arrives — TX posts it publicly within 14 days. 60-second tap-through."**
2. **"Jessica's 24-hour pre-service training is at 8 of 24 hours. Ch. 746.1305 says 8 must be done BEFORE she works with kids; remaining 16 within 90 days. She cleared the 8 — good. Block her from unsupervised contact until all 24 are done."**
3. **"You're at 1:12 in the toddler room (18–23mo). Ch. 746.1601 cap is 1:9. Move Ethan to the 2s or pull a staffer from preschool. Tap to auto-balance."**

**Inspection-day one-tap pack (in CCR inspector order using Forms 7259/7260/7261):**
- License certificate.
- Form 2948 Plan of Operation (current version).
- **Form 7261** Center Records Evaluation — our prefilled copy.
- **Form 7259** Personnel Records Evaluation — one per staff; includes DPS + FBI + Central Registry clearance dates, 24hr pre-service, 24hr/yr in-service, CPR/First Aid, SIDS, mandated reporter.
- **Form 7260** Children's Records Evaluation — one per child.
- Last 90 days Form 1100 daily checklists.
- Last 90 days Form 2941 sign-in/sign-out.
- Last 90 days Form 7239 incident reports.
- Emergency practices (Form 7263) + last 12 months of drill logs.
- Fire marshal clearance + local health clearance.
- Public deficiency history (we pull from childcare.hhs.texas.gov and show owner her own record).

**State quirks:**
- **Deficiency weight system** (High → Medium-High → Medium → Medium-Low → Low) drives admin-penalty math. Our compliance score weights identically — the owner sees the same math HHSC uses.
- **Everything is public within 14 days.** We scrape childcare.hhs.texas.gov nightly; the owner sees her own public record in-app and how she ranks in her city.
- **Form 1100 daily grind** is the #1 operational pain. Our daily-checklist feature replaces it — signed off as compliant the moment staff tap "done".
- **Chapter 745 Subchapter F background checks** are strictest in the US. Our background-check module integrates with DPS + FBI + Central Registry and blocks hire-until-clear.
- **Listed Family Home tier** (1–3 kids) is a micro-SKU — we can sell a $19/mo Listed tier to this market.
- **API-first state:** data.texas.gov Socrata feeds (`bc5r-88dy`) give us structured history. We're the only product that turns that into a score the owner sees.

---

### Florida

**Regulator:** DCF Office of Child Care Regulation · **Inspector title:** Licensing Counselor · **Statute:** Fla. Stat. § 402.301 et seq. · **Admin Code:** F.A.C. 65C-22 (+ Child Care Facility Handbook Oct 2021, incorporated by reference) · **Public inspection portal:** https://caressearch.myflfamilies.com/PublicSearch (CARES)
**Facility types:** Licensed Child Care Facility (2+) · Family Day Care Home (≤10) · Large Family Child Care Home (≤12) · Registered FDCH · School-Age Program · VPK site
**Ratios (F.S. § 402.305(4)):** 0–12mo **1:4** · 1–<2yr 1:6 · 2–<3yr 1:11 · 3–<4yr 1:15 · 4–<5yr 1:20 · 5+ 1:25 (all ratio violations are **Class 2**)
**Inspection cadence:** **Minimum 2 unannounced inspections per year** (most aggressive in the country); family + large family homes also 2/year.
**Renewal:** Annual.

**State-specific onboarding questions:**
- Are you in Hillsborough, Broward, Palm Beach, Pinellas, or Sarasota County? *(Those 5 counties have local licensing agencies that stack extra requirements on top of DCF.)*
- Do you operate a **VPK (Voluntary Pre-K)** site in addition to licensed child care? *(Dual oversight: DCF + DOE.)*
- Has every staff member completed the **40-hour DCF Introductory Child Care Training**? *(Required within 90 days of hire.)*
- Does your director hold the **Florida Director Credential**? Do lead teachers hold the **Florida Child Care Staff Credential**?
- Are your background checks live in the **Care Provider Background Screening Clearinghouse**?

**Day-1 auto-generated forms:**
- **CF-FSP 5081** — Application for License to Operate (if new program).
- **CF-FSP 5131A** — Child Care Application for Enrollment — one per child.
- **CF-FSP 5075** — Physician's Statement — one per child, parent-portal task.
- **CF-FSP 5274** — Health & Safety Checklist — **our daily operational checklist replaces the paper version** (one-tap).
- **CF-FSP 5337** — Background Screening & Personnel File Requirements — one per staff.
- Clearinghouse roster sync — we maintain employer roster in the Clearinghouse for portability.

**Wall-posting auto-print pack:**
- License certificate.
- Ratios poster per classroom (we print the exact F.S. § 402.305(4) caps and highlight the rooms you operate).
- Emergency evacuation map.
- Daily menu (week view).
- Staff credentials list + CPR/First-Aid current.
- Child abuse reporting poster (Florida mandated reporter).
- VPK schedule + curriculum (if VPK site).
- Parent's rights + complaint contact (DCF Helpline (855) 776-2729).

**Top 3 inspection-killer nags:**
1. **"Ratio count in the 2s room: 12 children, 1 teacher. F.S. § 402.305(4) cap is 1:11 — this is a Class 2 ratio violation and Licensing Counselors count heads on-the-spot. Pull someone in NOW. Tap to auto-balance."**
2. **"Maria has been on staff 87 days without her 40-hour DCF Intro Training completed. 3 days until non-compliance. Book the next session — $XX, online. Tap to enroll."**
3. **"CF-FSP 5274 Health & Safety Checklist not completed today. FL inspectors arrive UNANNOUNCED twice a year minimum — don't leave a gap. 45-second tap-through."**

**Inspection-day one-tap pack (in CF-FSP 5316 order, 32 categories):**
- License certificate.
- CF-FSP 5316 Standards Classification Summary — our prefilled version, showing our status on all 32 categories.
- Staff roster w/ Clearinghouse status, 40-hour training, 10hr/yr in-service, FL Staff/Director Credentials, CPR/First-Aid.
- Child roster w/ CF-FSP 5131A, immunizations (DOH 680/681), CF-FSP 5075 physicals, allergy plans.
- Last 90 days CF-FSP 5274 daily health & safety checklists.
- Last 90 days incident reports + daily attendance.
- Fire marshal clearance + county health clearance.
- Emergency practices + last 12 months drill logs.
- 5-year fatality disclosure acknowledgment (FL publishes; we show the owner her exposure).
- VPK paperwork (if VPK site).

**State quirks:**
- **Child Care Facility Handbook (Oct 2021) is incorporated by reference** into 65C-22 — it is literally the law. Our self-inspection sim mirrors the Handbook table of contents 1:1.
- **CF-FSP 5316 = 32 inspection categories.** Our sim + inspection-day pack are organized identically so nothing is out-of-order.
- **Class 1 / Class 2 / Class 3** violation classes drive enforcement. Our compliance score uses the same weights.
- **Clearinghouse portability** means background checks follow the employee across employers — our app keeps the roster authoritative in the Clearinghouse on the owner's behalf.
- **40-hour DCF Intro Training** is the strictest intro-training bar of the big 3 states. Built-in countdown clock from hire date + LMS integration.
- **5-county local licensing agency overlay** (Hillsborough, Broward, Palm Beach, Pinellas, Sarasota) stacks extra requirements — cartridge activates local sub-checklist by zip.
- **Semi-annual unannounced inspections** make "continuously ready" the only viable product posture — our daily-checklist + always-on score is built for this cadence.

---

## 5. Tier-2 + Tier-3 State Cartridges (All Other 47 States)

*Cartridges below follow the same template as the ICP three but are compressed to the fields that actually differ from the shell. Ordered by 2024 population rank.*

### New York
**Regulator:** OCFS Division of Child Care Services (NYC centers dual-regulated by DOHMH) · **Statute:** 18 NYCRR Part 418 (Subparts 418-1/-2), SSL § 390 · **Public inspection portal:** https://ocfs.ny.gov/programs/childcare/looking/ (NYC: https://a816-healthpsi.nyc.gov/ChildCare/childCareList.action)
**Facility types:** DCC (13+), SDCC (3–12), GFDC (7–12), FDC (3–6), SACC
**Ratios (toughest band):** Under 6 wks 1:3/gp 6; Infant 1:4/gp 8; Toddler 1:5/gp 12; 3yo 1:7/gp 18
**Inspection cadence:** Annual unannounced + monitoring visit each license period + complaint + annual fire
**Renewal:** Up to 4 years

**State-specific onboarding questions:**
- Are you sited inside NYC (five boroughs)? If yes, we generate BOTH OCFS and DOHMH Article 47 packets.
- Is your zip code in a NYS Part 67 lead-poisoning high-risk zone?
- Do any staff work with children under 3 (triggers Shaken Baby Syndrome training gate)?

**Day-1 auto-generated forms/packs:**
- OCFS-LDSS-4699 — License/Registration Application — pre-filled from operator profile, legal entity, site address
- OCFS-6001 + OCFS-6003 + OCFS-4930 — Staff/Volunteer app, fingerprint request, SCR check — one per hired staff
- OCFS-LDSS-7002 + OCFS-5188 — Child Medical + Enrollment/Emergency record — one per child
- OCFS-LDSS-4441 — Medication Administration Record — blank daily log per room

**Wall-posting auto-print pack:**
- OCFS license/registration certificate
- Most recent OCFS inspection results (last 2 years, per public profile retention)
- Emergency evacuation plan with site floor plan
- Written discipline/behavior policy
- Mandated reporter notice (SSL § 413) + SCR hotline
- Lead-prevention parent notice (Part 67 zones only)

**Top 3 inspection-killer nags:**
1. "A staff member just clocked in whose SCR database check isn't cleared — 18 NYCRR § 418-1.15. Block them from unsupervised contact now."
2. "Classroom X is at 1:5 for infants — OCFS caps you at 1:4 / group 8. Pull a floater in or move a child."
3. "15-hour pre-service orientation is overdue for [Staff]. Working with kids before this is a Class II violation — schedule today."

**Inspection-day one-tap pack:**
- Current OCFS license/registration + capacity letter
- Staff roster with SCR + fingerprint clearance dates + Aspire IDs
- 15-hr pre-service + 30-hr biennial training logs per staff
- Child roster with OCFS-LDSS-7002 medicals + PHL § 2164 immunization records
- Attendance log (current day + prior 30 days)
- Fire drill + evacuation log (12-month)
- Incident/accident reports (12-month) with parent signatures

**State quirks:**
- NYC centers carry two regulators and two inspection histories — our file cabinet must split OCFS and DOHMH documents from day one.
- Aspire registry enrollment is mandatory for every child-care staff member — we gate hiring on it.
- OCFS Class I/II/III severity model with a fine schedule for II/III — our violation simulator scores to this rubric, not a generic one.

### Pennsylvania
**Regulator:** DHS OCDEL Bureau of Certification Services · **Statute:** 55 Pa. Code Ch. 3270 (centers), 3280 (group), 3290 (family); Human Services Code 62 P.S. §§ 901–1087 · **Public inspection portal:** https://www.compass.dhs.pa.gov/providersearch/
**Facility types:** CCC (7+), GCCH (7–12 in residence), FCCH (4–6 in residence)
**Ratios (toughest band):** Infant 1:4/gp 8; Young tod 1:5/gp 10; Older tod 1:6/gp 12; Preschool 1:10/gp 20
**Inspection cadence:** Annual renewal + unannounced monitoring + complaint + annual fire + monthly facility fire
**Renewal:** Annual (12 months)

**State-specific onboarding questions:**
- List every household member 14+ (all require CY 113 + SP4-164 + FBI under Act 153).
- Which ELRC region (1–19) are you in? We route subsidy/STARS paperwork to the right regional hub.
- Are you in a PA radon-risk zone? (triggers 3-year testing artifact on the license.)

**Day-1 auto-generated forms/packs:**
- CD 92 — Application for Certificate of Compliance — pre-filled from operator + site
- CY 113 + SP4-164 + FBI Cogent packet — per staff, per volunteer, per household 14+
- CD 94 + CD 95 — Staff application/orientation + medical/TB — one per staff
- CD 51 + CD 54 — Child Enrollment/Health + Emergency Contact — one per child

**Wall-posting auto-print pack:**
- Certificate of Compliance + Certificate of Occupancy + Fire Marshal Certificate
- 55 Pa. Code § 3270.133 mandated-reporter poster (Act 31)
- Most recent COMPASS inspection summary
- Emergency/evacuation plan + monthly fire drill record
- Most recent radon test result (if in risk zone)
- CACFP non-discrimination + parent handbook acknowledgment line

**Top 3 inspection-killer nags:**
1. "Staffer [X]'s CY 113 Child Abuse Clearance expires in 14 days — Act 153 mandates renewal every 60 months. Submit now or they stop counting in ratio."
2. "You're showing 1 staff on the roster right now. § 3270.13 requires a minimum of 2 staff on site whenever a child is present. Call backup."
3. "Act 31 mandated-reporter biennial refresh is overdue for 3 staff. This is the #1 COMPASS citation — clear it before your renewal visit."

**Inspection-day one-tap pack:**
- Current Certificate of Compliance + Keystone STARS rating
- Staff file bundle: CD 94, CD 95, CY 113, SP4-164, FBI, Act 31 training for each
- Annual 6-hr training logs + PA Key registry printouts
- Child files: CD 51, CD 54, immunizations (28 Pa. Code Ch. 23)
- Monthly fire drill log + annual fire inspection cert
- Radon test (current 3-yr cycle)
- Incident/accident log, 12-month

**State quirks:**
- Annual license renewal (tightest-in-region) — our timer runs nonstop; we auto-open renewal 90 days out.
- Act 153 extends background checks to every household member 14+ — our staff module must model "household member" as a distinct role.
- Monthly in-facility fire-drill + annual Fire Marshal cert plus a 3-year radon cycle — three separate clocks, we track each independently.

### Illinois
**Regulator:** DCFS Division of Licensing (transitioning to IDEC 2026–2027) · **Statute:** Child Care Act of 1969 (225 ILCS 10); 89 Ill. Adm. Code Part 407 (centers), 406/408 (homes) · **Public inspection portal:** https://sunshine.dcfs.illinois.gov/
**Facility types:** DCC (15+), DCH (3–8 in home), GDCH (up to 12 in home)
**Ratios (toughest band):** Infant 1:4/gp 12; Toddler 1:5/gp 15; 2yo 1:8/gp 16; Preschool 1:10/gp 20
**Inspection cadence:** Annual unannounced + 60-day post-license + monthly permit visits + complaint + monthly self fire + annual Fire Marshal
**Renewal:** 3 years

**State-specific onboarding questions:**
- Are you in Cook County / Chicago? (CPS + county health layer on top of DCFS.)
- What's your last radon test date? (3-year cycle is mandatory, result goes next to the license.)
- Are you on the ExceleRate pathway (Licensed / Bronze / Silver / Gold)? We surface the right Gateways credential gaps.

**Day-1 auto-generated forms/packs:**
- CFS 388 — Day Care Facility License Application — pre-filled
- CFS 718-A + CFS 718-D — Staff personal info + CANTS/SACWIS background check — per staff/household
- CFS 600 / CFS 410-P / CFS 600-9 — Child medical / provider medical — per child and per adult provider
- CFS 437 — Emergency Preparedness Plan — pre-filled with site layout + evacuation map

**Wall-posting auto-print pack:**
- DCFS license (in public area per Part 407)
- CFS 1050-52 Summary of Licensing Standards (parent notice)
- Radon test result (current 3-yr cycle)
- Evacuation diagram + monthly fire drill log
- Most recent Sunshine Monitoring Report
- Mandated reporter / DCFS hotline notice

**Top 3 inspection-killer nags:**
1. "Your Sunshine Monitoring Report hit an 'ENR' code last visit — you're one violation from a referral for revocation. Tap to view the open citations."
2. "No tummy time logged today for infant room A — Part 407 requires daily tummy time for non-walking infants. Log in 30 seconds."
3. "CANTS clearance on [Staff] was not re-checked in the last 3 years — DCFS 383 non-compliance. Re-submit CFS 718-D now."

**Inspection-day one-tap pack:**
- DCFS license + capacity letter + most recent Monitoring Report
- Staff files: CFS 718-A, CANTS, ISP fingerprint, FBI, SOR, 15-hr annual training, CPR/FA
- Child files: CFS 600 + 77 IAC 665 immunizations + lead screening (<6 yo)
- Daily attendance + emergency plan (CFS 437)
- Monthly fire drill log + Fire Marshal cert + radon test
- Mandated reporter training rosters (3-year cycle)

**State quirks:**
- Illinois has the only state-run public violations portal (DCFS Sunshine) with real codes — CAN/COR/ENR/MON/NFA — we display live Sunshine severity codes against each citation.
- Radon testing every 3 years with the result posted alongside the license — unique compliance artifact.
- Licensing function is mid-transfer to IDEC (2026–2027) — the app must handle a dual-agency letterhead transition without breaking renewal workflows.

### Ohio
**Regulator:** Ohio Department of Children and Youth (DCY), Bureau of Child Care Licensing · **Statute:** ORC Ch. 5104 (§ 5104.033 ratios); OAC 5180:2-12 (centers, renumbered from 5101:2-12 on 01/02/2025) · **Public inspection portal:** https://childcaresearch.ohio.gov/
**Facility types:** Licensed Child Care Center (7+), Type A Family Home (7–12), Type B Family Home (≤6)
**Ratios (toughest band):** Infant <12mo 1:5 (or 2:12) gp 12; 12–18mo 1:6/gp 12; young tod 1:7/gp 14; 3yo 1:12/gp 24
**Inspection cadence:** Annual unannounced + complaint + annual fire + annual food service
**Renewal:** No expiration — license continues while compliant; annual inspection is the de facto gate

**State-specific onboarding questions:**
- Are you a Publicly Funded Child Care (PFCC) provider? (locks in SUTQ star-rating minimums that rise by year)
- Does your building house 7+ children at any point in the day? (triggers the 2-employee-on-premises rule)
- Is your administrator Ohio-residency ≥ 5 years? (if not, FBI fingerprint required on top of BCI)

**Day-1 auto-generated forms/packs:**
- JFS 01202 / DCY CC-1202 — Application for Child Care Center License — pre-filled
- JFS 01258 + JFS 01257 — Staff Orientation + Director Qualifications — per staff, per director
- JFS 01335 + JFS 01297 + JFS 01234 — Child enrollment + medical + care plan — per child
- JFS 01305 — Incident/Injury Report — blank template + auto-fill on trigger

**Wall-posting auto-print pack:**
- DCY license + OAC 5180:2-12-18 Appendix A (ratios and group sizes)
- Most recent inspection report from childcaresearch.ohio.gov
- SRNC parent-notice template (if any SRNC cited in last 15 business days)
- Emergency transportation plan + evacuation route
- Posted staff roster with assigned classrooms
- Communicable disease / safe-sleep posters

**Top 3 inspection-killer nags:**
1. "You have an open SRNC from [date] — parents must receive written notice within 15 business days (OAC 5180:2-12-03). 3 days left. Generate notices now."
2. "Classroom B has 12 infants with 2 staff but one just stepped out — you're down to 1:11 and below OAC 5180:2-12-18 Appendix A. Re-cover the room."
3. "Annual 2-hr child abuse recognition training is overdue for [Staff] — every year, on top of the 20-hr biennial."

**Inspection-day one-tap pack:**
- DCY license + capacity + most recent inspection PDF from childcaresearch
- Posted Appendix A and current staff-to-child count per room
- Staff files: BCI/FBI, 20-hr biennial training, communicable disease, safe sleep, pediatric CPR, OPR enrollment
- Child files: JFS 01335, 01297, immunizations per ODH schedule
- Daily sign-in/out for all children
- SRNC parent-notice log (12-month)
- Fire Marshal + food service license

**State quirks:**
- **Licenses never expire** — the annual unannounced inspection is the real gate. Our renewal engine must pivot from "date-based renewal" to "inspection-driven compliance score."
- SRNC/MRNC/Low-risk point system feeds a public compliance score — we show the live score in the dashboard.
- Jan 2025 agency transfer from ODJFS → DCY with rule renumbering (5101:2-12 → 5180:2-12); our citation engine must redirect legacy cites.

### Georgia
**Regulator:** Bright from the Start / DECAL, Child Care Services · **Statute:** O.C.G.A. Title 20 Ch. 1A; Rule Chapter 591-1-1 (CCLCs), 591-1-2 (FCCLHs) · **Public inspection portal:** https://families.decal.ga.gov/ChildCare/Search
**Facility types:** Child Care Learning Center (CCLC, 7+), Family Child Care Learning Home (FCCLH, 3–6), Exempt Only
**Ratios (toughest band):** Infant 1:6/gp 12; walking 1yo 1:8/gp 16; 2yo 1:10/gp 20; 3yo 1:15/gp 30
**Inspection cadence:** Minimum one unannounced/year + complaint + annual fire + annual health (food prep) + annual re-licensure
**Renewal:** Annual (1 year)

**State-specific onboarding questions:**
- Are you a Georgia's Pre-K lottery provider? (additional monitoring + curriculum requirements)
- Are you participating in CAPS subsidy? (Quality Rated star rating determines reimbursement)
- Will you be preparing/serving food on-site? (triggers county health inspection path)

**Day-1 auto-generated forms/packs:**
- DECAL CCLC / FCCLH License Application — pre-filled from operator profile
- Staff CRC + GBI/FBI fingerprint packet (IdentoGO) — per staff
- Form 3231 + Form 3300 — Immunization Certificate + Ear/Eye/Dental — per child
- DECAL Child Enrollment + Emergency Contact — per child

**Wall-posting auto-print pack:**
- DECAL license + capacity
- Background Check Certificate
- Current menu (weekly)
- Current Emergency Preparedness / Evacuation Plan
- Most recent Compliance at a Glance dashboard screenshot
- Illness Exclusion Policy + Sanitary Practices (posted per room)
- Pesticide application 24-hr notice template

**Top 3 inspection-killer nags:**
1. "[Staff] is in an infant room during lunch but not seated within arm's length — Rule 591-1-1-.09 violation. Reposition before this becomes a citation."
2. "Your Compliance at a Glance zone has slipped to 'Support' — DECAL auto-flags 'Deficient' next. Tap to clear 2 open items."
3. "Quarterly evacuation drill not logged this quarter — required and cited on every Licensing Study. Run one today."

**Inspection-day one-tap pack:**
- DECAL license + Quality Rated star + CAPS status
- Staff files: CRC, GBI/FBI, 10-hr annual training log, GaPDS enrollment, CPR/FA, safe sleep, mandated reporter
- Child files: Form 3231, Form 3300, enrollment, medical, allergy plans
- Operation Log (current + 12-month)
- Quarterly drill logs + monthly fire drills
- Most recent Visit Reports (12-month)
- Posted menu + immunization certificates

**State quirks:**
- Rule 591-1-1-.09 requires staff **within arm's length** of under-36-month children at meals — tighter than most states' line-of-sight rule.
- DECAL publishes a parent-facing "Compliance at a Glance" zone (Compliant/Support/Deficient) in a rolling 12-month window — we mirror the zone math so owners never get surprised.
- Annual license + annual Quality Rated re-rating tied to CAPS subsidy rates creates two stacked clocks we run side by side.

### North Carolina
**Regulator:** NCDHHS Division of Child Development and Early Education (DCDEE) · **Statute:** NCGS Ch. 110 Art. 7; 10A NCAC 09 (Chapter 9 effective 11/1/2024) · **Public inspection portal:** https://ncchildcare.ncdhhs.gov/childcaresearch (and legacy https://ncchildcaresearch.dhhs.state.nc.us/Visits.asp)
**Facility types:** Licensed Child Care Center (3+ preschool or 9+ school-age), FCCH (up to 8), Religious-sponsored, Exempt
**Ratios (toughest band):** Infant 1:5/gp 10; Toddler 1:6/gp 12; 2–3yo 1:10/gp 20; 3–4yo 1:15/gp 25
**Inspection cadence:** Unannounced at any time + annual compliance visit + annual fire + annual sanitation + complaint + 3-year Star Rating reassessment
**Renewal:** 3 years (for 3-star and above); shorter for 1–2 star / provisional

**State-specific onboarding questions:**
- What Star Rating do you hold today (1–5)? (Enhanced Ratios per 10A NCAC 09 .2818 apply to 4/5-star.)
- Do you serve 6+ children? (triggers mandatory Child Care Health Consultant contract)
- Any staff on the NC Responsible Individuals List? (RIL check is a separate gate from the CBC)

**Day-1 auto-generated forms/packs:**
- DCDEE Child Care Facility License Application (eLicensing) — pre-filled
- DCDEE-0281 + NCABCMS CBC submission — per staff
- DCDEE Emergency Information Form + Child Care Medical Action Plan — per child
- DCDEE-3111 Workforce Education Information — per staff

**Wall-posting auto-print pack:**
- Star-Rated License (showing star count)
- Most recent Visits.asp summary
- Emergency Preparedness and Response Plan
- CCHC contact + last onsite review
- Fire inspection + sanitation inspection certificates
- Child abuse / Responsible Individuals List reporting notice

**Top 3 inspection-killer nags:**
1. "Your enhanced-ratio floor for a 4-star license is tighter than base — 10A NCAC 09 .2818. Classroom C is at the base ratio, not the enhanced. Re-cover before visit."
2. "ITS-SIDS annual refresh is overdue for [Staff] in infant room — every NC inspector reads this first. Tap to schedule."
3. "Your CCHC hasn't done an onsite visit in 6 months — required for 6+ child centers. Email auto-drafted to consultant."

**Inspection-day one-tap pack:**
- Star-Rated License + capacity
- Visits.asp history printout (last 12 months)
- Staff files: CBC + RIL + SOR + EEC tier + annual training + ITS-SIDS + abusive head trauma + pediatric CPR/FA
- Child files: enrollment, immunizations, medical action plan
- CCHC review log
- Emergency plan + monthly fire drills
- ERS documentation (for star-rated visits)

**State quirks:**
- **The star rating IS the license** — 1–5 stars on the license certificate itself. Our renewal flow treats the ERS/Education Points re-rating as a license event.
- Mandatory Child Care Health Consultant (RN/RD/MD) contract for 6+ child centers — we track the CCHC contract as a compliance artifact.
- Public inspection data lives on legacy Classic ASP (Visits.asp) with no CSV export — we pre-pull and archive each visit PDF into the owner's file cabinet so they never lose history.

### Michigan
**Regulator:** MiLEAP Child Care Licensing Bureau (CCLB, moved from LARA/BCHS 12/2023) · **Statute:** 1973 PA 116, MCL 722.111–722.128; Mich. Admin. Code R 400.8101–8840 (2025 rewrite eff. May 2025) · **Public inspection portal:** https://cclb.my.site.com/micchirp/s/statewide-facility-search
**Facility types:** Child Care Center (CCC), Family Home 1–6 (DF), Group Home 7–12 (DG), Before/After School
**Ratios (toughest band):** Infant (birth–30mo) 1:4/gp 12; Toddler (30–36mo) 1:8/gp 16; Preschool 3–4 1:10/gp 30
**Inspection cadence:** Annual licensing inspection (largely unannounced) + complaints + renewal + random monitoring + annual fire/env
**Renewal:** 2 years (regular); 6 months non-renewable provisional

**State-specific onboarding questions:**
- Are you already in CCHIRP with a Salesforce record ID? (determines migration vs new enrollment)
- Great Start to Quality rating tier (Participating / Empowered / Accredited)?
- Do you offer overnight care? (requires BCAL-15-895 planning form + rest-period plan)

**Day-1 auto-generated forms/packs:**
- BCAL-4616 — Child Care Application (initial license) — pre-filled
- BCAL-3730 — Child Information Record — per child
- BCAL-4584 — Minimum Immunization Record (with MCIR cross-check) — per child
- BCAL-1326 + BCAL-3300 + BCAL-1248 — Medication auth, Incident/Accident, Serious Incident — blank templates on standby

**Wall-posting auto-print pack:**
- MiLEAP CCLB license
- Great Start to Quality star-rating certificate
- Written safe-sleep policy signed by parents (R 400.8305)
- Emergency evacuation plan
- Most recent Licensing Study Report (BCAL-5245)
- Mandated-reporter notice (Michigan Child Protection Law)

**Top 3 inspection-killer nags:**
1. "Serious incident logged 18 hours ago — BCAL-1248 must be filed with CCLB within 24 hours. Tap to file now."
2. "Infant Room A has 12 infants and only 2 caregivers on shift — R 400.8182 caps infant (birth–30mo) at 1:4. You need a 3rd caregiver."
3. "[Staff]'s 16 annual PD hours (R 400.8142) are at 9 with 90 days left in cycle. Schedule 7 hrs of approved training today."

**Inspection-day one-tap pack:**
- MiLEAP license + capacity + GSQ star rating
- Staff files: CCHIRP BG check, MERIT profile (if applicable), 16-hr PD, pediatric CPR/FA, SIDS, shaken baby, mandated reporter
- Child files: BCAL-3730 + BCAL-4584 (or MCIR) + health appraisal
- Safe-sleep policy with parent signatures
- Serious-incident log (BCAL-1248 copies)
- Daily attendance + monthly fire drills
- Corrective Action Plans from last Licensing Study

**State quirks:**
- CCHIRP is a Salesforce Experience Cloud — all licensing transactions flow through it. Our integration must mirror Salesforce record IDs, not state license numbers.
- The 2025 rule rewrite (R 400.8101 series effective May 2025) renumbered center rules — our citation engine has a pre-May-2025 / post-May-2025 switch.
- 24-hour serious-incident reporting on BCAL-1248 is tighter than most states' 48-hr rule — our incident timer is hard-coded to 24 hrs for MI.

### New Jersey
**Regulator:** DCF Office of Licensing (OOL) · **Statute:** N.J.S.A. 30:5B-1 et seq.; N.J.A.C. 3A:52 (centers), 3A:51 (family), 3A:54 (background) · **Public inspection portal:** https://childcareexplorer.njccis.com/portal/
**Facility types:** Licensed Child Care Center (6+), Registered Family Child Care Home (1–5), School-age program (3A:52 Subch. 8/8A)
**Ratios (toughest band):** <18mo 1:4 (12 max/room); 18mo–2.5yo 1:6 (18 max/room); 2.5–4yo 1:10/gp 20; 4yo 1:12/gp 20
**Inspection cadence:** Annual unannounced monitoring + renewal (every 3 yrs) + complaints + annual fire
**Renewal:** 3 years

**State-specific onboarding questions:**
- Are you on or adjacent to an NJDEP-listed former industrial site? (triggers 3A:52-7.11 environmental compliance: lead/radon/vapor)
- Ground-floor or basement classrooms? (radon testing required)
- Do 50%+ of enrolled children have special needs? (special-needs tighter ratios apply)

**Day-1 auto-generated forms/packs:**
- CCC-21 — Child Care Center License Application — pre-filled
- CCC-64 + CP&P 1-3 + NJCCIS registration — CARI + fingerprint + sex-offender per staff
- DCF CC-1 + DCF CC-2 — Universal Child Health Record + Immunization — per child
- CCC-108 — Inspection/Violation self-audit template for annual dry run

**Wall-posting auto-print pack:**
- DCF license
- Most recent CCC-108 inspection report (required posting)
- Information-to-Parents Statement (DCF standard)
- USDA non-discrimination poster
- Emergency exit plan + staff qualifications summary
- Manual of Requirements parent summary + SIDS/safe-sleep policy

**Top 3 inspection-killer nags:**
1. "You're at 1:5 in infant room A — N.J.A.C. 3A:52-4.3 caps infants at 1:4, max 12 per room. Pull a floater now."
2. "[Staff]'s 20-hr annual PD (DCF 2019 rule) is at 8 with 60 days left in NJCCIS reporting window. Assign training today."
3. "Field trip scheduled tomorrow with 1 staff listed — 3A:52 minimum is 2 staff on any field trip. Assign a second before confirming the bus."

**Inspection-day one-tap pack:**
- DCF license + most recent CCC-108 report
- Staff files: CARI + fingerprint + sex-offender + 20-hr PD (NJCCIS) + pediatric CPR/FA + SIDS
- Child files: DCF CC-1 + DCF CC-2 + emergency + medication plans
- Posted Information-to-Parents statement + Manual of Requirements summary
- Fire inspection + environmental (lead/radon) if applicable
- Incident/injury log 12 months

**State quirks:**
- 3-year license + 20 hr/yr PD (stricter than the 10–16 hr in neighboring states) — our PD engine defaults to NJ's 20-hr floor, not the CCDBG floor.
- 3A:52-7.11 layers NJDEP environmental review onto licensing — we pull the NJDEP Hazardous Sites overlay at onboarding.
- Family child care is **registered by county CCR&R**, not licensed by DCF — separate 3A:51 rule set; our flow branches on facility type at question 1.

### Virginia
**Regulator:** VDOE Division of Early Childhood Care and Education, OCCL (moved from VDSS 7/1/2021) · **Statute:** Va. Code § 22.1-289.010 et seq.; 8VAC20-780 (centers), 8VAC20-790 (family), 8VAC20-820 general, **8VAC20-821 effective 2026-02-01** · **Public inspection portal:** https://dss.virginia.gov/facility/search/cc2.cgi
**Facility types:** Licensed Child Day Center (13+), Licensed Family Day Home (5–12), Voluntarily Registered Home (≤4), Religiously Exempt, Local-Ordinance (NOVA)
**Ratios (toughest band):** Birth–16mo 1:4/gp 12; 16–24mo 1:5/gp 15; 2yo 1:8/gp 24; 3–school 1:10/gp 30
**Inspection cadence:** At least 1 unannounced/year + renewal + complaints + annual fire
**Renewal:** 2 years standard (provisional 6mo, conditional 1yr, 3yr for clean history)

**State-specific onboarding questions:**
- Are you in Fairfax / Arlington / Alexandria / Prince William / Falls Church? (NOVA local ordinance overrides state license for some home types)
- Is any current staff's last background check older than 5 years? (retroactive rechecks required Feb 1, 2026 under 8VAC20-821)
- Do you administer prescription medications? (triggers 100-hr VDOE MAT-Child Day trainer program or 6–8 hr admin course)

**Day-1 auto-generated forms/packs:**
- Form 032-05-0001 — License to Operate a Child Day Program — pre-filled
- Form 032-05-0029 + 032-05-0030 + OBC-SP-130-081-08 — Sworn Disclosure + Central Registry Release + fingerprint — per staff
- Form 032-05-0075 — Child's Physical Examination — per child
- Self-inspection checklist (required annually) — pre-filled for dry-run

**Wall-posting auto-print pack:**
- VDOE license (with posted expiration)
- Current Emergency Preparedness Plan (with drill log)
- Written Safe-Sleep / SUID policy
- Most recent cc2.cgi inspection summary
- Mandated-reporter notice
- VQB5 classroom assignment (if publicly funded)

**Top 3 inspection-killer nags:**
1. "Heads up: 8VAC20-821 kicks in Feb 1, 2026. Staff [X,Y,Z] have background checks older than 5 years — retroactive re-check required. Submit fingerprints this week."
2. "Child Care PASS (subsidy attendance) has 3 missed check-ins from yesterday — unlogged attendance is a Key/Core violation. Reconcile before close of business."
3. "Room 2 ratio is 1:9 for 2-year-olds — 8VAC20-780-350 caps 2yo at 1:8. Shift a staff member before the next classroom rotation."

**Inspection-day one-tap pack:**
- VDOE license + capacity + risk-matrix summary
- Staff files: 8VAC20-821 BG check (post-2/1/2026), Sworn Disclosure, 16-hr annual PD, MAT if applicable, pediatric CPR/FA, mandated reporter
- Child files: 032-05-0075 physical, immunization per § 22.1-271.2, care plans
- Daily health observation log
- Emergency plan + fire (monthly) + evac/lockdown/shelter (2 ea/yr)
- Playground annual inspection
- Serious-injury reports (within-2-business-day log)

**State quirks:**
- **8VAC20-821 effective 2026-02-01** — combined background-check rule requires retroactive re-checks for any staff whose last check is older than 5 years. Our app surfaces this as a top-priority migration task for every VA customer before February 1.
- Child Care PASS (Provider Attendance Submission System) launched 12/1/2025 for subsidy — we integrate attendance to PASS so missed check-ins don't become citations.
- Five NOVA jurisdictions (Fairfax/Arlington/Alexandria/Prince William/Falls Church) regulate some home programs by local ordinance, not state license — our rule engine branches on zip code.

### Washington
**Regulator:** DCYF Licensing Division · **Statute:** RCW 43.216; WAC 110-300 (ELP standards), WAC 110-301 (school-age) · **Public inspection portal:** https://www.findchildcarewa.org/
**Facility types:** Licensed Child Care Center (13+), Licensed Family Home Child Care (≤12), Licensed School-Age Program, Outdoor Nature-Based Program, Overnight Care
**Ratios (toughest band):** Infant (0–11mo) 1:4/gp 8 (or 1:3/gp 9); Toddler (12–29mo) 1:7/gp 14 (or 1:5/gp 15); Preschool 1:10/gp 20
**Inspection cadence:** Annual monitoring (unannounced) + re-licensing + complaint + annual fire + annual health/env
**Renewal:** 3 years (initial may be 1 yr)

**State-specific onboarding questions:**
- Building pre-1978? (lead paint compliance package)
- Below-grade classrooms? (radon + WA Dept. of Ecology vapor-intrusion review if on Hazardous Sites List)
- Outdoor Nature-Based or Overnight Care subclass? (separate Subchapter F or DCYF 15-895 planning form)

**Day-1 auto-generated forms/packs:**
- DCYF 15-955 — License/Certification Application — pre-filled
- DCYF 15-937 / 15-949 — Background Check Checklist (MERIT + Portable BG) — per staff
- DCYF 15-879 + DCYF 15-968 + DCYF 15-970 — Child Registration + Medication + Individual Care Plan — per child
- DCYF 15-966 — Health Consultant Agreement — for infant/toddler/special-care programs

**Wall-posting auto-print pack:**
- DCYF license + Early Achievers rating
- Written safe-sleep policy (WAC 110-300-0285)
- Earthquake preparedness plan + quarterly drill log
- Emergency evacuation plan + fire inspection
- Expulsion policy (WAC 110-300-0186)
- Immunization exemption notice (RCW 28A.210 — MMR/varicella medical-only)

**Top 3 inspection-killer nags:**
1. "Quarterly earthquake drill is 14 days overdue — WA is the only state that cites it, and DCYF does. Run one tomorrow."
2. "[Child]'s CIS shows personal-exemption for MMR — since 2019 SB 5841, personal/philosophical exemptions are PROHIBITED for MMR. Contact parent to submit medical exemption or vaccinate."
3. "Portable BG check for [Staff] pending — WAC 43.216.055 bars unsupervised contact until cleared. Restrict assignment now."

**Inspection-day one-tap pack:**
- DCYF license + Early Achievers
- Staff files: MERIT + STARS ID, Portable BG, 10-hr annual PD (or 30 hr first year), pediatric CPR/FA, orientation 20-hr
- Child files: DCYF 15-879, CIS (RCW 28A.210), Individual Care Plans
- Health Consultant Agreement (15-966) + log
- Earthquake drill log (quarterly) + monthly fire
- Expulsion-attempt documentation (if any dismissals)
- Serious-event reports (24-hr rule)

**State quirks:**
- WA bans personal/philosophical exemptions for MMR specifically (2019 SB 5841) while allowing religious for other vaccines — our exemption logic cannot treat "religious" as a blanket category.
- Quarterly earthquake-preparedness drills are a PNW-unique requirement layered on top of monthly fire drills.
- Outdoor Nature-Based Program (Subchapter F) is a WA-first license class — our facility-type taxonomy must include it or forms render wrong.

### Arizona
**Regulator:** ADHS Bureau of Child Care Licensing (centers); DES regulates Group Homes and Certified Family Homes · **Statute:** A.R.S. Title 36 Ch. 7.1 (§§ 36-881 to 36-897.01); 9 A.A.C. 5 (2024 rewrite, phased through Aug 2026) · **Public inspection portal:** https://azcarecheck.azdhs.gov/s/
**Facility types:** Child Care Center (ADHS, 5+), Child Care Group Home (DES, 5–10 in residence), Certified Family Child Care Home (DES, ≤4 for subsidy)
**Ratios (toughest band):** Infant <1yr 1:5 (or 2:11); 1yo 1:6 (or 2:13); 2yo 1:8; 3yo 1:13
**Inspection cadence:** Annual unannounced (ADHS centers); twice-yearly unannounced (DES group homes); complaints; annual fire & sanitation
**Renewal:** No fixed expiration for ADHS centers — annual inspection + annual update filing is the gate; DES homes renew annually

**State-specific onboarding questions:**
- ADHS-licensed center OR DES-certified home? (two totally different regulators, different forms, different ratios — this is question 1)
- Does every staff + volunteer + household member have a current AZ DPS Level I Fingerprint Clearance Card? (hard gate before any hire)
- Have you completed the 2024 rule-update training transition to 24 hrs/yr CE by August 2026? (phase-in deadline)

**Day-1 auto-generated forms/packs:**
- ADHS Child Care License Application — pre-filled via ADHS Licensing portal
- AZ DPS Level I Fingerprint Clearance Card request + DCS Central Registry request — per staff/volunteer/household
- Arizona Blue Card (School Entry Immunization) tracker — per child
- R9-5-407 Incident / Serious Injury / Death report template + Emergency and Disaster Plan (wildfire + monsoon scenarios)

**Wall-posting auto-print pack:**
- ADHS license
- Most recent AZ Care Check Statement of Deficiencies (if any)
- Posted staff roster with Level I card numbers
- Emergency and Disaster Plan (with wildfire + monsoon + active threat)
- Extreme-heat indoor temp + outdoor play heat-index chart
- Safe-sleep / SIDS policy (R9-5-509)

**Top 3 inspection-killer nags:**
1. "[Staff]'s Level I Fingerprint Clearance Card expires in 21 days. AZ has NO grace period — they're ineligible at the counter the next morning. Renew at AZ DPS this week."
2. "Outdoor heat index is 108°F — R9-5 heat-index rules require outdoor play cancellation. We've auto-drafted the schedule change; tap to apply."
3. "Annual CE hours at 15 of the new 24-hr target (rule update phase-in ends Aug 2026). You're 9 short with 4 months left in cycle."

**Inspection-day one-tap pack:**
- ADHS license + current AZ Care Check listing
- Staff files: Level I Fingerprint Clearance Card, DCS Central Registry, resume/qualifications per R9-5-401/403, 24-hr CE, pediatric CPR/FA, orientation
- Child files: Blue Card immunizations, enrollment, medication auth
- Daily staff sign-in/out per R9-5-402
- Emergency and Disaster Plan (wildfire/monsoon/heat) + monthly evac drills
- Statement of Deficiency responses + Plans of Correction (10-day deadline log)
- Square-footage worksheet (35 sq ft indoor / 75 sq ft outdoor per child, R9-5-501)

**State quirks:**
- Two different regulators for centers (ADHS) vs group/family homes (DES) — our onboarding branches at question 1. Getting the wrong regulator means wrong forms all the way down.
- Group-size cap is not a single number — it's a square-footage calculation (35 indoor / 75 outdoor per child). Our ratio calculator ingests floor plan dimensions.
- 2024 rule rewrite (9 A.A.C. 5) with 24 hr/yr CE phase-in ending **August 2026** — we countdown-clock every AZ customer's PD hours against this deadline.

### Tennessee
**Regulator:** TDHS Child Care Licensing (TDOE licenses public-school-run programs) · **Statute:** T.C.A. § 71-3-501 et seq.; Tenn. Comp. R. & Regs. 1240-04-01 (Nov 20, 2025 revision) · **Public inspection portal:** https://onedhs.tn.gov/csp?id=tn_cc_prv_maps
**Facility types:** Child Care Center (13+), Family Home (5–7), Group Home (8–12), Drop-In Center
**Ratios (toughest band):** Infant (6wk–15mo) 1:4/gp 8; Young tod (12–30mo) 1:6/gp 12; Older tod 1:7/gp 14; 3yo 1:9/gp 18
**Inspection cadence:** **Four visits/year** — 3 unannounced + 1 annual evaluation + complaints + annual fire + annual environmental
**Renewal:** Annual (1 year)

**State-specific onboarding questions:**
- Operating Chart 1, Chart 2 (mixed toddler) or Chart 3 (first/last 90 min only)? (determines which ratio chart the inspector checks)
- Subsidy / Certificate participant? (triggers CCMS electronic attendance + Report Card star rating)
- Transporting children in vehicles? (driver 21+, CDL or commercial endorsement for 10+ passengers, vehicle inspection file)

**Day-1 auto-generated forms/packs:**
- HS-2660 — Application for Child Care Agency License — pre-filled
- HS-0166 + HS-2985 — Personnel Info + Criminal BG Check — per staff
- HS-3035 + HS-3041 — Child Enrollment + TN-official Immunization Certificate — per child
- HS-3038 + HS-0222 + HS-3033 — Emergency Mgmt Plan + Serious Incident + Medication log

**Wall-posting auto-print pack:**
- TDHS license + Star-Quality Report Card
- Most recent Compliance History visit summary (posted conspicuously per rule)
- Child abuse summary (FY counts of injuries/abuse/deaths per Digital Tennessee)
- Safe-sleep policy (T.C.A. § 68-1-127) — in every infant room
- Emergency management plan + monthly fire drill + quarterly severe-weather drill log
- Mandated reporter + DCS hotline notice

**Top 3 inspection-killer nags:**
1. "Infant room hit 9 on Chart 1 — infants and toddlers have ZERO 10%-variance allowance in TN (1240-04-01-.22). Pull one child back to 8 before the next visit."
2. "High-risk violation cited 4 days ago — TDHS requires a 5-day follow-up revisit. Plan of Corrective Action must be filed by end of day tomorrow."
3. "Monthly fire drill done — but quarterly severe-weather drill is 10 days overdue (tornado season). Run and log today."

**Inspection-day one-tap pack:**
- TDHS license + current Star-Quality Report Card
- Staff files: TBI + FBI + Sex Offender + DCS Central Registry, 18-hr annual CE (TECTA), pediatric CPR/FA, safe-sleep, mandated reporter
- Child files: HS-3035, HS-3041, physical exam (30-day), medication logs
- Daily parent sign-in/out (HS-3035) + CCMS attendance (if subsidy)
- Monthly fire drill log + quarterly severe-weather drill log
- Vehicle inspection files + driver records (if applicable)
- Compliance History printout for last 12 months + all Plans of Corrective Action

**State quirks:**
- **Four inspections per year** is the tightest cadence of any state — our inspection-readiness engine has to stay at "ready" quarterly, not annually.
- Infants/toddlers get no 10%-variance tolerance that older age groups get — our ratio calculator hard-codes a zero-tolerance band for <36mo.
- TDHS publishes a fiscal-year "child abuse summary" that MUST be posted at entrance — we auto-refresh it annually from Digital Tennessee data.

### Massachusetts
**Regulator:** MA EEC · **Statute:** 606 CMR 7.00 (M.G.L. c. 15D) · **Public inspection portal:** https://childcare.mass.gov/findchildcare
**Facility types:** Family Child Care; Small Group & School Age; Large Group & School Age
**Ratios (toughest band):** Infants (birth–15 mo) 1:3, max group 7
**Inspection cadence:** Routine licensing visit every 2 years; unannounced monitoring in-between; 90-day posting window for findings
**Renewal:** 2-year license (provisional 6 mo for new programs)

**State-specific onboarding questions:**
- Building built before 1978 and serving children under 6? (triggers lead paint inspection)
- Do you transport children in a facility vehicle? (triggers written plan + driver BRC)
- Do you participate in C3 stabilization grants or take subsidy/CFCE?

**Day-1 auto-generated forms/packs:**
- EEC Application for a License — pre-filled from onboarding facility + owner data
- BRC Authorization Form — auto-generated per staff + household member 15+
- Health Care Policy (606 CMR 7.11) — template filled with facility name, director, medication admin designees
- Individual Health Care Plan (IHCP) — auto-generated per child flagged with allergy/chronic condition at enrollment

**Wall-posting auto-print pack:**
- Staff-to-child ratio card (posted visible at each group area)
- Current EEC license
- Emergency evacuation / shelter-in-place plan
- Mandated reporter poster (M.G.L. c. 119 § 51A)
- Safe Sleep ABCs poster (infant rooms)

**Top 3 inspection-killer nags:**
1. "Staff BRC expiring in 45 days — renew now. EEC requires all staff clear every 3 years."
2. "3 staff missing their 20-hour annual PD log. EEC inspectors check this every visit."
3. "Infant room ratio card not visible — post it before Monday open."

**Inspection-day one-tap pack:**
- Current license
- BRC status for all staff + household 15+
- Staff MAP / CPR / First Aid / Mandated Reporter certs
- Child immunization + lead screen records
- Health Care Policy and posted emergency plan
- Transportation plan + driver BRC (if applicable)

**State quirks:**
- Mandatory lead screen documentation at 9–12 mo and 2/3/4 years (MA DPH) — not optional.
- 2024 OSA audit flagged systemic BRC/investigation lapses; EEC has tightened verification — expect BRC documentation scrutiny to increase in 2026.

### Indiana
**Regulator:** FSSA OECOSL · **Statute:** 470 IAC 3-4.7 (centers), 3-1.1 (homes); IC 12-17.2 · **Public inspection portal:** https://secure.in.gov/apps/fssa/providersearch/home/category/ch
**Facility types:** Licensed Child Care Center; Class I Home (≤12); Class II Home (13–16); Registered Child Care Ministry
**Ratios (toughest band):** Infant (<16 mo) 1:4, max group 8
**Inspection cadence:** ≥1 unannounced annual monitoring (federal CCDBG); fire + local health annual
**Renewal:** 2 years (1 year provisional for new)

**State-specific onboarding questions:**
- Is this a Registered Child Care Ministry? (different rule set; IC 12-17.2-6)
- Licensed Home? (address must be redacted in any public output per IC 12-17.2-2-1(9))
- Are you pursuing Paths to QUALITY (PTQ) Level 3 or 4 for On My Way Pre-K?

**Day-1 auto-generated forms/packs:**
- Form 50076 — Initial Center Licensing Application (pre-filled via I-LEAD/ProviderConnect export)
- Form 49467 — Provider Background Check Authorization (per staff)
- Form 44129 — Caregiver Qualifications Verification (pre-filled from HR/staff records)
- Form 53466 — Child's Health Record (auto-issued per enrollment)
- Form 55090 — Incident/Injury Report (ready-to-submit template)

**Wall-posting auto-print pack:**
- Current license
- Tornado / fire / lockdown evacuation plans
- Staff-to-child ratio chart by room
- Immunization requirement summary (ISDH schedule)
- Safe Sleep ABCs + Shaken Baby poster (infant rooms)

**Top 3 inspection-killer nags:**
1. "Tornado drill missed for March — log one this week. Monthly drills required Mar–Jun."
2. "Red critical-violation flag risk: 2 staff over ratio in toddler room yesterday. Fix schedule today."
3. "Background check on [Staff Name] expires in 30 days — 5-year renewal is federally required; ratio-eligible status revokes if lapsed."

**Inspection-day one-tap pack:**
- Current license + most recent PTQ level sheet
- All staff CCDBG 10-topic pre-service training certs
- Fingerprint FBI + CPS + NSOR check printouts per staff
- Child immunization records + health statements
- Tornado/fire drill log (dated entries)
- Ratio worksheets by classroom by day

**State quirks:**
- Addresses of Licensed Homes are statutorily redacted from any public directory — our directory exports auto-suppress home addresses.
- Registered Child Care Ministries are exempt from full licensing but must register and meet minimum health/safety — different checklist entirely.

### Maryland
**Regulator:** MSDE Office of Child Care · **Statute:** COMAR 13A.16 (centers), 13A.15/18 (FCC); Md. Educ. Art. Title 9.5 · **Public inspection portal:** https://www.checkccmd.org/
**Facility types:** Child Care Center; Family Child Care Home; Large FCCH (9–12); Letter of Compliance program
**Ratios (toughest band):** Infant (6 wk–18 mo) 1:3, max group 6
**Inspection cadence:** Annual unannounced OCC inspection; annual fire marshal; findings posted within 30 days on CheckCCMD
**Renewal:** 3-year license/registration

**State-specific onboarding questions:**
- Which of 13 regional OCC offices? (determines licensing specialist contact)
- Residence in a targeted lead ZIP? (triggers lead testing verification for ages 1–2)
- Center, FCC, or Large FCCH? (drives which COMAR chapter applies)

**Day-1 auto-generated forms/packs:**
- OCC 1201 — Application for Child Care Center License (pre-filled)
- OCC 1203 / 1231 — CBC application + fingerprint referral (per staff + household)
- OCC 1214 — Child Health Inventory (per enrollment)
- OCC 1205 — Emergency Form (per child)
- OCC 1228 — Annual Renewal (auto-queued 90 days before term ends)

**Wall-posting auto-print pack:**
- Current license/registration
- Emergency Preparedness & Disaster Plan with drill schedule
- Ratio chart per group
- Safe Sleep Policy (signed, dated)
- Breastfeeding-friendly accommodation notice

**Top 3 inspection-killer nags:**
1. "12-hour annual in-service log short by 4 hours for 3 staff. MSDE cites this every year."
2. "CBC for [Staff Name] turns 5 years old in 60 days — fingerprint re-submission required; staff cannot remain counted in ratio without it."
3. "Emergency/disaster drill not logged this quarter — schedule one and log on CPDR."

**Inspection-day one-tap pack:**
- Current license + most recent CheckCCMD inspection
- CBC + SOR + CPS clearance per staff
- 45/90-hour course certs + CDA + Director 90-hour
- MAT certs (if dispensing medication)
- Individual Child Care Plans + immunization/lead records
- Drill log + evacuation/disaster plan

**State quirks:**
- Every inspection result is published on CheckCCMD within ~30 days — any violation is instantly public. Parents can and do check.
- CPDR (Continuing Professional Development Registry) — every staff must be listed. Missing registration can't be fixed at inspection time.

### Missouri
**Regulator:** DESE Office of Childhood, SCCR · **Statute:** 5 CSR 25-500 (RSMo Ch. 210) · **Public inspection portal:** https://healthapps.dhss.mo.gov/childcaresearch/
**Facility types:** Licensed Child Care Center (11+); Licensed Group Home (11–20); Licensed Family Home (≤10); License-Exempt (religious, subsidy-registered)
**Ratios (toughest band):** Birth–2 yr mixed 1:4, max group 8
**Inspection cadence:** ≥1 unannounced annual (CCDBG); fire annual; complaint as triggered
**Renewal:** 2 years (centers + group + family)

**State-specific onboarding questions:**
- Religious-affiliated program — licensed or exempt-registered with DESE?
- Current records still cite 19 CSR 30-62 (pre-2022 DHSS) or updated 5 CSR 25-500?
- Do you take CCDF/subsidy? (triggers 5 CSR 25-600 overlay)

**Day-1 auto-generated forms/packs:**
- CCFS-1 — Application for a Child Care License (pre-filled)
- CCFS-100 + CCFS-101 — Staff Record + Individual Medical Exam (per staff)
- CCFS-200 + CCFS-201 — Child Health & Emergency Form + Immunization Record (per child)
- CCFS-202 — Medication Authorization
- FCSR registration packet (per staff, sent pre-hire)

**Wall-posting auto-print pack:**
- Current license
- Tornado / fire / intruder drill procedures
- Safe Sleep / ABC policy (infant rooms)
- Staff ratio chart by age band
- Evacuation route map + assembly point

**Top 3 inspection-killer nags:**
1. "Tornado drill overdue — MO rule requires quarterly. Log one by Friday."
2. "FCSR re-screen for [Staff Name] due in 30 days. Biennial renewal is mandatory."
3. "12-hour annual CE log short for 2 staff; SCCR cites 5 CSR 25-500.182(3) on almost every visit."

**Inspection-day one-tap pack:**
- Current license
- FCSR + FBI fingerprint + CA/N + NSOR clearances per staff
- CCFS-201 immunization records per child
- CPR/First Aid + Safe Sleep + SBS + CCDBG 10-topic certs
- Quarterly drill log (fire, tornado, intruder)
- Director qualifications docs (per 5 CSR 25-500.182)

**State quirks:**
- 2021 reorg: licensing moved from DHSS to DESE. Pre-2022 records cite 19 CSR 30-62; we auto-map those to current 5 CSR 25-500 citations.
- 2026 regulatory change: CCLIS (Child Care Licensing Indicator System) rolls out statewide by June 2026 — abbreviated-inspection model will change field/cadence structure. We'll re-map inspection checklists at rollout.

### Wisconsin
**Regulator:** WI DCF Bureau of Early Care Regulation · **Statute:** DCF 250 (family), DCF 251 (group); Wis. Stat. 48.65 · **Public inspection portal:** https://childcarefinder.wisconsin.gov/
**Facility types:** Group Center (9+); Family Center (4–8); Day Camp; Certified (county, ≤3 non-related)
**Ratios (toughest band):** Birth–12 mo 1:4, max group 8
**Inspection cadence:** Annual unannounced (group); at least once per license term for family; more for new/prior-violation
**Renewal:** Continuous licensure — no routine renewal; annual fee + compliance only

**State-specific onboarding questions:**
- Group center (DCF 251), family (DCF 250), or county-certified (DCF 202)?
- Accepting Wisconsin Shares subsidy? (triggers YoungStar rating requirement)
- Infant room staff — all have 80-hour Registry coursework?

**Day-1 auto-generated forms/packs:**
- DCF-F-CFS0003 — Application for Child Care License (pre-filled)
- DCF-F-CFS0062 — Background Record Check Request (per staff)
- DCF-F-CFS0055 — Child's Health History & Emergency Care Plan (per child)
- DCF-F-CFS0077 — Staff Record
- DCF-F-0078 — Staff-to-Child Ratio Worksheet (auto-calculated per schedule)

**Wall-posting auto-print pack:**
- Current license
- Written policies pack (health & safety, emergency, discipline, grievance, biting, sick child)
- Ratio chart per classroom
- Shaken Baby Syndrome prevention notice (Wis. Stat. § 48.982)
- Safe Sleep ABC policy

**Top 3 inspection-killer nags:**
1. "25-hour annual Registry training short for 2 lead teachers — import hours before next visit. Top cited violation statewide."
2. "BRC for [Staff Name] will hit 4-year limit on [date] — WI requires recheck; staff cannot supervise children after lapse."
3. "Supervision failure most-frequently-cited statewide — verify every group has documented ratio coverage right now."

**Inspection-day one-tap pack:**
- Current license + current YoungStar rating sheet
- BRC + DOJ + SOR + DCF registry clearances per staff
- Registry-logged training hours (lead: 25/yr, assistants: 15/yr)
- Shaken Baby Syndrome signed training + parent handbook acks
- Child health histories + immunization records
- Ratio worksheet (Form 0078) for previous 2 weeks

**State quirks:**
- Continuous licensure — you don't renew, but you lose the license fast if you miss the annual fee or get cited for a DCF "Serious Violation."
- Infant/toddler rules revised and scheduled to take effect summer 2026 — rule engine flips automatically on effective date; verify ratio bands in the app on rollout day.

### Colorado
**Regulator:** CDEC (Colorado Dept. of Early Childhood) DELLA · **Statute:** 12 CCR 2509-8 §7.702 (centers), §7.707/7.708 (FCCH); C.R.S. § 26.5-5-301 · **Public inspection portal:** https://www.coloradoshines.com/search
**Facility types:** Child Care Center; Preschool; Infant Nursery; Family CCH (≤6); Large Family CCH (≤12); School-Age Center; NYO; Resident Camp
**Ratios (toughest band):** Infants 6 wk–12 mo 1:5, max group 10 (infants cannot be combined with >30 mo children)
**Inspection cadence:** ≥1 unannounced annual (CCDBG); higher-quality programs less frequent
**Renewal:** Continuous licensure (1-yr provisional → continuous)

**State-specific onboarding questions:**
- Participating in CCCAP subsidy? (triggers Fiscal Agreement + tiered reimbursement)
- Participating in Universal Preschool (UPK)? (separate CDEC contracting)
- Infant/toddler classroom in building with firearms stored on-site? (gun-safety storage verification)

**Day-1 auto-generated forms/packs:**
- DCEE1001 — Application for License to Operate a Child Care Facility (pre-filled)
- Fingerprint FBI/CBI background packet + Trails registry authorization (per staff)
- Medical Statement (Adult) + TB risk assessment (per staff)
- CIIS (Colorado Immunization Information System) access setup + child immunization uploads
- Emergency Preparedness Plan (fire + lockdown + evacuation + reunification)

**Wall-posting auto-print pack:**
- Current license
- Ratio chart by age band
- Emergency preparedness summary + evacuation map
- Safe Sleep / SIDS policy (infant rooms)
- Firearms / weapons storage policy notice

**Top 3 inspection-killer nags:**
1. "PDIS training hours short — you need 15 clock hours logged for [Staff Name] by [date]. CDEC pulls these directly from PDIS."
2. "Fingerprint re-submission for [Staff Name] due in 45 days (5-year limit). Staff can't be ratio-eligible after it lapses."
3. "Mandated-reporter annual refresher missing for 3 staff — 30-day initial + annual is rule 7.701."

**Inspection-day one-tap pack:**
- Current license
- PDIS roster + training hour printouts per staff
- Fingerprint + Trails + NSOR clearances per staff
- Child immunization from CIIS + health statements
- Emergency prep plan + drill log
- Director Qualification approval letter

**State quirks:**
- 2022 agency consolidation: licensing moved from CDHS to CDEC. Legacy records still cite old CDHS metadata — we auto-map.
- Continuous licensure, not periodic renewal — one sustained citation can tank your license; there's no "clean slate at renewal."

### Minnesota
**Regulator:** DCYF Licensing Division (mirrored on DHS LIL) · **Statute:** MN Rule 9503 (centers); Minn. Stat. 245A/142B · **Public inspection portal:** https://licensinglookup.dhs.state.mn.us/
**Facility types:** Child Care Center (Rule 3); Certified Child Care Center; Family Child Care (Rule 2); Drop-In / School-Age (9503.0075)
**Ratios (toughest band):** Infant (6 wk–16 mo) 1:4, max group 8
**Inspection cadence:** Annual unannounced; first-year "Early and Often" = 4 visits year 1 (1 scheduled TA + 3 unannounced); complaints anytime
**Renewal:** Annual — license expires Dec 31 each year

**State-specific onboarding questions:**
- Rule 3 center, Certified Center (streamlined), or Rule 2 family home?
- Are any household members 13+ on-site? (NETStudy 2.0 required for them)
- Drop-in program? (different ratio table under 9503.0075)

**Day-1 auto-generated forms/packs:**
- DHS-5148 — Applicant Agreement, Acknowledgment & Verification (notarized template)
- DHS-4477 — Child Care Center License Application (Rule 3)
- NETStudy 2.0 Background Study (per staff, volunteer, owner, board member, household 13+)
- Risk Reduction Plan (9503.0140) — annual template
- Emergency / Health & Safety Plan (9503.0140/0150) — pre-filled

**Wall-posting auto-print pack:**
- Current license
- Staff ratio chart
- Minimum-two-staff-on-site statement (9503.0090)
- Safe Sleep policy (9503.0155) per AAP
- Mandated reporter + SUIDS/SBS notices

**Top 3 inspection-killer nags:**
1. "License renewal due Dec 31 — MN requires annual renewal; start the packet today."
2. "Minimum TWO staff required on-site at all times — your Wednesday 5–6 PM shift shows only one. Fix schedule."
3. "Annual Risk Reduction Plan update not logged this year — DCYF cites 9503.0140 routinely."

**Inspection-day one-tap pack:**
- Current license
- NETStudy clearances per staff + household 13+
- Annual Risk Reduction Plan (dated current)
- Orientation training logs (mandated reporter, safe sleep, SUIDS, SBS)
- Child files: immunization (Minn. Stat. 121A.15) + ICCPP
- Two-staff-on-site schedule proof

**State quirks:**
- MN uniquely requires at least two staff on site whenever the center is operating, even if ratios only require one. Often the fastest-to-fix but most commonly cited violation.
- Jan 2026 Star Tribune/KSTP investigative wave has DCYF under heightened fraud scrutiny; expect tighter attendance/enrollment record audits through 2026.

### South Carolina
**Regulator:** SC DSS Division of Early Care and Education · **Statute:** S.C. Code Title 63 Ch. 13; SC Reg. 114-500 series · **Public inspection portal:** https://www.scchildcare.org/search.aspx
**Facility types:** Licensed Child Care Center (13+); Group Home (7–12); Family Home (≤6, registration mandatory); Religious-Exempt; Approved (schools)
**Ratios (toughest band):** Birth–1 yr 1:5
**Inspection cadence:** ≥1 unannounced annual (§ 63-13-520); complaint-triggered anytime; fire + DHEC health annual
**Renewal:** 2-year license / 2-year registration (6-mo provisional allowed)

**State-specific onboarding questions:**
- Church-operated — licensed, registered, or religiously-exempt? (exempt still requires parental notice + reporter duties per § 63-13-60)
- Family home — choosing optional licensure, or registration only?
- Participating in ABC Quality (required for SC Voucher subsidy)?

**Day-1 auto-generated forms/packs:**
- DSS 2902 — Application to Operate a Child Care Facility
- DSS 2905 — Health/Fire Inspection Request (submit to Fire Marshal + DHEC)
- DSS 2924 — Consent to Release Information / Compliance Statement
- DSS 2926 — Health Assessment (per operator, caregiver, + household 16+ for homes)
- DSS 3086 — Child's Enrollment Form (per child)

**Wall-posting auto-print pack:**
- Current license + most recent inspection report
- Emergency evacuation plan
- Complaint phone number (DSS CCS, 803-898-2570)
- DSS 2966 — Staff-to-Child Ratio reference card
- Expulsion policy (2019 BRIGHT Act–aligned)

**Top 3 inspection-killer nags:**
1. "Improper supervision is the #1 high-severity deficiency in SC (3,044 cases in 4 years). Verify every group has eyes-on coverage at transitions."
2. "Out-of-ratio risk: your 2-year-old room is at 1:9. SC cap is 1:8. Add a staff before open tomorrow."
3. "15-hour annual in-service log short for 2 staff — Reg. 114-504 cites this on nearly every renewal."

**Inspection-day one-tap pack:**
- Current license + posted most recent inspection
- SLED + FBI + Central Registry clearances per staff
- DSS 2926 Health Assessments (staff + household for home-based)
- Immunization certs (DHEC 2740) per child
- Pediatric First Aid + CPR (at least one on duty)
- Bloodborne pathogens + pre-service health/safety training docs

**State quirks:**
- No hard numeric group cap (except infants) — square footage (35 ft² indoor / 75 ft² outdoor) and supervision rules govern group structure.
- Deficiencies publicly visible on scchildcare.org for 36 months with High/Medium/Low severity codes — any "High" citation will still be live on every parent search for 3 years.

### Alabama
**Regulator:** Alabama DHR Child Care Services · **Statute:** Ala. Code § 38-7-1; Ala. Admin. Code 660-5-26 (centers), 660-5-27 (homes) · **Public inspection portal:** No public inspection history portal — directory only at https://apps.dhr.alabama.gov/daycare/daycare_search (deficiency reports posted only at the facility)
**Facility types:** Day Care Center (13+); Nighttime Center; Family Day Care Home (≤6); Group Day Care Home (7–12); Nighttime variants; License-Exempt (church, no state/fed funds)
**Ratios (toughest band):** 0–18 mo 1:5
**Inspection cadence:** ≥1 unannounced annual; quarterly monitoring for new or prior-deficiency centers; fire + health annual
**Renewal:** Annual (every 1 year)

**State-specific onboarding questions:**
- Church-operated — do you receive any state or federal funds including CCDBG? (if yes, 2018-390 requires you to be licensed, not exempt)
- Nighttime care (9 PM–5 AM)? (separate rule subchapter)
- Are any household members 19+ on-site for home-based? (SCAN/CA-N required)

**Day-1 auto-generated forms/packs:**
- DHR-CCS-1100 — Application for License to Conduct a Child Care Facility
- DHR-CCS-1207 — Information Form for Licensing Study
- DHR-CCS-1207A — Personnel / Staff Information (per staff)
- DHR-DHS-1617 — SCAN/CA-N Clearance consent (per staff)
- DHR-CCS-1503 — Emergency Preparedness & Evacuation Plan
- DHR-CCS-1532 — Discipline Policy Statement

**Wall-posting auto-print pack:**
- Current license
- Staff-to-child ratio chart per age band (660-5-26)
- Discipline policy (corporal punishment prohibited)
- Fire evacuation plan + assembly points
- Mandated reporter notice (§ 26-14)

**Top 3 inspection-killer nags:**
1. "Annual license renewal due in 60 days — AL is one of few states with annual (not 2-year) renewal. Start paperwork now."
2. "12-hour annual in-service log short for 2 staff — top-cited on 660-5-26 inspections."
3. "Child-check ('child left behind') protocol missing from transportation log — AL DHR cites this on nearly every transport-using center."

**Inspection-day one-tap pack:**
- Current license
- ABI + FBI + SCAN/CA-N clearances per staff
- Current fire marshal report (must be current, no violations)
- Current DHEC/health sanitation report
- Pediatric First Aid + CPR certs (at least one on duty)
- Immunization certs (IMM 50/51 blue card) per child
- Discipline policy parent-acknowledgment forms

**State quirks:**
- Annual license renewal — most states are 2–3 years. Set calendar 90 days before expiration.
- 2018 Child Care Safety Act (Act 2018-390) closed the religious-exempt loophole for programs receiving state/federal funds — if you touch CCDBG, you must be licensed.

### Louisiana
**Regulator:** LDE Division of Early Childhood — Licensing Section · **Statute:** La. R.S. 17:407.31 et seq.; Bulletin 137 = LAC 28:CLXI · **Public inspection portal:** https://louisianaschools.com/schools/{facility_code}/Inspections
**Facility types:** Early Learning Center Type I (religious, no state/fed funds); Type II (no state/fed except USDA CACFP); Type III (receives state/fed funds, Bulletin 140 required); Registered Family Home (RFCCP)
**Ratios (toughest band):** Infants (<1 yr) 5:1, max group 15
**Inspection cadence:** ≥1 unannounced annual (≤12 mo intervals); critical incident report within 24 hours; fire + LDH sanitation annual
**Renewal:** Annual (apply 30 days before expiration); CCCBC every 5 years

**State-specific onboarding questions:**
- Do you receive any state or federal funds (CCDF, LA 4, NSECD)? (if yes → Type III + Bulletin 140 overlay; auto-revoke Type I)
- Have any staff resided out-of-state in last 5 years? (triggers extra CCCBC out-of-state checks)
- Type III — is your Academic Approval (BESE) current?

**Day-1 auto-generated forms/packs:**
- Early Learning Center License Application (LDE, auto-filled with facility + Type selection)
- CCCBC Clearance packet per owner/director/staff/volunteer (+ household if home-based)
- Fire Marshal Inspection Report request
- LDH Sanitation Inspection Report request
- Critical Incident Report form (on file, 24-hr submission ready)
- Emergency Plan / Continuity of Operations Plan (hurricane-aware template)

**Wall-posting auto-print pack:**
- Current license (posted Type I/II/III)
- Ratio & group size chart (LAC 28:CLXI.1711)
- Evacuation + shelter-in-place + hurricane-reunification plan
- Mandated reporter notice (La. R.S. 14:403)
- SIDS / Safe Sleep + Shaken Baby prevention policy

**Top 3 inspection-killer nags:**
1. "Annual renewal window opens in 30 days — LDE requires submission 30 days pre-expiration or you lapse."
2. "Orientation training (15 topic areas) not logged within 7 days for [Staff Name] — this is Bulletin 137's most common cite."
3. "Critical Incident on [date] not logged with LDE within 24 hours — open it now, this is a hard rule."

**Inspection-day one-tap pack:**
- Current license + posted Type classification
- CCCBC clearance + out-of-state checks per staff
- Current Fire Marshal + LDH sanitation reports
- Orientation training (15 topics) + LDE Key Modules 2 & 3 completion certs per staff
- 12-hour annual training logs
- Emergency Plan with hurricane addendum
- Child immunization + physical records

**State quirks:**
- 3-tier license structure is fund-driven, not capacity — accepting state/federal dollars moves you to Type III + Bulletin 140 academic overlay automatically.
- Hurricane-zone: Emergency Preparedness Plan must cover evacuation + shelter-in-place + reunification; LDE checks this aggressively June–November.

### Kentucky
**Regulator:** CHFS OIG Division of Regulated Child Care (DRCC); DCBS for subsidy/quality · **Statute:** KRS 199.898–.899; 922 KAR 2:090/2:110/2:120/2:280/2:270 · **Public inspection portal:** https://kynect.ky.gov/benefits/s/child-care-provider
**Facility types:** Type I Center (4+ non-residential OR 13+ residential); Type II Center (7–12 in licensee's residence); Certified Family CC Home (≤6); Registered (subsidy); License-Exempt
**Ratios (toughest band):** Infant (<12 mo) 1:5, max group 10
**Inspection cadence:** Quarterly in first 2 years (probationary), then ≥1 annual; unannounced complaint inspections anytime
**Renewal:** Annual (6-mo preliminary license for new); CCBC every 5 years

**State-specific onboarding questions:**
- Type I (non-residential 4+ OR residential 13+) or Type II (residential 7–12)?
- Is this within your first 2 years of licensure? (quarterly inspection cadence applies)
- Have any staff resided in another state recently? (out-of-state registry checks required)

**Day-1 auto-generated forms/packs:**
- OIG-DRCC-01 — Initial Child-Care Center License Application
- OIG-DRCC-06 — Annual Renewal Form (auto-queued 60 days before expiration)
- OIG-DRCC-09 — Serious Incident Report (ready for 24-hr submission)
- CCBC background check packet per staff (KSP + FBI + CA/N + NSOR + out-of-state)
- DPP-156 — Child Abuse/Neglect Registry Check

**Wall-posting auto-print pack:**
- Current license + current All STARS rating
- Staff-to-child ratio chart per classroom (922 KAR 2:120)
- Discipline policy (corporal punishment prohibited)
- Fire/emergency evacuation plan + drill schedule
- Mandated reporter notice (KRS 620.030)

**Top 3 inspection-killer nags:**
1. "Annual renewal (OIG-DRCC-06) due in 45 days. Miss this and your license lapses — KY renews every 1 year."
2. "TB screening for [Staff Name] over 2 years old — KY requires biennial TB. Schedule this week."
3. "15-hour annual in-service short for 3 staff — 922 KAR 2:110 is the most-cited training-hour rule statewide."

**Inspection-day one-tap pack:**
- Current license + All STARS sheet
- CCBC clearance (KSP + FBI + CA/N + NSOR + out-of-state) per staff
- TB screening (within 2 years) per staff
- Pediatric First Aid + CPR current for all ratio staff
- Shaken Baby + Safe Sleep training certs (infant room staff)
- Medication Administration training certs (DPH-approved module)
- Transportation log (retained 5 years — KY-specific)

**State quirks:**
- Transportation log retention is 5 years — longer than almost any state. Our app archives automatically.
- Licensing is split: OIG-DRCC issues/monitors licenses; DCBS-DCC runs CCAP subsidy + All STARS. They do not share a single portal — two workflows.

### Oregon
**Regulator:** DELC Child Care Licensing Division (CCLD) · **Statute:** ORS 329A.250–.500; OAR 414 Div. 205 (general), 300/305 (CC centers), 307 (CF homes), 350 (RF homes), 061 (CBR) · **Public inspection portal:** https://findchildcareoregon.org/ (and legacy Child Care Safety Portal)
**Facility types:** Certified Child Care Center (CC); Certified School-Age Center (SC); Certified Family Home (CF, up to 16 w/ assistant); Registered Family Home (RF, ≤10); Recorded / License-Exempt
**Ratios (toughest band):** 6 wk–24 mo 1:4, max group 8 (Table 3A; post-July 2001 centers)
**Inspection cadence:** ≥1 on-site licensing inspection/year, typically unannounced; complaint inspections anytime; CCLD-0093 Contact Report generated each visit
**Renewal:** Annual (1-year term); CBR renewal typically every 2 years

**State-specific onboarding questions:**
- Was your center initially licensed on/before July 15, 2001? (determines whether you use Ratio Table 3A or the grandfathered 3B — no mixing)
- Any household member 16+ for home-based care? (Central Background Registry enrollment mandatory)
- Multi-site program under a single org/director? (OAR 414-305-0100 applies)

**Day-1 auto-generated forms/packs:**
- Certified Child Care Center license application (CCLD-0105 guide referenced; pre-filled)
- CEN-0001 — Central Background Registry (CBR) Application per staff + household 16+
- PR-0185 — Child Enrollment Form (per child)
- CCLD-0090 — Health & Safety Review Checklist (self-audit pre-inspection)
- CCLD-0109 — Sanitation Inspection Checklist (fillable, submit annually)
- PTA-0732 — Mixed-Age Ratio Table (auto-selected when ≤16 children)

**Wall-posting auto-print pack:**
- Current certification + most recent CCLD-0093 Contact Report (12-month posting rule for noncompliance)
- Ratio chart (3A or 3B per facility age)
- Safe Sleep for Oregon Infants policy
- Mandated reporter notice (ORS 419B.005)
- Evacuation + active-shooter plan summary

**Top 3 inspection-killer nags:**
1. "CBR enrollment for [Staff Name] expires in 30 days — no unsupervised child access after lapse. Renew today via CEN-0001."
2. "15-hour annual training log short: need 8 hrs in child dev/ECE + 1 hr health/safety/nutrition per OAR 414-305-0380."
3. "Food Handler Card for [Staff Name] not on file — required within 30 days for kitchen and infant-room bottle prep."

**Inspection-day one-tap pack:**
- Current license
- CBR clearances per staff + household 16+
- Pediatric First Aid + CPR current
- Safe Sleep for Oregon Infants + Abuse/Neglect reporter + Food Handler certs
- 15-hour annual training log (ORO records)
- Director's 10-hour Program Management hours (year 1)
- Lead-in-water + radon test results
- Previous 5 years of CCLD-0093 Contact Reports (valid findings history)

**State quirks:**
- Ratio Table 3A vs 3B is grandfathered by your initial licensure date (before/after July 15, 2001) — you pick once and can't mix.
- Find Child Care Oregon (Safety Portal) publishes "valid findings" on a 5-year rolling window and "unable to substantiate" on a 2-year window. Parents see everything for 5 years — the richest public-facing disclosure of any state in this set.

### Oklahoma
**Regulator:** OKDHS Child Care Services (OCCS) · **Statute:** OAC 340:110-3 + 10 O.S. §§ 401–410 (Child Care Facilities Licensing Act) · **Public inspection portal:** https://childcarefind.okdhs.org/
**Facility types:** Family Home, Large Family Home, Center, Part-Day, OST, Day Camp, Drop-In, Sick-Child
**Ratios (toughest band):** Infant (0–12 mo) 1:4, max group 8
**Inspection cadence:** Unannounced ≥1×/yr (2–4 for centers)
**Renewal:** Annual

**State-specific onboarding questions:**
- Are you a 1-Star, 2-Star, or 3-Star "Reaching for the Stars" program?
- Do any household members (home-based) need SAFETY Act background clearance?
- Do you transport children — if yes, any 15-passenger vans?

**Day-1 auto-generated forms/packs:**
- 07LC001E — Application for License — pre-filled from onboarding (facility type, capacity, owner)
- 07LC010E — Child Enrollment & Emergency Info — auto-generated per child from enrollment import
- 07LC016E — Emergency Preparedness Plan — filled from site address + nearest shelter
- 07LC036E — Monthly Fire Drill Log — auto-built blank for the year
- OSDH Form 216A — Certificate of Immunization — drafted from each child's immunization record

**Wall-posting auto-print pack:**
- Current OKDHS license
- Most recent monitoring visit report
- Posted ratio / max group size chart by room
- Safe Sleep / ITS-SIDS infant room poster
- Fire + tornado evacuation routes
- Mandated reporter hotline (1-800-522-3511)

**Top 3 inspection-killer nags:**
1. "CPR/Pediatric First Aid expires in 14 days for Jane D. — at least 1 certified staff must be on premises at all times. Renew now."
2. "Tornado drill for {month} not logged — OKDHS requires monthly drills March–October. Tap to log."
3. "SAFETY Act 5-year background recheck due this month for 2 staff — block them from the floor until cleared."

**Inspection-day one-tap pack:**
- Current license + last monitoring visit PDF
- Staff roster with OSBI/FBI clearance dates + training hours YTD
- Child files (immunization + 07LC010E + health assessment)
- 12 months of fire drills + 8 months of tornado drills
- Ratio snapshot per room (now)
- Fire extinguisher expiration + fire/health inspection dates
- Insurance certificate

**State quirks:**
- Firearms rule (OAC 340:110-3-283): unloaded, locked, ammo stored separately — audit at onboarding for home-based
- Staff training tiers: aides 12 hrs/yr, teachers 20, directors 30 — we track each tier separately

### Connecticut
**Regulator:** CT Office of Early Childhood (OEC) — Division of Licensing · **Statute:** CGS Ch. 368a §§ 19a-77 to 19a-87e; RCSA 19a-79-1a to -13 · **Public inspection portal:** https://www.elicense.ct.gov/Lookup/LicenseLookup.aspx
**Facility types:** Child Care Center (13+), Group Child Care Home (7–12), Family Child Care Home (≤6), Youth Camp
**Ratios (toughest band):** Under 3 = 1:4, max group 8 (under-2 group size capped at 8)
**Inspection cadence:** Unannounced ≥ every 2 yrs (often annual for centers)
**Renewal:** License term up to 4 yrs; background checks every 2 yrs drive re-inspection cadence

**State-specific onboarding questions:**
- Is your facility pre-1978 construction (triggers lead paint / RRP)?
- Is any classroom in a basement or grade-level room (radon test every 2 yrs)?
- Is every staff member enrolled in the Early Childhood Professional Registry?

**Day-1 auto-generated forms/packs:**
- OEC Center-Group-Initial-Application — prefilled from onboarding
- HAR-3 Health Assessment for Child Day Care — child-by-child template
- Emergency Evacuation & Security Plan — filled from site address
- Child Enrollment Record template per 19a-79-7a
- Background Check Authorization packet (DCF + state + FBI + DMV + sex offender)

**Wall-posting auto-print pack:**
- Current OEC license
- Posted ratio and group-size chart per classroom
- Immunization schedule incl. annual flu (Sept 1 – Jun 30, 6 mo – 5 yr)
- Mandated reporter hotline (1-800-842-2288)
- Fire evacuation map
- Corporal punishment ban notice (CGS 19a-79-6)

**Top 3 inspection-killer nags:**
1. "Background check for {staff name} expires in 21 days — CT requires renewal every 2 yrs. Start now or remove from floor."
2. "Radon test on file is >2 years old — required for basement/grade-level rooms. Schedule a vendor from your area."
3. "Flu vaccine season ends Jun 30 — 4 children in your 6-mo–5-yr roster are missing documentation. Message parents now."

**Inspection-day one-tap pack:**
- Current license PDF + most recent eLicense inspection PDF
- Staff roster with Registry IDs + background dates (2-yr cycle) + 15 hrs CE (30 for director)
- Child files: HAR-3 + immunization + flu + enrollment
- Fire drill log + radon test results + lead paint status
- Director qualification file (Bachelor's + 12 ECE credits)

**State quirks:**
- 2-yr background cycle + 4-yr license term is a mismatch — we alert on whichever expires first
- Flu shot required annually for 6 mo – 5 yr (unusual nationally) — we nag parents before Oct 1

### Utah
**Regulator:** Utah DHHS Division of Licensing and Background Checks (DLBC) · **Statute:** Utah Code 26B-2 Part 4; Utah Admin Code R381-100 (Centers), R381-60 (Hourly), R381-70 (Residential Family) · **Public inspection portal:** https://ccl.utah.gov/ (checklist deep-links at /ccl/public/checklist/{ID})
**Facility types:** Licensed Center, Hourly Center, Licensed Family Home (8–16), Residential Certificate Family (1–8), License-Exempt
**Ratios (toughest band):** Infant & Toddler (0–24 mo) 1:4, max group 8
**Inspection cadence:** Annual announced + unannounced on complaints
**Renewal:** Annual

**State-specific onboarding questions:**
- Is your program in the Care About Childcare (CAC) QRIS? What tier?
- Do any caregivers transport children in personal vehicles (triggers firearm + vehicle rules)?
- Do you operate outdoors during wildfire / AQI alerts?

**Day-1 auto-generated forms/packs:**
- CC License Application — prefilled
- Facility Self-Assessment Checklist — matches R381-100 rule-by-rule
- Director Qualification Form — fills from CAC profile
- Emergency Preparedness Plan (R381-100-15)
- Background Screening Consent for every staff/household member (routed to Office of Background Processing)

**Wall-posting auto-print pack:**
- DLBC license
- Ratio chart (R381-100-10) with mixed-age "youngest-child" rule
- AQI / wildfire outdoor-play policy
- Fire evacuation map + earthquake drill plan
- Mandated reporter (Utah Code 62A-4a-403)
- Water safety rules (pools / splash pads / open water)

**Top 3 inspection-killer nags:**
1. "AHT/Shaken Baby training due within 30 days of hire for {infant room staff} — cannot work infants until complete."
2. "Background screening for {staff} pending at Office of Background Processing — DO NOT allow unsupervised contact until clearance letter posted."
3. "20 pre-service hours not yet completed for {new hire} — cannot provide unsupervised care. Assign a CAC module now."

**Inspection-day one-tap pack:**
- DLBC license + last ccl.utah.gov checklist PDF
- Staff CAC profiles with 10 hrs/yr (20 for director) training log
- Background Processing clearance letters
- Self-Assessment Checklist (R381-100 master, 7/2/2025 version)
- Child immunization records + emergency plan
- Outdoor play area sq-ft verification (40 sq ft/child)

**State quirks:**
- "Oldest-child-minus-one-age-band" rule for max group size in mixed classrooms — we auto-compute per roster
- Every staff must have an active Care About Childcare registry ID — we block hire if missing

### Iowa
**Regulator:** Iowa HHS Bureau of Child Care · **Statute:** Iowa Code Ch. 237A; IAC 441-109 (Centers), 441-110 (CDHs) · **Public inspection portal:** https://secureapp.dhs.state.ia.us/dhs_titan_public/ChildCare/ComplianceReport
**Facility types:** Child Care Center, Licensed Preschool, Child Development Home Cat A/B/C, Non-registered Home
**Ratios (toughest band):** 0–12 mo 1:4 and 13–23 mo 1:4
**Inspection cadence:** Annual unannounced on-site
**Renewal:** License up to 2 yrs (most on 2-yr cycle); annual monitoring

**State-specific onboarding questions:**
- Are you a center, preschool, or Child Development Home Category A/B/C?
- What is your Iowa Quality for Kids (IQ4K) level?
- Are you within proximity to open water (pond/lake/river)?

**Day-1 auto-generated forms/packs:**
- Form 470-0648 — Application for Child Care Center License
- Form 470-0643 — Record of Immunization & Physical Exam
- Form 470-3871 — Child Abuse / Criminal Records Check (REQ A)
- Form 470-0720 — Physical Care Plan (generated per allergic/special-needs child)
- Centralized Employee Registry (CER) enrollment list for every paid staff

**Wall-posting auto-print pack:**
- Current license
- Posted ratios (IAC 441-109.8)
- Fire drill + tornado drill monthly calendar (Mar–Nov)
- Mandated reporter hotline (1-800-362-2178)
- Immunization exemption procedure
- Emergency evacuation map

**Top 3 inspection-killer nags:**
1. "Mandated reporter training for {staff} expires in 30 days — Iowa Code 232.69 requires 2 hrs every 3 yrs. Renew now."
2. "Tornado drill missed for {month} — IAC requires monthly March–November. Log one today."
3. "Out-of-state records check missing for {staff} who lived outside IA in last 5 yrs — file before next inspection."

**Inspection-day one-tap pack:**
- License + most recent Titan compliance report PDF
- Staff CER enrollments + background clearance (DCI + abuse + sex offender + dependent adult + FBI)
- Child files (470-0643, 470-0720, enrollment, emergency)
- Fire + tornado drill logs
- 10 hrs/yr training (≥2 in Iowa Early Learning Standards)
- Water safety plan (if applicable)

**State quirks:**
- Opening/closing 2-hour exception: 1 staff may care for ≤7 children if ≤4 under 2 — we surface this so you don't over-hire
- Iowa Child Care Connect (iachildcareconnect.org) surfaces your compliance status to parents — we prep your listing

### Nevada
**Regulator:** NV Division of Supportive Services (DSS) Child Care Licensing (consolidated 7/1/2024 from DPBH) · **Statute:** NRS Ch. 432A; NAC 432A.5205 (ratios), .190 (inspections) · **Public inspection portal:** Aithent ALiS — https://nvdpbh.aithent.com/Protected/LIC/LicenseeSearch.aspx?Program=HF&PubliSearch=Y (also findchildcare.nv.gov)
**Facility types:** Center, Institution, Infant/Toddler Nursery, Special Needs, Accommodation, Special Events, Outdoor Youth, Family CCH, Group CCH
**Ratios (toughest band):** Infant (0–12 mo) 1:4, max group 12
**Inspection cadence:** ≥2 unannounced per 12-mo period (every ~6 mo)
**Renewal:** Annual (12-mo term)

**State-specific onboarding questions:**
- Are you in Clark or Washoe County (family homes licensed locally, not state)?
- Do you operate night-care hours (9 PM – 6:30 AM awake-staff rule)?
- Are you a casino/hotel accommodation drop-in facility?

**Day-1 auto-generated forms/packs:**
- CCL-001 License Application
- CCL-002 Facility Information / Floor Plan
- CCL-100 Staff Roster & Background Attestation
- NRS 432A.170 Background Check (DPS + FBI + CANS + sex offender) packet per staff
- Emergency / Disaster Plan Form (heat + wildfire + earthquake)

**Wall-posting auto-print pack:**
- NV DSS license
- Daytime + night ratio charts (NAC 432A.5205)
- Safe sleep / SIDS infant room poster
- Mandated reporter (NRS 432B.220)
- Air Quality Index outdoor-play thresholds
- Fire evacuation map

**Top 3 inspection-killer nags:**
1. "{Staff} is at 12 of 24 required training hours — NRS 432A.1775 requires 24 hrs/yr. You have {N} days to close the gap."
2. "DPS + FBI + CANS check for {new hire} pending — they cannot have unsupervised contact. Current status: {state}."
3. "Next unannounced inspection window opens in ~30 days (6-mo cycle) — run the self-inspection simulator now."

**Inspection-day one-tap pack:**
- DSS license + last Aithent regulatory action PDF
- Nevada Registry IDs for all staff
- 24 hrs/yr training log per staff
- Background clearances (DPS + FBI + CANS + sex offender)
- Fire drills (monthly) + earthquake/shelter-in-place (annual)
- Heat + AQI outdoor-play logs

**State quirks:**
- 2024 reorg moved licensing from DPBH to DSS — old DPBH URLs still serve forms but new contracts/correspondence route through DSS
- Night-shift staff must remain awake — documented awake-check log required

### Arkansas
**Regulator:** AR DHS Division of Child Care and Early Childhood Education (DCCECE) · **Statute:** Ark. Code §§ 20-78-201 to -223; Admin Code 016.22.20-005 (Minimum Licensing Requirements) · **Public inspection portal:** https://ardhslicensing.my.site.com/elicensing/s/search-provider/find-providers (Salesforce — JS-rendered)
**Facility types:** Center, Licensed Family Home (≤10), Registered Family Home, Out-of-School Time, Night-time
**Ratios (toughest band):** Under 18 months 1:5
**Inspection cadence:** Unannounced 1–3×/yr (depends on program + compliance history)
**Renewal:** Annual

**State-specific onboarding questions:**
- Are you a Licensed Family Home or Registered Family Home (different rulebooks)?
- What is your Better Beginnings QRIS level (1/2/3/unrated)?
- Do you participate in ABC Pre-K (adds DESE overlay)?

**Day-1 auto-generated forms/packs:**
- DCC-100 Application (Center) or DCC-200 (Licensed Family Home)
- Reportable Offenses affidavit per Ark. Code § 20-78-607
- Background packet: AR State Police + Maltreatment Central Registry + FBI + Adult Maltreatment + Sex Offender
- ADH Immunization Record template per child
- Fire Marshal + Health Dept inspection cover pages

**Wall-posting auto-print pack:**
- DCCECE license
- Better Beginnings QRIS rating
- Ratio chart (016.22.20-005)
- Tornado shelter map (March–October)
- Mandated reporter hotline (1-800-482-5964)
- Fire evacuation map

**Top 3 inspection-killer nags:**
1. "{Staff} is at 9 of 15 required training hours (30 for director) — Better Beginnings docs needed for QRIS too. Close by {date}."
2. "Tornado drill not logged for {month} — AR requires monthly March–October. Tap to log now."
3. "5-yr background rescreen due in 14 days for {staff} — remove from floor if lapses."

**Inspection-day one-tap pack:**
- License + last compliance report from eLicensing
- Staff training log (15 hrs aides, 30 hrs director)
- Background clearances (State Police + CMCR + FBI + AMR + SOR)
- Child files: enrollment + ADH immunization + physical within 60 days
- Fire Marshal + Health Dept inspection certs
- Fire + tornado drill logs

**State quirks:**
- AR does not set max group size for most age bands — relies on ratio + sq-ft; we compute both for you
- Licensing portal is Salesforce Lightning — our inspection-prep mode doesn't depend on its uptime

### Mississippi
**Regulator:** MS State Department of Health (MSDH) Child Care Facilities Licensure Branch · **Statute:** Miss. Code § 43-20-1 et seq.; 15 Miss. Admin. Code Pt 11 Subpart 55 · **Public inspection portal:** https://www.msdh.provider.webapps.ms.gov/
**Facility types:** Center (13+), Home ≤12 (operator's home), Drop-in, Group Home, School-age
**Ratios (toughest band):** Infant (0–12 mo) 1:5, max group 10, 40 sq ft/child
**Inspection cadence:** ≥2×/yr (statutory); unannounced permitted any time
**Renewal:** Annual; notice 75 days out; apply ≥30 days before expiration; $25 late fee

**State-specific onboarding questions:**
- Are you a Center (13+) or in-home operator (≤12)?
- Do you prepare food on-site (triggers TummySafe/ServSafe manager requirement)?
- Is any classroom serving 2-yr-olds combined with school-age (disallowed)?

**Day-1 auto-generated forms/packs:**
- MSDH online initial/renewal license application payload
- Form #281 — Child Care Facility Inspection Report (self-audit template)
- Form #333 — Fire Inspection cover (routes to local fire authority)
- Forms #301/#302 — Food Service Inspection (if preparing food)
- Letter of Suitability for Employment request per staff (fingerprint + registries)

**Wall-posting auto-print pack:**
- Current MSDH license
- Posted ratios + sq-ft minimums (Rule 1.8.2/1.8.3)
- Safe sleep / SIDS poster (infants on backs)
- Mandated reporter hotline (1-800-222-8000)
- Fire evacuation map
- Sun safety programming notice (Rule 1.9.1)

**Top 3 inspection-killer nags:**
1. "Class I violation risk: ratio for {room} slips at {time} — assess $500 first/$1,000 repeat. Fix staffing now."
2. "Food Manager (TummySafe/ServSafe) certification not on file for {staff} — required if preparing food. Block meal prep until cleared."
3. "5-yr fingerprint rescreen due in 21 days for {staff} — Letter of Suitability will lapse. File now."

**Inspection-day one-tap pack:**
- MSDH license + recent inspection history from the provider search
- Letters of Suitability + TB screens per staff
- Child files: enrollment, Form 121 immunization, health exam, allergy plan
- Annual training log with CPR/First Aid current
- Fire (#333) + food (#301/#302) + sanitation inspection certs

**State quirks:**
- Class I monetary penalties: $500 first / $1,000 subsequent — we flag any finding with Class I risk loudly
- Raw veggies banned under 2 (choking hazard) and 1%/fat-free milk required ≥2 yrs — our menu-builder enforces this

### Kansas
**Regulator:** KDHE Child Care Licensing Program (transitioning to Office of Early Childhood 7/1/2026 per HB 2045) · **Statute:** K.S.A. 65-501 et seq.; K.A.R. 28-4-420 to -440 (28-4-428 staff ratios amended 8/2/2024) · **Public inspection portal:** https://khap.kdhe.ks.gov/OIDS/ (captcha-gated; 3-yr window)
**Facility types:** Family Child Care Home, Group Day Care Home (≤12), Preschool, Child Care Center (>12), School-age, Maternity Center
**Ratios (toughest band):** Infant (0–12 mo) 1:3 (Option A) or 1:4 (Option B), max 9 or 8
**Inspection cadence:** Initial + unannounced monitoring any time
**Renewal:** Annual; late fee = full renewal fee if >30 days late

**State-specific onboarding questions:**
- Are you in Johnson County (delegated licensing authority)?
- Do you use Infant Ratio Option A (1:3) or Option B (1:4)? (only one at a time per unit)
- Facility size tier: >60 / >100 / >160 children (director qualifications scale)

**Day-1 auto-generated forms/packs:**
- KDHE Child Care Facility Application
- Background packet: KBI + FBI fingerprint + Sex Offender + Child Abuse/Neglect Central Registry
- Annual Health Status Form per staff
- Emergency Plan template with annual drill log
- SIDS/safe-sleep training enrollment (4 hrs Year 1 for infant staff)

**Wall-posting auto-print pack:**
- KDHE license
- Infant Option A vs B ratio declaration (only one may be used at any one time)
- Ratio chart (K.A.R. 28-4-428 — Aug 2024 amendment)
- Safe sleep poster
- Mandated reporter hotline (1-800-922-5330)
- Fire evacuation map

**Top 3 inspection-killer nags:**
1. "SIDS / safe-sleep training not complete for {infant room staff} — K.A.R. 28-4-428 requires 4 hrs Year 1. Assign module now."
2. "Volunteer age check: {name} is 15 — under 16 volunteers cannot count in ratio (must be supervised). Update roster."
3. "Annual Health Status form missing for {staff} — required annually per 28-4-428a. Upload before next monitoring visit."

**Inspection-day one-tap pack:**
- KDHE license + OIDS 3-yr compliance print
- Staff files: background (KBI + FBI + SOR + CANR), health status (annual), training log
- Child files: enrollment, immunization, health assessment
- Annual emergency drill log
- Director qualification docs for your size tier

**State quirks:**
- **2026 regulatory change:** KDHE licensing transitions to Office of Early Childhood on 7/1/2026 — we monitor URL changes and re-route your submissions automatically
- Aug 2, 2024 K.A.R. 28-4-428 update expanded mixed-age group sizes — our ratio engine uses the new rule

### New Mexico
**Regulator:** NM Early Childhood Education and Care Department (ECECD) Regulatory Oversight Unit · **Statute:** 8.16.2 NMAC (Child Care Licensing); Universal Child Care regs finalized 10/2025 · **Public inspection portal:** https://childcare.ececd.nm.gov/search (surveys index: https://www.nmececd.org/child-care-services/child-care-licensed-and-registered-provider-inspection-surveys/)
**Facility types:** Center, Licensed Home (larger), Registered Family Home, Out-of-School Time, Tribal-land programs
**Ratios (toughest band):** Infant/Toddler (6 wks – 24 mo) 1:6, max group 12
**Inspection cadence:** Initial/renewal on-site + unannounced anytime; weekly playground docs required
**Renewal:** Annual (multi-year for nationally accredited); $25 late fee if <30 days out

**State-specific onboarding questions:**
- Are you on tribal land (special consideration under 8.16.2 NMAC)?
- Are you accepting Universal Child Care (UCC) funding (adds contract obligations)?
- Are you DoD-affiliated (needs certification letter)?

**Day-1 auto-generated forms/packs:**
- Notarized Licensing/Registration Application
- Background packet: FBI NGI + NM CANR + NM Sex Offender
- Annual signed staff statement (criminal eligibility, guardian sign for teen staff)
- Emergency Operations Plan (continuity + infants/special needs)
- DoD certification letter template (if applicable)

**Wall-posting auto-print pack:**
- ECECD license + UCC participation status
- Posted classroom capacities + ratios + group sizes (required by rule)
- Safe sleep / shaken baby poster
- Mandated reporter (1-855-333-SAFE)
- Fire evacuation map
- Substitute list (2 qualified names + phone)

**Top 3 inspection-killer nags:**
1. "Primary educator rule: {child name} has seen 4 primary teachers today — rule limits to 3 consecutive. Re-assign before PM block."
2. "Director must be on-site 50% of core hours — you're at 38% this week. {Director} schedule needs adjustment."
3. "Weekly playground inspection not logged for {week} — 8.16.2.29 NMAC requires weekly. Tap to log."

**Inspection-day one-tap pack:**
- ECECD license + last 3 yrs of survey PDFs
- Staff files: background clearance + 24 hrs annual training (7 competencies / 2 yrs) + 45-hr ECE course within 6 mo of hire
- Annual signed staff statements
- Child files: enrollment, NMDOH immunization, emergency medical auth
- Substitute list + Emergency Operations Plan
- Fire + playground weekly inspection logs

**State quirks:**
- **2026 regulatory change:** Universal Child Care final regs (Oct 2025) phase in 2025–2026 — we track UCC-provider contract obligations separately
- Posted ratios are literally required on the wall — our printable matches what ECECD inspectors look for

### Nebraska
**Regulator:** NE DHHS Division of Public Health, Licensure Unit, Office of Children's Services Licensing · **Statute:** Neb. Rev. Stat. § 71-1908 et seq.; Title 391 NAC Ch. 2 (FCCH I), Ch. 3 (Centers + FCCH II) · **Public inspection portal:** https://www.nebraska.gov/LISSearch/search.cgi (per-licensee) + monthly "CC Negative Actions" PDFs
**Facility types:** Family Child Care Home I (≤10), Family Child Care Home II (≤12, 2 providers), Child Care Center (>12), Preschool, School-Age-Only, Dual License
**Ratios (toughest band):** 6 wks – 18 mo = 4:1
**Inspection cadence:** ≤29 children: ≥1×/yr; ≥30 children: ≥2×/yr; unannounced monitoring anytime; 60-day follow-up after violation
**Renewal:** Annual (provisional 1 yr for new programs)

**State-specific onboarding questions:**
- Are you a new program (first-year provisional license)?
- Will you pursue Dual License (≤12 children under FCCH II ratios)?
- What is your Step Up to Quality level?

**Day-1 auto-generated forms/packs:**
- Child Care License Application (initial / provisional)
- Dual License Application and Agreement (if applicable)
- Health Information Report per staff (391 NAC 3-006.03F)
- Background packet: NSP + FBI + SOR + CPS Central Registry
- Annual Immunization Report per 173 NAC 4

**Wall-posting auto-print pack:**
- Current license (lesser of DHHS-approved and Fire Marshal capacity)
- Ratio chart (391 NAC 3-006.15C)
- Communicable disease notification protocol
- Written exclusion policy (fever, diarrhea, vomiting, chickenpox, measles)
- Mandated reporter (1-800-652-1999)
- Fire evacuation map

**Top 3 inspection-killer nags:**
1. "Same-day notification required: {illness} observed — auto-send to all enrolled families now?"
2. "Capacity conflict: Fire Marshal approval is {N}, DHHS is {M} — your license is the lesser. Current enrollment {X} — pause new intake if over."
3. "Staff must be awake and alert during naps — nap-room supervisor schedule missing for {PM block}. Fix before your next semi-annual."

**Inspection-day one-tap pack:**
- License + last negative-action PDF (check monthly ccnegactions feed)
- Staff files: NSP+FBI+SOR+CPS checks, Health Info Reports, law-enforcement-contact disclosures
- Annual immunization report (173 NAC 4)
- Child files: enrollment, immunization, health history
- Fire + sanitation inspection certs
- Exclusion policy + communicable disease log

**State quirks:**
- DHHS publishes monthly "CC Negative Actions" PDFs on the 5th — your own license changes show up fast, but so do competitors' enforcement actions
- Capacity is the **lesser** of DHHS + Fire Marshal — we show both and warn before over-enrolling

### Idaho
**Regulator:** ID Department of Health and Welfare (IDHW) Division of Family and Community Services; inspections by 7 regional public health districts (EIPH, CDHD, SWDH, etc.) · **Statute:** Idaho Code §§ 39-1101 to -1120 (Basic Day Care License Law); IDAPA 16.06.02 (esp. 16.06.02.335 point-based ratios); HB 243 (2025) · **Public inspection portal:** https://www.idahochildcarecheck.org/
**Facility types:** Family Daycare Home (≤6, license optional), Group Daycare Facility (7–12, licensed), Daycare Center (≥13, licensed)
**Ratios (toughest band):** Point-based — infant 0–24 mo = 2.000 pts/child, 12 pts/staff max (effectively 6:1 infants)
**Inspection cadence:** ~1 unannounced/yr by regional health district + IDHW; complaint-driven follow-ups
**Renewal:** Annual; enhanced background every 5 yrs for owner/operator

**State-specific onboarding questions:**
- Which regional public health district are you in (EIPH/CDHD/SWDH/SCDH/PHD/NCDPH/PHD3)?
- Are you inside Boise (or other city with stricter local rules)?
- Family Home (≤6): voluntary license? (required only if ICCP subsidy)

**Day-1 auto-generated forms/packs:**
- Day Care License Application (IDHW)
- Enhanced Background Check Request per staff/household ≥13
- Fire Marshal Inspection Report coversheet
- Public Health District Inspection Report coversheet (routes to your district)
- CPR / Infant-Child CPR / pediatric rescue breathing certification log

**Wall-posting auto-print pack:**
- IDHW license
- Point-based ratio calculator for current classroom composition
- Safe sleep poster (no car seats/swings/slings; one infant per crib)
- Mandated reporter hotline (1-855-552-KIDS)
- Fire evacuation map + playground/kitchen/diaper inspection dates

**Top 3 inspection-killer nags:**
1. "Classroom points: {room} at 12.8 / 12 — over limit. Move 1 toddler to meet 12-pt cap or add a qualified staff."
2. "Enhanced background check 5-yr rescreen due in 30 days for {owner/operator} — required per IDAPA 16.06.02."
3. "Infant {name} seen sleeping in car seat at 2:14 PM — safe-sleep violation. Move to crib, document correction."

**Inspection-day one-tap pack:**
- IDHW license + idahochildcarecheck.org provider page
- Per-staff CPR (infant-child + pediatric rescue breathing) certificates
- Background clearance letters
- Point-based ratio printouts per classroom per time block
- Fire Marshal + PHD sanitation certs (annual)
- Substantiated incidents log (idahochildcarecheck history)

**State quirks:**
- **2026 context:** 2025 HB 243 deregulation + unique point-based ratio (12 pts/staff cap) — our ratio engine calculates in points, not bodies
- Cities like Boise add stricter local rules on top of state — we layer the local overlay when detected

### West Virginia
**Regulator:** WV Department of Human Services (DoHS) Bureau for Family Assistance, Division of Early Care and Education (ECE) — post-2024 reorg from DHHR BCF · **Statute:** W. Va. Code § 49-2-801 et seq.; Title 78 CSR Series 1 (Child Care Centers); Appendix 78-1 E (ratio tables A + B) · **Public inspection portal:** https://www.wvdhhr.org/bcf/ece/cccenters/ecewvisearch.asp (classic ASP; get_details.asp?q={providerID})
**Facility types:** Child Care Center, Family Child Care Facility, Family Child Care Home, Informal/Relative, School-Age-Only, Day Camp
**Ratios (toughest band):** 6 wks – 12 mo = 4:1, max group 8; Water-activity ratio (≤12 mo) = 1:1
**Inspection cadence:** Unannounced anytime
**Renewal:** License up to 2 yrs; apply ≥60 days before expiration

**State-specific onboarding questions:**
- Do you have a pool / splash pad / plan water trips (Table B ratios apply)?
- Do you provide evening / overnight care (hourly nap checks required)?
- Any Youth Apprentice / Student Intern ≥17 in CDS program (may count in ratio, may not work alone)?

**Day-1 auto-generated forms/packs:**
- Center Licensure Application (initial / renewal)
- Background packet: WV State Police + FBI + WV CAN Registry + Sex Offender
- TB risk assessment / screening template per staff
- Emergency Plan / Evacuation Plan template
- Fire Marshal + OEHS sanitation inspection coversheets

**Wall-posting auto-print pack:**
- Current license
- Table A ratio chart (78-1 E) + Table B water-activity chart
- Safe sleep poster + infant nap-area visibility rule
- Mandated reporter (1-800-352-6513)
- Fire evacuation map
- No-child-unattended-in-vehicle notice

**Top 3 inspection-killer nags:**
1. "Water activity planned {date} with {N} infants — Table B requires 1:1 for ≤12 mo. You currently have {X} staff assigned. Add staff now."
2. "Nap-room visibility: infant room requires qualified staff IN the nap area with line-of-sight + hearing at all times — staff assignment currently {name} covering 2 rooms. Split now."
3. "Renewal packet due in 60 days — fire, OEHS, and food-service certs must be current. Missing: {list}. Schedule now."

**Inspection-day one-tap pack:**
- License (up to 2-yr term) + get_details.asp non-compliance history
- Staff background + TB + annual PD log + CPR/First Aid
- Director qualification file (78-1-9.1.h)
- Substitute plan (qualified sub for >2 weeks absence)
- Child files: enrollment, immunization, emergency, school contact (school-age)
- Fire Marshal + OEHS sanitation + food service certs

**State quirks:**
- Qualified staff definition excludes cooking / bookkeeping / lifeguarding — we flag any staff wearing two hats so your ratio count is honest
- "Chart of Open Providers" on DoHS site is stale (2021 vintage) — our export is your source of truth until DoHS refreshes

### Hawaii
**Regulator:** DHS BESSD Child Care Licensing (PATCH handles staff registry) · **Statute:** HRS §346-151 et seq.; HAR 17-891.2 / 892.1 / 895.1 · **Public inspection portal:** https://childcareprovidersearch.dhs.hawaii.gov/ (license status only — no violation history online; UIPA request required)
**Facility types:** Family CCH (≤6), Group CCH (7-12), Group Center (13+, ages 2+), Infant & Toddler Center (6wk-36mo)
**Ratios (toughest band):** Infant/Toddler 1:3 to 1:4 (6wk-24mo); Group Center age-2s 1:8
**Inspection cadence:** 1 annual on-site monitoring + unannounced complaint visits; county fire/health separate
**Renewal:** 1 year for first 4 years, then 2-year cycle possible

**State-specific onboarding questions:**
- Which island/unit are you under (Oahu-1, Oahu-2, East Hawaii, West Hawaii, Maui, Kauai)?
- Do you serve children under 24 months (triggers HAR 17-895.1 Infant/Toddler license, NOT Group Center)?
- Is every staff member currently active on the PATCH Early Childhood Registry?

**Day-1 auto-generated forms/packs:**
- DHS 1300/1301 — Child Care Center License Application — pre-fills facility info, capacity, hours, island unit routing
- DHS 1305 — Family CCH Registration — pre-fills operator, address, household member list
- Form 314-C — Criminal History / CANIS clearance request — one-click batch for every staff + 18+ household member
- HRS §321-22 TB Clearance (Form 14) — generates tracker for every child AND staff (Hawaii is one of few states requiring child TB)
- PATCH Registry Application — auto-packages staff education docs for PATCH evaluation

**Wall-posting auto-print pack:**
- Current DHS license (with island unit contact)
- Staff PATCH Registry status chart
- Fire evacuation plan + county-specific fire marshal contact
- Emergency/disaster plan (tsunami + hurricane section — Hawaii-specific)
- Daily schedule and posted ratios by room
- Mandated reporter / CPS hotline notice

**Top 3 inspection-killer nags:**
1. "Aiden (staff) has no active PATCH Registry record — he CANNOT count toward ratio until PATCH evaluates him. Upload transcript now."
2. "3 children are missing current TB clearance (Hawaii requires it on admission). Print letters to parents?"
3. "You have a 22-month-old enrolled in your Group Center room. Hawaii bars under-24mo in Group Centers — move her to your I/T license or request variance."

**Inspection-day one-tap pack:**
- Current DHS license
- PATCH Registry printout for every staff
- Child immunization + TB + physical packet (one PDF per child)
- Staff criminal + CANIS + TB log
- Last 12 months of fire & sanitation inspection reports
- Ratio-by-room log for the day
- Incident/accident log (current license year)

**State quirks:**
- Island-divided licensing units — complaint response is slow on neighbor islands; plan accordingly
- TB clearance required for children AND staff (nearly unique to Hawaii)
- Inspection/violation history is NOT online — HHS-OIG has flagged Hawaii as out of compliance on CCDBG transparency (2020 audit), so parents can't easily see competitor deficiencies

### New Hampshire
**Regulator:** NH DHHS Child Care Licensing Unit (CCLU) · **Statute:** RSA 170-E; He-C 4002 (readopted 2025-08-26) · **Public inspection portal:** https://new-hampshire.my.site.com/nhccis/NH_ChildCareSearch (last 3 yrs of monitoring + CAPs)
**Facility types:** Family CC (≤6), Family Group CC (≤12), Group Center, Preschool, Infant/Toddler, School-Age, Night Care
**Ratios (toughest band):** Infants 6wk-12mo 1:4 (max group 12); 13-24mo 1:5; mixed-age uses AVERAGE age (unusual)
**Inspection cadence:** At least 1 unannounced on-site per 3-year license cycle + complaint visits
**Renewal:** 3 years (unusually long)

**State-specific onboarding questions:**
- Which He-C 4002 program type are you (Family / Family Group / Group Center / Preschool / I/T / School-Age / Night Care)?
- Do you mix ages across groups (triggers NH's unique AVERAGE-age ratio rule with documentation requirement)?
- When was your last CCLU monitoring visit (so we can time your 3-year renewal correctly)?

**Day-1 auto-generated forms/packs:**
- CCLU Child Care Licensing Application — pre-fills facility data, program type, RSA 170-E disclosures
- Personnel Information Form — generated per staff with RSA 170-E:7 background check release (state + FBI + CAN registry + every state of residence past 5 yrs)
- Child Health Form + RSA 141-C:20-a immunization record — per child
- Fire Marshal Inspection request packet — pre-addressed to local fire marshal (2-year cycle tracker)
- Corrective Action Plan template for every rule flagged "critical" in He-C 4002

**Wall-posting auto-print pack:**
- Current NH license + program type
- He-C 4002 critical rules summary (so staff know which violations auto-trigger CAP)
- Fire evacuation plan + last fire marshal inspection date
- Emergency/disaster plan
- Mandated reporter poster (RSA 169-C)
- Parent grievance/complaint procedure with CCLU contact (603-271-4624)

**Top 3 inspection-killer nags:**
1. "Your 3-year-old room is running 1:10 today — mixed-age AVERAGE rule lets you stay compliant only if you document the average age in the room log. Log it now."
2. "5+ children present and only 1 staff in the building. He-C 4002 requires a second adult at 5+ children — call backup or pause admissions."
3. "Staff member Maria's background check is 4 years 10 months old. NH requires re-check every 5 years — start her re-run today to avoid lapse."

**Inspection-day one-tap pack:**
- Current 3-year license + any CAPs open/closed
- Personnel file per staff (BGC, references, health, quals, CPR/First Aid, 18 hrs/yr training log)
- Child files (health, immunization, emergency authorization)
- Ratio + group-size log (with average-age documentation for mixed groups)
- Fire marshal cert (current 2-year cycle)
- Incident/accident + critical-rule CAP history

**State quirks:**
- Mixed-age groups use AVERAGE age (not youngest) — NH-only
- 3-year license cycle is longer than almost any other state; administrative fines authorized under He-C 4002 (rare in Northeast)
- Portal publishes licensing history — any critical-rule violation is visible to parents

### Maine
**Regulator:** Maine DHHS OCFS Children's Licensing and Investigation Services (CLIS) · **Statute:** 22 M.R.S. §8301-A; 10-148 CMR Ch. 32 (centers) / Ch. 33 (family) · **Public inspection portal:** https://search.childcarechoices.me/ (3-yr rolling window of reports)
**Facility types:** Child Care Center (13+), Small CCF (3-12), Nursery School (half-day), Family CCP (home, ≤12)
**Ratios (toughest band):** Infants 6wk-1yr 1:4 (max group 8); young toddlers 1:4-1:5
**Inspection cadence:** 1 unannounced per license term, MUST fall within 6-18 months of issuance (statutory window)
**Renewal:** 2 years; renewal due 60 days before expiration

**State-specific onboarding questions:**
- Is this a Center (13+), Small Facility (3-12), Nursery School, or Family Provider?
- Do you operate more than 4 hours/day (triggers mandatory 60-min outdoor play rule, including winter)?
- When was your license issued (so we can predict your 6-18-month inspection window)?

**Day-1 auto-generated forms/packs:**
- OCFS-CLIS Child Care Licensing Application — pre-fills facility data + license type
- Background Check Authorization (state BCI + FBI fingerprint + ME child abuse registry) — per staff, 5-year re-run scheduler
- Child Health Information Form — immunization + physical, 30-day grace tracker
- State Fire Marshal inspection request — 2-year cycle auto-reminder
- Outdoor Play Waiver Log (documents any day weather exception was invoked)

**Wall-posting auto-print pack:**
- Current Maine license with Rising Stars rating
- Daily schedule including 60-min outdoor play block
- Fire evacuation plan + last fire marshal cert
- Mandated reporter poster (22 M.R.S. §4011-A)
- Emergency authorization & dismissal policy
- CLIS complaint line (800-791-4080)

**Top 3 inspection-killer nags:**
1. "It's 34°F and raining — you still owe 60 minutes of active outdoor play. Log weather exception with safe-clothing confirmation or take them out in 20-min bursts."
2. "Your license was issued 7 months ago — your unannounced inspection is statutorily due between month 6 and 18. Do the self-inspection simulator now."
3. "3 children hit their 30-day immunization grace-period deadline this week. Generate parent letters for follow-up."

**Inspection-day one-tap pack:**
- Current license + Rising Stars step report
- Staff files (30 hrs/yr training log via Maine Roads to Quality, CPR/First Aid, BGC 5-yr)
- Child files (immunization with grace-period status, physical, emergency auth)
- Fire marshal cert
- Daily outdoor-play log (with weather exceptions)
- 3-year record retention compliance check

**State quirks:**
- 60-min outdoor play is MANDATORY daily, including winter (unique rigor for cold-climate state)
- Statutory 6-18-month inspection window — you can't just assume "annual"; it's a fixed range
- Enforcement posture is lax: Maine Monitor (2024) found 16,000+ citations since 2021, zero revocations, zero fines ever assessed — but the reports ARE public, so reputation damage is real

### Montana
**Regulator:** MT DPHHS Early Childhood Services Bureau · **Statute:** MCA Title 52 Ch. 2 Part 7; ARM Title 37 Ch. 95 (post-HB 422 ratios) · **Public inspection portal:** https://webapp.sanswrite.com/MontanaDPHHS/ChildCare (SansWrite X — 3-yr history with PDFs; complaints with no citations not posted)
**Facility types:** Family CCH (≤6), Group CCH (≤12), Child Care Center (13+), Drop-In Center
**Ratios (toughest band):** Birth-12mo 1:4; 1-year-olds 1:6 (HB 422 loosened from 1:4); 2yr 1:8
**Inspection cadence:** Annual renewal inspection + unannounced monitoring + fire marshal annual
**Renewal:** 1 year (annual; 30 days before expiration)

**State-specific onboarding questions:**
- Are you a center (ARM 37.95.205+), family/group home (ARM 37.95.601+), or drop-in (ARM 37.95.1105+)?
- Is every staff member listed on the Early Childhood Practitioner Registry with a current level (required to count toward ratio)?
- Does your county sanitarian (local public health) have you on file for an active Certificate of Approval?

**Day-1 auto-generated forms/packs:**
- DPHHS-CCL-1 — Child Care Center License Application — pre-fills facility data
- DPHHS-CCL Family/Group Registration Application — for home-based providers
- Child Care Background Check Form (Centralized Background Check Unit: state + FBI + CPS)
- Practitioner Registry submission packet — pre-packages staff education/transcripts for registry evaluator
- Local health sanitarian Certificate of Approval request letter (pre-addressed to county sanitarian)

**Wall-posting auto-print pack:**
- Current DPHHS license/registration
- HB 422 post-2023 ratio chart (so staff use current numbers, not pre-2023)
- Fire marshal cert (annual — required for renewal)
- Local sanitarian Certificate of Approval
- Emergency/evacuation plan
- Mandated reporter + CPS hotline

**Top 3 inspection-killer nags:**
1. "Your annual fire marshal inspection expires in 30 days. MT DPHHS will not process your renewal without a current cert — schedule now."
2. "Sarah's Practitioner Registry level expired 2 weeks ago. She CANNOT count toward ratio until she completes 16 hrs of CE and renews. She's on the floor today at 1:6 — pull her or bring in another registered staff."
3. "Your 1-year-old room is running 1:7 — HB 422 allows 1:6. Call a sub or reduce enrollment by 1 child today."

**Inspection-day one-tap pack:**
- Current license + recent SansWrite inspection history
- Practitioner Registry printout per staff
- Staff orientation records (CPR/First Aid within 30 days, Infant Safety 2hr, Health/Safety 6hr, Together We Grow 3hr)
- Child records (immunization per DPHHS schedule, physician statement, emergency consent)
- Fire marshal + sanitarian certs
- Post-HB 422 ratio log per room

**State quirks:**
- HB 422 (2023) loosened ratios — if your internal docs still reference pre-2023 numbers, you're overstaffing
- Sanitarians are LOCAL (county), fire is STATE — dual track
- SansWrite portal publishes inspection history; API returns address/phone redacted but inspection data is discoverable

### Rhode Island
**Regulator:** RI DHS Office of Child Care (day care); DCYF handles enforcement referrals for unlicensed operators · **Statute:** R.I. Gen. Laws §40-13.2; 218-RICR-70-00-1/2/7 · **Public inspection portal:** https://earlylearningprograms.dhs.ri.gov/ (RISES — Salesforce, last 3 yrs)
**Facility types:** Child Care Center (13+), School-Age Program, Family CCH (≤6), Group Family CCH (≤12)
**Ratios (toughest band):** Younger infants 6wk-12mo 1:4 max group 8 — NO EXCEPTIONS; toddlers 18-36mo 1:6
**Inspection cadence:** 2 unannounced monitoring visits per year (double most states)
**Renewal:** 2 years; initial license is 6-month Provisional then converts

**State-specific onboarding questions:**
- Are you DHS-licensed day care or DCYF-residential (we ONLY support DHS day care — DCYF is a different regulator)?
- Do you participate in BrightStars QRIS (affects CCAP subsidy rate and is posted publicly)?
- Do you have 45 sq ft of usable floor space per child in infant/toddler rooms (explicit 218-RICR-70-00-1.8 requirement)?

**Day-1 auto-generated forms/packs:**
- DHS Center / Program License Application — pre-fills facility data, license type, capacity per room (with 45 sq ft check)
- Family CCH / Group Family Application — for home-based providers
- Comprehensive Background Check release (state BCI + FBI + CAN + sex offender) — per staff/household 18+, 5-year re-run
- Child Immunization Record (R23-1-IMM compliant) — per child
- Fire Marshal Certificate request + DOH Food Service Permit (if meals prepared)

**Wall-posting auto-print pack:**
- Current DHS license + BrightStars rating
- Room ratio chart with "NO EXCEPTIONS to infant ratio" call-out
- 45 sq ft/child floor plan for infant/toddler rooms
- Fire evacuation plan
- Mandated reporter + DCYF hotline (1-800-RI-CHILD)
- Emergency authorization + pickup policy

**Top 3 inspection-killer nags:**
1. "You have 9 infants in the infant room. 218-RICR-70-00-1 sets max group 8 with NO exceptions. You cannot combine groups or average — move one child NOW."
2. "Provisional license expires in 14 days. Schedule your DHS monitoring visit to convert to Regular or you lose legal authority to operate."
3. "DHS visits 2x/year unannounced in RI — your last visit was 7 months ago. Run the self-inspection simulator so the next surprise visit is a formality."

**Inspection-day one-tap pack:**
- Current license (Provisional or Regular) + BrightStars certificate
- Staff files (BGC 5-yr, CPR/First Aid, health, quals, PD log)
- Child files (immunization, physical, emergency auth, infant daily reports)
- Fire marshal + DOH food permits
- Room floor-plan with 45 sq ft calc per child
- Current ratio log + last 3 yrs monitoring reports/CAPs

**State quirks:**
- Two unannounced monitoring visits per YEAR (most states do 1 per license cycle)
- NO EXCEPTIONS to infant ratios (no combining, no averaging, absolute)
- Dual-authority: DHS for day care, DCYF for residential and unlicensed-operator prosecution (AG referral)

### Delaware
**Regulator:** DE DOE Office of Child Care Licensing (OCCL) · **Statute:** 14 DE Admin. Code 101 (DELACARE); 31 Del. C. Ch. 3 Subch. IV · **Public inspection portal:** https://education.delaware.gov/families/birth-age-5/occl/search_for_licensed_child_care/ + Socrata feeds (wb83-pkcv compliance, pnbd-85r6 complaints) — 5-YEAR retention
**Facility types:** Family CCH (≤6), Large Family CCH (7-12), Early Care & Education Center (13+), School-Age Center
**Ratios (toughest band):** Infants 0-12mo 1:4 max group 8; young toddlers 12-24mo 1:6
**Inspection cadence:** Annual unannounced monitoring + complaint visits
**Renewal:** 1 year (annual)

**State-specific onboarding questions:**
- Are you a Center, Large Family CCH, or Family CCH (drives which DELACARE rule applies)?
- Do you participate in Delaware Stars QRIS (ties to subsidy reimbursement)?
- Have you reviewed the public OCCL search page for YOUR facility (5 years of deficiencies are visible to parents)?

**Day-1 auto-generated forms/packs:**
- DELACARE Center License Application — pre-fills facility, capacity, county office routing (New Castle vs. Kent/Sussex)
- Family / Large Family CCH Application — for home-based
- Comprehensive Background Check (DE SBI + FBI + CPR + Adult Abuse + Sex Offender) — per staff + household 18+, 5-year re-run
- DE Delaware Immunization Program child record — per child
- State Fire Marshal Approval Letter request + DPH food permit (if meals prepared)

**Wall-posting auto-print pack:**
- Current DELACARE license + Delaware Stars level
- Daily ratio chart by room
- Fire marshal approval
- Emergency plan
- Mandated reporter + DE CPS hotline (1-800-292-9582)
- Nondiscrimination + parent grievance policy

**Top 3 inspection-killer nags:**
1. "Your public OCCL page shows a 2-year-old non-compliance that's still visible to parents. Resolve or respond publicly — DE shows 5 YEARS of history (longer than any other state)."
2. "Janelle's 5-year background re-check is due in 45 days. DE OCCL will flag this on your next unannounced visit. Start re-run packet now."
3. "Toddler room 2 has 13 kids (24-36mo). DELACARE caps at 16 max group but ratio must be 1:8 — you're running 1:13 with only one caregiver. Get a second staff in before transition today."

**Inspection-day one-tap pack:**
- Current DELACARE license + Delaware Stars cert
- Staff files (BGC 5-yr re-run status, Delaware First PD registry, CPR/First Aid, mandated reporter, quals)
- Child files (DE immunization, health appraisal, emergency auth)
- Fire marshal approval + DPH food permit
- Ratio + group-size log per room
- Last 5 years OCCL inspection Socrata export

**State quirks:**
- 5-year public transparency window (vs. federal 3-yr floor) — DE surfaces MORE deficiency history than any state
- Licensing moved from DSCYF to DOE in 2015 — Delaware is the rare state where DOE (education) not HHS/DSS regulates child care
- Three Socrata feeds make DE's compliance data machine-readable (benchmark other states' quirks don't have)

### South Dakota
**Regulator:** SD DSS Office of Licensing and Accreditation (OLA) · **Statute:** SDCL Title 26 Ch. 26-6; ARSD 67:42 · **Public inspection portal:** https://olapublic.sd.gov/child-care-provider-search/ (4-year history, PDFs)
**Facility types:** Licensed Child Care Program/Center (13+), Before & After School, Registered Family Day Care (≤12), Group Family Day Care
**Ratios (toughest band):** Infants <12mo 1:5 max group 10 (looser than most states); 3yr 1:10; school-age 1:20
**Inspection cadence:** Annual monitoring (announced baseline) + unannounced + complaint visits
**Renewal:** 1 year (annual)

**State-specific onboarding questions:**
- Do you care for any children NOT related to you (triggers required registration at minimum — ARSD 67:42:10)?
- Are you a Licensed Center (13+), Registered Family (≤12), or Group Family Day Care?
- Do you participate in CACFP / Head Start (adds USDA record-keeping on top of state requirements)?

**Day-1 auto-generated forms/packs:**
- OLA Constituent Portal Application packet (applications ONLY go through `olapublic.sd.gov`)
- DCI Fingerprint Card request (state + FBI) + Central Registry check — per staff/volunteer/household 18+
- SD DOH Immunization Record (SDCL 13-28-7.1 compliant) — per child
- Fire Marshal Inspection request (required for centers at initial + renewal)
- Correction plan template (auto-files via portal if deficiency cited)

**Wall-posting auto-print pack:**
- Current OLA license/registration
- Room ratio chart (ARSD 67:42:17:19)
- Fire marshal cert
- Evacuation + tornado/severe weather plan (SD-critical)
- Mandated reporter + SD CPS hotline
- Emergency contacts + authorized pickup policy

**Top 3 inspection-killer nags:**
1. "Your public OLA page shows inspection history for 4 years — run the self-inspection simulator, because DSS publishes every deficiency with PDF attachments."
2. "Central Registry check on Tom expired 30 days ago. SDCL 26-6-14.4 requires this for every adult in care settings — no unsupervised access until rerun."
3. "Tornado season starts April 1. Log your severe-weather drill within the next 7 days — inspectors look for this in the Upper Midwest."

**Inspection-day one-tap pack:**
- Current OLA license + last 4 yrs profile printout
- Staff files (DCI+FBI fingerprint, Central Registry, sex offender, CPR/First Aid, 20 hrs/yr CE)
- Child files (immunization per SDDOH, health statement, emergency auth)
- Fire marshal + local sanitarian certs
- Ratio + group-size log per room
- Tornado/severe-weather drill log

**State quirks:**
- Small state (~700-750 programs) — OLA staff may know you personally; complaint response fast
- No general FOIA — access governed by SDCL 1-27 open records (looser than neighbor states)
- Full constituent-portal workflow: applications, renewals, incidents, corrections ALL go through olapublic.sd.gov

### North Dakota
**Regulator:** ND DHHS Early Childhood Services — Early Childhood Licensing Unit · **Statute:** NDCC Ch. 50-11.1; NDAC Article 75-03 (ch. 08 family, 09 group, 10 center, 11 school-age, 12 self-declaration, 14 preschool) · **Public inspection portal:** DHHS CCL System online search tool (3-year history, launched 2023)
**Facility types:** Self-Declared (≤5), Family CC (≤7), Group CC (≤18), Child Care Center (19+), School-Age, Pre-School
**Ratios (toughest band):** Infant 0-12mo 1:4 max group 8; 12-23mo 1:5; 24-35mo 1:7
**Inspection cadence:** 2 monitoring visits per year (1 announced + 1 unannounced) + complaint
**Renewal:** 2 years for centers/homes (biennial); Self-Declared annually

**State-specific onboarding questions:**
- Do you qualify as Self-Declared (≤5 children, ≤3 under 24 months — optional but subsidy-eligible)?
- Are you on the ND CCL System (2023 online portal — ALL renewals and monitoring uploads run through it)?
- Does your facility size push you into Group (≤18) vs. Center (19+) — different rule chapter (75-03-09 vs. 75-03-10)?

**Day-1 auto-generated forms/packs:**
- Application for Early Childhood License — pre-fills via CCL System
- SFN 847/530 — Child health history & immunization
- SFN 1259 — Self-Declaration registration (if applicable)
- Criminal History Record Check authorization (state BCI + FBI fingerprint per NDCC 50-11.3) + CPS record check + Sex Offender
- Fire Marshal + local public health (sanitation) inspection request packets

**Wall-posting auto-print pack:**
- Current DHHS Early Childhood Services license
- Ratio chart (NDAC 75-03-10-08 for centers)
- Fire marshal cert + local health sanitation cert
- Emergency/evacuation + severe-weather plan
- Mandated reporter + ND CPS hotline
- Discipline policy (state-required)

**Top 3 inspection-killer nags:**
1. "Your announced monitoring visit is due this quarter (ND does 2/year — 1 announced, 1 unannounced). Pick 3 dates in your CCL portal."
2. "Center teacher Emily is at 17 of 24 required CE hours for the year (ND is above federal floor). Post Northern Lights-equivalent training links now."
3. "Household member Craig (18) hasn't cleared NDCC 50-11.3 fingerprint check. He has unsupervised access during pickup — suspend access until cleared."

**Inspection-day one-tap pack:**
- Current license pulled from CCL System
- Staff files (BCI+FBI, CPS, sex offender, CPR/First Aid, 24 hrs/yr CE for centers / 9 hrs for family)
- Child files (SFN 847/530, immunization, 90-day physical)
- Fire marshal + local health certs
- Ratio + group-size log per room
- 3-year monitoring history from CCL search

**State quirks:**
- Self-Declared tier is nationally unusual: legal for ≤5 children with ≤3 under 24 months, registration optional, subsidy-eligible
- CCL System was launched in 2023 — schema and features still evolving through 2026; plan for periodic integration rework
- 24 hrs/yr CE for center staff is well above the CCDBG floor of 10-12

### Alaska
**Regulator:** AK DOH DPA Child Care Program Office (CCPO) statewide; Municipality of Anchorage (MOA) Child Care Licensing is delegated local authority · **Statute:** AS 47.32; 7 AAC 57; AMC 16.55 (Anchorage) · **Public inspection portal:** AKCCIS https://akccis.com (statewide — license status) + MOA Socrata Childcare Inspections https://data.muni.org/Public-Health/Childcare-Inspections/abmr-hyh6/data (Anchorage — machine-readable 2008+)
**Facility types:** Child Care Home (≤8, ≤3 under 30mo), Group CCH (≤12), Child Care Center (13+), School-Age
**Ratios (toughest band):** Infant 0-18mo 1:5 max group 10; Toddler 19-36mo 1:6
**Inspection cadence:** Annual renewal inspection + random unannounced + complaints; 24-hr serious incident reporting
**Renewal:** 2 years (biennial), at least 30 days before expiration

**State-specific onboarding questions:**
- Is your facility INSIDE Anchorage city limits (MOA licenses + AMC 16.55 applies, parallel to 7 AAC 57) or outside (CCPO only)?
- Does any staff have a history requiring an Alaska Barrier Crimes Act (AS 47.05.310) variance?
- Do all staff have a current SEED Registry (Alaska Early Childhood Registry) account for tracking PD hours?

**Day-1 auto-generated forms/packs:**
- CC-501 — Application for Child Care Facility License (CCPO or MOA based on address)
- CC-35/CC-36 — Background Check Request (ABI fingerprint + FBI + Barrier Crimes Act screening) per staff/household 18+
- CC-61 — Parent Guide / Teddy Bear Letter (REQUIRED posting + given to every enrolling family)
- CC-80 series — Serious incident reporting template (24-hr deadline tracker)
- Fire Marshal + environmental health (DEC or local) inspection request

**Wall-posting auto-print pack:**
- Current CCPO/MOA license
- CC-61 Teddy Bear Letter (legally required posting, unique to Alaska)
- Most recent monitoring report (AKCCIS or MOA posts these — required visible)
- Fire inspection cert
- Earthquake + tsunami emergency plan (Alaska-specific hazards)
- Mandated reporter + Barrier Crimes Act disqualification list summary

**Top 3 inspection-killer nags:**
1. "A child was transported by ambulance yesterday. You have 24 HOURS from the incident to file CC-80 to CCPO (7 AAC 57.545). Draft now."
2. "The CC-61 Parent Guide isn't posted at your entrance. It's a required posting unique to Alaska — print and hang before the next unannounced visit."
3. "New hire James shows one Barrier Crime on his ABI return. He cannot have unsupervised contact until CCPO Background Check Unit approves a variance — lock out scheduling now."

**Inspection-day one-tap pack:**
- Current license (CCPO or MOA) + recent monitoring report
- Staff files (ABI+FBI, Barrier Crimes screening, SEED Registry PD record, CPR/First Aid, TB, mandated reporter)
- Child files (AK DOH immunization, physical, emergency consent, authorized pickup)
- Fire + environmental health certs
- CC-61 posting proof + ratio log
- 24-hr serious incident log

**State quirks:**
- Dual-licensor jurisdiction: INSIDE Anchorage = both CCPO (7 AAC 57) AND MOA (AMC 16.55); outside = CCPO only
- Alaska Barrier Crimes Act (AS 47.05.310) is an explicit disqualifier list — variance process required for many common offenses
- 24-hour serious incident reporting window is tighter than most states (per 7 AAC 57.545)

### Vermont
**Regulator:** VT DCF Child Development Division (CDD); BFIS is the operational system · **Statute:** 33 V.S.A. Ch. 35 (§3502, §3511); CVR 13-171-004 (CBCCPP) / 005 (family) / 006 (after-school) · **Public inspection portal:** https://www.brightfutures.dcf.state.vt.us (BFIS — min 5 yrs of violations/CAPs)
**Facility types:** Center Based Child Care and Preschool Program (CBCCPP), Registered Family CCH (≤6 FT + ≤4 PT SA), Licensed Family CCH (≤12 w/ assistant), After-School, Non-Recurring Drop-In
**Ratios (toughest band):** **Infants AND toddlers 6wk-24mo at 1:4** (tightest in nation); young toddler 24-36mo 1:5; 3yr 1:7
**Inspection cadence:** Annual scheduled monitoring + unannounced visits + complaint (14-30 day investigation window)
**Renewal:** 3 years for compliant programs (current CDD practice)

**State-specific onboarding questions:**
- Do you run CBCCPP (CVR 13-171-004) or a Registered/Licensed Family Home (CVR 13-171-005)?
- Does every ratio-counted staff spend ≥90% of assigned time directly with children (Vermont's 90% rule bars floating directors from counting)?
- Are you enrolled in STARS (1-5) and publicly listed in BFIS?

**Day-1 auto-generated forms/packs:**
- BFIS License/Registration Application — pre-fills facility + program type
- Background Records Check (BRC) request — VCIC + FBI fingerprint + CPR + Sex Offender + APS — per staff/household, 5-yr re-run
- Vermont DOH immunization form per child + individual care plan template
- Emergency Preparedness Plan (template aligned to CDD expectations)
- Northern Lights Career Development Center registry setup per staff (system of record for PD hours)

**Wall-posting auto-print pack:**
- Current VT license/registration + STARS level
- Ratio chart with Vermont 1:4 infant/toddler call-out AND "90% direct-care" note
- Fire evacuation plan
- Emergency/severe-weather plan
- Mandated reporter (33 V.S.A. §4913) + CPS hotline
- Parent grievance procedure + CDD contact (800-649-2642)

**Top 3 inspection-killer nags:**
1. "Your toddler room has 5 kids under 24 months with 1 teacher. Vermont mandates 1:4 for BOTH infants AND toddlers — pull a ratio helper NOW (this is the strictest rule in the US)."
2. "Director Janet is being counted toward ratio in the 3-yr room, but she's spending <90% of her time with kids (she takes admin calls). Vermont's 90% rule says she can't count — replace her on the ratio sheet."
3. "Staff member Lee's BRC expires in 60 days. BFIS will flag this publicly on your profile — start VCIC+FBI rerun today."

**Inspection-day one-tap pack:**
- Current CDD license + STARS certificate
- Staff files (BRC 5-yr, Northern Lights PD log, CPR/First Aid, mandated reporter, 90% direct-care attestation)
- Child files (VT DOH immunization, health history, consents, individual care plans)
- Ratio log showing 90% direct-care compliance per staff per shift
- 5-yr BFIS violation history + any open CAPs
- Emergency plan + fire cert

**State quirks:**
- **Tightest infant/toddler ratio in the nation: 1:4 all the way to 24 months + 90% direct-care rule**
- 2026 Vermont State Auditor report found 11 of 40 "standard" citations should have been "serious" — CDD severity classification is in flux; watch for re-scoring of historical visits
- Act 76 (2023) added a 0.44% payroll tax to fund universal child care expansion — affects provider economics

### Wyoming
**Regulator:** WY Department of Family Services (DFS), Division of Early Care and Education · **Statute:** W.S. §14-4-101 through §14-4-116; DFS Rules Ch. 5 (FCCH), Ch. 6 (FCCC), Ch. 7 (CCC) · **Public inspection portal:** https://childcare.dfs.wyo.gov/home/ (substantiated complaints 2019-present; pre-2019 and closed facilities require WPRA request)
**Facility types:** Family Child Care Home (3-10), Family Child Care Center (≤15, 2 caregivers >10), Child Care Center (16+), School-Age
**Ratios (toughest band):** Birth-12mo 1:4 (max group 10 with 3 staff); 12-24mo 1:5; 2yr 1:8
**Inspection cadence:** Annual inspection (announced or unannounced) + unannounced monitoring + complaint
**Renewal:** 1 year (annual certification — note WY uses "certification," not "license")

**State-specific onboarding questions:**
- Does your setup fit FCCH (3-10, solo, Ch. 5), FCCC (≤15, home or other building, Ch. 6), or CCC (16+, Ch. 7)?
- Are you aware WY calls this CERTIFICATION (not licensing) and that lapses require re-application, not simple reinstatement?
- Do you participate in the WY STAR QRIS (voluntary 1-4 stars, tied to subsidy enhancement)?

**Day-1 auto-generated forms/packs:**
- DFS Certification Application (Chapter 5 / 6 / 7 based on facility type)
- Background check packet (WDCI fingerprint + FBI + Central Registry + Sex Offender + every state of residence past 5 yrs) — per staff + household
- WY DOH immunization record + health history per child
- State Fire Marshal (or local) inspection cert request + environmental/sanitation inspection
- Required policies bundle: discipline, illness exclusion, safe sleep, medication, expulsion/suspension

**Wall-posting auto-print pack:**
- Current DFS certification (NOT license — use correct WY terminology)
- Ratio + group-size chart (WY enforces BOTH separately — you can pass ratio but fail group size)
- Fire inspection cert
- Severe-weather + winter-emergency plan (frontier-county specific)
- Mandated reporter + WY CPS hotline
- Written expulsion/suspension policy (CCDBG + DFS required)

**Top 3 inspection-killer nags:**
1. "Your certification lapses in 14 days. Wyoming REQUIRES re-application (not reinstatement) if it expires — submit renewal packet today or you'll restart from zero."
2. "Room B has 11 two-year-olds with 2 staff — ratio 1:5.5 passes, but GROUP SIZE cap is 16 and you've split rooms wrong. WY enforces group size separately. Re-split the rooms."
3. "New hire Mark lived in Colorado 3 years ago. WY (per CCDBG) requires background checks from EVERY state of residence in past 5 years — CO check not yet filed. Block his access."

**Inspection-day one-tap pack:**
- Current DFS certification (active status)
- Staff files (WDCI+FBI, Central Registry, sex offender, multi-state BGC, CPR/First Aid, WY Early Childhood PD record, 15+ hrs/yr training)
- Child files (WY DOH immunization, health, consents, safe-sleep acknowledgment for infants)
- Fire marshal + sanitation certs
- Ratio log AND group-size log per room (both required separately)
- Substantiated complaints history (2019+ from DFS portal)

**State quirks:**
- **Wyoming uses CERTIFICATION, not licensing** — terminology matters in all product copy; lapsed certification requires FULL re-application
- Three parallel cert chapters by setting size (Ch. 5 FCCH / Ch. 6 FCCC / Ch. 7 CCC) — picking the right one drives every downstream form
- Group size AND ratio are enforced SEPARATELY — a room can be in ratio but fail group-size compliance (unusual structure)

---

## 6. Build Order — What We Actually Ship First

The shell (§2) is built ONCE and serves all 50 states. Cartridges (§3–5) ship per state. GTM is ICP-first:

1. **Q2 2026 (now → MVP launch):** Shell + CA / TX / FL cartridges. Covers ~80,000 licensed facilities.
2. **Q3 2026:** NY + PA + IL + OH + GA (rank 4–8). Adds ~49,000 facilities; market now ~129,000 (~65% national).
3. **Q4 2026:** NC + MI + NJ + VA + WA + AZ + TN + MA (rank 9–16). Top-15 states complete.
4. **2027:** Remaining 35 states shipped as volume demand appears — each cartridge is <1 week of work once the shell is stable because 90% is filling this template, not writing new code.

**Sales POV:** a state cartridge is a sales artifact. Every row in §5 is a landing page, a pricing page bullet, a Facebook ad headline, and the exact copy in the owner's first onboarding email. No translation required.

**Engineering POV:** a state cartridge is a YAML file (see §3). The shell consumes it at runtime. Expanding to a new state means hiring a half-time regulatory researcher, not a full-time engineer.

**That's how this becomes TurboTax — not 50 apps, one app with 50 plug-ins.**
