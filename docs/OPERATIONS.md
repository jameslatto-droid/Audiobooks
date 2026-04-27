# Operations Guide — AquaCenyx Audiobookshelf

## Daily commands

| Action | Command |
|--------|---------|
| Start | `docker compose up -d` |
| Stop | `docker compose stop` |
| Restart | `docker compose restart audiobookshelf` |
| Logs (live) | `docker logs aquacenyx-audiobookshelf -f` |
| Logs (last 100) | `docker logs aquacenyx-audiobookshelf --tail 100` |
| Health check | `./scripts/healthcheck.sh` |
| Backup | `./scripts/backup.sh` |
| Update image | `docker compose pull && docker compose up -d` |

## Adding audiobooks

### Via web UI (recommended for small batches)
1. Open `https://audiobooks.aquacenyx.nl`
2. Admin → Libraries → Upload

### Via SCP (recommended for large imports)
```bash
scp -r "Author/Book/" user@aquacenyx:/mnt/fast-data/dev/nef/Audiobooks/media/audiobooks/Author/
```

### Via direct copy (if on the server)
```bash
cp -r /path/to/books/ /mnt/fast-data/dev/nef/Audiobooks/media/audiobooks/
```

Then in ABS: **Scan Library** to detect new files.

## Folder structure convention
```
media/audiobooks/
  Author Name/
    Series Name/        # optional
      01 - Book Title/
        book.m4b        # or .mp3, .flac, etc.
        cover.jpg       # optional
```

## Monitoring
- Uptime Kuma: add HTTP monitor → `http://127.0.0.1:13378/`
- Container health: `docker ps | grep audiobookshelf`
