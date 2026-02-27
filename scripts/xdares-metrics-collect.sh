#!/bin/bash
# xdares-metrics-collect.sh — Pull metrics from all platforms, write structured JSON
# Run daily via heartbeat or cron
set -euo pipefail

METRICS_DIR="$HOME/.openclaw/workspace/goals/xdares-seo-growth/metrics"
METRICS_FILE="$METRICS_DIR/latest.json"
HISTORY_FILE="$METRICS_DIR/history.jsonl"
TOKEN_FILE="$HOME/.openclaw/secrets/google-analytics-token.json"
POSTHOG_KEY_FILE="$HOME/.openclaw/secrets/posthog-api-key.txt"

mkdir -p "$METRICS_DIR"

TODAY=$(date -u +%Y-%m-%d)
WEEK_AGO=$(date -v-7d -u +%Y-%m-%d 2>/dev/null || date -d "7 days ago" -u +%Y-%m-%d)

echo "📊 Collecting Xdares metrics for $TODAY..."

# ── Helper: refresh Google access token ──
get_google_token() {
    if [ ! -f "$TOKEN_FILE" ]; then
        echo "❌ No Google token. Run: python3 scripts/xdares-metrics-auth.py" >&2
        return 1
    fi
    
    local refresh_token client_id client_secret
    refresh_token=$(python3 -c "import json; print(json.load(open('$TOKEN_FILE'))['refresh_token'])")
    client_id=$(python3 -c "import json; print(json.load(open('$TOKEN_FILE'))['client_id'])")
    client_secret=$(python3 -c "import json; print(json.load(open('$TOKEN_FILE'))['client_secret'])")
    
    local resp
    resp=$(curl -s -X POST "https://oauth2.googleapis.com/token" \
        -d "refresh_token=$refresh_token&client_id=$client_id&client_secret=$client_secret&grant_type=refresh_token")
    
    echo "$resp" | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])"
}

