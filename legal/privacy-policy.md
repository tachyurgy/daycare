# Privacy Policy

> **DISCLAIMER:** This is a draft template, not legal advice. Have an attorney licensed in your state review before use.

**Effective Date:** {{EFFECTIVE_DATE}}
**Last Updated:** {{EFFECTIVE_DATE}}
**Version:** 1.0.0

{{COMPANY_LEGAL_NAME}} ("**ComplianceKit**," "**we**," "**us**," or "**our**") operates the ComplianceKit software-as-a-service platform (the "**Service**"), which helps licensed child care providers manage regulatory compliance obligations, document retention, staff credentialing, and inspection readiness. This Privacy Policy explains how we collect, use, disclose, and protect personal information in connection with the Service and our public website at compliancekit.com (the "**Site**"). It also describes the rights individuals have under the laws of California (CCPA/CPRA), Texas (TDPSA), Florida (FDBR), and other applicable U.S. state and federal privacy laws.

This Privacy Policy applies to:

- Visitors to the Site.
- Authorized users of the Service (e.g., daycare owners, directors, and administrators who create accounts on behalf of a licensed child care provider).
- Daycare employees whose certifications, training records, or background check attestations are uploaded to the Service.
- Parents or guardians who use a parent upload portal to submit child immunization records or related documents at the request of a child care provider.

This Privacy Policy does **not** cover data practices of child care providers themselves, who determine what information to collect and upload to the Service. Child care providers act as **data controllers** (or "businesses" under CCPA). ComplianceKit acts as a **data processor** (or "service provider" under CCPA) on their behalf.

---

## 1. Summary: What You Should Know Up Front

- **We do not sell your personal information.** We also do not share it for cross-context behavioral advertising.
- **We do not knowingly collect personal information directly from children under 13.** When children's data appears in the Service, it is uploaded by the child's daycare provider or, in limited cases, by a parent or guardian at the daycare's direction.
- **Your daycare is in charge of your data.** If you are a parent, employee, or child, the daycare provider determines what data goes into the Service, how long it stays, and who can see it. For most privacy rights, you should contact your daycare directly. We support the daycare in honoring your requests.
- **We store data in the United States.** We do not currently transfer data internationally.
- **We use a small, audited set of sub-processors** to operate the Service. The current list is maintained at [Subprocessors](./subprocessors.md).
- **We follow state breach-notification laws** and commit to notifying affected customers within 72 hours of confirming a security incident affecting their data.

---

## 2. Information We Collect

### 2.1 Information You Provide Directly

| Category | Examples |
|----------|----------|
| Account & Contact Info | Name, email address, phone number, business name, role/title, password (hashed), facility license number |
| Billing Info | Billing name, billing address, last four digits of payment card, Stripe customer ID. Full payment card numbers are processed by Stripe and never stored by us. |
| Customer Content (uploaded by providers) | Child immunization records, child emergency contact forms, staff certifications, training logs, drill logs, facility inspection reports, wall posting photos, e-signatures, notes |
| Staff Data | Name, role, date of hire, certification numbers and expiration dates, training hours, background check attestations (**not the raw background check results**) |
| Parent/Guardian Data (via parent portal) | Name, email or phone, relationship to child, uploaded documents (typically immunization records), acknowledgments and e-signatures |
| Support Communications | Emails, chat messages, screenshots, and other content you send us |

### 2.2 Information Collected Automatically

| Category | Examples |
|----------|----------|
| Device & Log Data | IP address, user agent, device type, operating system, referrer URL, pages viewed, timestamps, session identifiers |
| Cookies & Similar Tech | Session cookies (authentication), analytics cookies. See [Cookie Policy](./cookie-policy.md) |
| Usage Data | Features used, documents uploaded (metadata, not content), alerts dismissed, dashboard interactions |
| Audit Trail Data | For every e-signature event: signer identity, document hash before/after, timestamp, IP, user agent, geo-IP approximation, magic-link token hash, consent version, declared name and title. See `signature-audit-trail-schema.md` for the full spec. |

