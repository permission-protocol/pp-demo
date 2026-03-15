#!/bin/bash
# mobile-qa-cron.sh — Daily mobile QA runner for cron jobs
# Runs audits on configured URLs, outputs structured summary
# Designed to be called by an OpenClaw cron agentTurn
#
# Usage: bash scripts/mobile-qa-cron.sh [url1] [url2] ...
# Default: permissionprotocol.com xdares.com

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
QA_SCRIPT="${SCRIPT_DIR}/iphone-qa.sh"
OUTPUT_BASE="${HOME}/.openclaw/workspace/tmp/mobile-qa-daily"
DATE=$(date +%Y%m%d)
URLS=("${@:-permissionprotocol.com xdares.com}")

# If no args, use defaults
if [ $# -eq 0 ]; then
    URLS=("permissionprotocol.com" "xdares.com")
fi

mkdir -p "$OUTPUT_BASE"

echo "═══════════════════════════════════════"
echo "📱 Daily Mobile QA — $(date '+%Y-%m-%d %H:%M %Z')"
echo "═══════════════════════════════════════"
echo ""

# Check if iPhone is connected
if ! python3 -c "from pymobiledevice3.usbmux import list_devices; devs=list_devices(); assert len(devs)>0" 2>/dev/null; then
    echo "❌ NO IPHONE CONNECTED VIA USB"
    echo "Skipping mobile QA. Connect iPhone and ensure it's unlocked."
    exit 1
fi

echo "✅ iPhone detected on USB"
echo ""

OVERALL_STATUS="pass"
SUMMARY=""

for url in "${URLS[@]}"; do
    SITE_DIR="${OUTPUT_BASE}/${DATE}-$(echo "$url" | tr '.' '-')"
    echo "───────────────────────────────────────"
    echo "🔍 Auditing: ${url}"
    echo "   Output: ${SITE_DIR}"
    echo ""
    
    if bash "$QA_SCRIPT" audit "$url" "$SITE_DIR" 2>&1; then
        # Parse results
        if [ -f "${SITE_DIR}/page-info.json" ]; then
            PAGE_INFO=$(python3 -c "
import json
d = json.load(open('${SITE_DIR}/page-info.json'))
print(f\"Title: {d['title']}\")
print(f\"Viewport: {d['w']}x{d['h']} @ {d['dpr']}x\")
print(f\"Page: {d['sh']}px ({d['sh']//d['h']} screens)\")
print(f\"Links: {d['links']}, Buttons: {d['buttons']}, Images: {d['images']}, Inputs: {d['inputs']}\")
print(f\"H1: {d['h1']}\")
" 2>/dev/null || echo "Failed to parse page info")
            echo "$PAGE_INFO"
        fi
        
        if [ -f "${SITE_DIR}/accessibility.json" ]; then
            A11Y=$(python3 -c "
import json
d = json.load(open('${SITE_DIR}/accessibility.json'))
tap = d.get('tapTargetIssues', 0)
alt = d.get('missingAlt', 0)
small = d.get('smallText', 0)
status = '⚠️' if (tap > 10 or alt > 0) else '✅'
print(f\"{status} Tap targets <44px: {tap}, Missing alt: {alt}, Small text: {small}\")
if tap > 10:
    print(f'   🔴 {tap} undersized tap targets is significant')
" 2>/dev/null || echo "Failed to parse accessibility")
            echo "$A11Y"
        fi
        
        if [ -f "${SITE_DIR}/performance.json" ]; then
            PERF=$(python3 -c "
import json
d = json.load(open('${SITE_DIR}/performance.json'))
dcl = d.get('domContentLoaded', 0)
load = d.get('load', 0)
status = '✅' if load < 3000 else '⚠️' if load < 5000 else '🔴'
print(f\"{status} DCL: {dcl}ms, Load: {load}ms, Resources: {d.get('resources', '?')}\")
" 2>/dev/null || echo "Failed to parse performance")
            echo "$PERF"
        fi
        
        # Count screenshots
        SS_COUNT=$(ls "${SITE_DIR}"/*.png 2>/dev/null | wc -l | tr -d ' ')
        echo "📸 ${SS_COUNT} screenshots captured"
        
        SUMMARY="${SUMMARY}\n✅ ${url} — audited (${SS_COUNT} screenshots)"
    else
        echo "❌ Audit failed for ${url}"
        OVERALL_STATUS="fail"
        SUMMARY="${SUMMARY}\n❌ ${url} — audit failed"
    fi
    echo ""
done

echo "═══════════════════════════════════════"
echo "📊 SUMMARY"
echo -e "$SUMMARY"
echo ""
echo "Screenshots at: ${OUTPUT_BASE}/${DATE}-*/"
echo "Status: ${OVERALL_STATUS}"
echo "═══════════════════════════════════════"

# Output paths for the cron agent to pick up
echo ""
echo "AUDIT_DIRS:"
for url in "${URLS[@]}"; do
    DIR="${OUTPUT_BASE}/${DATE}-$(echo "$url" | tr '.' '-')"
    [ -d "$DIR" ] && echo "  ${DIR}"
done
