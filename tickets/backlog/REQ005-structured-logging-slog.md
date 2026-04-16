---
id: REQ005
title: Structured JSON logging with slog
priority: P0
status: backlog
estimate: S
area: backend
epic: EPIC-01 Foundation
depends_on: [REQ001, REQ003]
---

## Problem
We need consistent, structured logs from day one so production debugging and log aggregation work. Unstructured `fmt.Println` is a dead end.

## User Story
As an operator, I want every request and every error to produce a structured JSON log line with a request ID, so that I can grep and aggregate logs efficiently.

## Acceptance Criteria
- [ ] `backend/internal/log/log.go` initializes `log/slog` with a JSON handler in prod, text handler in dev.
- [ ] Log level controlled by `LOG_LEVEL` env var (default `info`).
- [ ] HTTP middleware `log.RequestMiddleware` adds `request_id` (base62, 10 chars), method, path, status, duration_ms, remote_ip to every access log line.
- [ ] `request_id` is injected into `context.Context` via typed key and included in any downstream log within the request.
- [ ] Helper `log.FromContext(ctx) *slog.Logger` returns a logger pre-loaded with the request-scoped attrs.
- [ ] Panics in handlers are recovered and logged with stack trace at `error` level; response becomes 500 JSON `{"error":"internal"}`.
- [ ] Secrets (`Authorization`, `Cookie`, `X-Stripe-Signature`) are never logged as headers.

## Technical Notes
- Prefer stdlib `log/slog` (Go 1.21+). No third-party logger.
- Use `slog.HandlerOptions{AddSource: true}` in dev, false in prod (noisy + slow).
- For request IDs use `id.New` but trimmed or use `id.MagicToken()[:10]`.
- Middleware lives in `backend/internal/httpx/middleware.go`.

## Definition of Done
- [ ] A sample request produces a single-line JSON log with all required fields.
- [ ] Panic during a handler produces a structured error log + 500 response, server keeps serving.
- [ ] Tests cover: log level filtering, redaction of sensitive headers.

## Related Tickets
- Blocks: REQ007, REQ009, REQ022, REQ059
- Blocked by: REQ001, REQ003
