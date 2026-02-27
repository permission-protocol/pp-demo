#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GOAL_DIR="${SCRIPT_DIR}/../goals/xdares-seo-growth"

LATEST_FILE="${1:-$GOAL_DIR/metrics/latest.json}"
HISTORY_FILE="${2:-$GOAL_DIR/metrics/history.jsonl}"
STATE_FILE="${3:-$GOAL_DIR/state.json}"
OUTPUT_FILE="${4:-$GOAL_DIR/metrics/recommendations.json}"

python3 - "$LATEST_FILE" "$HISTORY_FILE" "$STATE_FILE" "$OUTPUT_FILE" <<'PY'
import json
import os
import re
import sys
from datetime import date, datetime

latest_file, history_file, state_file, output_file = sys.argv[1:5]


def as_float(v, default=None):
    try:
        if v is None:
            return default
        return float(v)
    except Exception:
        return default


def safe_round(v, ndigits=2):
    if v is None:
        return None
    return round(v, ndigits)


def pct_text(v):
    r = safe_round(v)
    return f"{r}%" if r is not None else "n/a"


def pct_change(new, old):
    if new is None or old is None:
        return None
    if old == 0:
        if new == 0:
            return 0.0
        return 100.0
    return ((new - old) / old) * 100.0


def classify(value, flat_threshold=5.0):
    if value is None:
        return "insufficient_data"
    if value > flat_threshold:
        return "up"
    if value < -flat_threshold:
        return "down"
    return "flat"


def parse_date(s):
    if not s:
        return None
    for fmt in ("%Y-%m-%d", "%Y-%m-%dT%H:%M:%S.%fZ", "%Y-%m-%dT%H:%M:%SZ"):
        try:
            return datetime.strptime(s, fmt).date()
        except Exception:
            continue
    try:
        return datetime.fromisoformat(str(s).replace("Z", "+00:00")).date()
    except Exception:
        return None


def parse_target_sessions_per_month(text):
    if text is None:
        return None
    s = str(text)
    match = re.search(r"(\d[\d,]*)", s)
    if not match:
        return None
    try:
        return float(match.group(1).replace(",", ""))
    except Exception:
        return None


def extract_slug(url):
    if not url:
        return "(unknown page)"
    value = str(url).strip().rstrip("/")
    if "/" not in value:
        return value
    slug = value.split("/")[-1]
    return slug or value


def get_overview(rec):
    ga4 = rec.get("ga4", {}) if isinstance(rec, dict) else {}
    ov = ga4.get("overview", {}) if isinstance(ga4, dict) else {}
    if not isinstance(ov, dict):
        ov = {}
    if not ov and isinstance(rec, dict) and isinstance(rec.get("ga4_overview"), dict):
        ov = rec.get("ga4_overview")
    return ov


def get_sources(rec):
    ga4 = rec.get("ga4", {}) if isinstance(rec, dict) else {}
    src = ga4.get("sources", []) if isinstance(ga4, dict) else []
    return src if isinstance(src, list) else []


def get_geo(rec):
    ga4 = rec.get("ga4", {}) if isinstance(rec, dict) else {}
    geo = ga4.get("geo", []) if isinstance(ga4, dict) else []
    return geo if isinstance(geo, list) else []


def get_search_console(rec):
    if not isinstance(rec, dict):
        return {}
    if isinstance(rec.get("searchConsole"), dict):
        sc = rec["searchConsole"]
        queries = sc.get("queries", {}) if isinstance(sc.get("queries"), dict) else {}
        pages = sc.get("pages", {}) if isinstance(sc.get("pages"), dict) else {}
        return {
            "clicks": queries.get("totalClicks", rec.get("sc_clicks")),
            "impressions": queries.get("totalImpressions", rec.get("sc_impressions")),
            "ctr": queries.get("ctr", rec.get("sc_ctr")),
            "position": queries.get("position", rec.get("sc_position")),
            "topQueries": queries.get("top", []),
            "topPages": pages.get("top", []),
        }
    if isinstance(rec.get("search_console"), dict):
        sc = rec["search_console"]
        return {
            "clicks": sc.get("clicks", rec.get("sc_clicks")),
            "impressions": sc.get("impressions", rec.get("sc_impressions")),
            "ctr": sc.get("ctr", rec.get("sc_ctr")),
            "position": sc.get("position", rec.get("sc_position")),
            "topQueries": sc.get("topQueries", []),
            "topPages": sc.get("topPages", []),
        }
    return {
        "clicks": rec.get("sc_clicks"),
        "impressions": rec.get("sc_impressions"),
        "ctr": rec.get("sc_ctr"),
        "position": rec.get("sc_position"),
        "topQueries": rec.get("topQueries", []),
        "topPages": rec.get("topPages", []),
    }


