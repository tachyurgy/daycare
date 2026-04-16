---
id: REQ004
title: base62 ID package
priority: P0
status: backlog
estimate: S
area: backend
epic: EPIC-01 Foundation
depends_on: [REQ001]
---

## Problem
Every table uses base62 IDs for URL-friendly, non-sequential primary keys. We need one canonical package so that `prv_XXXXX`, `chd_XXXXX`, `doc_XXXXX`, etc. are consistent and collision-resistant.

## User Story
As an engineer, I want `id.New("prv")` to return a typed, prefixed, collision-resistant identifier, so that ID generation is uniform across the codebase.

## Acceptance Criteria
- [ ] `backend/internal/id/id.go` exports `func New(prefix string) string`.
- [ ] Output format: `{prefix}_{12-char base62}` where the random part comes from 9 crypto-random bytes base62-encoded (≈72 bits entropy, still ≤ ~13 chars).
- [ ] Exports canonical prefixes as constants: `PrefixProvider="prv"`, `PrefixUser="usr"`, `PrefixChild="chd"`, `PrefixStaff="stf"`, `PrefixDocument="doc"`, `PrefixMagicLink="mlk"`, `PrefixSession="ses"`, `PrefixSubscription="sub"`, `PrefixViolation="vio"`, `PrefixNotification="ntf"`, `PrefixPolicyAccept="pol"`.
- [ ] `Parse(s) (prefix, suffix string, err error)` validates format and rejects strings without `_`.
- [ ] `MagicToken() string` returns a raw 32-byte base62 token (no prefix) for magic links.
- [ ] Uses `crypto/rand`, never `math/rand`.
- [ ] Alphabet is exactly `0-9A-Za-z`, 62 chars.
- [ ] Unit tests cover: uniqueness across 100k generations, prefix round-trip, invalid input rejection.

## Technical Notes
- Avoid third-party base62 libs; it's trivial and we don't want surprises. Convert big-endian bytes → base62 by repeated division, left-pad to fixed width.
- Benchmark: should be ≥ 1M IDs/sec on a laptop.
- All downstream packages MUST import this — forbid ad-hoc ID generation via linter comment in `CONTRIBUTING.md`.

## Definition of Done
- [ ] Tests pass including the 100k uniqueness test.
- [ ] `golangci-lint` clean.
- [ ] Benchmark committed in `id_bench_test.go`.

## Related Tickets
- Blocks: REQ002, REQ009, REQ015, REQ022
- Blocked by: REQ001
