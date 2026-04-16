#!/usr/bin/env bash
#
# backup-db.sh — nightly logical backup of the managed Postgres to S3.
#
# Runs on the droplet out of cron:
#     15 7 * * *  /opt/compliancekit/deploy/backup-db.sh   # 07:15 UTC = 02:15 CT
#
# Steps:
#   1. pg_dump (custom format, compressed) into a tmpfile on the droplet.
#   2. Stream-upload to s3://ck-backups/postgres/YYYY/MM/DD/HHMMSS.dump
#   3. Smoke-test the local file with `pg_restore --list` before deletion.
#   4. Emit a size/duration heartbeat line to syslog for alerting.
#
# S3 retention (30 days) is enforced by the bucket's lifecycle rule rather
# than this script — see infra/s3-bucket-policies/ck-backups.json and
# infra/README.md for the lifecycle configuration.
#
# Env reads `/etc/compliancekit/env` to get DATABASE_URL and
# CK_BUCKET_BACKUPS + AWS credentials.

set -euo pipefail

ENV_FILE="/etc/compliancekit/env"
[[ -r "$ENV_FILE" ]] || { echo "missing $ENV_FILE" >&2; exit 1; }
# shellcheck disable=SC1090
set -a; source "$ENV_FILE"; set +a

: "${DATABASE_URL:?DATABASE_URL not set in env}"
: "${CK_BUCKET_BACKUPS:?CK_BUCKET_BACKUPS not set in env}"
: "${AWS_REGION:?AWS_REGION not set in env}"
: "${AWS_ACCESS_KEY_ID:?AWS_ACCESS_KEY_ID not set}"
: "${AWS_SECRET_ACCESS_KEY:?AWS_SECRET_ACCESS_KEY not set}"

STAMP="$(date -u +%Y/%m/%d/%H%M%S)"
HOSTNAME_SHORT="$(hostname -s)"
TMPFILE="$(mktemp /tmp/ck-pgdump.XXXXXX.dump)"
trap 'rm -f "$TMPFILE"' EXIT

log() { logger -t ck-backup -- "$*"; printf "%s\n" "$*"; }

start=$(date +%s)

# ---------------------------------------------------------------------------
# 1. pg_dump — custom format (-Fc) gives us compression + pg_restore flexibility.
# ---------------------------------------------------------------------------
log "starting pg_dump"
pg_dump --format=custom --no-owner --no-privileges --compress=9 \
    --file="$TMPFILE" \
    "$DATABASE_URL"

size_bytes=$(stat -c%s "$TMPFILE")
log "pg_dump complete (${size_bytes} bytes)"

# ---------------------------------------------------------------------------
# 2. Integrity probe — if pg_restore can't list the TOC the dump is corrupt.
# ---------------------------------------------------------------------------
if ! pg_restore --list "$TMPFILE" > /dev/null; then
    log "FATAL: pg_restore --list failed on dump; aborting upload"
    exit 2
fi
log "pg_restore --list OK"

# ---------------------------------------------------------------------------
# 3. Upload to S3 (server-side encryption; storage class = STANDARD_IA via
#    lifecycle rule after 1 day — see bucket policy).
# ---------------------------------------------------------------------------
S3_KEY="postgres/${STAMP}_${HOSTNAME_SHORT}.dump"
log "uploading to s3://${CK_BUCKET_BACKUPS}/${S3_KEY}"

aws s3 cp "$TMPFILE" "s3://${CK_BUCKET_BACKUPS}/${S3_KEY}" \
    --region "$AWS_REGION" \
    --only-show-errors \
    --sse AES256

# ---------------------------------------------------------------------------
# 4. Heartbeat.
# ---------------------------------------------------------------------------
elapsed=$(( $(date +%s) - start ))
log "backup OK size=${size_bytes}B duration=${elapsed}s key=${S3_KEY}"
