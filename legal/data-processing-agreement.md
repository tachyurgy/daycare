# Data Processing Agreement

> **DISCLAIMER:** This is a draft template, not legal advice. Have an attorney licensed in your state review before use.

**Effective Date:** {{EFFECTIVE_DATE}}
**Version:** 1.0.0

This Data Processing Agreement (this "**DPA**") is entered into between {{COMPANY_LEGAL_NAME}}, a {{COMPANY_STATE}} limited liability company ("**ComplianceKit**" or "**Processor**"), and the entity that is a party to the Master Subscription Agreement ("**Customer**" or "**Controller**"). This DPA forms an annex to, and is incorporated by reference into, the Master Subscription Agreement between Customer and ComplianceKit (the "**MSA**"). In the event of conflict between this DPA and the MSA with respect to the processing of Personal Data, this DPA controls.

Although ComplianceKit is based in the United States and is not subject to the EU/UK General Data Protection Regulation as a matter of direct statutory application, this DPA adopts a GDPR-style framework to provide Customers with a thorough, recognizable, and transparent set of processor commitments. This DPA is also designed to meet the "service provider" and "processor" requirements of the California Consumer Privacy Act (as amended by the CPRA), the Texas Data Privacy and Security Act ("**TDPSA**"), and the Florida Digital Bill of Rights ("**FDBR**").

---

## 1. Definitions

For purposes of this DPA:

- "**Applicable Data Protection Law**" means all U.S. state and federal laws and regulations applicable to the processing of Personal Data under this DPA, including without limitation the CCPA/CPRA, TDPSA, FDBR, Washington state law, and all applicable breach-notification statutes.
- "**Controller**" means the natural or legal person that determines the purposes and means of the processing of Personal Data. As between the Parties, Customer is the Controller.
- "**Data Subject**" means the identified or identifiable individual to whom Personal Data relates.
- "**Personal Data**" means any information relating to an identified or identifiable Data Subject processed by ComplianceKit on behalf of Customer under the MSA.
- "**Processing**" (and "process") means any operation performed on Personal Data, whether or not by automated means.
- "**Processor**" means the entity that processes Personal Data on behalf of the Controller. ComplianceKit is the Processor.
- "**Security Incident**" means any breach of security leading to the accidental or unlawful destruction, loss, alteration, unauthorized disclosure of, or access to Personal Data.
- "**Sub-processor**" means any third party engaged by ComplianceKit that processes Personal Data in connection with the Service.

Capitalized terms not defined here have the meanings given in the MSA.

---

## 2. Subject Matter, Duration, Nature, and Purpose

- **Subject matter.** Processing of Personal Data by ComplianceKit necessary to deliver the Service described in the MSA (compliance management software for licensed child care providers).
- **Duration.** The term of the MSA plus any retention period required by law or set out in Section 10.
- **Nature.** Storage, hosting, transmission, processing, organization, retrieval, OCR, indexing, analysis, and deletion.
- **Purpose.** Providing the Service, including document management, alerting and reminder workflows, e-signature workflows, reporting, customer support, security, and compliance with legal obligations.

---

## 3. Categories of Data Subjects and Personal Data

### 3.1 Categories of Data Subjects

- **Customer personnel:** owners, directors, administrators, and other Authorized Users who operate the Service on Customer's behalf.
- **Daycare staff:** employees, contractors, and volunteers of Customer whose certifications, training logs, or attestations are managed in the Service.
- **Enrolled children:** children enrolled in Customer's child care program, whose compliance records (e.g., immunization history, emergency contacts) are uploaded by Customer.
- **Parents and legal guardians:** parents or guardians of enrolled children, whose contact details and portal acknowledgments are processed in connection with uploads.

### 3.2 Categories of Personal Data

| Category | Examples |
|----------|----------|
| Identifiers | Name, email, phone number, user ID, role, facility ID |
| Health-adjacent data | Child immunization records, medical exemption forms (not HIPAA-regulated in this context) |
| Family and emergency data | Emergency contacts, pickup authorizations, allergy notes |
| Staff credentials | Certifications, training logs, background check attestations (yes/no + date), date of hire |
| E-signature and audit data | Signature images, IP address, user agent, geo-IP approximation, timestamp, consent version, magic-link token hash |
| Account and billing data | Login metadata, Stripe customer ID, billing address |
| Support data | Emails, screenshots, session recordings (if any), ticket contents |

ComplianceKit does not process: Social Security numbers, driver's license numbers, raw background check reports, full payment card numbers, biometric identifiers, or precise geolocation, except where expressly described in the MSA or Privacy Policy.

---

## 4. Roles of the Parties

Customer is the Controller and ComplianceKit is the Processor. Customer is responsible for establishing the lawful basis for the processing and for providing all notices and obtaining all consents from Data Subjects as required by Applicable Data Protection Law. ComplianceKit processes Personal Data only on documented instructions from Customer, unless otherwise required by law, in which case ComplianceKit will (to the extent legally permitted) inform Customer before processing.

