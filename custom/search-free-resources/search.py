#!/usr/bin/env python3
"""
AquaCenyx Free Audiobook Search Tool
=====================================
Searches public-domain / CC-licensed audiobook sources.
Legal sources only. No auto-download.

Sources:
  - LibriVox API
  - Internet Archive advanced search

Usage:
  python3 search.py "Sherlock Holmes"
  python3 search.py "Jane Austen" --source librivox
  python3 search.py "Dickens" --source archive --limit 5
  python3 search.py "Poe" --save

Results are printed as JSON and optionally saved to results/.
"""

import sys
import json
import argparse
import urllib.request
import urllib.parse
import os
from datetime import datetime

RESULTS_DIR = os.path.join(os.path.dirname(__file__), "results")


# ─────────────────────────────────────────────────────────────────────────────
# Source: LibriVox
# ─────────────────────────────────────────────────────────────────────────────

def search_librivox(query: str, limit: int = 10) -> list[dict]:
    """Search LibriVox public API for audiobooks matching query."""
    params = urllib.parse.urlencode({
        "action": "search",
        "q": query,
        "format": "json",
        "limit": str(limit),
    })
    url = f"https://librivox.org/api/feed/audiobooks?{params}"

    try:
        req = urllib.request.Request(url, headers={"User-Agent": "AquaCenyx-ABS-Search/1.0"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode())
    except Exception as e:
        print(f"[LibriVox] Error: {e}", file=sys.stderr)
        return []

    books = data.get("books") or []
    results = []
    for book in books:
        results.append({
            "title": book.get("title", "").strip(),
            "author": _librivox_author(book),
            "source": "LibriVox",
            "url": book.get("url_librivox", ""),
            "license": "Public domain",
            "year": book.get("copyright_year", ""),
            "language": book.get("language", ""),
            "num_sections": book.get("num_sections", ""),
        })
    return results


def _librivox_author(book: dict) -> str:
    authors = book.get("authors") or []
    if not authors:
        return "Unknown"
    names = [f"{a.get('first_name', '')} {a.get('last_name', '')}".strip() for a in authors]
    return ", ".join(n for n in names if n)


# ─────────────────────────────────────────────────────────────────────────────
# Source: Internet Archive
# ─────────────────────────────────────────────────────────────────────────────

def search_archive(query: str, limit: int = 10) -> list[dict]:
    """Search Internet Archive for public-domain audiobooks."""
    params = urllib.parse.urlencode({
        "q": f"({query}) AND mediatype:audio AND subject:audiobook",
        "fl[]": "identifier,title,creator,licenseurl,year,language",
        "rows": str(limit),
        "page": "1",
        "output": "json",
    })
    url = f"https://archive.org/advancedsearch.php?{params}"

    try:
        req = urllib.request.Request(url, headers={"User-Agent": "AquaCenyx-ABS-Search/1.0"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode())
    except Exception as e:
        print(f"[Archive.org] Error: {e}", file=sys.stderr)
        return []

    docs = data.get("response", {}).get("docs") or []
    results = []
    for doc in docs:
        identifier = doc.get("identifier", "")
        results.append({
            "title": doc.get("title", "").strip(),
            "author": doc.get("creator", "Unknown"),
            "source": "Internet Archive",
            "url": f"https://archive.org/details/{identifier}" if identifier else "",
            "license": doc.get("licenseurl", "Public domain"),
            "year": doc.get("year", ""),
            "language": doc.get("language", ""),
        })
    return results


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Search free/public-domain audiobooks")
    parser.add_argument("query", help="Search term (title, author, or keyword)")
    parser.add_argument(
        "--source",
        choices=["librivox", "archive", "all"],
        default="all",
        help="Source to search (default: all)",
    )
    parser.add_argument("--limit", type=int, default=10, help="Max results per source")
    parser.add_argument("--save", action="store_true", help="Save results to results/ directory")
    args = parser.parse_args()

    results = []

    if args.source in ("librivox", "all"):
        lv = search_librivox(args.query, args.limit)
        print(f"[LibriVox] {len(lv)} result(s)", file=sys.stderr)
        results.extend(lv)

    if args.source in ("archive", "all"):
        ia = search_archive(args.query, args.limit)
        print(f"[Archive.org] {len(ia)} result(s)", file=sys.stderr)
        results.extend(ia)

    print(json.dumps(results, indent=2, ensure_ascii=False))

    if args.save and results:
        os.makedirs(RESULTS_DIR, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        safe_query = urllib.parse.quote_plus(args.query)[:40]
        out_path = os.path.join(RESULTS_DIR, f"search_{safe_query}_{timestamp}.json")
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(results, f, indent=2, ensure_ascii=False)
        print(f"\n[saved] {out_path}", file=sys.stderr)


if __name__ == "__main__":
    main()
