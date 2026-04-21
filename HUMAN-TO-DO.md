# HUMAN-TO-DO.md — the master list of things Magnus has to do himself

**Last updated:** 2026-04-20 · **MVP deadline:** 2026-04-23

Everything in this file is blocking launch and *cannot be done by Claude or any automated agent.* It requires your hands on a keyboard, your email, your credit card, or your attorney. Ordered by "do this first or everything else wastes time."

Legend:
- 🔴 **Blocker** — launch is not possible without this.
- 🟡 **Must-do pre-first-customer** — demo-OK without it, but cannot charge a cent.
- 🟢 **Post-launch** — ship without it, do in week 2–4.

---

## 🔴 Phase 0 — Before any code can run in production

### 1. Finalize LLC legal name + address 🔴

Multiple legal docs (`legal/master-subscription-agreement.md`, `legal/data-processing-agreement.md`, `legal/privacy-policy.md`, `legal/terms-of-service.md`) have placeholders: `{{COMPANY_LEGAL_NAME}}`, `{{COMPANY_ADDRESS}}`, `{{EFFECTIVE_DATE}}`.

**Do:**
- Finalize the WA LLC name if not already: search and confirm via Washington Secretary of State → file if needed.
- Pick a business address (your home address or a registered-agent address).
- Decide the "effective date" — today's date works.
- Run a global find-and-replace across `legal/*.md` for each `{{…}}` placeholder.
- Commit.

**Why blocking:** Shipping the product with literal `{{COMPANY_LEGAL_NAME}}` in the privacy policy is a bad look and unenforceable. Every customer will see these strings at signup.

### 2. Attorney review of the legal docs 🔴

`legal/README.md` has a list of `[LAWYER CHECK]` inline flags (~13 of them) across the privacy policy, MSA, DPA, ESIGN disclosure, parent/staff consents. None of us are lawyers.

**Do:**
- Shortlist three local WA startup attorneys ($300–$500/hr). Ask for a flat-fee package review of the 7 core docs (MSA, DPA, Privacy, ToS, ESIGN, Parent Consent, Staff Consent).
- Expect 3–8 hours of attorney time = $1,500–$4,000 all-in.
- Fix the `[LAWYER CHECK]` flags based on their guidance.
- Remove the draft banner at the top of each doc once approved.

**Why blocking:** You are asking child care providers to accept a DPA that covers data about *children*. If any of those contracts is indefensible, one pissed-off parent with a lawyer is a company-ending event.

### 3. Create the GitHub repo + push 🔴

**Do:**
- Create `github.com/tachyurgy/daycare` (public — required for GitHub Pages free tier). *(Already created based on the remote URL — skip if already set up.)*
- `git remote add origin git@github.com:tachyurgy/daycare.git` if not wired.
- Push every branch.

---

## 🔴 Phase 1 — Provision infrastructure (half a day of work)

**⚠ Hosting decision: Hetzner (EU) + Backblaze B2 (object storage).** ~€7–15/mo total vs. $30+/mo on AWS/DO. Full step-by-step runbook in [`DEPLOY-HETZNER.md`](./DEPLOY-HETZNER.md). Phase 1 below is the summary — read the full runbook once end-to-end before you start.

### 4. Hetzner VM 🔴

