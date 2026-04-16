# Sub-processors List

> **DISCLAIMER:** This is a draft template, not legal advice. Have an attorney licensed in your state review before use.

**Effective Date:** {{EFFECTIVE_DATE}}
**Last Updated:** {{EFFECTIVE_DATE}}
**Version:** 1.0.0

{{COMPANY_LEGAL_NAME}} ("**ComplianceKit**") uses the following sub-processors to help deliver the ComplianceKit service (the "**Service**"). A sub-processor is a third-party vendor that may process Personal Data of our customers' Data Subjects on our behalf.

This page is maintained as a **living document**. We provide at least **30 days' advance notice** before adding or replacing a sub-processor, as described in our [Data Processing Agreement](./data-processing-agreement.md) Section 9.

---

## Receive Sub-processor Change Notifications

To receive email notifications when we add or change sub-processors, subscribe here: **[Subscribe placeholder — replace with signup form or list-link]**. Customers on a paid plan are automatically notified via the email address on file.

---

## Current Sub-processors

| # | Sub-processor | Entity / Parent | Location of Processing | Purpose | Categories of Data Accessed | Vendor DPA / Security Page |
|---|---------------|------------------|--------------------------|---------|------------------------------|------------------------------|
| 1 | **Amazon Web Services (S3)** | Amazon Web Services, Inc. | United States (us-west-2, us-east-1) | Object storage for Customer Content (documents, images, audit-trail JSON) | All uploaded documents, derived images, audit-trail files | https://aws.amazon.com/compliance/data-privacy/ |
| 2 | **Amazon Web Services (SES)** | Amazon Web Services, Inc. | United States | Transactional email delivery (account, billing, compliance alerts) | Recipient email address, email body, metadata | https://aws.amazon.com/compliance/data-privacy/ |
| 3 | **Stripe** | Stripe, Inc. | United States | Payment processing for subscription billing | Billing contact info, last-4 card digits, Stripe customer ID | https://stripe.com/privacy and https://stripe.com/legal/dpa |
| 4 | **Twilio** | Twilio Inc. | United States | SMS and push notifications | Recipient phone number, message body, delivery metadata | https://www.twilio.com/legal/data-protection-addendum |
| 5 | **Mistral AI** | Mistral AI SAS | European Union (with U.S. endpoint as applicable) | AI-assisted OCR and structured data extraction from uploaded documents | Document contents at time of processing (not retained by vendor beyond processing window) | https://mistral.ai/terms/ |
| 6 | **Google (Gemini API)** | Google LLC | United States | AI-assisted OCR and document parsing | Document contents at time of processing (not used for model training per Gemini API enterprise terms) | https://cloud.google.com/terms/data-processing-addendum |
| 7 | **DigitalOcean** | DigitalOcean, LLC | United States (NYC3, SFO3) | Compute (application servers) and managed database hosting | All Customer Data at rest in managed database | https://www.digitalocean.com/legal/data-processing-agreement |
| 8 | **GitHub** | GitHub, Inc. (subsidiary of Microsoft) | United States | Source code management, issue tracking, CI/CD | No production Customer Data; limited log metadata if included in internal issues | https://docs.github.com/en/site-policy/privacy-policies |

---

## Data Scope by Sub-processor Tier

We classify our sub-processors into two tiers based on the scope of data they can access:

### Tier 1 — Broad Data Access

- **AWS S3 and DigitalOcean** process or store the full corpus of Customer Content at rest.
- These vendors are subject to the most rigorous onboarding review, contractual controls, and audit rights.

### Tier 2 — Limited / Transient Data Access

- **Stripe, Twilio, AWS SES** process specific categories of Personal Data only for a defined purpose (payment, SMS, email).
- **Mistral AI, Google Gemini** process document contents transiently during OCR/extraction; outputs are returned and the vendor does not retain content beyond the processing window per our contractual terms.
- **GitHub** is not intentionally used to process Customer Data; procedural controls forbid engineers from pasting Customer Data into GitHub issues.

---

## How We Evaluate Sub-processors

Before onboarding a new sub-processor, we assess:

1. **Security posture** — current SOC 2 Type II report, ISO 27001, or equivalent; vulnerability disclosure program.
2. **Data protection terms** — written DPA with obligations substantially equivalent to our own DPA.
3. **Data minimization** — does the vendor have access to the least data necessary for its function?
4. **Location of processing** — U.S. data residency strongly preferred; any non-U.S. processing requires documented lawful transfer mechanism.
5. **Sub-sub-processor transparency** — vendor's public sub-processor list is reviewed.
6. **Incident history** — known breaches are reviewed for severity and response quality.
7. **Termination and deletion terms** — must support timely data return and deletion on termination.

---

## Change History

| Date | Change | Notes |
|------|--------|-------|
| {{EFFECTIVE_DATE}} | Initial publication with 7 sub-processors (AWS, Stripe, Twilio, Mistral AI, Google, DigitalOcean, GitHub). Note: AWS is counted as a single entity but covers two services (S3 and SES), bringing the table to 8 rows. | — |

---

## Object to a Sub-processor

Paid customers may object to a new or replacement sub-processor within 15 days of our notice, per DPA Section 9.2. Objections should be sent to {{LEGAL_EMAIL}} with the subject line "Sub-processor Objection."

---

## Contact

- Privacy / Legal: {{LEGAL_EMAIL}}
- Support: {{SUPPORT_EMAIL}}

---

**[LAWYER CHECK: confirm vendor-DPA links are current and that our downstream terms with each vendor are on file and counter-signed where required. Mistral AI data residency in particular should be clarified because EU processing of U.S. child care data introduces transfer questions.]**