# ── 1. Google Analytics (GA4) ──
collect_ga4() {
    echo "  📈 Google Analytics..." >&2
    local token
    token=$(get_google_token) || { echo '{"error":"no_token"}'; return; }
    
    # GA4 property ID for ar-pwa-prod (Xdares)
    local GA4_PROPERTY="properties/256952992"
    
    curl -s "https://analyticsdata.googleapis.com/v1beta/$GA4_PROPERTY:runReport" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "{
            \"dateRanges\": [
                {\"startDate\": \"7daysAgo\", \"endDate\": \"today\"},
                {\"startDate\": \"14daysAgo\", \"endDate\": \"8daysAgo\"}
            ],
            \"metrics\": [
                {\"name\": \"activeUsers\"},
                {\"name\": \"sessions\"},
                {\"name\": \"engagedSessions\"},
                {\"name\": \"averageSessionDuration\"},
                {\"name\": \"newUsers\"},
                {\"name\": \"screenPageViews\"}
            ]
        }" 2>/dev/null
}

# ── 2. Google Analytics — Traffic Sources ──
collect_ga4_sources() {
    local token
    token=$(get_google_token) || { echo '{"error":"no_token"}'; return; }
    local GA4_PROPERTY="properties/256952992"
    
    curl -s "https://analyticsdata.googleapis.com/v1beta/$GA4_PROPERTY:runReport" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "{
            \"dateRanges\": [{\"startDate\": \"7daysAgo\", \"endDate\": \"today\"}],
            \"dimensions\": [{\"name\": \"sessionDefaultChannelGroup\"}],
            \"metrics\": [
                {\"name\": \"sessions\"},
                {\"name\": \"activeUsers\"},
                {\"name\": \"engagedSessions\"}
            ],
            \"orderBys\": [{\"metric\": {\"metricName\": \"sessions\"}, \"desc\": true}],
            \"limit\": 10
        }" 2>/dev/null
}

# ── 3. Google Analytics — Geographic ──
collect_ga4_geo() {
    local token
    token=$(get_google_token) || { echo '{"error":"no_token"}'; return; }
    local GA4_PROPERTY="properties/256952992"
    
    curl -s "https://analyticsdata.googleapis.com/v1beta/$GA4_PROPERTY:runReport" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "{
            \"dateRanges\": [{\"startDate\": \"7daysAgo\", \"endDate\": \"today\"}],
            \"dimensions\": [{\"name\": \"country\"}],
            \"metrics\": [{\"name\": \"activeUsers\"}, {\"name\": \"sessions\"}],
            \"orderBys\": [{\"metric\": {\"metricName\": \"activeUsers\"}, \"desc\": true}],
            \"limit\": 10
        }" 2>/dev/null
}

# ── 4. Google Search Console ──
collect_search_console() {
    echo "  🔍 Search Console..." >&2
    local token
    token=$(get_google_token) || { echo '{"error":"no_token"}'; return; }
    
    # Xdares blog
    curl -s "https://www.googleapis.com/webmasters/v3/sites/sc-domain%3Axdares.com/searchAnalytics/query" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "{
            \"startDate\": \"$WEEK_AGO\",
            \"endDate\": \"$TODAY\",
            \"dimensions\": [\"query\"],
            \"rowLimit\": 20
        }" 2>/dev/null
}

collect_search_console_pages() {
    local token
    token=$(get_google_token) || { echo '{"error":"no_token"}'; return; }
    
    curl -s "https://www.googleapis.com/webmasters/v3/sites/sc-domain%3Axdares.com/searchAnalytics/query" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "{
            \"startDate\": \"$WEEK_AGO\",
            \"endDate\": \"$TODAY\",
            \"dimensions\": [\"page\"],
            \"rowLimit\": 20
        }" 2>/dev/null
}

# ── 5. PostHog (permissionprotocol.com — tracking here too for cross-reference) ──
collect_posthog() {
    echo "  📊 PostHog..." >&2
    if [ ! -f "$POSTHOG_KEY_FILE" ]; then
        echo '{"error":"no_posthog_key"}'
        return
    fi
    local key
    key=$(cat "$POSTHOG_KEY_FILE")
    
    curl -s "https://us.posthog.com/api/projects/318328/insights/trend/" \
        -H "Authorization: Bearer $key" \
        -H "Content-Type: application/json" \
        -d "{
            \"events\": [{\"id\": \"\$pageview\", \"type\": \"events\"}],
            \"date_from\": \"-7d\",
            \"interval\": \"day\"
        }" 2>/dev/null
}

# ── 6. Kickofflabs (scrape via API if available, otherwise skip) ──
collect_kickofflabs() {
    echo "  📋 Kickofflabs..." >&2
    # Kickofflabs doesn't have a public API — we'll track manually or via browser
    # For now, output last known values from baseline
    echo '{"note":"manual_tracking","active_waitlist":216,"historical_waitlist":19509,"total":19725}'
}

# ── Collect all and assemble ──
TMP_DIR=$(mktemp -d)
echo "Collecting..."
collect_ga4 > "$TMP_DIR/ga4.json"
collect_ga4_sources > "$TMP_DIR/ga4_sources.json"
collect_ga4_geo > "$TMP_DIR/ga4_geo.json"
collect_search_console > "$TMP_DIR/sc_queries.json"
collect_search_console_pages > "$TMP_DIR/sc_pages.json"
collect_posthog > "$TMP_DIR/posthog.json"
collect_kickofflabs > "$TMP_DIR/kickoff.json"

# ── Parse into structured metrics ──
export TMP_DIR
python3 << 'PYEOF'
import json, sys, os
from datetime import datetime

metrics_dir = os.path.expanduser("~/.openclaw/workspace/goals/xdares-seo-growth/metrics")
metrics_file = os.path.join(metrics_dir, "latest.json")
history_file = os.path.join(metrics_dir, "history.jsonl")
tmp_dir = os.environ["TMP_DIR"]

def safe_json_file(path):
    try:
        with open(path) as f:
            return json.load(f)
    except:
        try:
            with open(path) as f:
                raw = f.read()
            return {"error": "parse_failed", "raw": raw[:200]}
        except:
            return {"error": "file_not_found"}

ga4 = safe_json_file(f"{tmp_dir}/ga4.json")
ga4_sources = safe_json_file(f"{tmp_dir}/ga4_sources.json")
ga4_geo = safe_json_file(f"{tmp_dir}/ga4_geo.json")
sc_queries = safe_json_file(f"{tmp_dir}/sc_queries.json")
sc_pages = safe_json_file(f"{tmp_dir}/sc_pages.json")
posthog = safe_json_file(f"{tmp_dir}/posthog.json")
kickoff = safe_json_file(f"{tmp_dir}/kickoff.json")

# Parse GA4 overview (two date ranges: this week vs last week)
def parse_ga4_overview(data):
    if "error" in data or "rows" not in data:
        return {"error": data.get("error", "no_rows")}
    rows = data.get("rows", [])
    if not rows:
        return {"error": "no_data"}
    
    this_week = {}
    last_week = {}
    metrics = ["activeUsers", "sessions", "engagedSessions", "avgSessionDuration", "newUsers", "pageViews"]
    
    for row in rows:
        vals = [v.get("value", "0") for v in row.get("metricValues", [])]
        range_idx = row.get("dimensionValues", [{}])[0].get("value", "date_range_0") if row.get("dimensionValues") else "0"
        # Two date ranges come as separate rows
        target = this_week  # Will be overwritten by proper parsing
        for i, m in enumerate(metrics):
            if i < len(vals):
                try:
                    target[m] = float(vals[i])
                except:
                    target[m] = vals[i]
    
    # Simpler: just grab totals from rows
    result = {}
    if rows:
        for i, m in enumerate(metrics):
            vals0 = rows[0].get("metricValues", [])
            if i < len(vals0):
                try:
                    result[f"{m}_thisWeek"] = float(vals0[i].get("value", "0"))
                except:
                    result[f"{m}_thisWeek"] = vals0[i].get("value", "0")
            if len(rows) > 1:
                vals1 = rows[1].get("metricValues", [])
                if i < len(vals1):
                    try:
                        result[f"{m}_lastWeek"] = float(vals1[i].get("value", "0"))
                    except:
                        result[f"{m}_lastWeek"] = vals1[i].get("value", "0")
    return result

# Parse dimension reports (sources, geo)
def parse_dimension_report(data, dim_name):
    if "error" in data or "rows" not in data:
        return []
    result = []
    for row in data.get("rows", []):
        dims = row.get("dimensionValues", [])
        vals = row.get("metricValues", [])
        entry = {dim_name: dims[0].get("value", "") if dims else ""}
        metric_names = ["sessions", "activeUsers", "engagedSessions"]
        for i, v in enumerate(vals):
            if i < len(metric_names):
                try:
                    entry[metric_names[i]] = int(v.get("value", "0"))
                except:
                    entry[metric_names[i]] = v.get("value", "0")
        result.append(entry)
    return result

# Parse Search Console
def parse_sc(data):
    if "error" in data or "rows" not in data:
        return {"error": data.get("error", "no_rows"), "total": {}}
    rows = data.get("rows", [])
    total_clicks = sum(r.get("clicks", 0) for r in rows)
    total_impressions = sum(r.get("impressions", 0) for r in rows)
    top = []
    for r in rows[:10]:
        keys = r.get("keys", [""])
        top.append({
            "key": keys[0] if keys else "",
            "clicks": r.get("clicks", 0),
            "impressions": r.get("impressions", 0),
            "ctr": round(r.get("ctr", 0) * 100, 1),
            "position": round(r.get("position", 0), 1),
        })
    return {"totalClicks": total_clicks, "totalImpressions": total_impressions, "top": top}

output = {
    "date": datetime.utcnow().strftime("%Y-%m-%d"),
    "timestamp": datetime.utcnow().isoformat() + "Z",
    "ga4": {
        "overview": parse_ga4_overview(ga4),
        "sources": parse_dimension_report(ga4_sources, "channel"),
        "geo": parse_dimension_report(ga4_geo, "country"),
    },
    "searchConsole": {
        "queries": parse_sc(sc_queries),
        "pages": parse_sc(sc_pages),
    },
    "posthog": posthog if "error" not in posthog else {"error": posthog.get("error")},
    "kickofflabs": kickoff,
}

# Write latest
with open(metrics_file, "w") as f:
    json.dump(output, f, indent=2)

# Append to history
with open(history_file, "a") as f:
    f.write(json.dumps({"date": output["date"], "ga4_overview": output["ga4"]["overview"], 
                         "sc_clicks": output["searchConsole"]["queries"].get("totalClicks", 0),
                         "sc_impressions": output["searchConsole"]["queries"].get("totalImpressions", 0)}) + "\n")

print(f"✅ Metrics written to {metrics_file}")
print(f"📈 GA4: {json.dumps(output['ga4']['overview'], indent=None)[:200]}")
print(f"🔍 SC: {output['searchConsole']['queries'].get('totalClicks', '?')} clicks, {output['searchConsole']['queries'].get('totalImpressions', '?')} impressions")
print(f"📋 Kickofflabs: {output['kickofflabs'].get('total', '?')} total leads")
PYEOF