### 2.3 Sensitive Information

Certain data we handle may be considered "sensitive" under state privacy laws. This includes:

- **Children's personal information** (name, date of birth, immunization history, emergency contacts) — handled only when uploaded by a daycare provider or a parent acting at the daycare's direction.
- **Health-related information** (primarily child immunization records). Daycare providers are **not** HIPAA covered entities, so this is not Protected Health Information under HIPAA, but we apply heightened safeguards consistent with state laws.
- **Precise geolocation** is not collected. We collect approximate (city/country-level) geo-IP only for security audit logging.

We do not collect Social Security numbers, driver's license numbers, financial account credentials, biometric identifiers, or government ID numbers as part of normal Service use. Customers are prohibited by the [Acceptable Use Policy](./acceptable-use-policy.md) from uploading such data except where specifically required by regulation.

**[LAWYER CHECK: confirm that our handling of children's data via daycare controller flow is correctly positioned outside the direct COPPA operator scope. Parent-upload-portal flow is a COPPA gray area.]**

---

## 3. How We Use Personal Information

We use personal information for the following purposes:

1. **Operating the Service** — account provisioning, authentication, document storage, compliance alerting, reminder notifications, e-signature workflows, reporting.
2. **Billing and payment** — processing subscription charges, sending invoices, collecting payment (via Stripe).
3. **Communication** — transactional emails, SMS notifications (via Twilio), in-app messages, product announcements, security notices.
4. **Customer support** — troubleshooting, responding to inquiries, maintaining support records.
5. **Product improvement** — analyzing aggregate usage patterns, diagnosing bugs, improving features. We do not train third-party AI models on customer content.
6. **AI-assisted features** — when a provider uploads a document, we use Mistral AI and/or Google Gemini to perform optical character recognition (OCR) and structured data extraction (e.g., expiration date extraction). These vendors process content under processor terms; they do not use customer content to train their public models.
7. **Security, fraud prevention, and audit** — detecting suspicious activity, protecting the integrity of the Service.
8. **Legal compliance** — responding to lawful requests, enforcing our agreements, protecting our rights.

We do **not** use personal information for targeted advertising, profiling for consequential decisions, or data brokerage of any kind.

---

## 4. Legal Bases for Processing

Although ComplianceKit operates under U.S. law and is not subject to GDPR, we document our legal bases as follows for clarity:

- **Contract performance** — necessary to deliver the Service to our customer (the daycare provider).
- **Legitimate interest** — security, fraud prevention, product improvement, and internal audit.
- **Consent** — parent/employee uploads, marketing communications, non-essential cookies.
- **Legal obligation** — tax retention, breach notification, court orders.

---

## 5. Sub-processors

We rely on the following sub-processors to provide the Service. A current, living list is maintained at [Subprocessors](./subprocessors.md).

| Vendor | Purpose | Data Accessed |
|--------|---------|----------------|
| Amazon Web Services (S3, SES) | Document storage, transactional email | All customer content, email metadata |
| Stripe | Payment processing | Billing contact, payment method token |
| Twilio | SMS notifications | Phone number, message body |
| Mistral AI | OCR and document parsing | Document contents at processing time |
| Google (Gemini API) | OCR and document parsing | Document contents at processing time |
| DigitalOcean | Compute and database hosting | All customer content (at rest in managed database) |
| GitHub | Source code, issue tracking (no production customer data) | None, except limited log metadata in issues |

We require each sub-processor to commit to confidentiality, security, and data-protection obligations substantially equivalent to our own.

---

## 6. Disclosures of Personal Information

We disclose personal information only in these circumstances:

- **To the customer (daycare provider)** — your data is always accessible to the daycare that entered it.
- **To sub-processors** — as listed above, solely to operate the Service on our behalf.
- **To legal or regulatory authorities** — when required by subpoena, court order, or binding legal demand. We will notify affected customers unless legally prohibited.
- **In connection with a business transfer** — if ComplianceKit is acquired, merged, or sells its assets, personal information may transfer to the acquirer, subject to this Privacy Policy.
- **With explicit consent** — any other disclosure will be made only with your informed consent.

We do **not** sell personal information, share it for cross-context behavioral advertising, or disclose it for targeted advertising as those terms are defined under CCPA/CPRA, TDPSA, or FDBR.

---

## 7. Your Privacy Rights

Depending on where you reside and your role, you may have the following rights:

### 7.1 Universal rights (all users)

- **Access** — request a copy of personal information we hold about you.
- **Correction** — request correction of inaccurate data.
- **Deletion** — request deletion of personal information, subject to our retention obligations.
- **Portability** — request export of data in a commonly used, machine-readable format.
- **Opt-out of sale/share** — not applicable: we do not sell or share personal information.

### 7.2 How to exercise rights

If you are a **parent, employee, or other individual whose data was uploaded by a daycare**, please contact the daycare directly. They are the data controller and have the tools to fulfill your request. We will assist the daycare in fulfilling verified requests.

If you are a **direct customer** (daycare owner or administrator), email {{LEGAL_EMAIL}} with "Privacy Request" in the subject line and include enough information for us to verify your identity.

### 7.3 Response times

We will confirm receipt of a verified request within 10 business days and respond substantively within 45 days (extendable by 45 additional days with notice, where law permits).

### 7.4 Appeals

If we deny a request, you may appeal by replying to our denial email. We will respond to the appeal within 60 days. If we deny the appeal, residents of states that provide an administrative appeal mechanism may contact their state attorney general.

### 7.5 No retaliation

We will not discriminate or retaliate against you for exercising your privacy rights.

---

## 8. State-Specific Rights

### 8.1 California (CCPA/CPRA)

California residents have the following additional rights:

- **Right to Know** — categories and specific pieces of personal information collected, sources, purposes, and third parties.
- **Right to Delete** — subject to exceptions (e.g., legal retention).
- **Right to Correct** — correct inaccurate personal information.
- **Right to Limit Use of Sensitive Personal Information** — we do not use sensitive personal information for any purpose beyond operating the Service, so this right is effectively already honored.
- **Right to Opt Out of Sale/Share** — we do not sell or share.
- **Right to Non-Discrimination.**

**Categories collected** (per CCPA Section 1798.140): identifiers, customer records, commercial information, internet/network activity, geolocation (approximate), professional/employment information, sensitive personal information (health records of children as processor).

**Authorized agents:** California residents may designate an authorized agent to submit requests by providing written permission.

**Shine the Light (California Civil Code §1798.83):** we do not share personal information with third parties for their direct marketing.

### 8.2 Texas (TDPSA, effective July 1, 2024)

Texas residents have rights of access, correction, deletion, portability, and opt-out of sale, targeted advertising, and profiling. Because we do not engage in sale, targeted advertising, or profiling for consequential decisions, opt-out is available by default. Appeals follow the process in Section 7.4.

### 8.3 Florida (FDBR)

Florida residents whose information is processed by a "controller" as defined under FDBR may exercise rights of access, correction, deletion, portability, and opt-out of sale/targeted advertising/profiling. Most daycare controllers will not meet the FDBR controller threshold; however, rights are honored as a matter of practice.

### 8.4 Other states

We honor analogous rights extended by other U.S. states (e.g., Colorado, Connecticut, Virginia, Utah, Oregon, Montana, Delaware) as they become effective. Contact {{LEGAL_EMAIL}} to exercise rights.

**[LAWYER CHECK: confirm TDPSA and FDBR controller-threshold applicability and whether direct-to-consumer exception applies to our B2B SaaS model.]**

---

## 9. Children's Privacy (COPPA)

ComplianceKit is not directed to children under 13. We do not knowingly collect personal information from children under 13. When children's data is present in the Service (e.g., in a child's compliance file), it has been uploaded by a licensed daycare provider acting as data controller, or by a parent or guardian at the daycare's request.

