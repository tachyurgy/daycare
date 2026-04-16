---
id: REQ040
title: GET /api/compliance/score endpoint
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-06 Compliance Engine
depends_on: [REQ035, REQ037, REQ038]
---

## Problem
The dashboard is hydrated by a single compliance payload endpoint. It needs to be fast, cached appropriately, and shape-stable.

## User Story
As a frontend, I want a single API call that returns everything the dashboard needs, so that first paint is sub-second and stateful UI stays in sync.

## Acceptance Criteria
- [ ] `GET /api/compliance/score` returns JSON:
  ```json
  {
    "score": 83,
    "sub_scores": { "staff": 88, "child": 75, "facility": 100 },
    "critical_alerts": [ { "id":"vio_...","severity":"critical","message":"...","subject":"staff:stf_...", "due_date":"YYYY-MM-DD" } ],
    "violations_count": { "critical": 2, "high": 3, "medium": 4, "low": 1 },
    "timeline_90d": [ { "date":"...", "kind":"expiring", ... } ],
    "last_computed_at":"...",
    "provider": { "id":"prv_...","name":"Sunshine Center","state":"CA" }
  }
  ```
- [ ] Requires provider-scope session (REQ013).
- [ ] Payload assembly: fetch provider snapshot from DB → call `Evaluate` → call `BuildTimeline` → call `Score` → serialize.
- [ ] Response cached per provider for 60 seconds in-memory (invalidated on document mutation via pub-sub channel).
- [ ] p95 latency ≤ 150ms on a typical provider.
- [ ] `ETag` header based on `sha256(payload)`; `304 Not Modified` when client sends `If-None-Match`.
- [ ] Timeline limited to 90 days; full history available via `GET /api/compliance/timeline?days=180` (separate but related endpoint — in scope).

## Technical Notes
- Invalidation channel: `internal/events/` simple pubsub; events emitted on document insert/update/supersede and staff/child changes.
- Snapshot builder in `internal/compliance/snapshot.go` assembles rows with a batched query plan (3 SELECTs, no N+1).
- Serialization via standard `encoding/json` with field ordering preserved.

## Definition of Done
- [ ] Endpoint returns the schema above, validated in integration tests.
- [ ] Load test: 50 req/s sustained with p95 under budget.
- [ ] Cache invalidation verified: document upload → next request reflects new score.

## Related Tickets
- Blocks:
- Blocked by: REQ035, REQ037, REQ038
