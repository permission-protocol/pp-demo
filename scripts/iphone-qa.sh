#!/bin/bash
# iphone-qa.sh — Autonomous mobile QA via Safari WebDriver on iPhone
# Usage:
#   ./scripts/iphone-qa.sh navigate <url>
#   ./scripts/iphone-qa.sh screenshot [output_path]
#   ./scripts/iphone-qa.sh scroll [pixels]
#   ./scripts/iphone-qa.sh info
#   ./scripts/iphone-qa.sh elements [css_selector]
#   ./scripts/iphone-qa.sh click <css_selector>
#   ./scripts/iphone-qa.sh type <css_selector> <text>
#   ./scripts/iphone-qa.sh js <javascript>
#   ./scripts/iphone-qa.sh audit <url> [output_dir]
#   ./scripts/iphone-qa.sh session-start
#   ./scripts/iphone-qa.sh session-stop

set -euo pipefail

WD_PORT="${WD_PORT:-4444}"
WD_URL="http://localhost:${WD_PORT}"
SESSION_FILE="/tmp/safari-session-id.txt"
DEFAULT_SCREENSHOT_DIR="/Users/moltbot/.openclaw/workspace/tmp"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[iphone-qa]${NC} $*"; }
warn() { echo -e "${YELLOW}[iphone-qa]${NC} $*"; }
err()  { echo -e "${RED}[iphone-qa]${NC} $*" >&2; }

# ── WebDriver helper ──────────────────────────────────────────────
wd_request() {
    local method="$1" path="$2" data="${3:-}"
    local url="${WD_URL}${path}"
    
    if [ -n "$data" ]; then
        curl -sf -X "$method" "$url" \
            -H "Content-Type: application/json" \
            -d "$data" 2>/dev/null
    else
        curl -sf -X "$method" "$url" 2>/dev/null
    fi
}

get_session() {
    if [ ! -f "$SESSION_FILE" ]; then
        err "No active session. Run: iphone-qa.sh session-start"
        exit 1
    fi
    cat "$SESSION_FILE"
}

ensure_safaridriver() {
    if ! curl -sf "${WD_URL}/status" >/dev/null 2>&1; then
        log "Starting safaridriver on port ${WD_PORT}..."
        pkill safaridriver 2>/dev/null || true
        sleep 1
        safaridriver -p "$WD_PORT" &
        sleep 3
        if ! curl -sf "${WD_URL}/status" >/dev/null 2>&1; then
            err "safaridriver failed to start"
            exit 1
        fi
    fi
}

# ── Commands ──────────────────────────────────────────────────────

cmd_session_start() {
    ensure_safaridriver
    log "Creating iOS Safari session..."
    
    local result
    result=$(wd_request POST "/session" '{"capabilities":{"alwaysMatch":{"browserName":"safari","platformName":"ios"}}}')
    
    if [ -z "$result" ]; then
        err "Session creation failed. Is iPhone connected via USB, unlocked, and Remote Automation enabled?"
        exit 1
    fi
    
    local sid
    sid=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin)['value']['sessionId'])" 2>/dev/null)
    
    if [ -z "$sid" ]; then
        err "Failed to parse session ID from: $result"
        exit 1
    fi
    
    echo "$sid" > "$SESSION_FILE"
    log "✅ Session: ${sid}"
    
    # Get device info
    local dims
    dims=$(wd_request POST "/session/${sid}/execute/sync" \
        '{"script":"return {innerWidth:window.innerWidth,innerHeight:window.innerHeight,dpr:window.devicePixelRatio,ua:navigator.userAgent}","args":[]}')
    
    if [ -n "$dims" ]; then
        echo "$dims" | python3 -c "
