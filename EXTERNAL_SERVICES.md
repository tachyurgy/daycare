# ComplianceKit — External Services Register

Authoritative list of every third-party service integrated by ComplianceKit. Must be kept in sync with `legal/subprocessors.md` (maintained separately by the legal agent).

Account owner email is a placeholder pending production account provisioning. Credentials are stored in `/etc/ck/env` on the droplet (mode 600, root-owned) and injected via systemd `EnvironmentFile`.

---

## Primary Services

| Service | Purpose | PII Flow | Cost @ 100 customers/mo | Subprocessor | Account Owner | Credentials (env var) |
|---------|---------|----------|------------------------|--------------|---------------|----------------------|
| AWS S3 (`ck-files`) | All uploaded documents, signed PDFs, and signature audit JSON (prefixes: `docs/`, `templates/`, `signed/`, `audit/`) | Yes — child/staff PII, immunization records, signatures, IP + UA | $5 (storage) + $3 (requests) | Yes | ops@compliancekit.app | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` |
| AWS SES | Transactional email — magic links, chase messages, digests | Yes — parent/staff email addresses, child first name in body | $3 (est. 30k emails) | Yes | ops@compliancekit.app | `CK_SES_ACCESS_KEY`, `CK_SES_SECRET_KEY`, `CK_SES_REGION` |
| Twilio | Transactional SMS — magic links, chase messages | Yes — parent/staff phone numbers, child first name | $83 (est. 10k SMS @ $0.0083) | Yes | ops@compliancekit.app | `CK_TWILIO_ACCOUNT_SID`, `CK_TWILIO_AUTH_TOKEN`, `CK_TWILIO_FROM_NUMBER` |
| Stripe | Subscription billing, payment processing | Yes — owner email, billing address, card tokens (card data never touches our servers) | $317 (processing fees on $9,900 MRR) | Yes | ops@compliancekit.app | `CK_STRIPE_SECRET_KEY`, `CK_STRIPE_WEBHOOK_SECRET`, `CK_STRIPE_PRICE_STARTER`, `CK_STRIPE_PRICE_PRO`, `CK_STRIPE_PRICE_ENTERPRISE` |
| Mistral OCR | Primary OCR — extracts text from uploaded documents | Yes — immunization records, certifications, photo IDs transiently sent | $15 (est. 15k pages @ $1/1k) | Yes | ops@compliancekit.app | `CK_MISTRAL_API_KEY` |
| Google Gemini Flash | LLM for structured extraction (expiration dates, doc kind) + onboarding chat | Yes — document OCR text, facility profile answers | $5 (est. 50k extractions) | Yes | ops@compliancekit.app | `CK_GEMINI_API_KEY` |
| DigitalOcean (Droplet) | Compute for Go API + worker + cron | Yes — all PII in transit and at rest on disk | $24 | Yes | ops@compliancekit.app | SSH key only; no API key stored |
| DigitalOcean (Managed Postgres) | Primary datastore | Yes — entire domain model | $15 | Yes | ops@compliancekit.app | `CK_DB_URL` |

---

## Supporting Services

| Service | Purpose | PII Flow | Cost @ 100 customers/mo | Subprocessor | Account Owner | Credentials (env var) |
|---------|---------|----------|------------------------|--------------|---------------|----------------------|
| GitHub Pages | Static hosting for React app + marketing SEO pages | No — code only, no runtime user data | $0 | No | ops@compliancekit.app | n/a (repo-level auth) |
| GitHub Actions | CI/CD for frontend + backend | No | $0 (free tier 2,000 min/mo) | No | ops@compliancekit.app | `ACTIONS_DEPLOY_SSH_KEY` (repo secret) |
| Cloudflare DNS | DNS for `compliancekit.app`, `api.compliancekit.app`, `app.compliancekit.app` | No | $0 (free tier) | No | ops@compliancekit.app | `CK_CF_API_TOKEN` (only if scripting DNS changes) |
| Let's Encrypt (via Caddy) | TLS certificate issuance for `api.compliancekit.app` | No | $0 | No | n/a (Caddy auto) | n/a |
| Grafana Cloud (free tier) | Log aggregation + metrics + alerts | Yes — logs may contain facility IDs and redacted email domains; no document content | $0 (10GB logs, 10k metrics free) | Yes | ops@compliancekit.app | `CK_GRAFANA_CLOUD_API_KEY` |
| UptimeRobot | External uptime ping for `/healthz` | No | $0 (free tier 50 monitors) | No | ops@compliancekit.app | n/a |

---

## PII Flow Summary

### Data that leaves our infrastructure

- **To Mistral OCR:** raw document bytes (immunization records, certifications). Mistral's retention policy reviewed before production use; no training on submitted data.
- **To Gemini Flash:** OCR-extracted text only, not raw images (except when Gemini Flash is the fallback OCR path, in which case bytes are sent). Google's Gemini API terms reviewed; no training on submitted data when using the paid API with the appropriate data-use flag set.
- **To SES:** recipient email address, email body (which contains facility name, child first name, document name).
- **To Twilio:** recipient phone number, message body (same content envelope as SES).
- **To Stripe:** owner email, owner name, billing address. Card data flows directly from browser to Stripe via Stripe.js; never through our servers.
- **To AWS S3:** encrypted at rest. Bucket policies deny all public access. Signed URLs are the only access path for authenticated users.

### Data that stays within our infrastructure

- All domain data (children, staff, documents metadata, compliance snapshots, audit logs) lives in managed Postgres on the DO private network.
- Magic link tokens are only ever stored as SHA-256 hashes.
- Session cookies are opaque base62 IDs; session state lives in Postgres.

---

## Credentials Management

- Storage: `/etc/ck/env` on the DigitalOcean droplet.
- Permissions: mode 600, owner root.
- Loaded into systemd via `EnvironmentFile=/etc/ck/env`.
- Rotation cadence: annual minimum; immediate on suspected compromise.
- Backup copy: 1Password vault `ComplianceKit-Production`.
- Access: only Magnus at MVP. When a second engineer joins, 1Password sharing + rotation event.

---

## Onboarding checklist (per service)

For each service above, production readiness requires:

1. [ ] Business-tier account provisioned (not personal)
2. [ ] Billing set to a business card/bank
3. [ ] MFA enabled on the root account
4. [ ] API keys scoped to least privilege (separate keys per environment)
5. [ ] DPA / BAA / subprocessor terms reviewed and filed in `legal/`
6. [ ] Service listed in `legal/subprocessors.md`
7. [ ] Credentials stored in `/etc/ck/env` and 1Password
8. [ ] Monitoring/alert hooks configured where applicable

See [DECISIONS.md](DECISIONS.md) ADR-010 for S3 bucket partitioning rationale and [ARCHITECTURE.md §9](ARCHITECTURE.md#9-cost-estimate--100-paying-customersmonth) for the full cost model.

---

**End of EXTERNAL_SERVICES.md.**