The parent upload portal presents a plain-language consent notice before any upload (see [Parent Consent](./parent-consent.md)). Parents may request that we or the daycare delete their child's information at any time.

If you believe a child under 13 has provided information to us directly and without parental consent, please contact {{LEGAL_EMAIL}} and we will promptly investigate and, where appropriate, delete the information.

**[LAWYER CHECK: whether parent-upload flow triggers direct COPPA operator status rather than schools/providers exception. If yes, a verifiable parental consent mechanism beyond click-through may be required.]**

---

## 10. Retention

| Data Type | Retention Period |
|-----------|------------------|
| Active customer account data | For the duration of the subscription |
| Billing records | 7 years after the last transaction (tax obligation) |
| Audit trail / signature records | 7 years after creation (regulatory/evidentiary) |
| Support tickets | 3 years after ticket closure |
| Security logs | 1 year |
| Marketing email records | Until unsubscribe + 30 days |
| Customer content after account termination | 30 days soft delete, then permanent deletion unless customer requests longer return window |
| Data subject to an immediate deletion request | Deleted within 30 days, subject to legal holds |

Immediate deletion on verified request overrides the active-account retention, but not statutory retention (tax, audit-trail records linked to executed e-signatures).

---

## 11. Security

We maintain administrative, technical, and physical safeguards designed to protect personal information, including:

