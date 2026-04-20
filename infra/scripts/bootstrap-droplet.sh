#!/usr/bin/env bash
#
# bootstrap-droplet.sh
#
# Idempotent provisioning for a fresh Ubuntu 24.04 LTS DigitalOcean Droplet
# that will host the ComplianceKit API.
#
# Run as root (via `ssh root@$DROPLET_IP 'bash -s' < bootstrap-droplet.sh`)
# or locally on the droplet with sudo. Safe to re-run — every step is
# guarded against existing state.
#
# What it does:
#   1. System update + baseline packages
#   2. Creates the `compliancekit` system user + dirs
#   3. Hardens SSH (no root password auth, keys only)
#   4. Installs + configures fail2ban
#   5. Installs + configures ufw (22, 80, 443 only)
#   6. Installs nginx, places our reverse-proxy config
#   7. Installs certbot, requests a cert for api.compliancekit.com
#   8. Installs the systemd unit
#   9. Installs the postgres client + migrate binary
#  10. Creates /etc/compliancekit/env scaffold (if absent)
#
# Env-var overrides:
#   API_DOMAIN      default: api.compliancekit.com
#   CERT_EMAIL      default: ops@compliancekit.com
#   ADMIN_SSH_KEY   public key to install for the `compliancekit` user (required)
#
# Usage:
#   ADMIN_SSH_KEY="$(cat ~/.ssh/id_ed25519.pub)" \
#     ssh root@$DROPLET_IP 'bash -s' < infra/scripts/bootstrap-droplet.sh

set -euo pipefail

# ----------------------------------------------------------------------------
# 0. Sanity + defaults
# ----------------------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: must run as root" >&2
    exit 1
fi

API_DOMAIN="${API_DOMAIN:-api.compliancekit.com}"
CERT_EMAIL="${CERT_EMAIL:-ops@compliancekit.com}"
ADMIN_SSH_KEY="${ADMIN_SSH_KEY:-}"

if [[ -z "$ADMIN_SSH_KEY" ]]; then
    echo "ERROR: ADMIN_SSH_KEY env var must be set (paste of your id_ed25519.pub)" >&2
    exit 1
fi

SERVICE_USER="compliancekit"
APP_DIR="/opt/compliancekit"
ENV_DIR="/etc/compliancekit"
LOG_DIR="/var/log/compliancekit"

log() { printf "\n\033[1;36m==> %s\033[0m\n" "$*"; }

# ----------------------------------------------------------------------------
# 1. apt update + baseline
# ----------------------------------------------------------------------------
log "Updating apt + installing baseline packages"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg lsb-release \
    rsync jq unzip git \
    nginx certbot python3-certbot-nginx \
    ufw fail2ban \
    postgresql-client-16 \
    unattended-upgrades

# Enable unattended security upgrades.
dpkg-reconfigure -f noninteractive unattended-upgrades || true

# ----------------------------------------------------------------------------
# 2. Service user + directories
# ----------------------------------------------------------------------------
log "Creating ${SERVICE_USER} user and directories"
if ! id -u "$SERVICE_USER" >/dev/null 2>&1; then
    useradd --system --create-home --shell /usr/sbin/nologin "$SERVICE_USER"
fi

install -d -o "$SERVICE_USER" -g "$SERVICE_USER" -m 0755 "$APP_DIR"
install -d -o "$SERVICE_USER" -g "$SERVICE_USER" -m 0755 "$APP_DIR/bin"
install -d -o "$SERVICE_USER" -g "$SERVICE_USER" -m 0755 "$APP_DIR/tmp"
install -d -o "$SERVICE_USER" -g "$SERVICE_USER" -m 0755 "$APP_DIR/migrations"
install -d -o root            -g root            -m 0750 "$ENV_DIR"
install -d -o "$SERVICE_USER" -g "$SERVICE_USER" -m 0755 "$LOG_DIR"

# Install the operator's key on the compliancekit account so deploy.sh can
# rsync into $APP_DIR as that user.
install -d -o "$SERVICE_USER" -g "$SERVICE_USER" -m 0700 "/home/$SERVICE_USER/.ssh"
AUTH_KEYS="/home/$SERVICE_USER/.ssh/authorized_keys"
touch "$AUTH_KEYS"
chown "$SERVICE_USER:$SERVICE_USER" "$AUTH_KEYS"
chmod 0600 "$AUTH_KEYS"
if ! grep -qF "$ADMIN_SSH_KEY" "$AUTH_KEYS"; then
    echo "$ADMIN_SSH_KEY" >> "$AUTH_KEYS"
fi

# Allow the compliancekit user to restart its own systemd service without
# sudo password — the deploy script relies on this.
SUDOERS_FILE="/etc/sudoers.d/compliancekit"
cat > "$SUDOERS_FILE" <<'EOF'
# Allow the compliancekit deploy account to restart the service and run
# migrations without password. Nothing else.
compliancekit ALL=(root) NOPASSWD: /bin/systemctl restart compliancekit, /bin/systemctl status compliancekit, /usr/local/bin/migrate
EOF
chmod 0440 "$SUDOERS_FILE"
visudo -c -f "$SUDOERS_FILE"

# ----------------------------------------------------------------------------
# 3. SSH hardening
# ----------------------------------------------------------------------------
log "Hardening sshd"
SSHD_DROPIN="/etc/ssh/sshd_config.d/10-compliancekit.conf"
cat > "$SSHD_DROPIN" <<'EOF'
# ComplianceKit hardening overrides
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
PubkeyAuthentication yes
X11Forwarding no
AllowTcpForwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
LoginGraceTime 20
EOF
sshd -t
systemctl reload ssh

