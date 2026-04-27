#!/usr/bin/env bash
# scripts/healthcheck.sh — Check Audiobookshelf container health
set -euo pipefail

CONTAINER="aquacenyx-audiobookshelf"
PORT="${AUDIOBOOKSHELF_PORT:-13378}"

echo "==> [healthcheck] Audiobookshelf"

# Container running?
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "FAIL: Container '${CONTAINER}' is not running."
  docker ps --filter "name=${CONTAINER}" --format "Status: {{.Status}}" 2>/dev/null || true
  exit 1
fi
echo "  Container : RUNNING"

# HTTP reachable locally?
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://127.0.0.1:${PORT}/" 2>/dev/null || echo "000")
if [[ "$HTTP_STATUS" == "200" || "$HTTP_STATUS" == "302" || "$HTTP_STATUS" == "301" ]]; then
  echo "  HTTP      : OK (${HTTP_STATUS})"
else
  echo "  HTTP      : WARN — status ${HTTP_STATUS} (container may still be starting)"
fi

# Volume mounts present?
for vol in config/audiobookshelf data/audiobookshelf media/audiobooks media/podcasts media/uploads; do
  if [ -d "$vol" ]; then
    echo "  Volume    : OK — ${vol}"
  else
    echo "  Volume    : MISSING — ${vol}"
  fi
done

echo "==> [healthcheck] Done"
