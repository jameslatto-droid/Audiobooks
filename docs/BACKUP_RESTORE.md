# Backup & Restore — AquaCenyx Audiobookshelf

## What is backed up

| Path | Contents | In backup? |
|------|----------|------------|
| `config/audiobookshelf/` | App config, user DB, settings | Yes |
| `data/audiobookshelf/` | Metadata, covers, progress | Yes |
| `media/` | Your actual audiobook files | No — back up separately |

Media files should be backed up via Duplicati (already running on this server) or rsync.

## Manual backup

```bash
cd /mnt/fast-data/dev/nef/Audiobooks
./scripts/backup.sh
```

Backup is written to `/mnt/fast-data/backups/audiobookshelf/` by default.  
Override path: `BACKUP_DIR=/other/path ./scripts/backup.sh`

## Scheduled backup (cron)

```bash
crontab -e
# Add:
0 3 * * * /mnt/fast-data/dev/nef/Audiobooks/scripts/backup.sh >> /var/log/abs-backup.log 2>&1
```

## Restore

```bash
cd /mnt/fast-data/dev/nef/Audiobooks
./scripts/restore.sh /mnt/fast-data/backups/audiobookshelf/abs_backup_20260427_030000.tar.gz
```

The service will be stopped, data extracted, then restarted automatically.

## Verify backup integrity

```bash
tar -tzf /path/to/abs_backup_YYYYMMDD_HHMMSS.tar.gz | head -20
```