Customer instructs ComplianceKit to process Personal Data as follows: (a) to provide, maintain, and improve the Service as described in the MSA and Documentation; (b) as further instructed in writing by Customer from time to time; (c) as required to comply with legal obligations.

**[LAWYER CHECK: confirm this "documented instructions" framing is sufficient for CCPA Section 1798.140(ag)(1) service provider status. Current CA AG guidance favors explicit purpose enumeration.]**

---

## 5. Processor Obligations

ComplianceKit will:

1. Process Personal Data only on documented instructions from Customer.
2. Ensure that personnel authorized to process Personal Data are under a duty of confidentiality (by contract or statute).
3. Implement and maintain appropriate technical and organizational measures to protect Personal Data against Security Incidents, as described in Section 7.
4. Assist Customer in fulfilling its obligations to respond to Data Subject requests, as described in Section 8.
5. Assist Customer in ensuring compliance with security, Security Incident notification, and data-protection impact assessments, taking into account the nature of processing and the information available.
6. At Customer's choice, delete or return all Personal Data at the end of the Services, as described in Section 10.
7. Make available to Customer all information reasonably necessary to demonstrate compliance with this DPA, as described in Section 9.
8. Not sell Personal Data or share it for cross-context behavioral advertising (as those terms are defined in the CCPA/CPRA).
9. Not retain, use, or disclose Personal Data for any purpose other than for the specific purpose of performing the Services or as otherwise permitted by Applicable Data Protection Law.
10. Not combine Personal Data received from Customer with Personal Data from other sources except as strictly necessary to operate the Service on Customer's behalf.
11. Notify Customer if, in ComplianceKit's opinion, an instruction violates Applicable Data Protection Law.

---

## 6. Security Incidents

### 6.1 Notification

ComplianceKit will notify Customer without undue delay, and in any event **within 72 hours** after confirming a Security Incident affecting Customer's Personal Data. Notification will include:

- A description of the nature of the Security Incident, including categories and approximate number of Data Subjects and records concerned.
- The likely consequences of the Security Incident.
- The measures taken or proposed to address the Security Incident and mitigate adverse effects.
- A point of contact for further information.

### 6.2 Cooperation

ComplianceKit will cooperate with Customer in the investigation of, and response to, any Security Incident, including by providing reasonable information to assist Customer in meeting its own notification obligations to Data Subjects and regulators.

### 6.3 No Admission

A Security Incident notification is not, by itself, an admission of fault or liability.

---

## 7. Security Measures

ComplianceKit will maintain the following measures, at a minimum:

### 7.1 Encryption

- TLS 1.2 or higher for data in transit.
- AES-256 or equivalent for data at rest.
- Database-level encryption on all managed data stores.

### 7.2 Access Control

- Role-based access control with principle of least privilege.
- Multi-factor authentication required for administrative access.
- Unique user IDs; no shared credentials.
- Quarterly review of access rights for production systems.

### 7.3 Network and Application Security

- Web application firewall.
- Rate limiting and denial-of-service protection.
- Automated dependency vulnerability scanning.
- Production secrets managed in a dedicated secret manager, not in source code.

### 7.4 Monitoring and Logging

- Centralized application and infrastructure logs.
- Anomaly detection on authentication events.
- Log retention of at least 12 months.
- Incident-response runbooks.

### 7.5 Operational Security

- Background checks for personnel with access to production systems (where permitted by law).
- Annual security awareness training for all personnel.
- Documented incident-response plan, tested at least annually.

### 7.6 Penetration Testing

- Annual third-party penetration test once at scale (1,000 paying customers or $1M ARR, whichever comes first). Prior to that, quarterly automated security scans of the production environment.

### 7.7 Business Continuity

- Daily automated backups of production databases with encryption.
- Recovery point objective: 24 hours. Recovery time objective: 24 hours.
- Backup restoration tested at least annually.

### 7.8 Sub-processor Oversight

- Security and data-protection review prior to onboarding each Sub-processor.
- Contractual commitments at least as stringent as those in this DPA.

---

## 8. Data Subject Rights

Taking into account the nature of processing, ComplianceKit will provide reasonable assistance (by appropriate technical and organizational measures) to enable Customer to fulfill its obligations to respond to requests from Data Subjects to exercise their rights (including access, correction, deletion, portability, and opt-out of sale/share).

ComplianceKit provides self-service tooling within the Service to allow Customer to:

- Export Personal Data in a machine-readable format.
- Delete records for specific Data Subjects.
- Generate reports of the Personal Data held about a specific Data Subject.

If ComplianceKit receives a request directly from a Data Subject, we will, unless legally prohibited, promptly forward the request to Customer and will not respond substantively except to acknowledge receipt and redirect the Data Subject to Customer.

