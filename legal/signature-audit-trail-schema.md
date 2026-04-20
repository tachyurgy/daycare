# Signature Audit Trail Schema

> **DISCLAIMER:** This is a draft template, not legal advice. Have an attorney licensed in your state review before use.

**Effective Date:** {{EFFECTIVE_DATE}}
**Version:** 1.0.0
**Owner:** ComplianceKit Engineering

This document specifies the schema for signature audit-trail records stored under the `audit/` prefix of the `ck-files` S3 bucket. Every e-signature event captured through the ComplianceKit service generates exactly one audit-trail JSON object. These records are part of the evidence we rely on to prove the validity of an electronic signature under the federal ESIGN Act and state UETA statutes.

The audit-trail object is written **after** the signed document is hashed, stored, and verified. The application never updates or deletes an audit object after write; correction of erroneous records is handled by writing a new object that references the original (see Section 5).

---

## 1. Storage Layout

```
s3://ck-files/audit/
  └── org={organization_id}/
        └── year={YYYY}/
              └── month={MM}/
                    └── {signature_id}.json
```

- Bucket: `ck-files` (region: us-west-2), `audit/` prefix.
- Server-side encryption: SSE-S3 (AES256) — the bucket's default.
- Object versioning: enabled on the bucket. Accidental overwrites or deletes can be recovered from prior versions.
- Access: read/write via the `ck-deploy` IAM user. Application code never performs delete or overwrite on `audit/` keys; any such mutation would indicate a code bug or credential compromise.

---

## 2. JSON Schema

