# Free Audiobook Search Tool

Searches LibriVox and Internet Archive for public-domain / CC-licensed audiobooks.

**No auto-download. Legal sources only.**

## Requirements

- Python 3.9+ (stdlib only — no extra packages)

## Usage

```bash
cd custom/search-free-resources

# Search all sources
python3 search.py "Sherlock Holmes"

# Search LibriVox only
python3 search.py "Jane Austen" --source librivox

# Search Archive.org only, limit 5 results
python3 search.py "Dickens" --source archive --limit 5

# Search and save results to results/ folder
python3 search.py "Edgar Allan Poe" --save
```

## Output format

```json
[
  {
    "title": "The Adventures of Sherlock Holmes",
    "author": "Arthur Conan Doyle",
    "source": "LibriVox",
    "url": "https://librivox.org/...",
    "license": "Public domain",
    "year": "1892",
    "language": "English"
  }
]
```

## Saved results

Results saved with `--save` are written to `results/` (gitignored).  
Use them as a wishlist or import queue.

## Adding to Audiobookshelf

1. Find a book you want
2. Download it manually from the source URL
3. Place it in `media/audiobooks/Author/Title/`
4. In ABS: **Scan Library**

## Adding more sources

To add a new source (e.g. Project Gutenberg audio), add a function following the pattern of `search_librivox()` or `search_archive()` in `search.py` and register it in `main()`.
