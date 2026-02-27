#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GOAL_DIR="${SCRIPT_DIR}/../goals/xdares-seo-growth"
RECOMMENDATIONS_FILE="${1:-$GOAL_DIR/metrics/recommendations.json}"
STATE_FILE="${2:-$GOAL_DIR/state.json}"

python3 - "$RECOMMENDATIONS_FILE" "$STATE_FILE" <<'PY'
import json
import os
import re
import sys
import tempfile
from datetime import datetime, timezone


STOP_WORDS = {
    "a", "an", "and", "are", "as", "at", "be", "by", "for", "from", "if", "in",
    "into", "is", "it", "of", "on", "or", "that", "the", "this", "to", "up",
    "with", "one", "two", "next", "week", "day", "days", "least", "add",
}

PRIORITY_TO_IMPACT = {
    "high": "HIGH",
    "medium": "MEDIUM",
    "low": "LOW",
}

IMPACT_RANK = {
    "LOW": 1,
    "MEDIUM": 2,
    "HIGH": 3,
}


def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def tokenize(text):
    words = re.findall(r"[a-z0-9]+", str(text).lower())
    return {w for w in words if len(w) >= 4 and w not in STOP_WORDS and not w.isdigit()}


def overlap_ratio(a, b):
    if not a:
        return 0.0
    return len(a & b) / len(a)


def is_duplicate(new_text, existing_text):
    new_kw = tokenize(new_text)
    existing_kw = tokenize(existing_text)
    if not new_kw or not existing_kw:
        return False
    ratio_new = overlap_ratio(new_kw, existing_kw)
    ratio_existing = overlap_ratio(existing_kw, new_kw)
    return ratio_new > 0.5 or ratio_existing > 0.5


def parse_task_num(task_id):
    m = re.match(r"^task-(\d+)$", str(task_id).strip())
    return int(m.group(1)) if m else None


def infer_category(text):
    t = str(text).lower()
    if any(k in t for k in ("seo", "query", "ranking", "title", "meta", "organic")):
        return "seo"
    if any(k in t for k in ("social", "referral", "distribution", "campaign", "launch")):
        return "distribution"
    if any(k in t for k in ("dashboard", "instrument", "kpi", "analytics", "metric")):
        return "analytics"
    return "content"


def confidence_for_priority(priority):
    p = str(priority).lower()
    if p == "high":
        return 90
    if p == "medium":
        return 80
    return 70


def normalize_candidates(recommendations):
    out = []
    recs = recommendations.get("recommendations", [])
    for rec in recs:
        if not isinstance(rec, dict):
            continue
        action = str(rec.get("action", "")).strip()
        if not action:
            continue
        p = str(rec.get("priority", "medium")).lower()
        if p not in PRIORITY_TO_IMPACT:
            p = "medium"
        out.append(
            {
                "description": action,
                "reasoning": str(rec.get("reasoning", "Metrics recommendation")).strip() or "Metrics recommendation",
                "priority": p,
            }
        )

    # Also absorb goal adjustments (string or object), defaulting to medium priority.
    for adj in recommendations.get("goal_adjustments", []):
        if isinstance(adj, str):
            desc = adj.strip()
            reason = "Goal adjustment from metrics engine."
            p = "medium"
        elif isinstance(adj, dict):
            desc = str(adj.get("action") or adj.get("description") or "").strip()
            reason = str(adj.get("reasoning") or "Goal adjustment from metrics engine.").strip()
            p = str(adj.get("priority", "medium")).lower()
            if p not in PRIORITY_TO_IMPACT:
                p = "medium"
        else:
            continue
        if not desc:
            continue
        out.append(
            {
                "description": desc,
                "reasoning": reason,
                "priority": p,
            }
        )
    return out


recommendations_path = sys.argv[1]
state_path = sys.argv[2]

recs_data = load_json(recommendations_path)
state = load_json(state_path)

tasks_root = state.setdefault("tasks", {})
queue = tasks_root.setdefault("queue", [])
if not isinstance(queue, list):
    raise SystemExit("state.json tasks.queue must be an array")

max_id = 0
for task in queue:
    if isinstance(task, dict):
        n = parse_task_num(task.get("id"))
        if n is not None and n > max_id:
            max_id = n

candidates = normalize_candidates(recs_data)

high_new = []
medium_new = []
low_new = []
added = 0
skipped = 0
reprioritized = 0

for cand in candidates:
    desc = cand["description"]
    reasoning = cand["reasoning"]
    priority = cand["priority"]
    impact = PRIORITY_TO_IMPACT[priority]

    found_idx = None
    for idx, existing in enumerate(queue):
        if not isinstance(existing, dict):
            continue
        existing_desc = str(existing.get("description", ""))
        if is_duplicate(desc, existing_desc):
            found_idx = idx
            break

    if found_idx is not None:
        existing = queue[found_idx]
        prev_impact = str(existing.get("impact", "LOW")).upper()
        if IMPACT_RANK.get(impact, 1) > IMPACT_RANK.get(prev_impact, 1):
            existing["impact"] = impact
            reprioritized += 1
        skipped += 1
        continue

    max_id += 1
    now = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    new_task = {
        "id": f"task-{max_id}",
        "description": desc,
        "reasoning": reasoning,
        "impact": impact,
        "confidence": confidence_for_priority(priority),
        "category": infer_category(desc),
        "classification": "GREEN",
        "method": "Metrics-driven recommendation",
        "rollback": "Remove task from queue",
        "estimated_duration": "25m",
        "created_at": now,
        "status": "pending",
        "source": "metrics-engine",
    }
    if priority == "high":
        high_new.append(new_task)
    elif priority == "low":
        low_new.append(new_task)
    else:
        medium_new.append(new_task)
    added += 1

# Preserve original ordering for existing tasks, while inserting new tasks by priority buckets.
tasks_root["queue"] = high_new + medium_new + queue + low_new

state_dir = os.path.dirname(os.path.abspath(state_path)) or "."
fd, tmp_path = tempfile.mkstemp(prefix=".state.json.", suffix=".tmp", dir=state_dir)
try:
    with os.fdopen(fd, "w", encoding="utf-8") as tmp:
        json.dump(state, tmp, indent=2)
        tmp.write("\n")
    os.replace(tmp_path, state_path)
except Exception:
    try:
        os.unlink(tmp_path)
    except OSError:
        pass
    raise

print(f"Added {added} task(s)")
print(f"Skipped {skipped} duplicate task(s)")
print(f"Reprioritized {reprioritized} existing task(s)")
if added:
    print("Inserted by priority: high/medium at front, low at end")
PY
