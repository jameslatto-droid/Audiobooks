#!/usr/bin/env bash
# scripts/git-sync-check.sh — Pre-commit safety check
# Ensures no secrets, media, config DBs, or large files are staged.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

FAIL=0

echo "==> [git-sync-check] Running pre-push safety checks"

# ── 1. .env must not be staged ───────────────────────────────────────────────
if git diff --cached --name-only | grep -q "^\.env$"; then
  echo "FAIL: .env is staged! Remove with: git reset HEAD .env" >&2
  FAIL=1
fi

# ── 2. media/ must not be staged ─────────────────────────────────────────────
if git diff --cached --name-only | grep -qE "^media/[^.]+"; then
  echo "FAIL: Files under media/ are staged. Add media/ to .gitignore." >&2
  git diff --cached --name-only | grep "^media/" >&2
  FAIL=1
fi

# ── 3. config DBs must not be staged ─────────────────────────────────────────
if git diff --cached --name-only | grep -qE "\.(db|sqlite|sqlite3)$"; then
  echo "FAIL: Database files are staged. These must never be committed." >&2
  git diff --cached --name-only | grep -E "\.(db|sqlite|sqlite3)$" >&2
  FAIL=1
fi

# ── 4. Large files (>10MB) check ─────────────────────────────────────────────
while IFS= read -r file; do
  if [ -f "$file" ]; then
    SIZE=$(stat -c%s "$file" 2>/dev/null || echo 0)
    if [ "$SIZE" -gt 10485760 ]; then
      echo "FAIL: Large file staged ($(( SIZE / 1024 / 1024 ))MB): ${file}" >&2
      FAIL=1
    fi
  fi
done < <(git diff --cached --name-only)

# ── Result ────────────────────────────────────────────────────────────────────
if [ "$FAIL" -eq 0 ]; then
  echo "==> [git-sync-check] All checks passed. Safe to commit."
  git status --short
else
  echo "==> [git-sync-check] FAILED — fix the above issues before committing." >&2
  exit 1
fi
