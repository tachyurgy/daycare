---
id: REQ002
title: Postgres schema and migration runner
priority: P0
status: backlog
estimate: L
area: backend
epic: EPIC-01 Foundation
depends_on: [REQ001]
---

## Problem
We need a versioned schema and a repeatable way to apply migrations in dev, staging, and prod. Without it we can't safely evolve the data model.

## User Story
As an engineer, I want `make migrate-up` to apply all SQL migrations against a target database, so that schema state is deterministic across environments.

## Acceptance Criteria
- [ ] `migrations/` contains numbered `.up.sql` / `.down.sql` pairs starting at `0001_init.up.sql`.
- [ ] Initial migration creates core tables: `providers`, `users`, `sessions`, `magic_links`, `children`, `staff`, `documents`, `document_types`, `compliance_violations`, `notification_events`, `policy_acceptances`, `subscriptions`.
- [ ] All IDs are `text primary key` (base62, see REQ005), not serial/uuid.
- [ ] Every table has `created_at timestamptz not null default now()` and `updated_at timestamptz not null default now()`.
- [ ] `providers.state` is `text not null check (state in ('CA','TX','FL'))` for MVP.
- [ ] Foreign keys use `on delete cascade` where appropriate (e.g., `children.provider_id` → `providers.id`).
- [ ] Migration runner: `github.com/golang-migrate/migrate/v4` wrapped in `make migrate-up`, `make migrate-down`, `make migrate-new NAME=foo`.
- [ ] CLI target reads `DATABASE_URL` from env.
- [ ] Rollback (`migrate-down`) is tested against a fresh DB.

## Technical Notes
- Prefer `text` over `varchar(n)` unless a hard limit exists.
- Use `jsonb` for flexible blobs (e.g., `documents.ocr_result`, `compliance_violations.context`).
- Add partial indexes on `documents (provider_id) where deleted_at is null`.
- Put shared SQL enums as `check` constraints, not Postgres enum types (easier to evolve).
- `backend/internal/db/db.go` opens a `*pgxpool.Pool` using `jackc/pgx/v5`.

## Definition of Done
- [ ] `make migrate-up` creates all tables in a fresh Postgres.
- [ ] `make migrate-down` cleanly drops them.
- [ ] `docker-compose up db` followed by `make migrate-up` is documented in README.

## Related Tickets
- Blocks: REQ003, REQ015, REQ022, REQ035
- Blocked by: REQ001
