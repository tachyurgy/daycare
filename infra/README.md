# ComplianceKit — Ops Runbook

End-to-end infrastructure and day-2 operations guide.

## Component inventory

| Component        | Provider        | Purpose                                  |
|------------------|-----------------|------------------------------------------|
| API server       | DigitalOcean Droplet (Ubuntu 24.04, 2 vCPU / 4 GB) | Go binary behind nginx |
| Database         | DigitalOcean Managed Postgres 16 | App DB + backups   |
| Object storage   | AWS S3 (us-east-1) | 4+1 buckets (documents, signed PDFs, audit trail, raw uploads, backups) |
| Frontend         | GitHub Pages (CNAME `compliancekit.com`) | Vite/React SPA |
| Email            | AWS SES         | Outbound transactional + chase emails    |
| SMS              | Twilio          | Chase SMS, 2FA, parent upload links      |
| Payments         | Stripe          | Subscription billing                     |
| OCR / extraction | Mistral + Gemini | Document field extraction               |
| DNS              | Cloudflare (proxy OFF for api) | A + CNAME records         |

---

## 0. One-time account setup

1. **DigitalOcean** — create team, add SSH key, enable 2FA.
2. **AWS** — create IAM user `ck-deploy` with programmatic access. Attach a
   custom policy limited to the 5 S3 buckets below + SES SendEmail.
3. **Stripe** — create account, enable tax collection, add bank account,
   create products (`starter`, `pro`, `enterprise`) + monthly prices.
4. **Twilio** — purchase A2P 10DLC number, register brand + campaign,
   verify sender ID.
5. **Cloudflare** — add `compliancekit.com`, leave proxy OFF for `api`
   (we terminate TLS on the droplet; Cloudflare's WAF is not needed yet
   and would hide the real client IP from our ESIGN audit log).
6. **GitHub** — create repo, protect `main`, add deploy secrets (see §7).

---

## 1. Create the DigitalOcean droplet

```bash
doctl compute droplet create compliancekit-api \
    --region nyc3 \
    --size s-2vcpu-4gb \
    --image ubuntu-24-04-x64 \
    --ssh-keys "$(doctl compute ssh-key list --format ID --no-header | tr '\n' ',')" \
    --enable-monitoring --enable-backups \
    --wait
```

Grab the public IP:

```bash
doctl compute droplet list --format Name,PublicIPv4
```

### Provision with the bootstrap script

```bash
ADMIN_SSH_KEY="$(cat ~/.ssh/id_ed25519.pub)" \
  ssh root@$DROPLET_IP 'bash -s' < infra/scripts/bootstrap-droplet.sh
```

This installs nginx, certbot, ufw, fail2ban, the `compliancekit` system
user, the `migrate` CLI, the systemd unit, and sketches out
`/etc/compliancekit/env`. **Fill in `/etc/compliancekit/env` with real
secrets before the first deploy.**

---

## 2. Create the managed Postgres

```bash
doctl databases create compliancekit-db \
    --engine pg \
    --version 16 \
    --region nyc3 \
    --size db-s-1vcpu-2gb \
    --num-nodes 1
```

Then:

1. Restrict inbound to the droplet's IP (DO UI → Databases → Trusted sources).
2. Copy the connection URL into `/etc/compliancekit/env` as `DATABASE_URL`
   (append `?sslmode=require`).
3. Turn on **daily backups** in the DO UI — this is our primary backup
   (the `backup-db.sh` S3 copy is defense-in-depth).

---

## 3. Create the S3 buckets

All buckets: **block all public access**, versioning **on**, default
encryption **SSE-S3 (AES256)**, lifecycle rules per bucket policy.

```bash
for b in ck-documents ck-signed-pdfs ck-audit-trail ck-raw-uploads ck-backups; do
    aws s3api create-bucket --bucket "$b" --region us-east-1
    aws s3api put-public-access-block --bucket "$b" \
        --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
    aws s3api put-bucket-versioning --bucket "$b" \
        --versioning-configuration Status=Enabled
    aws s3api put-bucket-encryption --bucket "$b" \
        --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
    aws s3api put-bucket-policy --bucket "$b" \
        --policy "file://infra/s3-bucket-policies/${b}.json"
done
```