The following is the authoritative JSON Schema (Draft 2020-12) for audit-trail objects.

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://compliancekit.com/schemas/signature-audit-trail/v1.json",
  "title": "ComplianceKit Signature Audit Trail",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schema_version",
    "signature_id",
    "organization_id",
    "signer_id",
    "signer_role",
    "document_id",
    "document_sha256_before",
    "document_sha256_after",
    "signed_at",
    "signer_ip",
    "signer_user_agent",
    "consent_version_id",
    "consent_accepted_at",
    "signature_png_sha256",
    "signature_png_s3_key",
    "signer_declared_name",
    "signer_declared_title"
  ],
  "properties": {
    "schema_version": {
      "description": "Semver version of this schema.",
      "type": "string",
      "const": "1.0.0"
    },
    "signature_id": {
      "description": "Globally unique base62 identifier for this signature event.",
      "type": "string",
      "pattern": "^[0-9A-Za-z]{22}$"
    },
    "organization_id": {
      "description": "UUID of the customer organization (daycare provider).",
      "type": "string",
      "format": "uuid"
    },
    "signer_id": {
      "description": "UUID of the signer, if known. Null for anonymous parent-portal signers where only email/phone is verified.",
      "type": ["string", "null"],
      "format": "uuid"
    },
    "signer_role": {
      "description": "Role classification of the signer.",
      "type": "string",
      "enum": ["provider_admin", "staff", "parent"]
    },
    "document_id": {
      "description": "UUID of the signed document record.",
      "type": "string",
      "format": "uuid"
    },
    "document_sha256_before": {
      "description": "SHA-256 hex digest of the document bytes immediately before signature application.",
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "document_sha256_after": {
      "description": "SHA-256 hex digest of the document bytes after the signature image and metadata are embedded.",
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "signed_at": {
      "description": "UTC timestamp of signature completion, ISO 8601 with Z suffix.",
      "type": "string",
      "format": "date-time"
    },
    "signer_ip": {
      "description": "IP address of the signing client, IPv4 or IPv6.",
      "type": "string",
      "oneOf": [
        {"format": "ipv4"},
        {"format": "ipv6"}
      ]
    },
    "signer_user_agent": {
      "description": "Raw User-Agent header string.",
      "type": "string",
      "maxLength": 1024
    },
    "signer_geoip_approx": {
      "description": "Approximate geolocation derived from signer_ip. City/country level only; no precise GPS.",
      "type": ["object", "null"],
      "additionalProperties": false,
      "properties": {
        "city": {"type": ["string", "null"], "maxLength": 100},
        "region": {"type": ["string", "null"], "maxLength": 100},
        "country": {"type": ["string", "null"], "pattern": "^[A-Z]{2}$"},
        "source": {"type": "string", "enum": ["maxmind_geolite2", "aws_locate", "null"]}
      }
    },
    "signer_email_verified_at": {
      "description": "UTC timestamp when the signer's email was verified (e.g., via magic link click). Null if not applicable.",
      "type": ["string", "null"],
      "format": "date-time"
    },
    "signer_phone_verified_at": {
      "description": "UTC timestamp when the signer's phone was verified via SMS code. Null if phone verification not used.",
      "type": ["string", "null"],
      "format": "date-time"
    },
    "magic_link_token_hash": {
      "description": "SHA-256 hex digest of the magic-link token used to authenticate this session. Raw token is never stored. Null if password-authenticated session.",
      "type": ["string", "null"],
      "pattern": "^[a-f0-9]{64}$"
    },
    "consent_version_id": {
      "description": "UUID referencing the policy_versions row for the ESIGN Disclosure accepted by the signer.",
      "type": "string",
      "format": "uuid"
    },
    "consent_accepted_at": {
      "description": "UTC timestamp when the signer accepted the ESIGN Disclosure version referenced in consent_version_id.",
      "type": "string",
      "format": "date-time"
    },
    "signature_png_sha256": {
      "description": "SHA-256 hex digest of the captured signature PNG image (drawn or typed).",
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "signature_png_s3_key": {
      "description": "S3 object key (relative to the signatures bucket) for the signature PNG image.",
      "type": "string",
      "maxLength": 512
    },
    "signer_declared_name": {
      "description": "Name as entered by the signer at the time of signing.",
      "type": "string",
      "minLength": 1,
      "maxLength": 200
    },
    "signer_declared_title": {
      "description": "Title or role as entered by the signer at the time of signing (e.g., 'Parent', 'Director', 'Lead Teacher').",
      "type": "string",
      "minLength": 1,
      "maxLength": 200
    },
    "supersedes_signature_id": {
      "description": "If this record supersedes a prior record (i.e., a correction), the signature_id of the record being corrected. Null for normal records.",
      "type": ["string", "null"],
      "pattern": "^[0-9A-Za-z]{22}$"
    },
    "notes": {
      "description": "Operational notes, bounded and audited. Do not include Personal Data.",
      "type": ["string", "null"],
      "maxLength": 2000
    }
  }
}
```

---

## 3. Field Descriptions

| Field | Required | Description |
|-------|----------|-------------|
| `schema_version` | Yes | Semver version of this schema. Pinned to `1.0.0` for this release. |
| `signature_id` | Yes | 22-character base62 identifier (approximately 131 bits of entropy). Sortable lexicographically when using a ULID-style base62 derivation. |
| `organization_id` | Yes | UUID of the daycare organization that owns the document. Also embedded in the S3 key for partition-based access control. |
| `signer_id` | Optional | UUID of the ComplianceKit user. Null for parent-portal signers who authenticate only by magic link and email. |
| `signer_role` | Yes | `provider_admin`, `staff`, or `parent`. |
| `document_id` | Yes | UUID referencing the document row in the application database. |
| `document_sha256_before` | Yes | Hex SHA-256 of the document bytes at the moment the signer opened the document for signing. |
| `document_sha256_after` | Yes | Hex SHA-256 of the document bytes after the signature image is embedded and metadata is written. |
| `signed_at` | Yes | ISO 8601 UTC timestamp (with `Z` suffix). |
| `signer_ip` | Yes | IPv4 or IPv6. Logged for fraud detection and audit. |
| `signer_user_agent` | Yes | Raw User-Agent header; bounded to 1024 characters. |
| `signer_geoip_approx` | Optional | Approximate (city/country-level) geolocation. We do not store precise coordinates. |
| `signer_email_verified_at` | Optional | UTC timestamp when the signer's email was verified. |
| `signer_phone_verified_at` | Optional | UTC timestamp when the signer's phone was verified. |
| `magic_link_token_hash` | Optional | SHA-256 hex digest of the magic-link token used to authenticate. Raw token never stored. |
| `consent_version_id` | Yes | UUID of the `policy_versions` row for the ESIGN Disclosure version accepted. |
| `consent_accepted_at` | Yes | UTC timestamp of ESIGN Disclosure acceptance. |
| `signature_png_sha256` | Yes | SHA-256 hex digest of the signature PNG image. |
| `signature_png_s3_key` | Yes | S3 key for the signature image. |
| `signer_declared_name` | Yes | Name entered by the signer. |
| `signer_declared_title` | Yes | Title/role entered by the signer. |
| `supersedes_signature_id` | Optional | Pointer to a superseded record (for corrections). |
| `notes` | Optional | Operational notes, bounded, no Personal Data. |

---

## 4. Sample Record

```json
{
  "schema_version": "1.0.0",
  "signature_id": "01HS9K2ZRQ7X4YAJ8M2VQ5",
  "organization_id": "8f84c7c5-d3df-4d9c-9bb1-6f1ec2d8a7e1",
  "signer_id": null,
  "signer_role": "parent",
  "document_id": "e42e5f8a-6b1e-4f2c-85c7-6a3b92d5e2f0",
  "document_sha256_before": "3a7bd3e2360a3d29eea436fcfb7e44c735d117c42d1c1835420b6b9942dd4f1b",
  "document_sha256_after": "c0c0d09c1f2e4b3a7f8d8c2e5a9b4e3d1c7f0a6b8e9d4c3f2a1b0e9d8c7f6a5b",
  "signed_at": "2026-04-16T14:32:07.412Z",
  "signer_ip": "198.51.100.42",
  "signer_user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
  "signer_geoip_approx": {
    "city": "Los Angeles",
    "region": "California",
    "country": "US",
    "source": "maxmind_geolite2"
  },
  "signer_email_verified_at": "2026-04-16T14:28:51.000Z",
  "signer_phone_verified_at": null,
  "magic_link_token_hash": "b41f9d6e7c8a2e5b3d1f0c9a8b7e6d5c4f3a2e1d0c9b8a7f6e5d4c3b2a1f0e9d",
  "consent_version_id": "d7a1e2c3-4b5c-6d7e-8f9a-0b1c2d3e4f5a",
  "consent_accepted_at": "2026-04-16T14:30:02.100Z",
  "signature_png_sha256": "8a2f7c6b5d4e3f2a1b0c9d8e7f6a5b4c3d2e1f0a9b8c7d6e5f4a3b2c1d0e9f8a",
  "signature_png_s3_key": "signatures/2026/04/01HS9K2ZRQ7X4YAJ8M2VQ5.png",
  "signer_declared_name": "Maria Hernandez",
  "signer_declared_title": "Parent",
  "supersedes_signature_id": null,
  "notes": null
}
```

---

## 5. Corrections and Supersession

Audit-trail records are immutable. If a record must be corrected (for example, a system error misrecorded a field):

1. Create a new record with a new `signature_id`.
2. Populate `supersedes_signature_id` with the original record's `signature_id`.
3. The corrected fields must be wholly restated (no deltas).
4. Attach a note describing the correction reason.
5. Both records are retained for the full retention period. Any user-facing display must indicate that the superseded record has been corrected.

---

## 6. Retention

Records are retained for **7 years** after `signed_at`. Retention is enforced by application policy (no delete path in code) and by routine audits; litigation holds may extend retention.

---

## 7. Security

- Writes are issued by the `ck-deploy` IAM user under the `audit/` prefix of `ck-files`. Application code never invokes delete or overwrite on this prefix.
- Reads occur from the same application role.
- All reads and writes emit CloudTrail events; CloudTrail logs are forwarded to a security log sink and retained 24 months.
- Bucket and IAM policy are reviewed quarterly.

---

## 8. Change Management

This schema is versioned in `schema_version`. Any breaking change requires:

- A new top-level `schema_version` value.
- A migration plan approved by engineering and legal.
- Backward-compatible readers for all prior versions during the retention period.

---

**[LAWYER CHECK: confirm that application-enforced 7-year retention (no S3 Object Lock / WORM) is acceptable for ESIGN/UETA audit evidence. If any customer or regulator requires a true WORM control, we would need to re-introduce a WORM-backed bucket for that tenant's audit writes.]**
