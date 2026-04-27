#!/usr/bin/env bash
# scripts/restore.sh — Restore Audiobookshelf config and metadata from backup
# Usage: ./scripts/restore.sh /path/to/abs_backup_YYYYMMDD_HHMMSS.tar.gz
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

BACKUP_FILE="${1:-}"
if [ -z "$BACKUP_FILE" ]; then
  echo "Usage: $0 <backup-file.tar.gz>" >&2
  exit 1
fi
if [ ! -f "$BACKUP_FILE" ]; then
  echo "ERROR: Backup file not found: ${BACKUP_FILE}" >&2
  exit 1
fi

cd "$REPO_ROOT"

echo "==> [restore] Source: ${BACKUP_FILE}"
echo "==> [restore] WARNING: This will overwrite config/ and data/. Press Ctrl+C to cancel."
sleep 5

# Stop service before restoring
docker compose stop audiobookshelf 2>/dev/null || true

# Extract
tar -xzf "$BACKUP_FILE" -C "$REPO_ROOT"

echo "==> [restore] Extraction complete"
echo "==> [restore] Starting service..."
docker compose up -d audiobookshelf
echo "==> [restore] Done. Check: docker logs aquacenyx-audiobookshelf --tail 50"
