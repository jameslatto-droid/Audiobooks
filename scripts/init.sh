#!/usr/bin/env bash
# scripts/init.sh — First-time setup for AquaCenyx Audiobook Server
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$REPO_ROOT"

echo "==> [init] AquaCenyx Audiobookshelf — initial setup"

# ── 1. Create .env from example if missing ──────────────────────────────────
if [ ! -f .env ]; then
  cp .env.example .env
  echo "==> [init] Created .env from .env.example"
  echo "    *** Edit .env and set your DOMAIN before starting the service ***"
else
  echo "==> [init] .env already exists — skipping"
fi

# ── 2. Ensure required directories exist ────────────────────────────────────
mkdir -p config/audiobookshelf data/audiobookshelf
mkdir -p media/audiobooks media/podcasts media/uploads
mkdir -p custom/search-free-resources
echo "==> [init] Directories verified"

# ── 3. Check Docker is available ────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
  echo "ERROR: docker not found. Install Docker first." >&2
  exit 1
fi
docker compose version &>/dev/null || { echo "ERROR: docker compose plugin not found." >&2; exit 1; }
echo "==> [init] Docker OK"

# ── 4. Check proxy network exists ───────────────────────────────────────────
if ! docker network inspect proxy &>/dev/null; then
  echo "WARNING: Docker network 'proxy' not found."
  echo "         Create it with: docker network create proxy"
  echo "         Or connect this compose to your existing Traefik network."
fi

echo ""
echo "==> [init] Setup complete. Next steps:"
echo "    1. Edit .env and set DOMAIN=audiobooks.aquacenyx.nl"
echo "    2. Run: docker compose up -d"
echo "    3. Check: docker logs aquacenyx-audiobookshelf --tail 50"
echo "    4. Visit: https://\$(grep DOMAIN .env | cut -d= -f2)"