def normalized_metrics(rec):
    ov = get_overview(rec)
    sources = get_sources(rec)
    sc = get_search_console(rec)

    sessions = as_float(ov.get("sessions_thisWeek", ov.get("sessions")))
    engaged = as_float(ov.get("engagedSessions_thisWeek", ov.get("engagedSessions")))
    duration = as_float(ov.get("avgSessionDuration_thisWeek", ov.get("avgSessionDuration")))

    organic_sessions = 0.0
    has_organic = False
    for src in sources:
        if not isinstance(src, dict):
            continue
        ch = str(src.get("channel", "")).strip().lower()
        if ch in ("organic search", "organic", "seo"):
            s = as_float(src.get("sessions"))
            if s is not None:
                organic_sessions += s
                has_organic = True

    clicks = as_float(sc.get("clicks"))
    impressions = as_float(sc.get("impressions"))
    ctr = as_float(sc.get("ctr"))
    position = as_float(sc.get("position"))

    if position in (None, 0):
        poss = []
        for q in sc.get("topQueries", []):
            if isinstance(q, dict):
                p = as_float(q.get("position"))
                if p is not None and p > 0:
                    poss.append(p)
        if poss:
            position = sum(poss) / len(poss)

    return {
        "traffic": sessions,
        "engaged": engaged,
        "duration": duration,
        "organic": organic_sessions if has_organic else None,
        "sc_clicks": clicks,
        "sc_impressions": impressions,
        "sc_ctr": ctr,
        "sc_position": position,
    }


def avg(values):
    vals = [v for v in values if v is not None]
    return (sum(vals) / len(vals)) if vals else None


def data_quality(valid_count):
    if valid_count >= 3:
        return "good"
    if valid_count >= 1:
        return "limited"
    return "none"


def tokenize(text):
    t = re.sub(r"[^a-z0-9\s]", " ", str(text).lower())
    words = [w for w in t.split() if len(w) > 2]
    stop = {
        "the", "and", "for", "with", "this", "that", "from", "into", "your", "over",
        "task", "draft", "publish", "page", "pages", "week", "next", "high", "medium", "low",
        "already", "covers", "prioritize", "execution", "planning", "seo", "sessions", "traffic"
    }
    return {w for w in words if w not in stop}


def queue_overlap_for(action_text, queue_items):
    rec_tokens = tokenize(action_text)
    if not rec_tokens:
        return (False, None, None)
    best = None
    best_score = 0.0
    rec_text_l = action_text.lower()
    for item in queue_items:
        desc = str(item.get("description", ""))
        desc_l = desc.lower()
        desc_tokens = tokenize(desc)
        if not desc_tokens:
            continue
        inter = len(rec_tokens & desc_tokens)
        union = len(rec_tokens | desc_tokens)
        score = (inter / union) if union else 0.0
        if desc_l in rec_text_l or rec_text_l in desc_l:
            score = max(score, 0.95)
        if score > best_score:
            best_score = score
            best = item
    if best and best_score >= 0.28:
        return (True, best.get("id"), best.get("description"))
    return (False, None, None)


