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
CRON_ERRORS=$(openclaw cron list --json --all 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
errors = []
for j in data.get('jobs', []):
    if not j.get('enabled', True):
        continue
    errs = j.get('state', {}).get('consecutiveErrors', 0)
    if errs > 0:
        # Sanitize error message to ASCII only
        last = j.get('state',{}).get('lastError','')[:100]
        last = last.encode('ascii', 'replace').decode('ascii')
        errors.append({'name': j['name'], 'errors': errs, 'last': last})
print(json.dumps(errors, ensure_ascii=True))
" 2>/dev/null || echo "[]")
CRON_ERROR_COUNT=$(echo "$CRON_ERRORS" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")

# ─── 2. Model Health ───
MODEL_STATUS=$(openclaw status 2>/dev/null | python3 -c "
import sys
lines = sys.stdin.read()
# Look for default model in Sessions line
if 'claude-opus-4-6' in lines and 'default claude-opus-4-6' in lines:
    print('ok')
elif 'claude-opus-4-6' in lines:
    print('ok')
else:
    print('unknown')
" 2>/dev/null || echo "unknown")

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
python3 << PYEOF
import json

alerts = []
warnings = []
cron_errors = json.loads('''$CRON_ERRORS''')

# Cron errors
if len(cron_errors) > 0:
    for e in cron_errors:
        if e['errors'] >= 3:
            alerts.append(f"cron:{e['name']} - {e['errors']} consecutive errors: {e['last']}")
        else:
            warnings.append(f"cron:{e['name']} - {e['errors']} error(s): {e['last']}")

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

# Model
model = "$MODEL_STATUS"
if model == "unknown":
    warnings.append("model_check: could not confirm opus-4-6")

# Memory plugin
import subprocess
mem_check = subprocess.run(["openclaw", "status"], capture_output=True, text=True, timeout=10)
if "memory-lancedb" in mem_check.stdout:
    pass  # good
elif "memory-core" in mem_check.stdout:
    alerts.append("memory_downgraded: LanceDB replaced by memory-core — config likely wiped, see SAFETY.md §4")

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
