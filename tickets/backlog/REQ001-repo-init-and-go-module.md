---
id: REQ001
title: Repo init and Go module setup
priority: P0
status: backlog
estimate: S
area: backend
epic: EPIC-01 Foundation
depends_on: []
---

## Problem
There is no monorepo skeleton yet. Everything downstream (auth, compliance, billing) needs a stable layout and a working Go module before work can parallelize.

## User Story
As the founding engineer, I want a clean repo skeleton with a working `go build`, so that I can begin implementing features without tripping on structure.

## Acceptance Criteria
- [ ] Git repo initialized at `/Users/magnusfremont/Desktop/daycare/` with `main` branch.
- [ ] `backend/` directory with `go.mod` declaring module `github.com/compliancekit/ck` and Go 1.22+.
- [ ] `frontend/` directory reserved (empty README placeholder) for the Vite app.
- [ ] Directory tree committed: `backend/cmd/api/`, `backend/internal/{auth,compliance,documents,chase,billing,storage,db,config,id,log,httpx}/`, `backend/migrations/`, `backend/scripts/`.
- [ ] `backend/cmd/api/main.go` contains a stub `main()` that logs "ck-api starting" and exits 0.
- [ ] `make build` produces `bin/ck-api`.
- [ ] `.gitignore` excludes `bin/`, `.env`, `node_modules/`, `dist/`, `*.log`.
- [ ] `README.md` at repo root explains how to build/run locally.

## Technical Notes
- Use standard library `log/slog` stub in `main.go` for now; structured logging is expanded in REQ006.
- `go.mod` should pin `go 1.22`. Avoid pulling dependencies yet beyond stdlib.
- Follow `cmd/` + `internal/` layout (https://github.com/golang-standards/project-layout) but keep it minimal.
- Do not vendor deps; rely on module proxy.

## Definition of Done
- [ ] `go build ./...` succeeds.
- [ ] `make build` succeeds.
- [ ] Repo pushed to GitHub (private for backend, public for frontend later).
- [ ] README lists: prereqs (Go 1.22, Node 20, Docker), `make build`, `make run`.

## Related Tickets
- Blocks: REQ002, REQ003, REQ004, REQ005, REQ006, REQ007, REQ008
- Blocked by: —