def add_recommendation(out, queue_items, priority, action, reasoning, metric_trigger):
    overlap, task_id, task_desc = queue_overlap_for(action, queue_items)
    if overlap and task_id:
        final_action = f"{task_id} already covers this - prioritize execution over new planning."
        final_reason = f"Queue overlap with existing task: {task_desc}"
    else:
        final_action = action
        final_reason = reasoning
    out.append({
        "priority": priority,
        "action": final_action,
        "reasoning": final_reason,
        "metric_trigger": metric_trigger,
        "queue_overlap": overlap,
    })


with open(latest_file, "r", encoding="utf-8") as f:
    latest = json.load(f)

history_records = []
if os.path.exists(history_file):
    with open(history_file, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                history_records.append(json.loads(line))
            except Exception:
                continue

state = {}
if state_file and os.path.exists(state_file):
    try:
        with open(state_file, "r", encoding="utf-8") as f:
            state = json.load(f)
    except Exception:
        state = {}

queue_items = []
if isinstance(state, dict):
    tasks = state.get("tasks", {}) if isinstance(state.get("tasks"), dict) else {}
    q = tasks.get("queue", []) if isinstance(tasks.get("queue"), list) else []
    for item in q:
        if isinstance(item, dict):
            queue_items.append(item)

valid_history = []
for rec in history_records:
    ov = get_overview(rec)
    if not isinstance(ov, dict):
        continue
    if "error" in ov:
        continue
    if ov.get("sessions_thisWeek") is None and ov.get("sessions") is None:
        continue
    valid_history.append(rec)

latest_metrics = normalized_metrics(latest)
baseline_set = valid_history[-3:]
baseline_metrics = [normalized_metrics(r) for r in baseline_set]

metric_keys = ["traffic", "engaged", "duration", "organic", "sc_clicks", "sc_impressions", "sc_ctr", "sc_position"]
baseline = {}
counts = {}
for key in metric_keys:
    vals = [m.get(key) for m in baseline_metrics if m.get(key) is not None]
    baseline[key] = avg(vals)
    counts[key] = len(vals)

traffic_pct = pct_change(latest_metrics.get("traffic"), baseline.get("traffic"))
engaged_pct = pct_change(latest_metrics.get("engaged"), baseline.get("engaged"))
duration_pct = pct_change(latest_metrics.get("duration"), baseline.get("duration"))
engagement_pct = None
if engaged_pct is not None and duration_pct is not None:
    engagement_pct = (engaged_pct + duration_pct) / 2.0
organic_pct = pct_change(latest_metrics.get("organic"), baseline.get("organic"))

impr_pct = pct_change(latest_metrics.get("sc_impressions"), baseline.get("sc_impressions"))
click_pct = pct_change(latest_metrics.get("sc_clicks"), baseline.get("sc_clicks"))
pos_improvement_pct = None
if baseline.get("sc_position") is not None and latest_metrics.get("sc_position") is not None:
    pos_improvement_pct = pct_change(baseline.get("sc_position"), latest_metrics.get("sc_position"))
search_visibility_score = None
if None not in (impr_pct, click_pct, pos_improvement_pct):
    search_visibility_score = (impr_pct + click_pct + pos_improvement_pct) / 3.0

traffic_quality = data_quality(counts["traffic"])
engaged_quality = data_quality(min(counts["engaged"], counts["duration"]))
organic_quality = data_quality(counts["organic"])
search_quality = data_quality(min(counts["sc_impressions"], counts["sc_clicks"], counts["sc_position"]))

trends = {
    "traffic": classify(traffic_pct) if traffic_quality == "good" else "insufficient_data",
    "traffic_pct_change": safe_round(traffic_pct),
    "engagement": classify(engagement_pct) if engaged_quality == "good" else "insufficient_data",
    "engagement_pct_change": safe_round(engagement_pct),
    "organic": classify(organic_pct) if organic_quality == "good" else "insufficient_data",
    "organic_pct_change": safe_round(organic_pct),
    "search_visibility": classify(search_visibility_score) if search_quality == "good" else "insufficient_data",
    "data_quality": "none" if "none" in (traffic_quality, engaged_quality, organic_quality, search_quality) else ("limited" if "limited" in (traffic_quality, engaged_quality, organic_quality, search_quality) else "good"),
}

signals = []
recommendations = []
goal_adjustments = []

signals.append(
    f"Traffic trend: {trends['traffic']} ({pct_text(traffic_pct)} vs last {len(baseline_set)} valid snapshots baseline)."
)
signals.append(
    f"Engagement trend: {trends['engagement']} ({pct_text(engagement_pct)} combined engaged sessions + avg duration)."
)
signals.append(
    f"Organic trend: {trends['organic']} ({pct_text(organic_pct)} vs baseline)."
)
signals.append(
    f"Search visibility trend: {trends['search_visibility']} (impressions/clicks/position composite)."
)

sc = get_search_console(latest)
query_rows = [q for q in sc.get("topQueries", []) if isinstance(q, dict)]
page_rows = [p for p in sc.get("topPages", []) if isinstance(p, dict)]

query_rows = sorted(query_rows, key=lambda x: as_float(x.get("impressions"), 0.0) or 0.0, reverse=True)
page_rows = sorted(page_rows, key=lambda x: as_float(x.get("impressions"), 0.0) or 0.0, reverse=True)

if page_rows:
    top_page = page_rows[0]
    top_page_key = str(top_page.get("key", ""))
    top_page_slug = extract_slug(top_page_key)
    top_page_impr = int(as_float(top_page.get("impressions"), 0.0) or 0)
    top_page_pos = safe_round(as_float(top_page.get("position"), 0.0) or 0.0, 1)

    support_queries = [
        q for q in query_rows
        if (as_float(q.get("position"), 0.0) or 0.0) >= 8.0 and (as_float(q.get("impressions"), 0.0) or 0.0) >= 1.0
    ]
    support_terms = [str(q.get("key", "")).strip() for q in support_queries[:3] if str(q.get("key", "")).strip()]
    if support_terms:
        query_phrase = ", ".join(support_terms)
        action = (
            f"{top_page_slug} gets {top_page_impr} impressions at position {top_page_pos} - create 3 supporting articles targeting {query_phrase}, then add internal links back to {top_page_slug}."
        )
        reasoning = "High-impression page with mid-SERP position is a direct cluster-expansion opportunity."
        trigger = f"top_page_impressions={top_page_impr},top_page_position={top_page_pos}"
        add_recommendation(recommendations, queue_items, "high", action, reasoning, trigger)

if page_rows and query_rows:
    candidate_page = None
    for p in page_rows:
        pos = as_float(p.get("position"), 0.0) or 0.0
        impr = as_float(p.get("impressions"), 0.0) or 0.0
        if impr >= 30 and pos >= 8.0:
            candidate_page = p
            break
    if candidate_page is not None:
        cslug = extract_slug(candidate_page.get("key", ""))
        cimpr = int(as_float(candidate_page.get("impressions"), 0.0) or 0)
        cctr = safe_round(as_float(candidate_page.get("ctr"), 0.0) or 0.0, 1)
        cpos = safe_round(as_float(candidate_page.get("position"), 0.0) or 0.0, 1)

        top_query = query_rows[0]
        qkey = str(top_query.get("key", "")).strip() or "core keyword"
        qimpr = int(as_float(top_query.get("impressions"), 0.0) or 0)

        action = (
            f"Retitle {cslug} to include '{qkey}' and tighten meta description for click intent; page is at {cimpr} impressions, {cctr}% CTR, position {cpos}."
        )
        reasoning = f"Top query '{qkey}' already shows demand ({qimpr} impressions); aligning title/meta can improve CTR without net-new content."
        trigger = f"page_position={cpos},page_impressions={cimpr},query={qkey}"
        add_recommendation(recommendations, queue_items, "medium", action, reasoning, trigger)

geo = get_geo(latest)
geo_sessions = []
for item in geo:
    if isinstance(item, dict):
        s = as_float(item.get("sessions"), 0.0) or 0.0
        geo_sessions.append((str(item.get("country", "Unknown")), s))

total_geo_sessions = sum(v for _, v in geo_sessions)
if total_geo_sessions > 0 and geo_sessions:
    top_country, top_sessions = max(geo_sessions, key=lambda x: x[1])
    share = (top_sessions / total_geo_sessions) * 100.0
    if share > 50.0:
        action = (
            f"{top_country} drives {safe_round(share,2)}% of sessions; localize the two highest-impression pages and interlink them to diversify organic demand."
        )
        reasoning = "Country concentration is high enough to create channel-risk if rankings shift in one market."
        trigger = f"geo_top_country={top_country},share={safe_round(share,2)}%"
        add_recommendation(recommendations, queue_items, "medium", action, reasoning, trigger)

latest_date = parse_date(latest.get("date") if isinstance(latest, dict) else None) or date.today()

goal = state.get("goal", {}) if isinstance(state.get("goal"), dict) else {}
deadline = parse_date(goal.get("deadline"))
target_text = None
target = None
if isinstance(goal.get("success_metric"), dict):
    target_text = goal["success_metric"].get("target")
    target = parse_target_sessions_per_month(target_text)
if target is None:
    target = 5000.0
if deadline is None:
    deadline = date(2026, 3, 5)

days_left = (deadline - latest_date).days
traffic_now = latest_metrics.get("traffic") or 0.0
monthly_run_rate = traffic_now * (30.0 / 7.0)
pace_pct = (monthly_run_rate / target) * 100.0 if target else 0.0
projected = round(monthly_run_rate)

signals.append(
    f"Current run-rate is ~{safe_round(monthly_run_rate,1)} sessions/month ({safe_round(pace_pct,1)}% of {int(target)}/month target) with {days_left} day(s) to {deadline.isoformat()}."
)

if pace_pct < 20.0 and days_left < 7:
    reset_action = (
        f"Current goal ({int(target)}/month by {deadline.isoformat()}) is unreachable at {safe_round(monthly_run_rate,1)}/month. "
        f"Recommend resetting to a realistic target based on current trajectory: {projected} sessions/month by end of next 30-day cycle."
    )
    reset_reason = "Late-cycle pace is below 20%, so acceleration alone cannot close the gap before deadline."
    reset_trigger = f"pace_pct={safe_round(pace_pct,1)}%,days_left={days_left}"
    add_recommendation(recommendations, queue_items, "high", reset_action, reset_reason, reset_trigger)

    accel_action = (
        "Secondary: activate short-cycle traffic boosts this week (launch post, referral push, and organic social distribution with tracked links)."
    )
    accel_reason = "Useful for improving next cycle trajectory, but insufficient to hit current deadline target."
    accel_trigger = f"secondary_acceleration,pacing_gap={safe_round(100-pace_pct,1)}%"
    add_recommendation(recommendations, queue_items, "medium", accel_action, accel_reason, accel_trigger)
else:
    if monthly_run_rate < target:
        accel_action = (
            "Activate short-cycle traffic boosts this week (launch post, referral push, and organic social distribution with tracked links)."
        )
        accel_reason = "Run-rate is below target and still has enough runway for distribution-heavy recovery."
        accel_trigger = f"monthly_run_rate={safe_round(monthly_run_rate,1)} vs target={int(target)}"
        add_recommendation(recommendations, queue_items, "high", accel_action, accel_reason, accel_trigger)

if trends["organic"] == "up":
    goal_adjustments.append("Increase execution on existing SEO queue items tied to ranking pages and long-tail cluster support.")
elif trends["organic"] == "down":
    goal_adjustments.append("Prioritize ranking-recovery updates on pages with high impressions and falling position.")

output = {
    "date": latest_date.isoformat(),
    "trends": trends,
    "signals": signals,
    "recommendations": recommendations,
    "goal_adjustments": goal_adjustments,
}

os.makedirs(os.path.dirname(output_file), exist_ok=True)
tmp_file = output_file + ".tmp"
with open(tmp_file, "w", encoding="utf-8") as f:
    json.dump(output, f, ensure_ascii=True, indent=2)
    f.write("\n")
os.replace(tmp_file, output_file)
PY
