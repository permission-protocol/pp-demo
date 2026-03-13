"""
Shared utilities for PP Signer Gap Engine.
Qwen3-32B client, JSON validation, corpus loading.
"""

import json
import os
import re
import hashlib
import requests
from pathlib import Path
from datetime import datetime, timezone

# Config
OLLAMA_HOST = os.environ.get("OLLAMA_HOST", "http://localhost:11434")
MODEL = os.environ.get("SGE_MODEL", "qwen3:32b")
CORPUS_DIR = Path(__file__).parent.parent / "corpus"
RECORDS_DIR = Path(__file__).parent.parent / "records"
PACKETS_DIR = Path(__file__).parent.parent / "packets"

RECORDS_DIR.mkdir(parents=True, exist_ok=True)
PACKETS_DIR.mkdir(parents=True, exist_ok=True)


def query_model(prompt: str, system: str = "", temperature: float = 0.3, max_tokens: int = 4096) -> str:
    """Send a prompt to Qwen3-32B via Ollama native API."""
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "options": {
            "temperature": temperature,
            "num_predict": max_tokens,
        },
    }
    if system:
        payload["system"] = system

    try:
        resp = requests.post(f"{OLLAMA_HOST}/api/generate", json=payload, timeout=300)
        resp.raise_for_status()
        return resp.json().get("response", "")
    except Exception as e:
        print(f"[ERROR] Model query failed: {e}")
        return ""


def extract_json(text: str):
    """Extract first JSON object or array from model output."""
    # Try to find JSON in code blocks first
    m = re.search(r"```(?:json)?\s*(\{[\s\S]*?\}|\[[\s\S]*?\])\s*```", text)
    if m:
        try:
            return json.loads(m.group(1))
        except json.JSONDecodeError:
            pass

    # Try to find bare JSON
    for pattern in [r"(\{[\s\S]*\})", r"(\[[\s\S]*\])"]:
        m = re.search(pattern, text)
        if m:
            try:
                return json.loads(m.group(1))
            except json.JSONDecodeError:
                continue
    return None


def load_corpus(category: str = None, max_chars: int = 60000) -> str:
    """Load corpus files, optionally filtered by category (subdirectory)."""
    chunks = []
    total = 0
    search_dir = CORPUS_DIR / category if category else CORPUS_DIR

    for f in sorted(search_dir.rglob("*")):
        if f.is_file() and f.suffix in (".md", ".txt", ".html", ".json"):
            content = f.read_text(errors="ignore")
            if total + len(content) > max_chars:
                remaining = max_chars - total
                if remaining > 500:
                    chunks.append(f"=== {f.relative_to(CORPUS_DIR)} ===\n{content[:remaining]}\n")
                break
            chunks.append(f"=== {f.relative_to(CORPUS_DIR)} ===\n{content}\n")
            total += len(content)

    return "\n".join(chunks)


def record_id() -> str:
    """Generate a unique record ID."""
    now = datetime.now(timezone.utc)
    h = hashlib.sha256(f"{now.isoformat()}{os.getpid()}".encode()).hexdigest()[:6]
    return f"sg_{now.strftime('%Y_%m_%d')}_{h}"


def append_record(record: dict):
    """Append a signer gap record to the JSONL ledger."""
    path = RECORDS_DIR / "signer_gaps.jsonl"
    with open(path, "a") as f:
        f.write(json.dumps(record) + "\n")
    print(f"  → Saved: {record.get('record_id', '?')} — {record.get('title', '?')[:60]}")


def load_records(days=7):
    """Load recent records from the JSONL ledger."""
    path = RECORDS_DIR / "signer_gaps.jsonl"
    if not path.exists():
        return []

    records = []
    cutoff = datetime.now(timezone.utc).strftime(f"%Y_%m_")  # rough filter
    for line in path.read_text().strip().split("\n"):
        if not line.strip():
            continue
        try:
            r = json.loads(line)
            records.append(r)
        except json.JSONDecodeError:
            continue
    return records


def dedupe_title(title, existing, threshold=0.7):
    """Simple title-based deduplication. Returns True if duplicate found."""
    title_lower = title.lower().strip()
    for r in existing:
        existing_title = r.get("title", "").lower().strip()
        # Jaccard similarity on word sets
        a = set(title_lower.split())
        b = set(existing_title.split())
        if not a or not b:
            continue
        jaccard = len(a & b) / len(a | b)
        if jaccard > threshold:
            return True
    return False
