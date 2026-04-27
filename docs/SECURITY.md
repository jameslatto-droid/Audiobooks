# Security Guide — AquaCenyx Audiobookshelf

## Architecture

```
Internet
  │ HTTPS/443
  ▼
Traefik (reverse proxy)
  │  TLS termination (Let's Encrypt)
  ▼
CrowdSec Bouncer (IP reputation / rate limiting)
  │
  ▼
Authelia (MFA / SSO)
  │
  ▼
Audiobookshelf (127.0.0.1:13378 — internal only)
```

## Security controls in place

| Control | Status |
|---------|--------|
| HTTPS enforced | Yes — `websecure` entrypoint only |
| TLS certificate | Let's Encrypt auto-renew |
| Port 13378 public | No — bound to 127.0.0.1 only |
| Auth layer | Authelia MFA via `chain-secure@file` |
| IP reputation | CrowdSec bouncer |
| Secrets in Git | Never — `.env` is gitignored |

## Required actions on first deploy

1. **Set a strong Audiobookshelf admin password** (min 16 chars, unique)
2. Confirm DNS A record for `audiobooks.aquacenyx.nl` points to this server
3. Verify Authelia has a user entry for audiobooks access (if ACL rules are restrictive)
4. Check Traefik dashboard that the `audiobooks` router is green

## External access risks

| Risk | Mitigation |
|------|-----------|
| Brute-force login | Authelia + CrowdSec rate limiting |
| Stale TLS cert | Traefik auto-renews via ACME |
| Container escape | Container runs as non-root (ABS default) |
| Data exfiltration | Authelia auth required for all routes |

## Future hardening options

- Add `middlewares=authelia@docker` directly at service level if Authelia chain changes
- Add IP allowlist middleware for admin-only routes
- Enable Audiobookshelf 2FA within the app itself (extra layer)
- Restrict Authelia to specific users for this subdomain via `access_control` rules
