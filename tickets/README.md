# ComplianceKit Ticket Backlog

A lightweight, file-based Jira-like workflow. Every piece of work lives as a Markdown file on disk. Git is the source of truth.

## Folder layout

```
tickets/
├── backlog/        # New / not yet started
├── in-progress/    # Being actively worked on (WIP limit: 3)
├── blocked/        # Waiting on a dependency, decision, or external action
└── done/           # Shipped / merged / closed
```

## File naming

`REQ###-kebab-case-title.md`

- `REQ` prefix + zero-padded three-digit ID (e.g. `REQ001`, `REQ042`).
- Title in lowercase kebab-case, concise (≤7 words).
- IDs are permanent. They never change when the file moves between folders.

Examples:
- `REQ001-repo-init-and-go-module.md`
- `REQ024-ocr-pipeline-mistral-primary.md`
- `REQ056-digitalocean-droplet-provisioning.md`

## Workflow

1. **Pick work** from `backlog/` — grab the highest-priority, unblocked ticket whose dependencies are all `done/`.
2. **Start work**: `git mv tickets/backlog/REQ###-foo.md tickets/in-progress/`. Update `status:` in frontmatter to `in-progress`. Commit.
3. **Blocked?** `git mv` to `blocked/`, set `status: blocked`, add a `Blocked by:` note in the body. Commit.
4. **Finish**: `git mv` to `done/`, set `status: done`. Commit. Reference the ticket ID in the implementation commit(s).

WIP limit: no more than 3 tickets in `in-progress/` at a time for a solo founder.

## Frontmatter schema

Every ticket starts with YAML frontmatter:

```yaml
---
id: REQ###
title: Human-readable title
priority: P0 | P1 | P2 | P3
status: backlog | in-progress | blocked | done
estimate: S | M | L | XL
area: backend | frontend | infra | docs | legal
epic: EPIC-## Epic Name
depends_on: [REQ001, REQ002]   # list of REQ IDs; [] if none
---
```

### Priority

- **P0** — blocks MVP launch. Must ship.
- **P1** — needed for the first paying customer.
- **P2** — ship shortly after first customer (weeks, not months).
- **P3** — post-MVP, nice-to-have, future work.

### Estimate

- **S** — ≤4 hours
- **M** — ≤1 day
- **L** — ≤3 days
- **XL** — >3 days. Split if possible; if not, flag for review.

### Area

- `backend` — Go API, workers, migrations, business logic
- `frontend` — React/Vite/TS UI
- `infra` — DigitalOcean, S3, CI/CD, observability, networking
- `docs` — runbooks, architecture notes, onboarding
- `legal` — ToS, Privacy, DPA, compliance artifacts

## Body sections (required)

```markdown
## Problem
One to three sentences. Why does this ticket exist? What gap does it close?

## User Story
As a [role], I want [capability], so that [outcome].

## Acceptance Criteria
- [ ] Concrete, testable checkbox items.
- [ ] Each criterion should be verifiable by running code or a command.
- [ ] Include error/edge cases, not just the happy path.

## Technical Notes
File paths, package choices, schema hints, API shapes. A senior engineer
should be able to implement the ticket from this section alone.

## Definition of Done
- [ ] Code merged to `main`.
- [ ] Tests passing in CI.
- [ ] Deployed to staging (or production, where applicable).
- [ ] Any additional ticket-specific gates.

## Related Tickets
- Blocks: REQ###
- Blocked by: REQ###
- See also: REQ###
```

## Epic index

- **EPIC-01 Foundation** — REQ001–REQ008
- **EPIC-02 Auth & Magic Links** — REQ009–REQ014
- **EPIC-03 Onboarding Wizard** — REQ015–REQ021
- **EPIC-04 Document Management** — REQ022–REQ030
- **EPIC-05 PDF Signing** — REQ031–REQ034
- **EPIC-06 Compliance Engine** — REQ035–REQ040
- **EPIC-07 Chase Service** — REQ041–REQ045
- **EPIC-08 Billing (Stripe)** — REQ046–REQ048
- **EPIC-09 Parent & Staff Portals** — REQ049–REQ052
- **EPIC-10 Legal & Data** — REQ053–REQ055
- **EPIC-11 Deploy & Observability** — REQ056–REQ060

## Ticket template

Copy this block into a new file under `backlog/`:

```markdown
---
id: REQ###
title: Short title in sentence case
priority: P1
status: backlog
estimate: M
area: backend
epic: EPIC-## Epic Name
depends_on: []
---

## Problem
<Why this exists.>

## User Story
As a <role>, I want <capability>, so that <outcome>.

## Acceptance Criteria
- [ ] Criterion one.
- [ ] Criterion two.
- [ ] Edge case handled.

## Technical Notes
<Packages, file paths, schema, API shapes.>

## Definition of Done
- [ ] Code merged to `main`.
- [ ] Tests passing in CI.
- [ ] Deployed.

## Related Tickets
- Blocks:
- Blocked by:
- See also:
```
