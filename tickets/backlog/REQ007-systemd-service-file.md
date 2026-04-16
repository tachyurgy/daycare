---
id: REQ007
title: systemd service file for DigitalOcean droplet
priority: P0
status: backlog
estimate: S
area: infra
epic: EPIC-01 Foundation
depends_on: [REQ003, REQ005]
---

## Problem
Production runs the API as a long-lived process on a DigitalOcean droplet. We need systemd to manage lifecycle, restarts, and env loading.

## User Story
As an operator, I want `systemctl restart ck-api` to cleanly restart the service with the latest binary, so that deploys are safe and auto-recover on crash.

## Acceptance Criteria
- [ ] `deploy/systemd/ck-api.service` committed with `[Unit]`, `[Service]`, `[Install]` sections.
- [ ] `Service` section: `Type=simple`, `ExecStart=/opt/ck/bin/ck-api`, `Restart=on-failure`, `RestartSec=5`, `User=ck`, `Group=ck`, `EnvironmentFile=/etc/ck/ck.env`, `WorkingDirectory=/opt/ck`, `StandardOutput=journal`, `StandardError=journal`.
- [ ] Hardening flags set: `NoNewPrivileges=true`, `PrivateTmp=true`, `ProtectSystem=strict`, `ProtectHome=true`, `ReadWritePaths=/var/log/ck`.
- [ ] Graceful shutdown: `KillSignal=SIGTERM`, `TimeoutStopSec=30`.
- [ ] Go API handles `SIGTERM` by draining HTTP server with a 25s context.
- [ ] Install script `deploy/scripts/install-systemd.sh` copies the unit file, runs `systemctl daemon-reload`, `systemctl enable ck-api`.
- [ ] README section documents log inspection via `journalctl -u ck-api -f`.

## Technical Notes
- Drain in `main.go` with `signal.NotifyContext(ctx, syscall.SIGINT, syscall.SIGTERM)` + `server.Shutdown(shutdownCtx)`.
- `/etc/ck/ck.env` is mode 0640 owned by `root:ck`, provisioned by REQ056.
- Do not use `After=network.target` only; use `After=network-online.target` with `Wants=network-online.target`.

## Definition of Done
- [ ] Unit file validated with `systemd-analyze verify`.
- [ ] Manual test on droplet: `systemctl start ck-api` → healthy, `kill -TERM` → clean shutdown in logs.

## Related Tickets
- Blocks: REQ056
- Blocked by: REQ003, REQ005
