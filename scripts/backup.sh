#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${BACKUP_DIR:-$ROOT_DIR/backups}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$BACKUP_DIR"

cd "$ROOT_DIR"
set -a
source ./.env
set +a

OUT="$BACKUP_DIR/dawarich-${STAMP}.dump"
docker compose exec -T dawarich_db pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc > "$OUT"
chmod 600 "$OUT"
find "$BACKUP_DIR" -type f -name 'dawarich-*.dump' -mtime +"$RETENTION_DAYS" -delete

echo "Backup written: $OUT"
