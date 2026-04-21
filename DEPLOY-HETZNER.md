# Deploying ComplianceKit on Hetzner

**Target stack:** single Hetzner Cloud VM (CX22 or CPX21) running the Go backend + nginx, SQLite on local disk, S3-compatible object storage from Hetzner Storage Box or a separate bucket provider, GitHub Pages for the frontend. Monthly cost floor ≈ **€7–15/mo** all-in.

**Why Hetzner.** ~⅓ the price of AWS/DO for comparable VMs, EU-based (good for eventual GDPR story), the fastest disks in the mass-market VPS tier, and they keep egress pricing sane (20 TB/mo included on every plan).

Walk through this doc once end-to-end on a scratch server before you do it on production. The first deploy is the hard one.

---

## 0. What you need before you start

- A credit card (Hetzner bills in EUR; don't be surprised when your US bank charges a foreign-transaction fee — use a Chase Sapphire or similar).
- The domain name you're launching on (`compliancekit.com` here — swap your own everywhere).
- An SSH key on your laptop (`ssh-keygen -t ed25519 -C "you@compliancekit.com"` if you don't have one).
- A GitHub account with push rights to the repo.
- All the API keys from `HUMAN-TO-DO.md` §9–§14 (Stripe, SES, Twilio, Mistral, Gemini, MAGIC_LINK_SIGNING_KEY).

Budget for two hours end-to-end the first time. After that, subsequent deploys are a single GitHub Actions run.

---

## 1. Create the Hetzner project + API token

1. Sign up at [console.hetzner.cloud](https://console.hetzner.cloud). Verify with ID (they're strict about this — 15-minute delay if your passport photo is blurry).
2. Create a new **Project** called `compliancekit-prod`.
3. Inside the project → **Security → API tokens** → Generate a Read & Write token. Save the token somewhere private. **You cannot view it again** — if you lose it, rotate.
4. Add your SSH public key under **Security → SSH keys**. Label it `magnus-laptop` or similar.

---

## 2. Pick a VM size

| Plan | Specs | Price | When to pick it |
|---|---|---|---|
| **CX22** | 2 vCPU ARM (Ampere), 4 GB RAM, 40 GB NVMe SSD | **€4.59/mo** | MVP launch, &lt;100 providers. ARM; Go builds for arm64 without fuss. |
| **CPX21** | 3 vCPU x86 (AMD EPYC), 4 GB RAM, 80 GB NVMe SSD | **€8.46/mo** | If you insist on x86 (reasons: some Go deps ship only amd64 binaries; e.g., some OCR wrappers). |
| **CPX31** | 4 vCPU x86, 8 GB RAM, 160 GB NVMe SSD | **€14.80/mo** | Scale step — move here when CPU idle &lt; 30% sustained or RAM &gt; 70%. |

**Pick CX22** unless you know you need x86. ComplianceKit's backend (pure Go, no cgo except `modernc.org/sqlite` which is pure Go) runs fine on arm64.

Create it:
- **Image:** Ubuntu 24.04
- **Location:** Helsinki (`hel1`), Nuremberg (`nbg1`), or Ashburn VA (`ash`). For US customers pick `ash`; for global / EU pick `hel1` or `nbg1`.
- **SSH key:** the one you just added.
- **Networking:** keep IPv4 + IPv6 both enabled. Public IPv4 costs €0.60/mo extra (still cheaper than DO's "free" IP which bakes into the droplet price).
- **Backups:** enable (+20% surcharge; ~€0.92/mo extra on a CX22 — cheap DR).
- Give it a hostname like `ck-prod-01`.
- Create.

Note the public IPv4 once it boots. You'll use it for DNS + SSH.

---

## 3. Reserve a floating IP (so you can swap VMs without DNS changes)

1. Console → **Floating IPs** → Create.
2. Type IPv4, same location as the VM, assign it to `ck-prod-01`.
3. Cost: €1/mo.

Without this, if the VM ever gets replaced (upgrade, migration), DNS has to propagate again — 10-minute downtime minimum. With it, you reassign the floating IP in 5 seconds.

**Use the floating IP in your DNS A record, not the VM's primary IP.**

---

## 4. First SSH + hardening

```bash
ssh root@<floating-ip>
```

Accept the fingerprint. Inside:

```bash
# Update
apt-get update && apt-get upgrade -y

# Firewall: allow 22, 80, 443 only
apt-get install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Create non-root user for the app
adduser --disabled-password --gecos "" ck
usermod -aG sudo ck
mkdir -p /home/ck/.ssh
cp /root/.ssh/authorized_keys /home/ck/.ssh/
chown -R ck:ck /home/ck/.ssh
chmod 700 /home/ck/.ssh
chmod 600 /home/ck/.ssh/authorized_keys

# Disable root SSH (after you verify you can log in as ck from another terminal)
# sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
# systemctl restart ssh
```

Log out, log back in as `ck` from a fresh terminal. Once that works, run the commented-out lines above as root to disable root SSH.

Fail2ban (optional but cheap paranoia):
```bash
sudo apt-get install -y fail2ban
```

---

## 5. Install the runtime

```bash
# Install Go (latest stable — check https://go.dev/dl/ for the current version)
GO_VERSION=1.24.2
curl -LO https://go.dev/dl/go${GO_VERSION}.linux-arm64.tar.gz  # use amd64 if you're on CPX21/CPX31
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-arm64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile.d/go.sh
source /etc/profile.d/go.sh
go version  # sanity check

# nginx + certbot
sudo apt-get install -y nginx certbot python3-certbot-nginx

# migrate CLI (for DB migrations; alternatively we ship them via a server startup step)
curl -L https://github.com/golang-migrate/migrate/releases/latest/download/migrate.linux-arm64.tar.gz | tar xvz
sudo mv migrate /usr/local/bin/
```

---

## 6. Provision the app directory

As `ck`:

```bash
sudo mkdir -p /var/lib/compliancekit
sudo chown ck:ck /var/lib/compliancekit
sudo mkdir -p /etc/compliancekit
sudo chmod 750 /etc/compliancekit
```

Database lives at `/var/lib/compliancekit/ck.db`. Env file at `/etc/compliancekit/env` (root-readable only; see step 10).

---

## 7. S3-compatible object storage — two options

ComplianceKit's backend uses `aws-sdk-go-v2/service/s3` with a configurable endpoint. You have three cheap choices; pick one.

### Option A — Hetzner Storage Box + rclone (cheapest, ~€3.81/mo for 1 TB)

Hetzner Storage Box is SFTP/WebDAV/SMB, **not** S3-compatible. You'd need to mount it or run rclone as a daemon that exposes an S3 façade. **Recommend against** for production — the integration story is thin.

### Option B — Hetzner Object Storage (currently closed beta in 2026; check console)

When generally available this will be the cleanest fit: native S3 API, EU region, Hetzner billing.

### Option C — Backblaze B2 (recommended today, ~$5/TB stored, $10/TB egress)

Backblaze B2 is fully S3-compatible. Set endpoint = `https://s3.us-west-004.backblazeb2.com` (or pick your region).

**Do:**
1. Sign up at [backblaze.com/b2](https://www.backblaze.com/b2/cloud-storage.html). Verify email.
2. Create two buckets: `ck-files` (private), `ck-backups` (private). Enable versioning on `ck-files`.
3. Create an **Application Key** restricted to both buckets, with `listBuckets + listFiles + readFiles + writeFiles + deleteFiles`. Save the `keyID` + `applicationKey`.
4. In your backend env (step 10), set:
   - `AWS_REGION=us-west-004`
   - `AWS_ACCESS_KEY_ID=<keyID>`
   - `AWS_SECRET_ACCESS_KEY=<applicationKey>`
   - `AWS_ENDPOINT_URL=https://s3.us-west-004.backblazeb2.com`
   - `S3_BUCKET_DOCUMENTS=ck-files`
   - `S3_BUCKET_SIGNED_PDFS=ck-files`
   - `S3_BUCKET_AUDIT_TRAIL=ck-files`
   - `S3_BUCKET_RAW_UPLOADS=ck-files`

The backend's `storage/s3.go` already honors `AWS_ENDPOINT_URL` when it's set — Backblaze works without code changes.

### Option D — AWS S3 us-east-1 (if you're already there)

Keep all the AWS S3 instructions from the earlier DO-flavored runbook. Slightly more expensive per-GB than B2; DNS/IAM familiarity is worth something.

**Pick Option C for new deployments.** It's cheaper than AWS by 3–4x at our storage scale.

---

## 8. Email + SMS + LLM API keys

Unchanged from `HUMAN-TO-DO.md`:

- **AWS SES** for email (§10 in HUMAN-TO-DO.md) — Hetzner has no equivalent, SES is the right choice.
- **Twilio** for SMS (§11).
- **Mistral** + **Gemini** for OCR (§12–§13).
- **Stripe** for billing (§9).

These all live in env vars on the server.

---

## 9. DNS

Point DNS at the Hetzner floating IP:
- `A` `api.compliancekit.com` → `<floating-ip>`
- `AAAA` `api.compliancekit.com` → `<IPv6-address>` (optional; Hetzner gives you one for free)
- `A` `compliancekit.com` → GitHub Pages IPs (`185.199.108–111.153`).
- `CNAME` `www.compliancekit.com` → `compliancekit.com.`

Wait 10 minutes, then `dig api.compliancekit.com` should resolve to your floating IP.

---

## 10. Write the production env file

As root on the server:

```bash
sudo tee /etc/compliancekit/env > /dev/null <<'EOF'
APP_ENV=production
PORT=8080
DATABASE_URL=/var/lib/compliancekit/ck.db

FRONTEND_BASE_URL=https://compliancekit.com
APP_BASE_URL=https://api.compliancekit.com
SESSION_COOKIE_DOMAIN=.compliancekit.com

MAGIC_LINK_SIGNING_KEY=<openssl rand -hex 32>

# Object storage (Backblaze B2 S3-compatible)
AWS_REGION=us-west-004
AWS_ACCESS_KEY_ID=<B2 keyID>
AWS_SECRET_ACCESS_KEY=<B2 applicationKey>
AWS_ENDPOINT_URL=https://s3.us-west-004.backblazeb2.com
S3_BUCKET_DOCUMENTS=ck-files
S3_BUCKET_SIGNED_PDFS=ck-files
S3_BUCKET_AUDIT_TRAIL=ck-files
S3_BUCKET_RAW_UPLOADS=ck-files

# Email (AWS SES)
SES_FROM_EMAIL=no-reply@compliancekit.com

# SMS (Twilio)
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_FROM_NUMBER=

# LLM / OCR
MISTRAL_API_KEY=
GEMINI_API_KEY=

# Billing
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_PRICE_PRO=
EOF

sudo chmod 600 /etc/compliancekit/env
sudo chown root:root /etc/compliancekit/env
```

Fill in every blank value from your saved credentials.

---

## 11. systemd service

```bash
sudo tee /etc/systemd/system/compliancekit.service > /dev/null <<'EOF'
[Unit]
Description=ComplianceKit backend
After=network.target

[Service]
Type=simple
User=ck
Group=ck
WorkingDirectory=/var/lib/compliancekit
ExecStart=/usr/local/bin/compliancekit-server
Restart=on-failure
RestartSec=5
EnvironmentFile=/etc/compliancekit/env
# Hardening
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/compliancekit
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable compliancekit
```

Binary location: `/usr/local/bin/compliancekit-server`. We haven't put it there yet — that happens in step 13.

---

## 12. nginx reverse proxy + TLS

```bash
sudo tee /etc/nginx/sites-available/compliancekit > /dev/null <<'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name api.compliancekit.com;
    location /.well-known/acme-challenge/ { root /var/www/html; }
    location / { return 301 https://$host$request_uri; }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name api.compliancekit.com;

    # TLS certs filled in by certbot below
    ssl_certificate     /etc/letsencrypt/live/api.compliancekit.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.compliancekit.com/privkey.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;

    # Sane defaults
    client_max_body_size 30M;  # document uploads
    proxy_read_timeout   120s;
    proxy_connect_timeout 5s;

    # Stripe webhooks need the raw body — don't buffer
    location /webhooks/stripe {
        proxy_pass http://127.0.0.1:8080;
        proxy_request_buffering off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/compliancekit /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t

# Get the cert (port 80 must be open + DNS must resolve)
sudo certbot --nginx -d api.compliancekit.com --email you@compliancekit.com --agree-tos --redirect --no-eff-email

sudo systemctl reload nginx
```

`certbot` auto-renews via a systemd timer; no further cron work needed.

---

## 13. First deploy (from your laptop)

From the repo root:

```bash
# Cross-compile for the server's arch. If your VM is CX22 (arm64):
cd backend
GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -trimpath -ldflags='-s -w' -o compliancekit-server ./cmd/server
# (For CPX21/CPX31 use GOARCH=amd64)

# Apply migrations remotely
scp -r migrations ck@<floating-ip>:/tmp/
ssh ck@<floating-ip> 'migrate -path /tmp/migrations -database "sqlite:///var/lib/compliancekit/ck.db" up'

# Ship the binary
scp compliancekit-server ck@<floating-ip>:/tmp/
ssh ck@<floating-ip> 'sudo mv /tmp/compliancekit-server /usr/local/bin/ && sudo chmod 755 /usr/local/bin/compliancekit-server'

# Start
ssh ck@<floating-ip> 'sudo systemctl start compliancekit && sleep 2 && sudo systemctl status compliancekit --no-pager'

# Verify
curl -sf https://api.compliancekit.com/healthz
# expected: {"status":"ok"}
```

If `systemctl status` is green and `/healthz` returns 200, you're live.

---

## 14. Frontend to GitHub Pages

Unchanged from the DO runbook:
- GitHub repo → **Settings → Pages** → Source = "GitHub Actions".
- `.github/workflows/frontend-pages.yml` (already in the repo) builds the Vite app and deploys to the `github-pages` environment on every push to `main`.
- Wait ~2 min. `https://compliancekit.com` should render the landing page.

---

## 15. Backups

```bash
sudo tee /etc/cron.daily/compliancekit-backup > /dev/null <<'EOF'
#!/bin/bash
set -euo pipefail
source /etc/compliancekit/env
TS=$(date -u +%Y%m%dT%H%M%SZ)
sqlite3 /var/lib/compliancekit/ck.db ".backup /tmp/ck-${TS}.db"
aws --endpoint-url "$AWS_ENDPOINT_URL" s3 cp /tmp/ck-${TS}.db "s3://${S3_BUCKET_DOCUMENTS%ck-files}ck-backups/ck-${TS}.db" \
    --no-progress
rm /tmp/ck-${TS}.db
EOF
sudo chmod +x /etc/cron.daily/compliancekit-backup
```

First backup fires tomorrow night. Test a manual run right now:
```bash
sudo /etc/cron.daily/compliancekit-backup
```

Set a B2 Lifecycle Rule on `ck-backups` to delete objects older than 30 days.

Restore drill (practice this once before you need it):
```bash
aws --endpoint-url https://s3.us-west-004.backblazeb2.com s3 cp s3://ck-backups/ck-YYYYMMDD.db /tmp/restore.db
sqlite3 /tmp/restore.db ".tables"
```

---

## 16. Monitoring

- UptimeRobot free tier: monitor `https://api.compliancekit.com/healthz` + `https://compliancekit.com/` every 5 min. SMS you if down.
- Better Stack / Logtail free tier: forward journald logs there for searchable history. Cron job:
  ```bash
  sudo apt-get install -y vector  # or fluentbit
  # configure vector to tail journald and push to Better Stack HTTP endpoint
  ```
- Hetzner's own console shows per-VM CPU/disk/network graphs; set email alerts on CPU &gt; 80% for 10 min.

---

## 17. CI/CD — make future deploys one-click

Replace step 13's manual deploy with a GitHub Actions workflow. The repo ships one at `.github/workflows/backend-deploy.yml`. It does:
- `go build` for linux/arm64 (or amd64).
- `scp` the binary + migrations to the server.
- Runs `migrate up`.
- `sudo systemctl restart compliancekit`.
- `curl /healthz` with retry.

You need to add these repo secrets:
- `PRODUCTION_HOST=api.compliancekit.com`
- `PRODUCTION_SSH_USER=ck`
- `PRODUCTION_SSH_KEY=<contents of a fresh `id_ed25519` that you added to /home/ck/.ssh/authorized_keys on the server>`
- `PRODUCTION_TARGET_ARCH=arm64` (or `amd64`)

Add required reviewers on the `production` environment (Settings → Environments) so a random PR can't ship to prod.

---

## 18. What it costs

All-in monthly recurring at launch:

| Line | €/mo | $/mo (approx) |
|---|---|---|
| Hetzner CX22 | 4.59 | 5.10 |
| Floating IPv4 | 1.00 | 1.10 |
| Automated backups (20%) | 0.92 | 1.00 |
| Backblaze B2 (first 10 GB free, then $0.005/GB) | 0–4 | 0–5 |
| AWS SES (10k emails/mo free) | 0 | 0 |
| Twilio SMS ($1/mo + usage) | — | 1–5 |
| Domain (annual ÷ 12) | — | 1 |
| UptimeRobot | 0 | 0 |
| **Total at launch** | **~7** | **~9–15** |

Scale up at 500 providers: move to CPX31 (€14.80) + B2 hits ~$15/mo for 3 TB = ~$30/mo total.

---

## 19. Things that WILL bite you

- **ARM vs x86 mismatch.** If your VM is CX22 (arm64) and you `go build` locally on an Intel Mac without `GOARCH=arm64`, `systemctl start` fails with "cannot execute binary file". Always cross-compile.
- **SES sandbox.** New SES accounts can only send to verified addresses. Request production access (15-min form, ~24h turnaround) before launch day.
- **Twilio 10DLC.** You cannot send marketing SMS to US numbers without 10DLC registration. Start this the same day you sign up for Twilio — it takes 1–2 weeks.
- **SQLite on an NVMe VM is fast but single-writer.** Chase worker + request writes share the same DB file. If you hit `SQLITE_BUSY` spam in logs, bump `busy_timeout` in `db/db.go` (currently 5s). At 1000+ providers you outgrow single-VM SQLite; that's a day-365 problem, not day-1.
- **Backblaze B2 upload speed from EU VM is ~20 MB/s.** Fine for document uploads. If you ever move to a US-East VM, pick B2 us-east-005 region to match.
- **Certbot renews from port 80.** Keep it open or renewals silently fail until the cert expires.
- **Stripe webhook signature verification fails if nginx buffers the body.** The nginx block in §12 disables buffering for `/webhooks/stripe` specifically — don't touch that.
- **Hetzner will suspend your VM if you run Tor exits, open SMTP relays, or get abuse reports.** Don't do those. (Read their AUP.)

---

## 20. When to upgrade

| Signal | Action |
|---|---|
| CPU idle &lt; 30% sustained for a week | Upgrade to CPX31 (2 min downtime — Hetzner rescales in place). |
| Disk > 60% full | Upgrade plan (more SSD) or archive old S3 objects via lifecycle rules. |
| `SQLITE_BUSY` in logs > 5/hr | Move to Postgres (ADR-003-style, the one we superseded). 1 week of work. |
| Single-region latency complaints | Put Cloudflare in front of nginx and cache `/healthz` + the marketing pages globally. |

---

## 21. Rollback

If a bad deploy breaks things:

```bash
# Instant rollback: revert to the previous binary
ssh ck@<floating-ip>
ls -la /usr/local/bin/compliancekit-server*  # GH Actions keeps last 3
sudo cp /usr/local/bin/compliancekit-server.previous /usr/local/bin/compliancekit-server
sudo systemctl restart compliancekit
curl -sf https://api.compliancekit.com/healthz
```

If the bad deploy ran a migration, roll it back too: `migrate -path migrations -database sqlite://ck.db down 1`.

---

## 22. Where to put this in the product roadmap

This runbook replaces/supersedes any DigitalOcean-specific guidance in `infra/README.md` and `HUMAN-TO-DO.md` §4. When you finish steps 1–13, tick them off in `HUMAN-TO-DO.md` Phase 1. The rest (SES, Twilio, Stripe setup) is unchanged — those sections apply identically to a Hetzner deployment.

When we move off MVP (~month 3–6), consider:
- Fly.io or Railway for an easier ops story if you'd rather not babysit Ubuntu.
- Cloudflare in front of nginx for DDoS + caching.
- A second Hetzner VM in a different region with SQLite replication (Litestream) for DR.

Until then, **one VM + one bucket + one Postgres-less backend** is all this product needs.
