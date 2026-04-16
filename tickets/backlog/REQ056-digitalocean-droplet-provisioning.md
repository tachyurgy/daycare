---
id: REQ056
title: DigitalOcean droplet provisioning script
priority: P0
status: backlog
estimate: L
area: infra
epic: EPIC-11 Deploy & Observability
depends_on: [REQ006, REQ007]
---

## Problem
We need a repeatable, documented way to stand up a production droplet with TLS, firewall, Postgres connectivity, and the API running under systemd.

## User Story
As an operator, I want one script plus one secrets file to spin a fresh droplet into production readiness, so that disaster recovery takes under an hour.

## Acceptance Criteria
- [ ] `deploy/scripts/provision-droplet.sh` bootstraps a fresh Ubuntu 24.04 LTS droplet:
  - Creates `ck` system user with sudo-only for `systemctl ck-api`.
  - Installs: `ca-certificates`, `curl`, `gnupg`, `ufw`, `fail2ban`, `unattended-upgrades`, `nginx`, `certbot`, `python3-certbot-nginx`.
  - Sets timezone to UTC, enables NTP.
  - Configures UFW: allow 22 (rate limited), 80, 443; deny all else.
  - Installs fail2ban with ssh jail enabled.
  - Enables unattended security upgrades.
  - Copies `deploy/systemd/ck-api.service` (REQ007) and enables it.
  - Writes `/etc/ck/ck.env` from a local `.env.prod` (never committed).
  - Configures nginx reverse proxy `api.compliancekit.com → localhost:8080` with `proxy_pass`, streaming (no buffering), WebSocket upgrade headers.
  - Obtains TLS cert via Certbot + configures nginx HTTPS with HSTS.
- [ ] Script is idempotent (safe to re-run).
- [ ] DigitalOcean-managed Postgres cluster connection configured via `DATABASE_URL` with SSL mode `require`.
- [ ] S3 buckets `ck-documents`, `ck-signed-pdfs` (Object Lock on), `ck-audit-trail` (Object Lock on), `ck-raw-uploads` (lifecycle 30d) created via a separate one-shot `deploy/scripts/create-s3-buckets.sh`.
- [ ] Terraform deferred (post-MVP); bash is fine for MVP.
- [ ] Runbook in `deploy/RUNBOOK.md` documents: create droplet in DO UI → attach SSH key → run provision script → copy env file → `systemctl start ck-api`.

## Technical Notes
- Droplet size: `s-2vcpu-4gb` for launch ($24/mo). Can scale up without downtime via DO resize.
- Backups: enable DO weekly backups on droplet; Postgres has managed backups.
- Secrets `.env.prod` stored in 1Password; pasted into `/etc/ck/ck.env` as part of provisioning.

## Definition of Done
- [ ] Fresh droplet provisioned in ≤ 20 minutes following runbook.
- [ ] `https://api.compliancekit.com/healthz` returns 200.
- [ ] SSH hardened; only key auth.

## Related Tickets
- Blocks: REQ057, REQ058, REQ060
- Blocked by: REQ006, REQ007
