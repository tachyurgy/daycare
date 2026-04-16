---
id: REQ008
title: Local dev Makefile
priority: P0
status: backlog
estimate: S
area: infra
epic: EPIC-01 Foundation
depends_on: [REQ001, REQ002, REQ006]
---

## Problem
Commands like build, test, migrate, lint, run should live in one place so we don't memorize flags or re-type them across environments.

## User Story
As a developer, I want `make help` to show every common task, so that I can work productively without a wiki.

## Acceptance Criteria
- [ ] `Makefile` at repo root.
- [ ] Targets: `help` (default), `build`, `run`, `test`, `lint`, `fmt`, `tidy`, `migrate-up`, `migrate-down`, `migrate-new`, `docker-up`, `docker-down`, `db-reset`, `seed`, `gen`, `frontend-dev`, `frontend-build`, `ci`.
- [ ] `help` auto-generates from `## ` comments on each target.
- [ ] `make test` runs `go test -race -count=1 ./...`.
- [ ] `make lint` runs `golangci-lint run ./...` (config in `.golangci.yml`).
- [ ] `make fmt` runs `gofmt -w` + `goimports -w`.
- [ ] `make db-reset` stops docker db, wipes volume, restarts, migrates, seeds — all in one command.
- [ ] `make ci` runs `tidy && fmt && lint && test && build` and is used by GitHub Actions.
- [ ] `.golangci.yml` committed with: `errcheck`, `govet`, `staticcheck`, `gosec`, `unused`, `gocritic`, `revive` enabled.

## Technical Notes
- Use `.PHONY` for every target.
- Detect OS for `goimports` installation hint.
- Keep Makefile POSIX-compatible so it works on Linux + macOS.
- `make seed` calls a tiny Go program at `backend/cmd/seed/main.go` that inserts one demo provider, two children, two staff, a few documents.

## Definition of Done
- [ ] `make help` prints a readable target list.
- [ ] `make ci` green locally and in GitHub Actions.
- [ ] README references Make targets for all common workflows.

## Related Tickets
- Blocks: REQ057, REQ058
- Blocked by: REQ001, REQ002, REQ006
