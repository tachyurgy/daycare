#!/usr/bin/env bash
#
# deploy.sh — ship a new build of ComplianceKit to the production droplet.
#
# Steps:
#   1. Build the Go binary locally (static, linux/amd64).
#   2. rsync the binary + migrations + deploy/ to the droplet.
#   3. Run `migrate up` over ssh.
#   4. Atomically swap the binary (symlink dance).
#   5. `systemctl restart compliancekit`.
#   6. Poll /healthz; if unhealthy, roll back to the previous binary.
#
# Env-var overrides:
#   DEPLOY_HOST     default: api.compliancekit.com
#   DEPLOY_USER     default: compliancekit
#   APP_DIR         default: /opt/compliancekit
#   HEALTH_URL      default: https://api.compliancekit.com/healthz
#   HEALTH_TIMEOUT  default: 60 (seconds)
#
# Usage:
#   infra/scripts/deploy.sh

set -euo pipefail

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
DEPLOY_HOST="${DEPLOY_HOST:-api.compliancekit.com}"
DEPLOY_USER="${DEPLOY_USER:-compliancekit}"
APP_DIR="${APP_DIR:-/opt/compliancekit}"
HEALTH_URL="${HEALTH_URL:-https://api.compliancekit.com/healthz}"
HEALTH_TIMEOUT="${HEALTH_TIMEOUT:-60}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND_DIR="$REPO_ROOT/backend"
BUILD_DIR="$REPO_ROOT/.build/deploy"
RELEASE_ID="$(date -u +%Y%m%dT%H%M%SZ)-$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo nogit)"

SSH_OPTS=(-o StrictHostKeyChecking=accept-new -o ServerAliveInterval=15)
SSH="ssh ${SSH_OPTS[*]} ${DEPLOY_USER}@${DEPLOY_HOST}"
RSYNC_SSH="ssh ${SSH_OPTS[*]}"