---

## 9. Sub-processors

### 9.1 Authorization

Customer provides a general authorization for ComplianceKit to engage Sub-processors to provide the Service. The current list of Sub-processors is maintained at [Subprocessors](./subprocessors.md). As of the Effective Date, the Sub-processors are:

| Sub-processor | Purpose | Region |
|---------------|---------|--------|
| Amazon Web Services (S3, SES) | Object storage; transactional email | United States |
| Stripe, Inc. | Payment processing | United States |
| Twilio Inc. | SMS notifications | United States |
| Mistral AI | OCR and document parsing (AI) | European Union (with US endpoint as applicable) |
| Google LLC (Gemini API) | OCR and document parsing (AI) | United States |
| DigitalOcean, LLC | Compute and managed database hosting | United States |
| GitHub, Inc. | Source code management, issue tracking (no production Customer Data) | United States |

### 9.2 Change Notification

ComplianceKit will provide at least **30 days' advance notice** of any intended addition or replacement of Sub-processors, by email to Customer's designated privacy contact and by updating the [Subprocessors](./subprocessors.md) page. Customer may object to the change by notifying ComplianceKit in writing within 15 days of notice, stating reasonable grounds. If the Parties cannot resolve the objection, Customer may terminate the affected Service with pro-rated refund of any prepaid, unused Fees.

### 9.3 Sub-processor Liability

ComplianceKit will (i) enter into written agreements with each Sub-processor that impose data-protection obligations substantially equivalent to those in this DPA, and (ii) remain liable for any Sub-processor's acts or omissions to the same extent as if ComplianceKit performed the acts or omissions directly.

**[LAWYER CHECK: confirm that Mistral AI's terms and data-residency options meet Processor obligations for customer content; if EU routing is default, customer comms should clarify this.]**

---

## 10. Return and Deletion of Data

Upon termination or expiration of the MSA, ComplianceKit will, at Customer's choice:

1. Return Personal Data to Customer in a commonly used, machine-readable format, after which ComplianceKit will delete such Personal Data; or
2. Delete Personal Data.

The return/deletion process:

- Customer has **30 days** after termination to export Personal Data via self-service tools in the Service.
- After the 30-day export window, ComplianceKit will delete Personal Data from production systems within **60 days**.
- Personal Data contained in backups will be purged according to the backup rotation, not later than **90 days** after deletion from production.
- Personal Data subject to legal retention (e.g., tax records for 7 years; e-signature audit trails for 7 years) will be retained in encrypted form for the legally required period and then deleted.

On written request, ComplianceKit will provide a written certification of deletion.

---

## 11. Audits

### 11.1 Annual Evidence Package

Upon written request not more than once per 12 months, ComplianceKit will provide Customer with reasonable evidence of compliance with this DPA, which may include:

- Summary of our information-security program.
- Summary of our most recent penetration-test results and remediation status (once available).
- Sub-processor list with update history.
- SOC 2 or equivalent reports, when available.

### 11.2 On-Site Audit

Customer may, upon reasonable prior written notice (not less than 30 days), conduct an on-site audit limited to the extent necessary to assess ComplianceKit's compliance with this DPA. Audits will occur during business hours, will not unreasonably interfere with operations, and must be conducted by Customer personnel (or a third-party auditor bound by confidentiality acceptable to ComplianceKit). Audit costs are borne by Customer. On-site audits are limited to **once every 24 months** except where conducted following a Security Incident affecting Customer's Personal Data.

### 11.3 Regulator Audits

ComplianceKit will cooperate with regulator audits or inquiries as required by Applicable Data Protection Law.

---

## 12. Liability

The liability of each Party under this DPA is subject to the limitations and exclusions of liability set out in the MSA. For clarity, any claim arising under this DPA is considered a claim under the MSA and counts against the aggregate liability cap in the MSA.

---

## 13. Governing Law and Venue

This DPA is governed by the laws of the State of {{COMPANY_STATE}} (default: Washington), without regard to conflict-of-laws principles. Venue and dispute resolution follow the MSA.

---

## 14. Miscellaneous

- **Precedence.** In case of conflict with the MSA, this DPA prevails as to Personal Data processing.
- **Amendment.** This DPA may be amended only in writing signed by both Parties, except that ComplianceKit may update the Sub-processor list as described in Section 9.
- **Survival.** Sections 6, 10, 11, and 12 survive termination.
- **Severability.** If any provision is unenforceable, it will be modified to the minimum extent necessary, and the remainder will remain in effect.

---

## 15. Contact

- Data Protection Officer / Privacy Contact: {{LEGAL_EMAIL}}
- Mailing address: {{COMPANY_LEGAL_NAME}}, {{COMPANY_ADDRESS}}

---

**Revisions**

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | {{EFFECTIVE_DATE}} | Initial publication. |
