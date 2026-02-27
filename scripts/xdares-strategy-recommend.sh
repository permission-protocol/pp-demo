#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GOAL_DIR="${SCRIPT_DIR}/../goals/xdares-seo-growth"
LATEST_FILE="${GOAL_DIR}/metrics/latest.json"
HISTORY_FILE="${GOAL_DIR}/metrics/history.jsonl"
OUTPUT_FILE="${GOAL_DIR}/metrics/recommendations.json"

python3 - "$LATEST_FILE" "$HISTORY_FILE" "$OUTPUT_FILE" <<'PY'
import json
import math
import os
import sys
from datetime import datetime, date

latest_file, history_file, output_file = sys.argv[1:4]

def as_float(v, default=0.0):
    try:
        if v is None:
            return float(default)
        return float(v)
    except Exception:
        return float(default)

def pct_change(new, old):
    new = as_float(new, 0.0)
    old = as_float(old, 0.0)
    if old == 0:
        if new == 0:
            return 0.0
        return 100.0
    return ((new - old) / old) * 100.0

def classify(value, flat_threshold=5.0):
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
            d = datetime.strptime(s, fmt)
            return d.date()
        except Exception:
            continue
    return None

def get_overview(rec):
    ga4 = rec.get("ga4", {}) if isinstance(rec, dict) else {}
    ov = ga4.get("overview", {}) if isinstance(ga4, dict) else {}
    if not isinstance(ov, dict):
        ov = {}
    # Backward compatibility with alternate flattened schema in history
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
    # Support both documented and observed schema variants
    if isinstance(rec.get("search_console"), dict):
        return rec.get("search_console")
    if isinstance(rec.get("searchConsole"), dict):
        sc = rec.get("searchConsole")
        q = sc.get("queries", {}) if isinstance(sc, dict) else {}
        # normalize minimal fields used by this script
        return {
            "clicks": q.get("totalClicks", rec.get("sc_clicks", 0)),
            "impressions": q.get("totalImpressions", rec.get("sc_impressions", 0)),
            "ctr": q.get("ctr", 0),
            "position": q.get("position", 0),
            "topQueries": q.get("top", []),
        }
    # fallback keys from older snapshots
    return {
        "clicks": rec.get("sc_clicks", 0),
        "impressions": rec.get("sc_impressions", 0),
        "ctr": rec.get("sc_ctr", 0),
        "position": rec.get("sc_position", 0),
        "topQueries": rec.get("topQueries", []),
    }

def normalized_metrics(rec):
    ov = get_overview(rec)
    sources = get_sources(rec)
    sc = get_search_console(rec)

    sessions = ov.get("sessions_thisWeek", ov.get("sessions", 0))
    engaged = ov.get("engagedSessions_thisWeek", ov.get("engagedSessions", 0))
    duration = ov.get("avgSessionDuration_thisWeek", ov.get("avgSessionDuration", 0))

    organic_sessions = 0.0
    for src in sources:
        if not isinstance(src, dict):
            continue
        ch = str(src.get("channel", "")).strip().lower()
        if ch in ("organic search", "organic", "seo"):
            organic_sessions += as_float(src.get("sessions", 0))

    clicks = as_float(sc.get("clicks", 0))
    impressions = as_float(sc.get("impressions", 0))
    ctr = as_float(sc.get("ctr", 0))
    position = as_float(sc.get("position", 0))

    # If position is not provided directly, infer from top queries if present.
    if position == 0 and isinstance(sc.get("topQueries"), list):
        poss = [as_float(q.get("position", 0)) for q in sc.get("topQueries", []) if isinstance(q, dict)]
        poss = [p for p in poss if p > 0]
        if poss:
            position = sum(poss) / len(poss)

    return {
        "traffic": as_float(sessions),
        "engaged": as_float(engaged),
        "duration": as_float(duration),
        "organic": as_float(organic_sessions),
        "sc_clicks": clicks,
        "sc_impressions": impressions,
        "sc_ctr": ctr,
        "sc_position": position,
    }

