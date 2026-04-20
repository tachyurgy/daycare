# ComplianceKit — Build Status

Snapshot as of **2026-04-16** (Day 1 of the 1-week MVP sprint).

This file is the at-a-glance index of what exists in the repo right now. If you read nothing else after cloning, read this, then [`README.md`](./README.md), then [`SPEC.md`](./SPEC.md). For a plain-language tour of every feature, see [`FEATURES.md`](./FEATURES.md).

## What is done

| Area | Artifact | Files | Notes |
|---|---|---|---|
| Product & architecture | [`SPEC.md`](./SPEC.md), [`ARCHITECTURE.md`](./ARCHITECTURE.md), [`ROADMAP.md`](./ROADMAP.md), [`DECISIONS.md`](./DECISIONS.md), [`EXTERNAL_SERVICES.md`](./EXTERNAL_SERVICES.md), [`QUESTIONS.md`](./QUESTIONS.md) | 7 | 11,445 words of strategy docs. 17 ADRs (ADR-003 Postgres superseded by ADR-017 SQLite on 2026-04-17). 20 open questions. |
| Tickets | [`tickets/`](./tickets/) | 61 | 60 REQ tickets across 11 epics, Jira-like folder workflow (`backlog/ → in-progress/ → done/`). Each ticket has frontmatter, acceptance criteria, technical notes, dependencies. |
| Legal | [`legal/`](./legal/) | 14 | Privacy, ToS, MSA, DPA, subprocessors, parent consent (EN/ES), staff consent (EN/ES), cookie, AUP, ESIGN disclosure, audit trail schema. Every doc has a "this is a draft, have an attorney review" header and inline `[LAWYER CHECK]` flags. |
| DB schema | [`backend/migrations/`](./backend/migrations/), [`backend/db-schema.md`](./backend/db-schema.md) | 18 SQL files + README + narrative | 22 tables, 48+ indexes. Base62 IDs. `updated_at` trigger. Migrations `000001`–`000009`. |
| Go backend | [`backend/`](./backend/) | 33 files + pdfsign package | Compiles, `go vet` clean. Chi router, `database/sql` + SQLite (modernc.org/sqlite, pure-Go), S3, Stripe, Twilio, SES, Mistral, Gemini. Real implementations, no TODO panics. |
| Own PDF e-signature | [`backend/internal/pdfsign/`](./backend/internal/pdfsign/) + [`frontend/src/components/PdfSigner/`](./frontend/src/components/PdfSigner/) + [`docs/pdf-signature-spec.md`](./docs/pdf-signature-spec.md) | 19 files / 3,813 LOC | Browser-side render (react-pdf/PDF.js), signature_pad canvas, pdf-lib stamp, server-side hash verify, audit trail JSON to dedicated S3 bucket. 10 unit tests passing. No PSPDFKit, no DocuSign. |
| React frontend | [`frontend/`](./frontend/) | 63 files | Vite + React 18 + TS strict, React Query + Zustand, Tailwind UI kit. Full route tree, onboarding wizard, dashboard, portals, billing. |
| Deployment & CI | [`backend/deploy/`](./backend/deploy/), [`infra/scripts/`](./infra/scripts/), [`.github/workflows/`](./.github/workflows/), [`infra/s3-bucket-policies/`](./infra/s3-bucket-policies/) | 11 files + README | systemd unit, nginx conf, droplet bootstrap script, deploy script, DB backup script, 3 GitHub Actions workflows (frontend GH Pages, backend CI, backend deploy), 5 S3 bucket policies + CORS + lifecycle. |

## Numbers

- **229 files** written, ~40k LOC/words excluding pre-existing marketing HTML.
- **22 SQLite tables**, **48+ indexes** (migrations in SQLite dialect, see ADR-017).
- **60 tickets**, all priority P0 or P1 for MVP or first customer.
- **17 ADRs** locked into [`DECISIONS.md`](./DECISIONS.md) (ADR-003 PostgreSQL superseded by ADR-017 SQLite).
- **14 legal docs**, all drafts ready for attorney review.
- **10 Go unit tests** passing in the pdfsign package; backend `go build ./...` and `go vet ./...` clean.

## What you need to do before first deploy

From [`QUESTIONS.md`](./QUESTIONS.md) and the agents' post-run notes, these need human action:

1. **Create a GitHub repo** named `daycare` (public, for GH Pages) and push. Repo not created yet — that's a remote action that needs your GitHub account.
2. **Finalize LLC legal name** and replace the `{{COMPANY_LEGAL_NAME}}` / `{{COMPANY_ADDRESS}}` / `{{EFFECTIVE_DATE}}` placeholders in `legal/*.md`.
3. **Have an attorney review the legal docs.** The [`README in legal/`](./legal/README.md) lists the 13 `[LAWYER CHECK]` hot spots.
4. **Provision infra:** DigitalOcean Droplet (SQLite lives on the droplet's disk — no managed DB, per ADR-017), 2 S3 buckets (`ck-files`, `ck-backups`). Scripts are in [`infra/scripts/`](./infra/scripts/); runbook in [`infra/README.md`](./infra/README.md).
5. **Replace `ACCOUNT_ID_PLACEHOLDER`** in `infra/s3-bucket-policies/*.json` with your AWS account number.
6. **Get API credentials** for: Stripe, Twilio, AWS (SES + S3), Mistral, Gemini. Placeholder env vars are in `backend/.env.example` and `frontend/.env.example`.
7. **Configure DNS:** `api.compliancekit.com` → droplet IP, `compliancekit.com` → GitHub Pages. SES DKIM + SPF.
8. **Configure the GitHub Actions `production` environment** (required approvers) before `backend-deploy.yml` can run.
9. **Write the production env file** at `/etc/compliancekit/env` on the droplet — bootstrap script writes a scaffold but it has no real secrets.

## How to pick up work

```bash
# See what's available (sorted by ID)
ls tickets/backlog/

# Start a ticket
mv tickets/backlog/REQ001-*.md tickets/in-progress/

# When done
mv tickets/in-progress/REQ001-*.md tickets/done/
```

Recommended Week 1 execution order (from [`ROADMAP.md`](./ROADMAP.md)):

- **Day 1 (today):** Foundation — REQ001 through REQ008 (already largely scaffolded; move them to `done/` after manual verification).
- **Day 2:** Auth & magic links — REQ009–REQ014.
- **Day 3:** Onboarding wizard — REQ015–REQ021.
- **Day 4:** Document management + OCR — REQ022–REQ030.
- **Day 5:** PDF signing (mostly scaffolded, needs integration test) — REQ031–REQ034, then compliance engine REQ035–REQ040.
- **Day 6:** Chase service + billing — REQ041–REQ048.
- **Day 7:** Portals + legal + deploy — REQ049–REQ060. First paying customer eligible.

## Known integration gaps (closed, documented here for posterity)

The Go backend references five DB objects that weren't in the original 8-migration plan:

- `sessions` table (server-side session store)
- `document_chase_sends` dedup table
- `drill_logs` table
- `providers.ratio_ok` column
- `providers.postings_complete` column

These are all added in **migration `000009_sessions_chase_drills.sql`**, which was written after the DB-schema agent and backend agent both completed. No code change was needed — the Go handlers already expected these objects.

## Lineage

This skeleton was built on **2026-04-16** in a single session, in parallel, by seven background subagents coordinating on non-overlapping file paths. The top-level index ([`README.md`](./README.md)) and this status file are hand-stitched.
