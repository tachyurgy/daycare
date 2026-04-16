# ComplianceKit — Open Questions

Items where defaults were chosen unilaterally during initial architecture work. Each should be reviewed by Magnus before or immediately after MVP launch. Ordered roughly by urgency.

---

## Pre-MVP (decide before 2026-04-23)

### Q1 — SES sandbox exit

AWS SES accounts start in sandbox mode (only verified recipients, 200/day cap). Production sending requires exiting sandbox via a support-ticket request that Amazon reviews. Lead time: typically 24–48 hours but can be up to a week.

- **Default assumption:** ticket submitted Day 1 of MVP week.
- **Change if:** Magnus would rather use Postmark or Resend ($15–20/mo) for faster setup and cleaner deliverability reputation.

### Q2 — Twilio phone number and A2P 10DLC registration

Twilio requires A2P 10DLC brand + campaign registration before high-volume SMS can be sent to US consumers. Unregistered numbers get heavily throttled or blocked by carriers. Registration takes 1–3 weeks.

- **Default assumption:** start with a toll-free number (faster verification, higher cost per SMS) for MVP and file 10DLC in parallel.
- **Change if:** Magnus has a registered brand already or would rather defer SMS and launch with email-only chase messages.

### Q3 — Domain and subdomain split

Docs assume `compliancekit.app` as the TLD, `app.compliancekit.app` for the React app, `api.compliancekit.app` for the backend.

- **Default assumption:** purchase `compliancekit.app` if not already owned.
- **Change if:** Magnus already owns `compliancekit.com` or a similar; update all docs and CORS/cookie domain config accordingly.

### Q4 — Stripe pricing IDs + coupon codes

We referenced $49 Starter / $99 Pro / $199 Enterprise without deciding on annual-discount structure.

- **Default assumption:** monthly only at MVP; 14-day free trial via Stripe; one launch coupon code (`LAUNCH50` = 50% off first 3 months).
- **Change if:** Magnus wants annual plans day 1 (~20% discount is standard).

### Q5 — Free trial payment capture

Stripe supports trials that require a card upfront vs. trials without. With-card has higher conversion; without-card has higher signup volume.

- **Default assumption:** no-card 14-day trial, credit-card prompt at day 12 with reminder email.
- **Change if:** Magnus wants to optimize for paid conversion rather than raw signups.

### Q6 — SMS quiet hours

The Notifications module enforces no SMS before 8 a.m. or after 8 p.m. local to the recipient. Determining recipient's timezone requires either asking them or inferring from phone number area code.

- **Default assumption:** use facility's state to infer timezone for all recipients.
- **Change if:** we need to ask parents/staff for timezone at first upload.

### Q7 — OCR confidence threshold for auto-approval

If OCR returns a result with high confidence (say > 95% on all fields), should the document skip the owner review queue?

- **Default assumption:** always require owner review at MVP. Trust improves only with data.
- **Change if:** Magnus wants an auto-approve path for a handful of obviously-structured document types (e.g., CPR cards with standardized layouts).

### Q8 — Gemini Flash prompt for expiration extraction

The exact prompt/schema for Gemini Flash extraction is not yet written. It shapes OCR accuracy materially.

- **Default assumption:** structured output via Gemini's JSON mode with a strict schema (`{kind, subject_name, issued_at, expires_at, issuer}`). Fall back to null on any uncertainty.
- **Change if:** Magnus has a specific document taxonomy he wants to standardize first.

---

## MVP-week (can be decided during build)

### Q9 — Facility state change mid-subscription

If a facility moves from TX to FL, does compliance history carry over? Does the checklist swap entirely?

- **Default assumption:** state is immutable post-onboarding; changing requires a new facility record. Acceptable friction at MVP volume.
- **Change if:** post-launch we see this happening in practice.

### Q10 — Multi-owner at a single facility

Many facilities have two owners (spouses, co-founders). Both want login access.

- **Default assumption:** one owner account per facility at MVP. Second owner logs in with the same email or asks the primary to forward the magic link.
- **Change if:** this is the #1 complaint from early users.

### Q11 — Data export for churned customers

If a customer cancels, can they export everything? Is there a retention grace period?

- **Default assumption:** 30-day grace post-cancellation with full read access. After 30 days, hard-delete per DSR policy.
- **Change if:** legal/DPA requires a different retention window.

### Q12 — Compliance score formula transparency

Owners will ask why their score is what it is. Do we show the formula?

- **Default assumption:** show the violation list with weights visible, but don't publish the exact aggregation formula.
- **Change if:** transparency becomes a differentiator vs. competitors.

### Q13 — Inspector-facing PDF format

Each state inspector has preferences. Florida inspectors are often shown binders organized by CF-FSP form number. Texas inspectors follow HHSC Chapter 746 section order.

- **Default assumption:** single PDF layout ordered by our internal section hierarchy at MVP.
- **Change if:** real inspector feedback demands state-specific layouts.

### Q14 — Signed document legal weight

Our self-built signing (ADR-006) is audit-trail-good but not ESIGN/UETA-compliant-grade.

- **Default assumption:** positioned as internal record-keeping, not legally-binding contracts.
- **Change if:** a customer asks for signature artifacts they'd use in litigation — then we layer in a qualified vendor.

---

## Post-MVP

### Q15 — CACFP (food program) module

Many daycares participate in CACFP and track meal counts for USDA reimbursement. We're out-of-scope at MVP but this is a common ask.

- **Default assumption:** evaluate as a Pro-tier add-on in Week 5.
- **Change if:** it's ICP-defining and should move earlier.

### Q16 — Inspector portal

A read-only portal for inspectors to walk into a facility and see everything without the owner logging in.

- **Default assumption:** roadmap item Q3 of 2026. Requires trust signals (SOC 2 at minimum).
- **Change if:** a state agency expresses interest in partnership.

### Q17 — Bring-your-own-state

Users in states not yet supported (e.g., Georgia, Arizona). Do we let them use a generic checklist with state rules disabled?

- **Default assumption:** no at MVP — we say "coming soon" and capture their email.
- **Change if:** we're getting material organic signup traffic from non-supported states.

### Q18 — Multilingual UI

Many daycare staff in CA/TX are Spanish-dominant. Upload portal UX in Spanish would materially increase completion rates.

- **Default assumption:** English-only at MVP, Spanish in Week 4 for the parent/staff upload portals only.
- **Change if:** early usage data shows abandonment correlated with Spanish speakers.

### Q19 — AI features as upsell

Gemini Flash is already in the stack. Natural language dashboard queries ("show me everything that expires in March") are a few days of work.

- **Default assumption:** not at MVP.
- **Change if:** Pro tier needs a flashier differentiator.

### Q20 — Customer support tooling

No support tool picked. Intercom, Help Scout, or just a shared `help@compliancekit.app` inbox.

- **Default assumption:** `help@compliancekit.app` forwards to Magnus's email at MVP.
- **Change if:** support volume exceeds 30 min/day consistently — then Help Scout ($20/mo).

---

**End of QUESTIONS.md.** Review cadence: weekly during first month, monthly after that.