def avg(values):
    vals = [as_float(v) for v in values]
    return sum(vals) / len(vals) if vals else 0.0

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
                obj = json.loads(line)
            except Exception:
                continue
            history_records.append(obj)

# Keep only entries with usable GA4 overview values.
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

baseline = {
    "traffic": avg([m["traffic"] for m in baseline_metrics]),
    "engaged": avg([m["engaged"] for m in baseline_metrics]),
    "duration": avg([m["duration"] for m in baseline_metrics]),
    "organic": avg([m["organic"] for m in baseline_metrics]),
    "sc_clicks": avg([m["sc_clicks"] for m in baseline_metrics]),
    "sc_impressions": avg([m["sc_impressions"] for m in baseline_metrics]),
    "sc_ctr": avg([m["sc_ctr"] for m in baseline_metrics]),
    "sc_position": avg([m["sc_position"] for m in baseline_metrics]),
}

traffic_pct = pct_change(latest_metrics["traffic"], baseline["traffic"])
engaged_pct = pct_change(latest_metrics["engaged"], baseline["engaged"])
duration_pct = pct_change(latest_metrics["duration"], baseline["duration"])
engagement_pct = (engaged_pct + duration_pct) / 2.0
organic_pct = pct_change(latest_metrics["organic"], baseline["organic"])

impr_pct = pct_change(latest_metrics["sc_impressions"], baseline["sc_impressions"])
click_pct = pct_change(latest_metrics["sc_clicks"], baseline["sc_clicks"])
# Lower average position is better; convert to "improvement" percentage.
pos_improvement_pct = pct_change(baseline["sc_position"], latest_metrics["sc_position"]) if baseline["sc_position"] else 0.0
search_visibility_score = (impr_pct + click_pct + pos_improvement_pct) / 3.0

trends = {
    "traffic": classify(traffic_pct),
    "traffic_pct_change": round(traffic_pct, 2),
    "engagement": classify(engagement_pct),
    "engagement_pct_change": round(engagement_pct, 2),
    "organic": classify(organic_pct),
    "organic_pct_change": round(organic_pct, 2),
    "search_visibility": classify(search_visibility_score),
}

signals = []
recommendations = []
goal_adjustments = []

# Signals: traffic/engagement/organic/search
signals.append(
    f"Traffic is {trends['traffic']} ({trends['traffic_pct_change']}% vs last 3 snapshots baseline)."
)
signals.append(
    f"Engagement is {trends['engagement']} ({trends['engagement_pct_change']}% combined change from engaged sessions and avg session duration)."
)
signals.append(
    f"Organic sessions are {trends['organic']} ({trends['organic_pct_change']}% vs baseline)."
)
signals.append(
    f"Search visibility is {trends['search_visibility']} (impressions/clicks/position composite)."
)

# Organic branch
if trends["organic"] == "up":
    recommendations.append({
        "priority": "high",
        "action": "Double down on SEO by publishing 2 high-intent pages this week targeting top converting query themes and refreshing titles/meta on existing ranking pages.",
        "reasoning": "Organic search is trending up; increasing output while momentum is positive typically compounds impressions and clicks.",
        "metric_trigger": f"organic_pct_change={round(organic_pct,2)}%",
    })
    goal_adjustments.append("Increase SEO executor allocation: add at least 2 content tasks and 1 on-page refresh task in the next 7 days.")
elif trends["organic"] == "down":
    recommendations.append({
        "priority": "high",
        "action": "Pivot SEO plan to recovery: audit pages with impression losses, fix internal linking to top pages, and retarget content to query clusters with existing traction.",
        "reasoning": "Organic sessions are declining versus recent history, so preserving and recovering search demand should be prioritized.",
        "metric_trigger": f"organic_pct_change={round(organic_pct,2)}%",
    })
    goal_adjustments.append("Reprioritize next sprint: replace one net-new content task with SEO diagnostics and ranking recovery fixes.")