import sys, json
d = json.load(sys.stdin)['value']
print(f\"   📐 Viewport: {d.get('innerWidth','?')}x{d.get('innerHeight','?')}, DPR: {d.get('dpr','?')}\")
ua = d.get('ua','')
if 'iPhone' in ua:
    import re
    m = re.search(r'iPhone OS (\d+_\d+)', ua)
    print(f\"   📱 iOS {m.group(1).replace('_','.') if m else '?'}\")
" 2>/dev/null || true
    fi
}

cmd_session_stop() {
    local sid
    sid=$(get_session)
    wd_request DELETE "/session/${sid}" || true
    rm -f "$SESSION_FILE"
    log "Session closed"
}

cmd_navigate() {
    local url="$1"
    local sid=$(get_session)
    
    # Add https if no protocol
    [[ "$url" =~ ^https?:// ]] || url="https://${url}"
    
    log "Navigating to ${url}..."
    wd_request POST "/session/${sid}/url" "{\"url\":\"${url}\"}"
    sleep 3
    
    local title
    title=$(wd_request GET "/session/${sid}/title" | python3 -c "import sys,json; print(json.load(sys.stdin)['value'])" 2>/dev/null)
    log "📄 Title: ${title}"
}

cmd_screenshot() {
    local sid=$(get_session)
    local output="${1:-${DEFAULT_SCREENSHOT_DIR}/iphone-screenshot-$(date +%s).png}"
    
    # Ensure directory exists
    mkdir -p "$(dirname "$output")"
    
    wd_request GET "/session/${sid}/screenshot" | \
        python3 -c "
import sys, json, base64
data = json.load(sys.stdin)['value']
img = base64.b64decode(data)
with open('${output}', 'wb') as f:
    f.write(img)
print(f'📸 {len(img)} bytes → ${output}')
"
}

cmd_scroll() {
    local sid=$(get_session)
    local pixels="${1:-500}"
    
    wd_request POST "/session/${sid}/execute/sync" \
        "{\"script\":\"window.scrollBy(0,${pixels}); return {scrollY: window.scrollY, maxScroll: document.body.scrollHeight - window.innerHeight}\",\"args\":[]}" | \
        python3 -c "
import sys, json
d = json.load(sys.stdin)['value']
print(f\"Scrolled to {d['scrollY']}px / {d['maxScroll']}px\")
" 2>/dev/null
}

cmd_info() {
    local sid=$(get_session)
    
    local url title dims
    url=$(wd_request GET "/session/${sid}/url" | python3 -c "import sys,json; print(json.load(sys.stdin)['value'])" 2>/dev/null)
    title=$(wd_request GET "/session/${sid}/title" | python3 -c "import sys,json; print(json.load(sys.stdin)['value'])" 2>/dev/null)
    
    dims=$(wd_request POST "/session/${sid}/execute/sync" \
        '{"script":"return {innerWidth:window.innerWidth,innerHeight:window.innerHeight,scrollHeight:document.body.scrollHeight,scrollY:window.scrollY,dpr:window.devicePixelRatio}","args":[]}')
    
    echo -e "${CYAN}URL:${NC} ${url}"
    echo -e "${CYAN}Title:${NC} ${title}"
    echo "$dims" | python3 -c "
import sys, json
d = json.load(sys.stdin)['value']
print(f\"Viewport: {d['innerWidth']}x{d['innerHeight']}\")
print(f\"DPR: {d['dpr']}\")
print(f\"Page height: {d['scrollHeight']}px\")
print(f\"Scroll position: {d['scrollY']}px\")
" 2>/dev/null
}

cmd_elements() {
    local sid=$(get_session)
    local selector="${1:-a,button,h1,h2,h3,input,nav}"
    
    wd_request POST "/session/${sid}/execute/sync" "{
        \"script\": \"var els = document.querySelectorAll(arguments[0]); return Array.from(els).slice(0,50).map(function(e){return {tag:e.tagName,text:(e.textContent||'').trim().substring(0,80),href:e.href||'',type:e.type||'',id:e.id||'',classes:e.className.toString().substring(0,40)}})\",
        \"args\": [\"${selector}\"]
    }" | python3 -c "
import sys, json
els = json.load(sys.stdin)['value']
for i, e in enumerate(els):
    text = e['text'].replace('\n',' ').strip()[:60]
    extra = e.get('href','') or e.get('type','')
    print(f\"  [{i}] <{e['tag'].lower()}> \\\"{text}\\\" {extra[:50]}\")
print(f\"\n  Total: {len(els)} elements\")
" 2>/dev/null
}

cmd_click() {
    local sid=$(get_session)
    local selector="$1"
    
    local el
    el=$(wd_request POST "/session/${sid}/element" "{\"using\":\"css selector\",\"value\":\"${selector}\"}")
    local el_id
    el_id=$(echo "$el" | python3 -c "import sys,json; d=json.load(sys.stdin)['value']; print(d.get('element-6066-11e4-a52e-4f735466cecf') or d.get('ELEMENT'))" 2>/dev/null)
    
    if [ -z "$el_id" ]; then
        err "Element not found: ${selector}"
        exit 1
    fi
    
    wd_request POST "/session/${sid}/element/${el_id}/click" '{}' >/dev/null
    log "✅ Clicked: ${selector}"
    sleep 1
}

cmd_type() {
    local sid=$(get_session)
    local selector="$1"
    local text="$2"
    
    local el
    el=$(wd_request POST "/session/${sid}/element" "{\"using\":\"css selector\",\"value\":\"${selector}\"}")
    local el_id
    el_id=$(echo "$el" | python3 -c "import sys,json; d=json.load(sys.stdin)['value']; print(d.get('element-6066-11e4-a52e-4f735466cecf') or d.get('ELEMENT'))" 2>/dev/null)
    
    if [ -z "$el_id" ]; then
        err "Element not found: ${selector}"
        exit 1
    fi
    
    # Clear existing text
    wd_request POST "/session/${sid}/element/${el_id}/clear" '{}' >/dev/null 2>&1 || true
    
    # Type text
    wd_request POST "/session/${sid}/element/${el_id}/value" "{\"text\":\"${text}\"}" >/dev/null
    log "✅ Typed into: ${selector}"
}

cmd_js() {
    local sid=$(get_session)
    local script="$1"
    
    wd_request POST "/session/${sid}/execute/sync" \
        "{\"script\":\"return ${script}\",\"args\":[]}" | \
        python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin)['value'], indent=2))" 2>/dev/null
}

cmd_audit() {
    local url="$1"
    local output_dir="${2:-${DEFAULT_SCREENSHOT_DIR}/audit-$(date +%Y%m%d-%H%M%S)}"
    local sid
    
    mkdir -p "$output_dir"
    log "🔍 Starting mobile audit of ${url}"
    log "   Output: ${output_dir}"
    
    # Check if session exists, create if not
    if [ ! -f "$SESSION_FILE" ] || ! wd_request GET "/session/$(cat "$SESSION_FILE" 2>/dev/null)/url" >/dev/null 2>&1; then
        cmd_session_start
    fi
    sid=$(get_session)
    
    # Navigate
    [[ "$url" =~ ^https?:// ]] || url="https://${url}"
    log "1. Navigating..."
    wd_request POST "/session/${sid}/url" "{\"url\":\"${url}\"}" >/dev/null
    sleep 5
    
    # Collect page info
    log "2. Collecting page data..."
    local page_data
    page_data=$(wd_request POST "/session/${sid}/execute/sync" '{
        "script": "return {url:location.href, title:document.title, w:window.innerWidth, h:window.innerHeight, sh:document.body.scrollHeight, dpr:window.devicePixelRatio, links:document.querySelectorAll(\"a\").length, buttons:document.querySelectorAll(\"button\").length, images:document.querySelectorAll(\"img\").length, inputs:document.querySelectorAll(\"input,textarea,select\").length, h1:Array.from(document.querySelectorAll(\"h1\")).map(function(e){return e.textContent.trim()}).join(\" | \"), meta_desc:(document.querySelector(\"meta[name=description]\") || {}).content || \"\", meta_viewport:(document.querySelector(\"meta[name=viewport]\") || {}).content || \"\"}",
        "args": []
    }')
    echo "$page_data" | python3 -c "import sys,json; json.dump(json.load(sys.stdin)['value'], open('${output_dir}/page-info.json','w'), indent=2)"
    
    # Screenshot: top of page
    log "3. Screenshots..."
    wd_request POST "/session/${sid}/execute/sync" '{"script":"window.scrollTo(0,0)","args":[]}' >/dev/null
    sleep 1
    cmd_screenshot "${output_dir}/01-top.png"
    
    # Get scroll height for full-page screenshots
    local scroll_height viewport_height
    scroll_height=$(echo "$page_data" | python3 -c "import sys,json; print(json.load(sys.stdin)['value']['sh'])" 2>/dev/null)
    viewport_height=$(echo "$page_data" | python3 -c "import sys,json; print(json.load(sys.stdin)['value']['h'])" 2>/dev/null)
    
    # Scroll through the page in viewport-sized chunks
    local scroll_pos=0
    local screen_num=2
    while [ "$scroll_pos" -lt "$scroll_height" ] && [ "$screen_num" -le 12 ]; do
        scroll_pos=$((scroll_pos + viewport_height))
        wd_request POST "/session/${sid}/execute/sync" "{\"script\":\"window.scrollTo(0,${scroll_pos})\",\"args\":[]}" >/dev/null
        sleep 1
        local padded
        padded=$(printf "%02d" "$screen_num")
        cmd_screenshot "${output_dir}/${padded}-scroll-${scroll_pos}px.png"
        screen_num=$((screen_num + 1))
    done
    
    # Collect accessibility data
    log "4. Accessibility check..."
    wd_request POST "/session/${sid}/execute/sync" '{
        "script": "var issues=[]; document.querySelectorAll(\"img\").forEach(function(img){if(!img.alt)issues.push({type:\"missing-alt\",src:img.src.substring(0,80)})}); document.querySelectorAll(\"a,button\").forEach(function(el){var r=el.getBoundingClientRect(); if(r.width<44||r.height<44)issues.push({type:\"small-tap-target\",tag:el.tagName,text:(el.textContent||\"\").trim().substring(0,40),size:Math.round(r.width)+\"x\"+Math.round(r.height)})}); var contrast=[]; document.querySelectorAll(\"p,span,a,li,h1,h2,h3,h4,h5,h6\").forEach(function(el){var s=getComputedStyle(el); if(parseFloat(s.fontSize)<12)contrast.push({type:\"small-text\",tag:el.tagName,text:(el.textContent||\"\").trim().substring(0,30),fontSize:s.fontSize})}); return {tapTargetIssues:issues.filter(function(i){return i.type===\"small-tap-target\"}).length, missingAlt:issues.filter(function(i){return i.type===\"missing-alt\"}).length, smallText:contrast.length, details:issues.concat(contrast).slice(0,30)}",
        "args": []
    }' | python3 -c "import sys,json; json.dump(json.load(sys.stdin)['value'], open('${output_dir}/accessibility.json','w'), indent=2)" 2>/dev/null
    
    # Collect performance metrics
    log "5. Performance metrics..."
    wd_request POST "/session/${sid}/execute/sync" '{
        "script": "var p=performance.getEntriesByType(\"navigation\")[0]||{}; return {domContentLoaded:Math.round(p.domContentLoadedEventEnd-p.startTime), load:Math.round(p.loadEventEnd-p.startTime), domInteractive:Math.round(p.domInteractive-p.startTime), transferSize:p.transferSize, resources:performance.getEntriesByType(\"resource\").length}",
        "args": []
    }' | python3 -c "import sys,json; json.dump(json.load(sys.stdin)['value'], open('${output_dir}/performance.json','w'), indent=2)" 2>/dev/null
    
    # Summary
    log ""
    log "✅ Audit complete!"
    log "   📁 ${output_dir}/"
    ls -la "$output_dir"/ | grep -v total | awk '{print "      " $NF " (" $5 " bytes)"}'
    
    echo ""
    echo "Page info:"
    python3 -c "
import json
d = json.load(open('${output_dir}/page-info.json'))
print(f\"  URL: {d['url']}\")
print(f\"  Title: {d['title']}\")
print(f\"  Viewport: {d['w']}x{d['h']} @ {d['dpr']}x\")
print(f\"  Page height: {d['sh']}px ({d['sh']//d['h']} screens)\")
print(f\"  Elements: {d['links']} links, {d['buttons']} buttons, {d['images']} images, {d['inputs']} inputs\")
print(f\"  H1: {d['h1']}\")
if d.get('meta_viewport'): print(f\"  Viewport meta: {d['meta_viewport']}\")
" 2>/dev/null
    
    echo ""
    echo "Accessibility:"
    python3 -c "
import json
d = json.load(open('${output_dir}/accessibility.json'))
print(f\"  Small tap targets (<44px): {d['tapTargetIssues']}\")
print(f\"  Missing alt text: {d['missingAlt']}\")
print(f\"  Small text (<12px): {d['smallText']}\")
if d.get('details'):
    for issue in d['details'][:10]:
        if issue['type'] == 'small-tap-target':
            print(f\"    ⚠️  {issue['tag'].lower()} \\\"{issue.get('text','')}\\\" — {issue['size']}\")
        elif issue['type'] == 'missing-alt':
            print(f\"    ⚠️  img missing alt: {issue['src']}\")
        elif issue['type'] == 'small-text':
            print(f\"    ⚠️  {issue['tag'].lower()} \\\"{issue.get('text','')}\\\" — {issue['fontSize']}\")
" 2>/dev/null
    
    echo ""
    echo "Performance:"
    python3 -c "
import json
d = json.load(open('${output_dir}/performance.json'))
print(f\"  DOM Content Loaded: {d.get('domContentLoaded','?')}ms\")
print(f\"  Full Load: {d.get('load','?')}ms\")
print(f\"  DOM Interactive: {d.get('domInteractive','?')}ms\")
print(f\"  Resources loaded: {d.get('resources','?')}\")
" 2>/dev/null
}

# ── Main ──────────────────────────────────────────────────────────

case "${1:-help}" in
    session-start|start)  cmd_session_start ;;
    session-stop|stop)    cmd_session_stop ;;
    navigate|nav|go)      cmd_navigate "${2:?URL required}" ;;
    screenshot|ss|snap)   cmd_screenshot "${2:-}" ;;
    scroll)               cmd_scroll "${2:-500}" ;;
    info)                 cmd_info ;;
    elements|els)         cmd_elements "${2:-a,button,h1,h2,h3,input,nav}" ;;
    click)                cmd_click "${2:?CSS selector required}" ;;
    type)                 cmd_type "${2:?CSS selector required}" "${3:?Text required}" ;;
    js)                   cmd_js "${2:?JavaScript required}" ;;
    audit)                cmd_audit "${2:?URL required}" "${3:-}" ;;
    help|--help|-h)
        echo "iphone-qa.sh — Mobile QA via Safari WebDriver"
        echo ""
        echo "Commands:"
        echo "  start                    Start WebDriver session"
        echo "  stop                     End session"
        echo "  nav <url>                Navigate to URL"
        echo "  ss [path]                Take screenshot"
        echo "  scroll [px]              Scroll down (default: 500px)"
        echo "  info                     Current page info"
        echo "  els [selector]           List elements"
        echo "  click <selector>         Click element"
        echo "  type <selector> <text>   Type into element"
        echo "  js <code>                Execute JavaScript"
        echo "  audit <url> [dir]        Full mobile audit"
        echo ""
        echo "Environment:"
        echo "  WD_PORT=4444             WebDriver port"
        echo ""
        echo "Requirements:"
        echo "  - iPhone connected via USB data cable"
        echo "  - iPhone unlocked"
        echo "  - Safari → Advanced → Web Inspector ON"
        echo "  - Safari → Advanced → Remote Automation ON"
        echo "  - Tap 'Continue Testing' on iPhone when prompted"
        ;;
    *)
        err "Unknown command: $1"
        echo "Run: $0 help"
        exit 1
        ;;
esac