# ----------------------------------------------------------------------------
# 4. fail2ban
# ----------------------------------------------------------------------------
log "Configuring fail2ban"
cat > /etc/fail2ban/jail.d/compliancekit.local <<'EOF'
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5

[sshd]
enabled = true

[nginx-http-auth]
enabled = true

[nginx-botsearch]
enabled = true
EOF
systemctl enable --now fail2ban
systemctl restart fail2ban

# ----------------------------------------------------------------------------
# 5. ufw
# ----------------------------------------------------------------------------
log "Configuring ufw (22, 80, 443 only)"
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'ssh'
ufw allow 80/tcp comment 'http (acme + redirect)'
ufw allow 443/tcp comment 'https'
ufw --force enable
ufw status verbose

# ----------------------------------------------------------------------------
# 6. nginx
# ----------------------------------------------------------------------------
log "Installing nginx site config"
NGINX_SITE="/etc/nginx/sites-available/compliancekit"
if [[ -f /opt/compliancekit/deploy/nginx.conf ]]; then
    cp /opt/compliancekit/deploy/nginx.conf "$NGINX_SITE"
else
    # First-run placeholder — deploy.sh will replace with the real file.
    # Leave a minimal HTTP-only stub so certbot can complete the challenge.
    cat > "$NGINX_SITE" <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${API_DOMAIN};
    location /.well-known/acme-challenge/ { root /var/www/html; }
    location / { return 503; }
}
EOF
fi
ln -sf "$NGINX_SITE" /etc/nginx/sites-enabled/compliancekit
# Remove the default site so it can't shadow ours.
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl enable --now nginx
systemctl reload nginx

# ----------------------------------------------------------------------------
# 7. TLS cert via certbot
# ----------------------------------------------------------------------------
log "Requesting TLS certificate for ${API_DOMAIN}"
if [[ ! -d "/etc/letsencrypt/live/${API_DOMAIN}" ]]; then
    certbot --nginx \
        --non-interactive --agree-tos \
        --email "$CERT_EMAIL" \
        -d "$API_DOMAIN" \
        --redirect
else
    echo "Certificate already present — skipping issuance."
fi

# Renewal is handled by the certbot.timer shipped with the package; verify.
systemctl enable --now certbot.timer

# ----------------------------------------------------------------------------
# 8. systemd unit for the Go service
# ----------------------------------------------------------------------------
log "Installing systemd unit"
UNIT_FILE="/etc/systemd/system/compliancekit.service"
if [[ -f /opt/compliancekit/deploy/compliancekit.service ]]; then
    cp /opt/compliancekit/deploy/compliancekit.service "$UNIT_FILE"
else
    echo "WARNING: deploy/compliancekit.service not present yet — placing a stub."
    cat > "$UNIT_FILE" <<'EOF'
[Unit]
Description=ComplianceKit API server (stub)
After=network.target
[Service]
Type=simple
User=compliancekit
WorkingDirectory=/opt/compliancekit
ExecStart=/usr/bin/sleep infinity
Restart=always
[Install]
WantedBy=multi-user.target
EOF
fi
systemctl daemon-reload
systemctl enable compliancekit

# ----------------------------------------------------------------------------
# 9. golang-migrate
# ----------------------------------------------------------------------------
log "Installing golang-migrate CLI"
MIGRATE_VER="v4.17.1"
if [[ ! -x /usr/local/bin/migrate ]] || ! /usr/local/bin/migrate --version 2>&1 | grep -q "$MIGRATE_VER"; then
    TMPDIR_MIG="$(mktemp -d)"
    curl -sSL -o "$TMPDIR_MIG/migrate.tar.gz" \
        "https://github.com/golang-migrate/migrate/releases/download/${MIGRATE_VER}/migrate.linux-amd64.tar.gz"
    tar -xzf "$TMPDIR_MIG/migrate.tar.gz" -C "$TMPDIR_MIG"
    install -m 0755 "$TMPDIR_MIG/migrate" /usr/local/bin/migrate
    rm -rf "$TMPDIR_MIG"
fi
/usr/local/bin/migrate -version

# ----------------------------------------------------------------------------
# 10. /etc/compliancekit/env scaffold
# ----------------------------------------------------------------------------
log "Creating /etc/compliancekit/env scaffold (if not already present)"
ENV_FILE="${ENV_DIR}/env"
if [[ ! -f "$ENV_FILE" ]]; then
    cat > "$ENV_FILE" <<'EOF'
# ComplianceKit runtime environment — FILL IN BEFORE FIRST START.
# Permissions: 0640, owner root:compliancekit.

# --- Core ---
CK_ENV=production
CK_HTTP_ADDR=127.0.0.1:8080
CK_PUBLIC_BASE_URL=https://api.compliancekit.com
CK_FRONTEND_BASE_URL=https://app.compliancekit.com

# --- Database ---
DATABASE_URL=postgres://USER:PASS@HOST:25060/compliancekit?sslmode=require

# --- S3 ---
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
CK_BUCKET=ck-files
CK_BUCKET_BACKUPS=ck-backups

# --- Stripe ---
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=

# --- Twilio ---
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_FROM_NUMBER=

# --- AWS SES ---
SES_FROM_ADDRESS=no-reply@compliancekit.com

# --- AI providers ---
MISTRAL_API_KEY=
GEMINI_API_KEY=

# --- Session / JWT ---
CK_JWT_SIGNING_KEY=
CK_MAGIC_LINK_PEPPER=
EOF
    chown root:"$SERVICE_USER" "$ENV_FILE"
    chmod 0640 "$ENV_FILE"
    echo "WROTE SCAFFOLD: $ENV_FILE — fill in secrets before starting the service."
else
    echo "$ENV_FILE already exists; leaving alone."
fi

log "Bootstrap complete. Next step: run infra/scripts/deploy.sh from your workstation."
