# Customisation Plan — AquaCenyx Audiobookshelf

## Current state (v1)
Boring and reliable. Audiobookshelf running behind Traefik + Authelia on `audiobooks.aquacenyx.nl`.

## Planned enhancements

### Near-term
- [ ] Uptime Kuma monitor for `http://127.0.0.1:13378/`
- [ ] Duplicati job for `media/` folder backup
- [ ] Dashy tile: Audiobooks link + status badge
- [ ] Authelia ACL rule scoped to `audiobooks.aquacenyx.nl`

### Medium-term
- [ ] AquaCenyx dashboard widget (listening stats via ABS API)
- [ ] Automated import script: detect new files → trigger ABS library scan via API
- [ ] Notification (n8n): new audiobook added → push notification

### Long-term
- [ ] AI recommendations: query Spark/Ollama with listening history → suggest books
- [ ] Voice integration: Kokoro TTS narration of summaries/blurbs
- [ ] Mobile: Audiobookshelf native app works out of the box — no extra config needed

## ABS API reference
All management is possible via the REST API:
- Docs: https://api.audiobookshelf.org
- Base: `https://audiobooks.aquacenyx.nl/api/`
- Auth: Bearer token (generate in ABS Settings → API Tokens)
