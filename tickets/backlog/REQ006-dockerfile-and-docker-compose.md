---
id: REQ006
title: Dockerfile and docker-compose for local dev
priority: P0
status: backlog
estimate: S
area: infra
epic: EPIC-01 Foundation
depends_on: [REQ001, REQ002]
---

## Problem
Local dev needs Postgres and the API running together, reproducibly. A single `docker-compose up` should stand the stack up.

## User Story
As a new contributor, I want `docker-compose up` to start Postgres and the API, so that I can develop without installing Postgres locally.

## Acceptance Criteria
- [ ] `backend/Dockerfile` is a multi-stage build: `golang:1.22-alpine` builder → `gcr.io/distroless/static-debian12` runtime.
- [ ] Final image is ≤ 30 MB and runs as non-root uid `65532`.
- [ ] Image exposes port `8080`, runs `/ck-api`.
- [ ] `docker-compose.yml` at repo root defines services: `db` (`postgres:16-alpine`, volume `pgdata`, port `5432`), `api` (built from `backend/Dockerfile`, depends on `db`, reads `.env`).
- [ ] `docker-compose.yml` forwards `8080:8080` and mounts `./backend/migrations:/migrations:ro` for migrate-on-start.
- [ ] A `migrate` one-shot service runs `migrate -path /migrations -database $DATABASE_URL up` before `api` starts.
- [ ] `docker compose up` (v2) works without errors; API responds to `GET /healthz` with 200.
- [ ] Healthcheck in compose for both `db` (pg_isready) and `api` (`GET /healthz`).

## Technical Notes
- Use `CGO_ENABLED=0 GOOS=linux go build -ldflags='-s -w' -o /ck-api ./cmd/api`.
- Healthz endpoint at `backend/internal/httpx/health.go` returns `{"status":"ok","version":"...","db":"ok|down"}`.
- Ship `.dockerignore` that excludes `.git`, `bin/`, `node_modules/`, `.env`.

## Definition of Done
- [ ] `docker compose up --build` brings up a fully working dev stack.
- [ ] `curl localhost:8080/healthz` returns 200.
- [ ] Image size under 30 MB confirmed via `docker images`.

## Related Tickets
- Blocks: REQ008, REQ056
- Blocked by: REQ001, REQ002
