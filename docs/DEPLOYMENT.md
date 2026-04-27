# Deployment Guide — AquaCenyx Audiobookshelf

## Prerequisites

- Docker + Docker Compose v2
- Traefik running on the `proxy` network (already present on this server)
- DNS record: `audiobooks.aquacenyx.nl` → server IP
- Port 443 open on firewall (handled by Traefik)

## First-time setup

```bash
cd /mnt/fast-data/dev/nef/Audiobooks

# 1. Run init script
./scripts/init.sh

# 2. Edit .env
nano .env
# Set DOMAIN=audiobooks.aquacenyx.nl and TZ=Europe/Amsterdam

# 3. Start service
docker compose up -d

# 4. Verify
docker ps | grep audiobookshelf
docker logs aquacenyx-audiobookshelf --tail 50
curl -I http://127.0.0.1:13378/
```

## External access

Traffic flows: `Internet → Traefik (443) → chain-secure@file (Authelia + CrowdSec) → Audiobookshelf (127.0.0.1:13378)`

- HTTPS: automatic via Let's Encrypt (`certresolver=letsencrypt`)
- Auth: Authelia MFA via `chain-secure@file` middleware
- Port 13378 is **only** bound to `127.0.0.1` — not reachable from internet directly

## Update

```bash
docker compose pull
docker compose up -d
```

## Remove / clean up

```bash
docker compose down
# To also remove volumes (destructive):
docker compose down -v
```