Apply the CORS config to `ck-documents` (for browser presigned-PUT):

```bash
aws s3api put-bucket-cors --bucket ck-documents \
    --cors-configuration file://infra/s3-bucket-policies/ck-documents.cors.json
```

Apply lifecycle for `ck-backups` (30-day retention):

```bash
aws s3api put-bucket-lifecycle-configuration --bucket ck-backups \
    --lifecycle-configuration file://infra/s3-bucket-policies/ck-backups.lifecycle.json
```

Apply Object Lock + retention for `ck-audit-trail` (WORM compliance for
ESIGN records — configure **at bucket create time**; the `create-bucket`
line above must be replaced with the two-step flow below for this bucket):

```bash
aws s3api create-bucket --bucket ck-audit-trail --region us-east-1 \
    --object-lock-enabled-for-bucket
aws s3api put-object-lock-configuration --bucket ck-audit-trail \
    --object-lock-configuration '{"ObjectLockEnabled":"Enabled","Rule":{"DefaultRetention":{"Mode":"COMPLIANCE","Years":7}}}'
```

---

## 4. DNS

Cloudflare (or your registrar) records:

| Type  | Name                     | Value                                   | Proxy |
|-------|--------------------------|-----------------------------------------|-------|
| A     | api.compliancekit.com    | *droplet public IPv4*                   | OFF   |
| AAAA  | api.compliancekit.com    | *droplet public IPv6*                   | OFF   |
| CNAME | compliancekit.com        | `<github-user>.github.io.`              | OFF   |
| CNAME | www.compliancekit.com    | compliancekit.com.                      | OFF   |
| CNAME | app.compliancekit.com    | `<github-user>.github.io.`              | OFF   |

Then re-run `certbot` on the droplet if the A record was changed after the
initial bootstrap:

```bash
sudo certbot --nginx --redirect -d api.compliancekit.com
```

---

## 5. SES domain identity

1. AWS console → SES → Create identity → Domain `compliancekit.com`.
2. Add the DKIM CNAMEs to Cloudflare (AWS shows 3 records).
3. Add SPF: TXT `compliancekit.com` → `v=spf1 include:amazonses.com ~all`.
4. Add DMARC: TXT `_dmarc.compliancekit.com` →
   `v=DMARC1; p=quarantine; rua=mailto:dmarc@compliancekit.com; fo=1`.
5. Request production access (removes the sandbox 200-recipient limit).
6. Configure a configuration set `ck-transactional` with event destinations
   for `Bounce` and `Complaint` → SNS → webhook to the API for the
   `notification_suppressions` writeback.

---

## 6. Twilio

1. Purchase a local 10DLC long code.
2. Register A2P: brand = ComplianceKit LLC, campaign = "Low-volume account
   notifications", sample messages = our chase SMS templates.
3. In `/etc/compliancekit/env` set `TWILIO_FROM_NUMBER` to the E.164 form.
4. Configure inbound webhook on that number → `https://api.compliancekit.com/webhooks/twilio/inbound`
   so STOP/HELP keywords flow back into `notification_suppressions`.

---

## 7. GitHub secrets

Set these on the repo (Settings → Secrets → Actions):

| Secret                      | Used by                            |
|-----------------------------|------------------------------------|
| `VITE_API_BASE_URL`         | frontend-deploy.yml                |
| `VITE_BASE_PATH`            | frontend-deploy.yml (empty if CNAME) |
| `DEPLOY_SSH_PRIVATE_KEY`    | backend-deploy.yml (openssh key for `compliancekit@` user) |
| `DEPLOY_SSH_KNOWN_HOSTS`    | backend-deploy.yml (`ssh-keyscan api.compliancekit.com`) |
| `DEPLOY_HOST`               | backend-deploy.yml (`api.compliancekit.com`) |

