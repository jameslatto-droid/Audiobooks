#!/usr/bin/env bash
# scripts/backup.sh — Backup Audiobookshelf config and metadata
# Media files (books/podcasts) are NOT backed up here — they should be
# backed up separately via Duplicati or rsync.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${BACKUP_DIR:-/mnt/fast-data/backups/audiobookshelf}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/abs_backup_${TIMESTAMP}.tar.gz"

cd "$REPO_ROOT"

echo "==> [backup] AquaCenyx Audiobookshelf — ${TIMESTAMP}"

mkdir -p "$BACKUP_DIR"

# Stop container briefly for consistent backup (optional — ABS tolerates hot backup)
# docker compose stop audiobookshelf

tar -czf "$BACKUP_FILE" \
  config/audiobookshelf \
  data/audiobookshelf \
  .env.example \
  docker-compose.yml \
  2>/dev/null

# docker compose start audiobookshelf

echo "==> [backup] Written to: ${BACKUP_FILE}"
echo "==> [backup] Size: $(du -sh "$BACKUP_FILE" | cut -f1)"

# Prune backups older than 30 days
find "$BACKUP_DIR" -name "abs_backup_*.tar.gz" -mtime +30 -delete
echo "==> [backup] Old backups (>30 days) pruned"
