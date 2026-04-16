---
id: REQ025
title: OCR pipeline — Mistral primary, Gemini fallback
priority: P0
status: backlog
estimate: L
area: backend
epic: EPIC-04 Document Management
depends_on: [REQ003, REQ022, REQ023]
---

## Problem
Parents upload phone photos of creased immunization cards and scanned PDFs. We need robust OCR to extract text before we can classify or extract expiration dates.

## User Story
As the system, I want to run uploaded documents through OCR with automatic fallback, so that one provider's outage doesn't stop compliance work.

## Acceptance Criteria
- [ ] `internal/ocr/` package with `OCR` interface: `Extract(ctx, doc Document) (Result, error)`.
- [ ] Primary implementation: `mistral.go` — calls Mistral OCR API, returns text + bounding boxes + page count.
- [ ] Fallback implementation: `gemini.go` — uses Gemini Flash vision with an "extract all text" prompt.
- [ ] `Pipeline.Extract` tries Mistral with 30s timeout; on error or timeout or confidence < 0.5, retries with Gemini.
- [ ] Circuit breaker per provider (`sony/gobreaker`): after 5 consecutive failures in 60s, skip that provider for 2 min.
- [ ] Retry with exponential backoff within a provider: 3 attempts at 1s/3s/9s (only for 5xx and network errors; 4xx → hard fail).
- [ ] Result persisted to `documents.ocr_raw`, `documents.ocr_provider`, `documents.ocr_attempts`.
- [ ] Job runner: `internal/ocr/worker.go` polls `documents where status='ocr_pending'` with `FOR UPDATE SKIP LOCKED`, processes in parallel (max 4 concurrent).
- [ ] On exhaustion of all providers, sets `status='ocr_failed'` and raises an `ocr_failed` event for operator alerting.
- [ ] Metrics emitted: per-provider latency, success rate, fallback rate.

## Technical Notes
- Download from S3 into memory (25 MB cap already enforced). HEIC images converted to JPEG with `x/image/...` or a lightweight CGO-free libvips shim — evaluate at implementation time.
- Mistral endpoint: `/v1/ocr` (verify current docs). Bearer auth from config.
- Keep provider calls in interface-only files to make testing with fakes clean.

## Definition of Done
- [ ] Unit test with both provider fakes covers primary-success, primary-fail-fallback-success, both-fail paths.
- [ ] Circuit breaker test verifies skip logic.
- [ ] Real run against staging Mistral + Gemini on 5 sample immunization images.

## Related Tickets
- Blocks: REQ026, REQ027
- Blocked by: REQ003, REQ022, REQ023