# Engagement drop
if trends["engagement"] == "down":
    recommendations.append({
        "priority": "high",
        "action": "Run a landing-page engagement sprint: improve above-the-fold clarity, add stronger CTAs, and reduce initial friction on signup/waitlist flows.",
        "reasoning": "Engagement declined across session quality metrics, which can suppress conversion even if traffic rises.",
        "metric_trigger": f"engagement_pct_change={round(engagement_pct,2)}%",
    })
    goal_adjustments.append("Add a UX/CRO task block focused on session depth and conversion-path friction for the next cycle.")

# Geo concentration
geo = get_geo(latest)
geo_sessions = []
for item in geo:
    if isinstance(item, dict):
        geo_sessions.append((str(item.get("country", "Unknown")), as_float(item.get("sessions", 0))))

total_geo_sessions = sum(v for _, v in geo_sessions)
if total_geo_sessions > 0 and geo_sessions:
    top_country, top_sessions = max(geo_sessions, key=lambda x: x[1])
    share = (top_sessions / total_geo_sessions) * 100.0
    if share > 50.0:
        signals.append(f"Geographic concentration detected: {top_country} accounts for {round(share,2)}% of tracked sessions.")
        recommendations.append({
            "priority": "medium",
            "action": f"Diversify acquisition beyond {top_country}: launch one geo-targeted campaign and localize high-traffic pages for the next top 1-2 countries.",
            "reasoning": "Over-concentration increases growth risk and makes performance sensitive to one market.",
            "metric_trigger": f"geo_top_country_share={round(share,2)}%",
        })
        goal_adjustments.append("Add geo-diversification tasks: country-specific campaigns and localized landing page experiments.")

# Pace check for 5000/month goal by deadline
latest_date = parse_date(latest.get("date") if isinstance(latest, dict) else None) or date.today()
deadline = date(2026, 3, 5)
days_left = (deadline - latest_date).days
monthly_run_rate = latest_metrics["traffic"] * (30.0 / 7.0)
pace_pct = (monthly_run_rate / 5000.0) * 100.0 if 5000 else 0.0

if days_left >= 0:
    signals.append(
        f"Current monthly traffic run-rate is ~{round(monthly_run_rate,1)} sessions ({round(pace_pct,1)}% of 5000/month target) with {days_left} day(s) until 2026-03-05."
    )
else:
    signals.append(
        f"Deadline 2026-03-05 has passed by {-days_left} day(s); current run-rate is ~{round(monthly_run_rate,1)} sessions/month ({round(pace_pct,1)}% of target)."
    )

if monthly_run_rate < 5000:
    recommendations.append({
        "priority": "high",
        "action": "Activate short-cycle traffic boosts this week: publish one launch post, run one referral push, and increase social distribution cadence with tracked links.",
        "reasoning": "Current session run-rate is materially below the 5000/month goal, requiring immediate top-of-funnel acceleration.",
        "metric_trigger": f"monthly_run_rate={round(monthly_run_rate,1)} vs goal=5000",
    })
    goal_adjustments.append("Shift executor plan toward growth loops and distribution tasks until run-rate exceeds 70% of monthly target.")
else:
    recommendations.append({
        "priority": "medium",
        "action": "Maintain growth cadence and protect quality: keep acquisition volume while monitoring engagement to avoid low-intent traffic dilution.",
        "reasoning": "Traffic run-rate is at or above target pace; focus should balance volume and conversion quality.",
        "metric_trigger": f"monthly_run_rate={round(monthly_run_rate,1)} vs goal=5000",
    })

# Ensure there is always at least one medium/low tactical recommendation
if not any(r["priority"] == "low" for r in recommendations):
    recommendations.append({
        "priority": "low",
        "action": "Instrument weekly KPI review automation to track channel mix, engagement depth, and query movement from a single dashboard.",
        "reasoning": "Consistent instrumentation reduces reaction time when trend direction changes.",
        "metric_trigger": "monitoring_gap",
    })

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
