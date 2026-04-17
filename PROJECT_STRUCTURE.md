# Project Structure

Top-level map of the ComplianceKit repository.

```
daycare/
├── README.md                         Quickstart + links to major docs
├── STATUS.md                         What's done, what's next, integration gaps closed
├── FEATURES.md                       Plain-language tour of all 20 features w/ state per feature
├── SPEC.md                           Master product + technical spec (3k+ words)
├── ARCHITECTURE.md                   System context, packages, data flow, security
├── ROADMAP.md                        Day-by-day Week 1 plan, Week 2-8 post-MVP
├── DECISIONS.md                      16 ADRs (Go, React, Postgres, base62, etc.)
├── EXTERNAL_SERVICES.md              Every third-party dependency, cost, env var
├── QUESTIONS.md                      Open questions for Magnus (20 items)
├── PROJECT_STRUCTURE.md              This file
├── CLAUDE.md                         Project instructions for Claude sessions
├── MEMORY.md                         Pointer to per-project memory dir (not in repo)
├── .gitignore                        Excludes .env, builds, leads CSVs
│
├── backend/                          Go API server (deployed on DigitalOcean)
│   ├── go.mod                        Module: github.com/markdonahue100/compliancekit/backend
│   ├── Makefile                      build, run, test, migrate-up, fmt, lint, docker-build
│   ├── Dockerfile                    Multi-stage, distroless final
│   ├── docker-compose.yml            Local dev: api + postgres:16 + minio
│   ├── .env.example                  Every env var the server expects
│   ├── db-schema.md                  Narrative + ERD + retention policy
│   │
│   ├── cmd/server/main.go            Entrypoint: config → pool → router → graceful shutdown
│   │
│   ├── internal/
│   │   ├── api/                      Chi router wiring (was in httpx, split to avoid cycle)
│   │   ├── config/                   Env var config loader
│   │   ├── db/                       pgxpool + Tx helper
│   │   ├── httpx/                    Error types + JSON error envelope
│   │   ├── base62/                   26-char IDs from 32 random bytes
│   │   ├── magiclink/                HMAC-hashed tokens, 5 kinds, sliding TTL
│   │   ├── middleware/               RequireProviderSession, RequireIndividualMagicLink,
│   │   │                              RequireStripeCustomer, ratelimit
│   │   ├── models/                   Go structs mirroring DB rows
│   │   ├── storage/                  AWS S3 wrapper (4 buckets)
│   │   ├── notify/                   SES email, Twilio SMS, chase scheduler
│   │   ├── billing/                  Stripe checkout, webhook, portal, paywall
│   │   ├── ocr/                      Mistral + Gemini chain + expiration extraction
│   │   ├── immunization/             Deterministic CDC ACIP schedule (10 vaccines)
│   │   ├── compliance/               Pure rule evaluator + state rule packs (CA/TX/FL)
│   │   ├── pdfsign/                  In-house e-sig server: sessions, finalize, audit JSON
│   │   ├── handlers/                 HTTP handlers per resource
│   │   └── auth/                     (placeholder; auth lives in middleware + magiclink)
│   │
│   ├── migrations/                   golang-migrate SQL pairs, 000001–000009
│   │   ├── 000001_init_providers_and_users.{up,down}.sql
│   │   ├── 000002_children.{up,down}.sql
│   │   ├── 000003_staff.{up,down}.sql
│   │   ├── 000004_documents.{up,down}.sql
│   │   ├── 000005_pdfsign.{up,down}.sql
│   │   ├── 000006_compliance_and_notifications.{up,down}.sql
│   │   ├── 000007_billing_and_legal.{up,down}.sql
│   │   ├── 000008_audit_and_activity.{up,down}.sql
│   │   ├── 000009_sessions_chase_drills.{up,down}.sql
│   │   └── README.md
│   │
│   └── deploy/
│       ├── compliancekit.service     systemd unit for the Go binary
│       └── nginx.conf                TLS reverse proxy, 50MB client_max_body_size
│
├── frontend/                         React SPA (deployed on GitHub Pages)
│   ├── package.json                  All deps: react-pdf, pdf-lib, signature_pad, etc.
│   ├── vite.config.ts                base path configurable, pdfjs worker copy
│   ├── tsconfig.json                 Strict mode
│   ├── tailwind.config.ts            brand=emerald-600, caution=amber-500, critical=red-600
│   ├── index.html
│   ├── .env.example                  VITE_API_BASE_URL, VITE_STRIPE_PUBLISHABLE_KEY, etc.
│   ├── public/404.html               GH Pages SPA redirect shim
│   │
│   └── src/
│       ├── main.tsx                  QueryClientProvider + Router
│       ├── App.tsx                   Route tree with Suspense-lazy /sign/:token, /templates
│       ├── index.css                 Tailwind directives
│       │
│       ├── api/                      Typed fetch wrappers, zod response validation
│       ├── hooks/                    useSession (zustand), useDashboard, etc. (React Query)
│       ├── lib/                      base62, format, validation, zodResolver
│       ├── components/common/        Button, Input, Card, Badge, Modal, Layout, etc.
│       │
│       ├── components/PdfSigner/     Own e-signature UI (owned by pdfsign agent)
│       │   ├── PdfSigner.tsx         Main orchestrator
│       │   ├── SignaturePad.tsx      signature_pad wrapper
│       │   ├── FieldOverlay.tsx      Field renderer, signer + authoring modes
│       │   ├── FieldDesigner.tsx     Provider authoring UI (drag fields onto PDF)
│       │   ├── pdfStamp.ts           pdf-lib stamping + SHA-256
│       │   ├── types.ts, api.ts
│       │   ├── README.md, package-deps.md
│       │
│       └── pages/
│           ├── Landing.tsx
│           ├── MagicLinkRequest.tsx, MagicLinkCallback.tsx
│           ├── onboarding/           TurboTax-style wizard + steps + wizardStore
│           ├── Dashboard.tsx
│           ├── Children.tsx, ChildDetail.tsx
│           ├── Staff.tsx, StaffDetail.tsx
│           ├── Documents.tsx, DocumentDetail.tsx
│           ├── PortalParent.tsx      magic-link parent upload
│           ├── PortalStaff.tsx       magic-link staff upload
│           ├── Settings.tsx, SettingsBilling.tsx
│           ├── SignDocument.tsx      (owned by pdfsign agent)
│           └── DocumentTemplates.tsx (owned by pdfsign agent)
│
├── tickets/                          Jira-like flat-file ticket system
│   ├── README.md                     Workflow + ticket template
│   ├── backlog/                      60 files: REQ001 through REQ060
│   ├── in-progress/                  (empty; move tickets here when starting)
│   ├── blocked/                      (empty)
│   └── done/                         (empty; move tickets here when finished)
│
├── legal/                            Draft legal docs for attorney review
│   ├── README.md                     Index + when each doc is presented
│   ├── privacy-policy.md             CCPA/CPRA/TDPSA/FDBR compliant
│   ├── terms-of-service.md           12-month liability cap, WA governing law
│   ├── master-subscription-agreement.md  B2B contract with 99.5% SLA
│   ├── data-processing-agreement.md  Processor-role DPA, 7 subprocessors
│   ├── subprocessors.md              Living list
│   ├── parent-consent.md (+ -es.md)  Plain-language, ES translation
│   ├── employee-consent.md (+ -es)
│   ├── cookie-policy.md
│   ├── acceptable-use-policy.md
│   ├── esignature-disclosure.md      ESIGN Act / UETA consent disclosure
│   └── signature-audit-trail-schema.md  JSON shape for ck-audit-trail bucket
│
├── infra/                            Ops and deployment
│   ├── README.md                     End-to-end runbook
│   ├── scripts/
│   │   ├── bootstrap-droplet.sh      One-shot Ubuntu 24.04 hardening + nginx + certbot
│   │   ├── deploy.sh                 Build → rsync → migrate → restart → health-check
│   │   └── backup-db.sh              Daily pg_dump → ck-backups bucket
│   └── s3-bucket-policies/           JSON policies + CORS + lifecycle
│       ├── ck-documents.json (+ .cors.json)
│       ├── ck-signed-pdfs.json
│       ├── ck-audit-trail.json       Object Lock compliance mode, 7-year retention
│       ├── ck-raw-uploads.json
│       └── ck-backups.json (+ .lifecycle.json)
│
├── .github/workflows/
│   ├── frontend-deploy.yml           Build + deploy Vite to gh-pages branch
│   ├── backend-ci.yml                go vet + go build + go test (with postgres service)
│   └── backend-deploy.yml            SSH rollout to droplet, gated by environment approval
│
├── docs/
│   └── pdf-signature-spec.md         Threat model + signing lifecycle + audit schema
│
├── planning-docs/                    Pre-existing regulatory research (state PDFs)
│
├── *.html                            Pre-existing marketing / SEO content
│   └── (compliancekit-product-overview, how-to-pass-daycare-inspection-*, etc.)
│
└── *_leads.csv                       Pre-existing lead lists (gitignored)
```
