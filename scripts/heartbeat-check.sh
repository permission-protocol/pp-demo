#!/bin/bash
# Deterministic heartbeat check — outputs JSON status.
# If "clear" → heartbeat can reply HEARTBEAT_OK without reasoning.
# If "attention" → LLM interprets and acts.

set -uo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
ALERTS='[]'
WARNINGS='[]'
CRON_ERROR_COUNT=0
GW_PIDS=0
DISK_USAGE=0

# ─── 1. Cron Health ───
# Use grep -v to strip [plugins] lines before parsing JSON
CRON_ERRORS=$(openclaw cron list --json --all 2>/dev/null | grep -v "^\[plugins\]" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    print('[]')
    sys.exit(0)
errors = []
for j in data.get('jobs', []):
    if not j.get('enabled', True):
        continue
    state = j.get('state', {})
    errs = state.get('consecutiveErrors', 0)
    if errs > 0:
        # Sanitize error message to ASCII only
        last = state.get('lastError','')[:100]
        last = last.encode('ascii', 'replace').decode('ascii')
        errors.append({'name': j['name'], 'errors': errs, 'last': last})
print(json.dumps(errors, ensure_ascii=True))
" 2>/dev/null || echo "[]")
CRON_ERROR_COUNT=$(echo "$CRON_ERRORS" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")

# ─── 2. JSON Status Data (Multi-check) ───
STATUS_JSON=$(openclaw status --json 2>/dev/null | grep -v "^\[plugins\]")

# ─── 3. Gateway Process Health ───
GW_PIDS=$(ps axo comm | grep -c "openclaw-gateway" 2>/dev/null || echo 0)

# ─── 4. Cooldown Check ───
COOLDOWN_STATUS="ok"
AUTH_PROFILES="$HOME/.openclaw/agents/main/agent/auth-profiles.json"
if [ -f "$AUTH_PROFILES" ]; then
    COOLDOWN_STATUS=$(python3 -c "
import json, datetime
with open('$AUTH_PROFILES') as f:
    d = json.load(f)
for profile in d.get('profiles', d if isinstance(d, list) else []):
    stats = profile.get('usageStats', {})
    disabled = stats.get('disabledUntil')
    if disabled:
        try:
            dt = datetime.datetime.fromtimestamp(disabled/1000, datetime.timezone.utc)
            if dt > datetime.datetime.now(datetime.timezone.utc):
                print(f'cooldown until {dt.strftime(\"%H:%M UTC\")}')
                exit()
        except: pass
print('ok')
" 2>/dev/null || echo "unknown")
fi

# ─── 5. Disk Space ───
DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | tr -d '%')

# ─── Build alerts/warnings ───
export CRON_ERRORS
export STATUS_JSON
python3 << PYEOF
import json
import os

alerts = []
warnings = []

# Cron errors
cron_errors_raw = os.environ.get('CRON_ERRORS', '[]')
try:
    cron_errors = json.loads(cron_errors_raw)
    for e in cron_errors:
        if e['errors'] >= 3:
            alerts.append(f"cron:{e['name']} - {e['errors']} consecutive errors: {e['last']}")
        else:
            warnings.append(f"cron:{e['name']} - {e['errors']} error(s): {e['last']}")
except Exception as e:
    cron_errors = []
    alerts.append(f"heartbeat_script_error: failed to parse cron errors: {e}")

# JSON Status checks
status_raw = os.environ.get('STATUS_JSON', '{}')
try:
    status_data = json.loads(status_raw)
    
    # Model
    model = status_data.get('sessions', {}).get('defaults', {}).get('model', 'unknown')
    if 'gemini-3.1-pro-preview' not in model:
        warnings.append(f"model_check: unexpected default model '{model}' (expected gemini-3.1-pro-preview)")
    
    # Memory
    mem_plugin = status_data.get('memoryPlugin', {})
    if not mem_plugin.get('enabled') or mem_plugin.get('slot') not in ['memory-lancedb', 'memory-core']:
        alerts.append(f"memory_offline: plugin {mem_plugin.get('slot')} not ready")
        
except Exception as e:
    alerts.append(f"heartbeat_script_error: failed to parse status JSON: {e}")

# Gateway
gw = $GW_PIDS
if gw == 0:
    alerts.append("gateway_down: no openclaw-gateway process")
elif gw > 1:
    alerts.append(f"gateway_rogue: {gw} processes (expect 1)")

# Cooldown
cooldown = "$COOLDOWN_STATUS"
if cooldown != "ok" and cooldown != "unknown":
    alerts.append(f"api_cooldown: {cooldown}")

# Disk
disk = $DISK_USAGE
if disk > 90:
    alerts.append(f"disk_critical: {disk}% used")
elif disk > 80:
    warnings.append(f"disk_warning: {disk}% used")

status = "attention" if alerts else ("watch" if warnings else "clear")

print(json.dumps({
    "status": status,
    "alerts": alerts,
    "warnings": warnings,
    "cron_errors": len(cron_errors),
    "gateway_processes": gw,
    "disk_usage_pct": disk,
    "cooldown": cooldown
}, indent=2))
PYEOF
