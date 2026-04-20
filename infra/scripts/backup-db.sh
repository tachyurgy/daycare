#!/usr/bin/env bash
#
# backup-db.sh — nightly online backup of the SQLite DB to S3.
#
# Runs on the droplet out of cron:
#     15 7 * * *  /opt/compliancekit/deploy/backup-db.sh   # 07:15 UTC = 02:15 CT
#
# Steps:
#   1. `sqlite3 $DB '.backup /tmp/snap.db'` (online, consistent; readers not blocked).
#   2. gzip the snapshot.
#   3. Integrity probe: `sqlite3 snap.db 'pragma integrity_check;'` must return "ok".
#   4. Upload to s3://ck-backups/sqlite/YYYY/MM/DD/HHMMSS.db.gz
#   5. Emit a size/duration heartbeat line to syslog for alerting.
#
# S3 retention (30 days) is enforced by the bucket's lifecycle rule rather
# than this script — see infra/s3-bucket-policies/ck-backups.json and
# infra/README.md for the lifecycle configuration.
#
# Env reads `/etc/compliancekit/env` to get DATABASE_URL and
# CK_BUCKET_BACKUPS + AWS credentials.
#
# See ADR-017 for why SQLite.

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

# DATABASE_URL may be a bare path or `file:/path?opts`. Strip the scheme + query.
DB_PATH="${DATABASE_URL#file:}"
DB_PATH="${DB_PATH%%\?*}"
[[ -r "$DB_PATH" ]] || { echo "cannot read SQLite DB at $DB_PATH" >&2; exit 1; }

STAMP="$(date -u +%Y/%m/%d/%H%M%S)"
HOSTNAME_SHORT="$(hostname -s)"
SNAPSHOT="$(mktemp /tmp/ck-snap.XXXXXX.db)"
ARCHIVE="${SNAPSHOT}.gz"
trap 'rm -f "$SNAPSHOT" "$ARCHIVE"' EXIT

log() { logger -t ck-backup -- "$*"; printf "%s\n" "$*"; }

start=$(date +%s)

# ---------------------------------------------------------------------------
# 1. Online backup via the sqlite3 CLI. This is safe under WAL — readers and
#    writers keep going against the live DB while the snapshot is copied.
# ---------------------------------------------------------------------------
log "starting sqlite3 .backup from $DB_PATH"
sqlite3 "$DB_PATH" ".backup '$SNAPSHOT'"

# ---------------------------------------------------------------------------
# 2. Integrity probe on the snapshot itself.
# ---------------------------------------------------------------------------
integrity="$(sqlite3 "$SNAPSHOT" 'pragma integrity_check;')"
if [[ "$integrity" != "ok" ]]; then
    log "FATAL: integrity_check returned '$integrity'; aborting upload"
    exit 2
fi
log "integrity_check OK"

# ---------------------------------------------------------------------------
# 3. Compress. gzip -9 is cheap for our DB sizes (GB range even at scale).
# ---------------------------------------------------------------------------
gzip -9 "$SNAPSHOT"
size_bytes=$(stat -c%s "$ARCHIVE")
log "compressed snapshot (${size_bytes} bytes)"

# ---------------------------------------------------------------------------
# 4. Upload to S3 (server-side encryption; storage class = STANDARD_IA via
#    lifecycle rule after 1 day — see bucket policy).
# ---------------------------------------------------------------------------
S3_KEY="sqlite/${STAMP}_${HOSTNAME_SHORT}.db.gz"
log "uploading to s3://${CK_BUCKET_BACKUPS}/${S3_KEY}"

aws s3 cp "$ARCHIVE" "s3://${CK_BUCKET_BACKUPS}/${S3_KEY}" \
    --region "$AWS_REGION" \
    --only-show-errors \
    --sse AES256

# ---------------------------------------------------------------------------
# 5. Heartbeat.
# ---------------------------------------------------------------------------
elapsed=$(( $(date +%s) - start ))
log "backup OK size=${size_bytes}B duration=${elapsed}s key=${S3_KEY}"