Create the GitHub Environment `production` and require manual approval from
at least one reviewer — `backend-deploy.yml` gates on this environment.

---

## 8. First deploy

```bash
# From your workstation:
infra/scripts/deploy.sh
```

This will:
1. Build the Go binary statically.
2. rsync it + migrations + deploy configs to `/opt/compliancekit/releases/<ts>/`.
3. Run `migrate up` over SSH.
4. Swap the `current` symlink, restart the service.
5. Poll `/healthz` and roll back if the service doesn't come up green in 60s.

---

## 9. Daily backup cron

On the droplet, after first deploy has placed `backup-db.sh`:

```bash
sudo crontab -e -u compliancekit
# Add:
15 7 * * * /opt/compliancekit/deploy/backup-db.sh >> /var/log/compliancekit/backup.log 2>&1
```

The matching S3 lifecycle rule (`ck-backups`) expires objects after 30 days.

---

## 10. Disaster recovery

### Droplet dies

The state on the droplet is **disposable**. The full recovery sequence:

1. `doctl compute droplet create …` (same command as §1).
2. `ADMIN_SSH_KEY=… ssh root@$NEW_IP 'bash -s' < infra/scripts/bootstrap-droplet.sh`.
3. Copy `/etc/compliancekit/env` from a 1Password vault → the new droplet.
   (NEVER commit this file.)
4. Update the `A` record in Cloudflare to the new IP (TTL is 5 min).
5. `infra/scripts/deploy.sh` from your workstation.

ETA: ~15 minutes start to finish.

### Database dies / corrupt

Primary recovery is **DigitalOcean point-in-time restore** (last 7 days).
If that window has been blown past, restore from the S3 nightly dump:

```bash
# On the droplet:
aws s3 cp s3://ck-backups/postgres/2026/04/15/071500_compliancekit-api.dump /tmp/restore.dump
pg_restore --clean --if-exists --no-owner --dbname "$DATABASE_URL" /tmp/restore.dump
```

Expect up to 24 hours of data loss in that scenario (nightly cadence).

### S3 bucket compromise

`ck-audit-trail` is Object-Lock-locked in COMPLIANCE mode for 7 years — it
cannot be tampered with even by the root account. Everything else has
versioning on; a malicious delete can be un-done by restoring prior
versions. Rotate the `ck-deploy` IAM access keys and audit CloudTrail
immediately.

### Secret leak

1. Rotate the affected secret at the source (Stripe → roll key, Twilio →
   roll auth token, AWS → deactivate+rotate IAM key).
2. Update `/etc/compliancekit/env` on the droplet.
3. `sudo systemctl restart compliancekit`.
4. File a rotation record in the security log (`docs/security-log.md`).

---

## 11. Monitoring & alerting (to add later)

- **UptimeRobot** free plan → pings `/healthz` every 5 min, pages on 2
  consecutive failures.
- **DO Monitoring** → CPU + disk alerts on the droplet.
- **Stripe Sigma** → dashboard for MRR/churn (not in scope for MVP).
- **Sentry** → enable in the Go backend once we have paying customers; send
  DSN in via env.

---

## 12. Common operations

```bash
# Tail API logs
ssh compliancekit@api.compliancekit.com 'sudo journalctl -u compliancekit -f'

# Connect to prod Postgres
ssh compliancekit@api.compliancekit.com
source /etc/compliancekit/env
psql "$DATABASE_URL"

# Roll back to the previous release immediately
ssh compliancekit@api.compliancekit.com bash -c '
  ln -sfn "$(readlink /opt/compliancekit/previous)" /opt/compliancekit/current
  ln -sfn /opt/compliancekit/current/bin/compliancekit /opt/compliancekit/bin/compliancekit
  sudo systemctl restart compliancekit
'

# Force-renew TLS (certbot does this automatically, but if needed)
ssh compliancekit@api.compliancekit.com 'sudo certbot renew --force-renewal'
```