- TLS 1.2+ encryption in transit; AES-256 encryption at rest.
- Role-based access control and principle-of-least-privilege.
- Multi-factor authentication required for administrative access.
- Access logging and regular log review.
- Annual penetration test once at scale.
- Vendor security reviews before onboarding new sub-processors.
- Incident response plan with 72-hour customer notification commitment.

No method of transmission or storage is perfectly secure. If you believe your account has been compromised, contact {{LEGAL_EMAIL}} immediately.

---

## 12. Breach Notification

In the event of a security incident affecting personal information, we will:

- Notify affected customers without undue delay and in any event within 72 hours of confirming an incident affecting their data.
- Provide the nature of the incident, categories of data affected, and mitigation measures.
- Cooperate with customer notifications to end users as required by state breach-notification laws, including (but not limited to) the laws of all 50 states and the District of Columbia.
- Notify applicable state attorneys general and regulators as required by law.

---

## 13. International Transfers

We store and process personal information in the United States. We do not currently offer the Service outside the United States and do not intentionally transfer data internationally. Sub-processors may process data in the United States only; we do not permit international transfers without a documented lawful transfer mechanism.

---

## 14. Do Not Track

Some browsers send a "Do Not Track" (DNT) signal. Because there is no industry consensus on how to interpret DNT, we do not currently respond to DNT signals. However, we do not track users across third-party sites for advertising purposes regardless of DNT.

For California residents: we recognize the Global Privacy Control (GPC) signal as a valid opt-out of sale/share. Because we do not engage in sale or share, the GPC signal has no functional effect but is logged for audit purposes.

---

## 15. Automated Decision-Making

We do not make automated decisions that produce legal or similarly significant effects about individuals. AI-assisted features (e.g., OCR, expiration extraction) are assistive only; a human reviewer at the daycare verifies any data before it is relied upon for compliance purposes.

---

## 16. Changes to This Privacy Policy

We may update this Privacy Policy from time to time. If changes are material, we will provide at least 30 days' advance notice by email and in-app banner. Continued use of the Service after the effective date constitutes acceptance of the updated policy. Prior versions are archived and available on request.

---

## 17. How to Contact Us

- **Privacy / Legal Inquiries:** {{LEGAL_EMAIL}}
- **Support:** {{SUPPORT_EMAIL}}
- **Mail:** {{COMPANY_LEGAL_NAME}}, {{COMPANY_ADDRESS}}

If you are a California resident and we fail to respond to your request within the legally required time, you may contact the California Attorney General's office. For Texas residents, the Texas Attorney General's Consumer Protection Division. For Florida residents, the Florida Department of Legal Affairs.

---

**Revisions**

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | {{EFFECTIVE_DATE}} | Initial publication. |