log()  { printf "\n\033[1;36m==> %s\033[0m\n" "$*"; }
die()  { printf "\033[1;31mERROR: %s\033[0m\n" "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 0. Preflight
# ---------------------------------------------------------------------------
command -v go     >/dev/null 2>&1 || die "go not in PATH"
command -v rsync  >/dev/null 2>&1 || die "rsync not in PATH"
command -v ssh    >/dev/null 2>&1 || die "ssh not in PATH"
command -v curl   >/dev/null 2>&1 || die "curl not in PATH"

if ! git -C "$REPO_ROOT" diff --quiet || ! git -C "$REPO_ROOT" diff --cached --quiet; then
    log "WARNING: working tree has uncommitted changes; continuing anyway."
fi

# ---------------------------------------------------------------------------
# 1. Build
# ---------------------------------------------------------------------------
log "Building Go binary (linux/amd64, static) — release ${RELEASE_ID}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/bin"

( cd "$BACKEND_DIR" && \
  CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
  go build -trimpath \
    -ldflags "-s -w -X main.Version=${RELEASE_ID}" \
    -o "$BUILD_DIR/bin/compliancekit" \
    ./cmd/compliancekit )

# Copy the other deploy artifacts we want on the server.
mkdir -p "$BUILD_DIR/migrations" "$BUILD_DIR/deploy"
cp -r "$BACKEND_DIR/migrations/." "$BUILD_DIR/migrations/"
cp -r "$BACKEND_DIR/deploy/."     "$BUILD_DIR/deploy/"

log "Built binary:"
ls -lh "$BUILD_DIR/bin/compliancekit"

# ---------------------------------------------------------------------------
# 2. rsync to droplet (to a release-scoped dir; we swap atomically below)
# ---------------------------------------------------------------------------
REMOTE_RELEASE_DIR="${APP_DIR}/releases/${RELEASE_ID}"

log "Syncing release to ${DEPLOY_USER}@${DEPLOY_HOST}:${REMOTE_RELEASE_DIR}"
$SSH "mkdir -p '${REMOTE_RELEASE_DIR}/bin' '${REMOTE_RELEASE_DIR}/migrations' '${REMOTE_RELEASE_DIR}/deploy'"

rsync -az --delete \
    -e "$RSYNC_SSH" \
    "$BUILD_DIR/bin/"        "${DEPLOY_USER}@${DEPLOY_HOST}:${REMOTE_RELEASE_DIR}/bin/"
rsync -az --delete \
    -e "$RSYNC_SSH" \
    "$BUILD_DIR/migrations/" "${DEPLOY_USER}@${DEPLOY_HOST}:${REMOTE_RELEASE_DIR}/migrations/"
rsync -az --delete \
    -e "$RSYNC_SSH" \
    "$BUILD_DIR/deploy/"     "${DEPLOY_USER}@${DEPLOY_HOST}:${REMOTE_RELEASE_DIR}/deploy/"

# ---------------------------------------------------------------------------
# 3. Run migrations (from the new release dir, using DATABASE_URL from env file)
# ---------------------------------------------------------------------------
log "Running database migrations"
$SSH bash <<EOF
set -euo pipefail
# Load DATABASE_URL from /etc/compliancekit/env without exporting other secrets
# into this shell.
DATABASE_URL="\$(grep -E '^DATABASE_URL=' /etc/compliancekit/env | cut -d= -f2-)"
if [[ -z "\$DATABASE_URL" ]]; then
    echo "DATABASE_URL not set in /etc/compliancekit/env" >&2
    exit 1
fi
/usr/local/bin/migrate -path '${REMOTE_RELEASE_DIR}/migrations' -database "\$DATABASE_URL" up
EOF

# ---------------------------------------------------------------------------
# 4. Atomic swap: update the `current` symlink, update bin/, reload units
# ---------------------------------------------------------------------------
log "Swapping symlinks + installing deploy configs"
$SSH bash <<EOF
set -euo pipefail

# Preserve the previous release symlink for rollback.
if [[ -L '${APP_DIR}/current' ]]; then
    ln -sfn "\$(readlink '${APP_DIR}/current')" '${APP_DIR}/previous'
fi

# Point current -> new release.
ln -sfn '${REMOTE_RELEASE_DIR}' '${APP_DIR}/current'

# The systemd unit uses /opt/compliancekit/bin/compliancekit (a stable path).
# Point that at the release's binary via a second symlink.
ln -sfn '${APP_DIR}/current/bin/compliancekit' '${APP_DIR}/bin/compliancekit'

# Install/refresh the systemd unit + nginx config if they changed.
if ! cmp -s '${APP_DIR}/current/deploy/compliancekit.service' /etc/systemd/system/compliancekit.service 2>/dev/null; then
    sudo cp '${APP_DIR}/current/deploy/compliancekit.service' /etc/systemd/system/compliancekit.service
    sudo systemctl daemon-reload
fi
if ! cmp -s '${APP_DIR}/current/deploy/nginx.conf' /etc/nginx/sites-available/compliancekit 2>/dev/null; then
    sudo cp '${APP_DIR}/current/deploy/nginx.conf' /etc/nginx/sites-available/compliancekit
    sudo nginx -t
    sudo systemctl reload nginx
fi

# Retain only the last 5 releases.
cd '${APP_DIR}/releases'
ls -1t | tail -n +6 | xargs -r rm -rf

# Restart the service.
sudo systemctl restart compliancekit
EOF

# ---------------------------------------------------------------------------
# 5. Health check loop
# ---------------------------------------------------------------------------
log "Polling ${HEALTH_URL} for up to ${HEALTH_TIMEOUT}s"
deadline=$(( $(date +%s) + HEALTH_TIMEOUT ))
healthy=0
while [[ $(date +%s) -lt $deadline ]]; do
    status=$(curl -sS -o /dev/null -w "%{http_code}" --max-time 5 "$HEALTH_URL" || echo "000")
    if [[ "$status" == "200" ]]; then
        healthy=1
        break
    fi
    printf "  health check: %s (retry in 2s)\n" "$status"
    sleep 2
done

if [[ $healthy -ne 1 ]]; then
    log "HEALTH CHECK FAILED — rolling back"
    $SSH bash <<EOF
set -euo pipefail
if [[ -L '${APP_DIR}/previous' ]]; then
    ln -sfn "\$(readlink '${APP_DIR}/previous')" '${APP_DIR}/current'
    ln -sfn '${APP_DIR}/current/bin/compliancekit' '${APP_DIR}/bin/compliancekit'
    sudo systemctl restart compliancekit
    echo "Rolled back to previous release."
else
    echo "No previous release symlink — cannot roll back automatically!"
    exit 1
fi
EOF
    die "Deploy failed health check; rolled back. Investigate systemd logs: journalctl -u compliancekit -n 200"
fi

log "Deploy OK — release ${RELEASE_ID} is live."
