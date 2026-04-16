# ComplianceKit Legal Document Set

> **DISCLAIMER:** This is a draft template, not legal advice. Have an attorney licensed in your state review before use.

This directory contains the complete legal document set for **{{COMPANY_LEGAL_NAME}}** (operating the ComplianceKit SaaS product). All documents are first drafts authored for internal use and attorney review. Nothing in this repository should be treated as final, executed, or enforceable until it has been reviewed by counsel licensed in the applicable jurisdiction and formally adopted by the company.

---

## Document Index

| # | File | Audience | When Shown / Signed | Binding? |
|---|------|----------|----------------------|----------|
| 1 | `privacy-policy.md` | Public (all visitors) | Linked from every page footer; must be reviewed before account creation | Yes (notice by posting) |
| 2 | `terms-of-service.md` | Public (all users) | Click-through at account creation; linked from footer | Yes (click-wrap) |
| 3 | `master-subscription-agreement.md` | Paying customers (daycare providers) | Presented at paid-plan checkout; click-through acceptance | Yes (click-wrap commercial contract) |
| 4 | `data-processing-agreement.md` | Paying customers (as annex to MSA) | Presented alongside MSA; single acceptance covers both | Yes |
| 5 | `subprocessors.md` | Public / customers | Linked from DPA and Privacy Policy; living document | Informational (notice) |
| 6 | `parent-consent.md` / `parent-consent-es.md` | Parents using the upload portal | Displayed before first upload to parent portal; explicit click-through | Yes (consent) |
| 7 | `employee-consent.md` / `employee-consent-es.md` | Daycare staff uploading their own certifications | Displayed before first staff upload; explicit click-through | Yes (consent) |
| 8 | `cookie-policy.md` | Public | Linked from footer; cookie banner on first visit | Yes (notice) |
| 9 | `acceptable-use-policy.md` | All users | Incorporated by reference into ToS and MSA | Yes (via ToS/MSA) |
| 10 | `esignature-disclosure.md` | Any user about to e-sign | Displayed once, before first e-signature; recorded in audit trail | Yes (federal ESIGN Act / UETA) |
| 11 | `signature-audit-trail-schema.md` | Internal engineering | Reference spec; not user-facing | N/A (internal) |

---

## Lifecycle Summary

### 1. Public-facing documents (no signature required)

- **Privacy Policy**, **Terms of Service**, **Cookie Policy**, **Subprocessors List**
- Posted publicly on the marketing site.
- Continued use of the site constitutes acceptance per the terms.
- Any material change requires 30 days' notice by email and banner.

### 2. Click-wrap at account creation

- Signup flow requires explicit checkbox acknowledgment of **Terms of Service** and **Privacy Policy**.
- The system records: (a) the policy version ID, (b) UTC timestamp, (c) IP address, (d) user agent.

### 3. Click-wrap at paid signup

- Before first payment, the user must separately accept the **Master Subscription Agreement (MSA)** and **Data Processing Agreement (DPA)**.
- Acceptance is recorded the same way as above, with an additional field marking the authorized signer (company-level acceptance).

### 4. Consent at first portal use

- **Parent Consent** is displayed the first time a parent opens a magic-link upload portal. Parent must click-accept before uploading.
- **Employee Consent** is displayed the first time a daycare employee logs in to upload their own certifications.

### 5. E-signature disclosure

- Before any user e-signs any document (compliance attestations, staff acknowledgments, etc.), the **ESIGN Disclosure** is displayed.
- Acceptance is recorded in the signature audit trail JSON object per `signature-audit-trail-schema.md`.

---

## How to Update a Document

ComplianceKit maintains a `policy_versions` database table that tracks every version of every legal document in effect. The schema is approximately:

```sql
CREATE TABLE policy_versions (
  id               UUID PRIMARY KEY,
  document_key     TEXT NOT NULL,          -- e.g. 'privacy-policy', 'tos', 'msa', 'dpa', 'parent-consent'
  version_label    TEXT NOT NULL,          -- e.g. 'v1.0.0', 'v1.1.0'
  effective_date   TIMESTAMPTZ NOT NULL,
  rendered_html    TEXT NOT NULL,          -- locked, rendered version of the document
  rendered_sha256  TEXT NOT NULL,          -- content hash for audit
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by       UUID NOT NULL REFERENCES users(id),
  UNIQUE (document_key, version_label)
);

CREATE TABLE policy_acceptances (
  id                  UUID PRIMARY KEY,
  user_id             UUID REFERENCES users(id),
  organization_id     UUID REFERENCES organizations(id),
  policy_version_id   UUID NOT NULL REFERENCES policy_versions(id),
  accepted_at         TIMESTAMPTZ NOT NULL,
  ip_address          INET NOT NULL,
  user_agent          TEXT NOT NULL,
  acceptance_context  TEXT NOT NULL        -- e.g. 'signup', 'msa_checkout', 'parent_portal'
);
```

### Update workflow

1. Edit the Markdown file in this repo.
2. Attorney review completed; changes approved.
3. Engineering renders the Markdown to HTML, computes SHA-256, and inserts a new row into `policy_versions` with a new `version_label` and a future `effective_date` (typically 30 days out for material changes; immediate for non-material).
4. If the change is material, notification is sent to all affected users 30 days in advance (email + in-app banner). Non-material changes (typos, clarifying language, contact updates) require only public posting.
5. On and after the `effective_date`, new acceptances reference the new `policy_version_id`. Previously accepted versions remain valid for existing users per their last acceptance until they re-accept.
6. The change log should be maintained inline at the top of each document as a dated "Revisions" table.

### What counts as "material"?

Generally material (requires 30-day notice): changes to fees, limitation of liability, governing law, arbitration, privacy rights, retention periods, new data categories, new sub-processor categories.

Generally non-material (no notice required): typo corrections, formatting, contact email updates, addition of examples, clarifications that do not change user rights.

**[LAWYER CHECK: materiality criteria should be reviewed by counsel for your jurisdiction before first publication.]**

---

## Placeholders Used Throughout

| Placeholder | Meaning | Default if known |
|-------------|---------|-------------------|
| `{{COMPANY_LEGAL_NAME}}` | Finalized LLC name | TBD |
| `{{EFFECTIVE_DATE}}` | Document effective date | TBD at publication |
| `{{COMPANY_ADDRESS}}` | Registered business address | TBD |
| `{{COMPANY_STATE}}` | State of LLC formation | Washington |
| `{{SUPPORT_EMAIL}}` | Customer support contact | support@compliancekit.com |
| `{{LEGAL_EMAIL}}` | Legal / privacy contact | legal@compliancekit.com |

---

## Contact

Legal inquiries: {{LEGAL_EMAIL}}
Support: {{SUPPORT_EMAIL}}
Mailing address: {{COMPANY_ADDRESS}}