- Sign up at [console.hetzner.cloud](https://console.hetzner.cloud). Verify with ID (15-min delay).
- Create project `compliancekit-prod`. Generate a Read+Write API token. Add your SSH key.
- Create a VM:
  - **Plan:** CX22 (€4.59/mo, 2 vCPU ARM, 4 GB RAM, 40 GB NVMe). Or CPX21 (€8.46/mo) if you insist on x86.
  - **Image:** Ubuntu 24.04.
  - **Location:** Ashburn VA (`ash`) for US customers, or Helsinki/Nuremberg for EU.
  - **Backups:** enable (+20% surcharge; cheap DR).
- Reserve a **Floating IPv4** (€1/mo) and assign it to the VM. Always use the floating IP in DNS — lets you swap VMs without a DNS change.
- Save the floating IP.

### 5. Harden + install runtime 🔴

Full commands in `DEPLOY-HETZNER.md` §4–§5. Short version:
- SSH in as `root`, `apt-get update`, install ufw, create non-root `ck` user, disable root SSH.
- Install Go 1.24+ (arm64 or amd64 to match your VM), nginx, certbot, golang-migrate CLI.

### 6. Object storage — Backblaze B2 🔴

Hetzner Storage Box is SFTP (no S3 API); Hetzner Object Storage is beta-only in 2026. Use Backblaze B2 — fully S3-compatible, ~$5/TB stored, $10/TB egress. Cheaper than AWS by 3–4× at our scale.

**Do:**
- Sign up at [backblaze.com/b2](https://www.backblaze.com/b2/cloud-storage.html).
- Create two buckets: `ck-files` (private, versioning enabled) and `ck-backups` (private, 30-day lifecycle rule to auto-delete old dumps).
- Create an **Application Key** restricted to both buckets with read+write+delete permissions. Save `keyID` + `applicationKey`.
- Backend env vars (set in step 15):
  - `AWS_REGION=us-west-004` (or the region you picked)
  - `AWS_ACCESS_KEY_ID=<keyID>`
  - `AWS_SECRET_ACCESS_KEY=<applicationKey>`
  - `AWS_ENDPOINT_URL=https://s3.us-west-004.backblazeb2.com`
  - `S3_BUCKET_DOCUMENTS=ck-files` (and the other three S3_BUCKET_* vars)

### 7. DNS 🔴

**Do:**
- Own `compliancekit.com` (or whatever name) via Namecheap / Cloudflare / Porkbun.
- Point `compliancekit.com` at GitHub Pages: `A` records to `185.199.108.153`, `.109.153`, `.110.153`, `.111.153`.
- Point `api.compliancekit.com` at your **Hetzner floating IP** (A record) + IPv6 AAAA record.
- `CNAME` `www.compliancekit.com` → `compliancekit.com.`
- SES DKIM + SPF: AWS gives you CNAME records to add when you verify the sender in §10.

### 8. TLS certificates 🔴

**Do:**
- On the Hetzner VM (after DNS propagates): `sudo certbot --nginx -d api.compliancekit.com --email you@compliancekit.com --agree-tos --redirect --no-eff-email`.
- GitHub Pages auto-provisions TLS for `compliancekit.com` — tick "Enforce HTTPS" in repo settings 5 min after DNS resolves.

---

## 🔴 Phase 2 — External service signups (these are API keys you have to get)

### 9. Stripe 🔴

**Do:**
- Sign up at [stripe.com](https://stripe.com). Use your real business info (LLC name, EIN if you have it, personal info if not).
- In Dashboard → **Products**: create a product "ComplianceKit Pro", $99/mo recurring.
  - Copy the price ID → this is `STRIPE_PRICE_PRO` in env.
- In Dashboard → **Developers → API keys**: grab the live secret key (`sk_live_…`) → `STRIPE_SECRET_KEY`.
- In Dashboard → **Developers → Webhooks**: add an endpoint for `https://api.compliancekit.com/webhooks/stripe`, subscribe to `customer.subscription.created/updated/deleted/trial_will_end` and `invoice.payment_failed`. Copy the webhook secret → `STRIPE_WEBHOOK_SECRET`.
- **Test mode first.** Use `sk_test_…` and `whsec_test_…` until you have a paying customer. Swap to live mode on launch day.

### 10. AWS SES (email) 🔴

**Do:**
- AWS Console → SES → request production access (they start you in sandbox limiting you to verified addresses). The request form takes 15 min. They approve within 24h.
- Verify a sender identity: `no-reply@compliancekit.com`. Add the DKIM CNAME records they give you to your DNS. Wait for verification.
- `SES_FROM_EMAIL = no-reply@compliancekit.com` in env.

### 11. Twilio (SMS) 🟡

**Do:**
- Sign up at [twilio.com](https://twilio.com). Buy a US long-code number (~$1/mo + $0.0075/SMS).
- Programmable Messaging → copy Account SID + Auth Token + the phone number → `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_FROM_NUMBER`.
- **10DLC registration**: required to send SMS to US numbers. Costs ~$4 one-time + $1/mo for the campaign. Takes 1–2 weeks to approve — **start this ASAP.**
- Until 10DLC is approved, SMS to unregistered recipients fails silently. Email works fine without this.

### 12. Mistral OCR 🟡

**Do:**
- Sign up at [console.mistral.ai](https://console.mistral.ai).
- Create an API key → `MISTRAL_API_KEY`.
- Pay-as-you-go pricing; expect <$20/mo at MVP volumes.

### 13. Google Gemini 🟡

**Do:**
- Sign up at [aistudio.google.com](https://aistudio.google.com). Create an API key → `GEMINI_API_KEY`.
- Free tier covers MVP; budget $0.

### 14. MagicLink signing key 🔴

**Do:**
- `openssl rand -hex 32` on your laptop. Save the output.
- `MAGIC_LINK_SIGNING_KEY=<that value>` in env. **Never rotate in production** — token validation breaks for any link already in someone's inbox. If you must rotate, accept a 15-min outage window and notify all parent/staff portal users to request a fresh link.

---

## 🔴 Phase 3 — Deploy

### 15. Write the production env file 🔴

On the droplet, as root:
```bash
sudo mkdir -p /etc/compliancekit
sudo tee /etc/compliancekit/env > /dev/null <<EOF
APP_ENV=production
PORT=8080
DATABASE_URL=/var/lib/compliancekit/ck.db

FRONTEND_BASE_URL=https://compliancekit.com
APP_BASE_URL=https://api.compliancekit.com
SESSION_COOKIE_DOMAIN=.compliancekit.com

MAGIC_LINK_SIGNING_KEY=<from step 14>

AWS_REGION=us-west-2
AWS_ACCESS_KEY_ID=<from step 6>
AWS_SECRET_ACCESS_KEY=<from step 6>
S3_BUCKET_DOCUMENTS=ck-files
S3_BUCKET_SIGNED_PDFS=ck-files
S3_BUCKET_AUDIT_TRAIL=ck-files
S3_BUCKET_RAW_UPLOADS=ck-files

SES_FROM_EMAIL=no-reply@compliancekit.com
TWILIO_ACCOUNT_SID=<from step 11>
TWILIO_AUTH_TOKEN=<from step 11>
TWILIO_FROM_NUMBER=<from step 11>

MISTRAL_API_KEY=<from step 12>
GEMINI_API_KEY=<from step 13>

STRIPE_SECRET_KEY=<from step 9>
STRIPE_WEBHOOK_SECRET=<from step 9>
STRIPE_PRICE_PRO=<from step 9>
EOF

sudo chmod 600 /etc/compliancekit/env
sudo chown root:root /etc/compliancekit/env
```

### 16. Configure the GitHub Actions `production` environment 🔴

**Do:**
- GitHub repo → Settings → Environments → New environment `production`.
- Add required reviewers (yourself).
- Add the SSH private key that can log into the droplet as a secret: `PRODUCTION_DEPLOY_SSH_KEY`.
- Add the droplet hostname: `PRODUCTION_HOST=api.compliancekit.com`.
- Save.

This unlocks the `backend-deploy.yml` workflow.

### 17. First deploy 🔴

**Do:**
- Trigger `backend-deploy.yml` manually from the Actions tab.
- Watch it. It should: build the Go binary, scp it to the droplet, run migrations, restart the systemd service, verify `/healthz`.
- Trigger `frontend-pages.yml` manually.
- Visit `https://compliancekit.com` — marketing pages should render.
- Visit `https://api.compliancekit.com/healthz` — should return `{"status":"ok"}`.

---

## 🟡 Phase 4 — Cannot-charge-yet blockers

### 18. Run the Stripe smoke test in live mode 🟡

**Do:**
- Create a test provider via the production signup. Trigger the Stripe Checkout with a real card — yours.
- Confirm the webhook fires, `subscriptions` row updates to `status=active`.
- Cancel the subscription. Confirm webhook fires, status updates.
- Refund yourself via the Stripe dashboard.

### 19. Enable Stripe fraud rules 🟡

**Do:**
- Stripe Radar → turn on the recommended rules. At minimum: block cards from known-fraud countries unless you're selling there (CA/TX/FL means US only — block everything else).
- Set a max charge of $500 (blocks accidental 100x subscriptions).

### 20. Business bank account + routing to Stripe 🟡

**Do:**
- Open a business checking account (Mercury is fast, free, and startup-friendly). Need LLC docs.
- Add bank info to Stripe → Payouts.
- First payout lands 7–14 days after the first successful charge.

### 21. W-9 / EIN 🟡

**Do:**
- If LLC doesn't have an EIN: apply at [irs.gov/ein](https://irs.gov/ein). Takes 10 minutes, free.
- File W-9 with Stripe (Stripe prompts for this).

---

## 🟡 Phase 5 — Reliability before first customer

### 22. Backups running 🟡

**Do:**
- Verify cron ran `infra/scripts/backup-db.sh` — should see timestamped dumps in `ck-backups` S3 bucket overnight.
- Test a restore: copy a dump down, load it into a fresh SQLite DB, inspect.
- Set a calendar reminder to test this monthly.

### 23. UptimeRobot monitor 🟡

**Do:**
- Sign up at [uptimerobot.com](https://uptimerobot.com) (free tier covers 50 monitors at 5-min cadence).
- Add monitor: `https://api.compliancekit.com/healthz` every 5 min. Alert to your phone on down.
- Add monitor: `https://compliancekit.com/` every 5 min.

### 24. Error alerts 🟡

**Do:**
- Pipe the structured slog JSON to a log collector. Cheapest option: Better Stack (formerly Logtail) — free tier holds 1 GB of logs.
- Add a filter: any `level=error` line sends a Slack message / email.

### 25. Customer support email 🟡

**Do:**
- Create `support@compliancekit.com` in Google Workspace ($6/mo).
- Forward to your personal inbox, auto-reply "thanks, we'll respond within 24h."
- Wire it into the frontend `Contact` footer and legal docs.

---

## 🟡 Phase 6 — First 10 customers (marketing, not product)

### 26. Launch list 🟡

**Do:**
- `state-guides/how-to-pass-*.md` is your SEO moat. Pick 10 providers from `florida_leads.csv`, `california_leads.csv`, `texas_leads.csv`.
- Send each a personalized email offering a free month. Template in `/planning-docs/sales-playbook-*` (if present) or draft fresh.

### 27. Publish the state guides as HTML 🟡

**Do:**
- Convert `state-guides/how-to-pass-*.md` to HTML and push to `/guides/` on GitHub Pages.
- Meta descriptions + schema.org `HowTo` markup for Google rich results.

### 28. Put a real pricing page at /pricing 🟡

**Do:**
- Currently hard-coded to $99/mo in Stripe. Make this visible on the site.
- Add a Starter ($49) and Enterprise ($199/site/mo) tier in Stripe + price-page UI when you have customer signal.

---

## 🟢 Phase 7 — Post-launch cleanup (week 2+)

### 29. Cyber liability insurance 🟢

**Do:**
- Buy $1M cyber liability (Hiscox, Coalition, At-Bay — all under $100/mo at our scale).
- Mention the coverage in sales conversations with risk-averse buyers.

### 30. SOC 2 Type I — skip until $20k MRR 🟢

Not worth the $15–$20k audit cost until you have enterprise buyers asking.

### 31. Hire a part-time regulatory researcher 🟢

**Do:**
- When you cross 50 paying customers, hire a part-time researcher (10–15 hrs/week, $30–50/hr) to keep compliance rule packs current and expand to new states. Post-MVP focus.

### 32. Attorney on retainer 🟢

**Do:**
- After MVP revenue covers $2k/mo, put the same attorney on a $1k/mo retainer for small questions (DMCA, new feature review, churn flow review).

### 33. Tax — state sales tax registration 🟢

**Do:**
- SaaS is taxable in some states. Check Stripe Tax → auto-collects + remits for you. ~$30/mo after a free tier. Turn on before you have revenue in states like Washington, Texas, Connecticut.

---

## Open questions — you have to pick the answer

- **What's the LLC's legal name exactly?** (determines placeholders in §1)
- **Which WA address do we use in legal docs?** (home address shows up in PDPPs; registered agent costs $150/yr to avoid that — worth it for privacy)
- **Does the product launch as `compliancekit.com` or something else?** (determines DNS in §7)
- **Who's your launch customer #1?** (determines the very first support load)
- **What's the annual pricing?** (the $99/mo is monthly; annual at 10x = $990 is a common SaaS discount. Or 12x for no discount but better cashflow.)

---

## What Claude has already done for you (so you don't redo it)

- ✅ All backend code (Go, ~40k LOC, compiles + tests green).
- ✅ Frontend React app (all 17 pages).
- ✅ 22 SQLite tables + 12 migrations.
- ✅ All legal docs as first drafts with `[LAWYER CHECK]` flags.
- ✅ 60 tickets in `tickets/`.
- ✅ 50 state research docs (`all-states/*/compliance.md`).
- ✅ 50 plain-English state guides (`state-guides/how-to-pass-*.md`).
- ✅ Master product vision (`PRODUCT-TURBOTAX.md`).
- ✅ Feature audit + QA guide (`FEATURE-AUDIT.md`, `QA-TESTING-GUIDE.md`).
- ✅ Backend integration tests + frontend Playwright scaffolding.
- ✅ CA / TX / FL compliance rule packs (10 rules × 3 states).
- ✅ CA / TX / FL inspection checklists (33 / 32 / 32 items).
- ✅ CA / TX / FL state-aware ratio tables.
- ✅ Facility & Operations feature (drills, postings, ratio).
- ✅ Inspection Readiness simulator.
- ✅ SEO landing pages (CA / TX / FL × 3 topics).
- ✅ Stripe billing + webhook.
- ✅ OCR chain (Mistral + Gemini).
- ✅ Magic-link passwordless auth.
- ✅ Document chase worker (email + SMS).
- ✅ Self-hosted PDF e-signature (10 Go unit tests).
- ✅ Session cleanup + nightly snapshot + pdfsign wiring (this session).
- ✅ RBAC enforcement + admin audit log viewer (this session — in progress).
- ✅ 90-day purge + data export (this session — in progress).

---

*When you finish an item, delete it from this file or move it to a `DONE-HUMAN.md` log. Keeps the open list short enough to act on.*
