#!/usr/bin/env python3
"""
PP Signer Gap Engine — Corpus Ingest
Chunks corpus files and creates a manifest.

Usage:
  python3 ingest.py              # ingest all corpus files
  python3 ingest.py --stats      # show corpus stats only
"""

import argparse
import json
from pathlib import Path
from datetime import datetime, timezone
from utils import CORPUS_DIR

MANIFEST_PATH = CORPUS_DIR / "manifest.json"


def ingest_stats():
    """Show corpus statistics."""
    stats = {"categories": {}, "total_files": 0, "total_chars": 0}

    for category_dir in sorted(CORPUS_DIR.iterdir()):
        if not category_dir.is_dir():
            continue
        cat_name = category_dir.name
        files = list(category_dir.rglob("*"))
        files = [f for f in files if f.is_file() and f.suffix in (".md", ".txt", ".html", ".json")]
        total_chars = sum(f.read_text(errors="ignore").__len__() for f in files)

        stats["categories"][cat_name] = {
            "files": len(files),
            "chars": total_chars,
            "file_list": [str(f.relative_to(CORPUS_DIR)) for f in files],
        }
        stats["total_files"] += len(files)
        stats["total_chars"] += total_chars

    return stats


def write_manifest(stats: dict):
    """Write corpus manifest."""
    manifest = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        **stats,
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, indent=2))
    print(f"Manifest written to {MANIFEST_PATH}")


def main():
    parser = argparse.ArgumentParser(description="PP Signer Gap Engine — Corpus Ingest")
    parser.add_argument("--stats", action="store_true", help="Show stats only")
    args = parser.parse_args()

    stats = ingest_stats()

    print(f"\n=== PP CORPUS STATS ===")
    print(f"Total files: {stats['total_files']}")
    print(f"Total chars: {stats['total_chars']:,}")
    print()
    for cat, info in stats["categories"].items():
        print(f"  {cat}/: {info['files']} files, {info['chars']:,} chars")
        for f in info["file_list"]:
            print(f"    - {f}")
    print()

    if not args.stats:
        write_manifest(stats)
        print("[OK] Corpus ingested. Ready for pipeline.")


if __name__ == "__main__":
    main()
