---
id: REQ055
title: Data deletion on churn (90-day grace, then purge)
priority: P1
status: backlog
estimate: L
area: backend
epic: EPIC-10 Legal & Data
depends_on: [REQ047, REQ054]
---

## Problem
When a provider cancels, we must honor our DPA: 90-day grace where they can re-activate and export, then a hard purge of PII from S3 + DB. This protects us legally and keeps storage costs in check.

## User Story
As a former customer, I want my child data to actually be deleted after I cancel, so that I trust ComplianceKit with the next center I run.

## Acceptance Criteria
- [ ] On `customer.subscription.deleted` (REQ047), set `providers.deletion_scheduled_at = now() + interval '90 days'` and `providers.status='canceled'`.
- [ ] During grace: provider can re-subscribe via portal, which clears `deletion_scheduled_at` and restores `status='active'`. Read-only access to data allowed during grace; no new uploads or chases.
- [ ] Full export available during grace: `POST /api/account/export` generates a zip of `documents/*` + `data.json` (all rows scoped to provider) placed in `ck-documents` with presigned GET (7-day TTL). Email sent to the director when ready.
- [ ] Purge job: daily cron scans `providers where deletion_scheduled_at <= now() and status='canceled'`. For each:
  - Delete all S3 objects under `providers/{prv_id}/` in all four buckets (honor Object Lock: audit-trail and signed-pdfs are retained per legal hold; only `ck-raw-uploads` and `ck-documents` non-retained objects are purged).
  - Delete DB rows in dependency order: documents → signatures → compliance_violations → notification_events → children → staff → users → sessions → magic_links → subscriptions → provider.
  - Write a purge receipt to `purge_log(provider_id, purged_at, s3_objects_deleted, db_rows_deleted, retention_holds[])`.
- [ ] Purge job is idempotent and tolerates partial failure (resume on next run).
- [ ] Audit trail S3 objects kept per Object Lock (legal requirement) — purge log notes the hold.
- [ ] Monthly "your data is scheduled for deletion in N days" email during grace (via REQ010).

## Technical Notes
- Purge uses S3 `ListObjectsV2` + `DeleteObjects` in batches of 1000.
- Object Lock retention respected — do not attempt to delete audit objects; skip and record in `retention_holds`.
- Feature flag `CK_PURGE_ENABLED=true` on first deploy; flip to on after smoke test on a staging tenant.

## Definition of Done
- [ ] End-to-end: cancel a test provider → 90 days sim → purge cron → S3 objects gone, DB rows gone (except audit).
- [ ] Re-subscribe during grace restores full access.
- [ ] Export zip valid.

## Related Tickets
- Blocks:
- Blocked by: REQ047, REQ054
