---
id: REQ002
title: SQLite schema and migration runner
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
- [ ] `migrations/` contains numbered `.up.sql` / `.down.sql` pairs starting at `000001_*.up.sql`.
- [ ] Initial migration creates core tables: `providers`, `users`, `sessions`, `magic_link_tokens`, `children`, `staff`, `documents`, `document_types`, `compliance_violations`, `notification_events`, `policy_acceptances`, `subscriptions`.
- [ ] All IDs are `TEXT PRIMARY KEY` (base62, see REQ005), not serial/uuid.
- [ ] Every table has `created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP` and `updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP`. ISO 8601 UTC strings.
- [ ] `providers.state` is `TEXT NOT NULL`; state-code validation is enforced in Go (SQLite has no regex CHECK without a loadable extension).
- [ ] Foreign keys use `ON DELETE CASCADE` where appropriate (e.g., `children.provider_id` → `providers.id`). FK enforcement requires `PRAGMA foreign_keys = ON`, set by `db.Open`.
- [ ] Migration runner: `github.com/golang-migrate/migrate/v4` (sqlite3 driver) wrapped in `make migrate-up`, `make migrate-down`, `make migrate-new NAME=foo`.
- [ ] CLI target reads `DATABASE_URL` from env (file path or `file:` URL).
- [ ] Rollback (`migrate-down`) is tested against a fresh DB file.

## Technical Notes
- SQLite dialect (ADR-017 supersedes the original Postgres choice in ADR-003).
- Prefer `TEXT` over any varchar. SQLite stores all text as TEXT regardless.
- Use `TEXT` validated by `json_valid(col)` for flexible JSON blobs (e.g., `documents.ocr_result`, `compliance_violations.context`). The `json1` extension is compiled in; no setup needed.
- Partial indexes on `documents (provider_id) WHERE deleted_at IS NULL` are supported (SQLite 3.8+).
- Express enums as `CHECK (col IN (...))` constraints — same shape as the original plan.
- `backend/internal/db/db.go` opens a `*sql.DB` using the pure-Go `modernc.org/sqlite` driver and applies pragmas: `journal_mode=WAL`, `synchronous=NORMAL`, `foreign_keys=ON`, `busy_timeout=5000`, `temp_store=MEMORY`.
- Case-insensitive columns use `COLLATE NOCASE` (replaces PG CITEXT).

## Definition of Done
- [ ] `make migrate-up` creates all tables in a fresh SQLite file.
- [ ] `make migrate-down` cleanly drops them.
- [ ] Local dev quickstart (`.env` + `make migrate-up`) is documented in README.

## Related Tickets
- Blocks: REQ003, REQ015, REQ022, REQ035
- Blocked by: REQ001
