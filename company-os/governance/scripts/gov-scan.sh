#!/bin/bash
# Governance Scanner — produces normalized gov_scan_latest.json
# Captures: all live processes, ledger state, drift, SLA, run history
# Output: company-os/governance/snapshots/gov_scan_latest.json
#         company-os/governance/snapshots/gov_scan_YYYYMMDD_HHMM.json

set -uo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
GOV_DIR="$WORKSPACE/company-os/governance"
SNAP_DIR="$GOV_DIR/snapshots"
LEDGER="$GOV_DIR/AUTONOMOUS_PROCESS_LEDGER.md"
mkdir -p "$SNAP_DIR"

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
NOW_FILE=$(date -u +%Y%m%d_%H%M)

# 1. Collect live cron state
LIVE_JSON=$(openclaw cron list --json 2>/dev/null)

# 2. Collect system processes
LAUNCHD_OPENCLAW=$(launchctl list 2>/dev/null | grep openclaw | awk '{print $3}' || true)
DOCKER_PS=$(docker ps --format '{{.Names}}|{{.Image}}|{{.Status}}|{{.Ports}}' 2>/dev/null || true)

# 3. Parse ledger + live state into normalized JSON
python3 << 'PYEOF'
import json, re, subprocess, os
from datetime import datetime, timedelta

workspace = os.environ.get("HOME", "") + "/.openclaw/workspace"
gov_dir = workspace + "/company-os/governance"
snap_dir = gov_dir + "/snapshots"
ledger_path = gov_dir + "/AUTONOMOUS_PROCESS_LEDGER.md"

now = datetime.utcnow()
now_iso = now.strftime("%Y-%m-%dT%H:%M:%SZ")

# Parse live crons
try:
    raw = subprocess.run(["openclaw", "cron", "list", "--json"], capture_output=True, text=True, timeout=10)
    live_data = json.loads(raw.stdout)
    live_jobs = live_data.get("jobs", live_data) if isinstance(live_data, dict) else live_data
except:
    live_jobs = []

# Build live job map
live_map = {}
for j in live_jobs:
    live_map[j["name"]] = {
        "id": j["id"],
        "name": j["name"],
        "enabled": j.get("enabled", True),
        "schedule": j.get("schedule", {}),
        "model": j.get("payload", {}).get("model", "default"),
        "timeout_seconds": j.get("payload", {}).get("timeoutSeconds"),
        "delivery": j.get("delivery", {}).get("mode", "none"),
        "session_target": j.get("sessionTarget", "unknown"),
        "state": j.get("state", {}),
    }

# Parse ledger index table
ledger_entries = {}
try:
    with open(ledger_path) as f:
        for line in f:
            line = line.strip()
            if not re.match(r'^\| (PP|XD|SYS|GOV)-', line):
                continue
            cols = [c.strip() for c in line.split("|")[1:-1]]
            if len(cols) >= 9:
                entry = {
                    "ledger_id": cols[0],
                    "name": cols[1],
                    "authority": cols[2],
                    "human_gate": cols[3],
                    "risk": cols[4],
                    "runs_on": cols[5],
                    "schedule": cols[6],
                    "status": cols[7],
                    "last_reviewed": cols[8],
                }
                ledger_entries[cols[1]] = entry
except:
    pass

# Parse system processes
launchd_services = []
try:
    result = subprocess.run(["launchctl", "list"], capture_output=True, text=True, timeout=5)
    for line in result.stdout.strip().split("\n"):
        if "openclaw" in line.lower():
            parts = line.split()
            launchd_services.append({
                "pid": parts[0] if parts[0] != "-" else None,
                "exit_code": parts[1],
                "label": parts[2],
            })
except:
    pass

docker_containers = []
try:
    result = subprocess.run(["docker", "ps", "--format", "{{.Names}}|{{.Image}}|{{.Status}}|{{.Ports}}"],
                          capture_output=True, text=True, timeout=5)
    for line in result.stdout.strip().split("\n"):
        if line:
            parts = line.split("|")
            docker_containers.append({
                "name": parts[0],
                "image": parts[1] if len(parts) > 1 else "",
                "status": parts[2] if len(parts) > 2 else "",
                "ports": parts[3] if len(parts) > 3 else "",
            })
except:
    pass

# Build normalized process list
processes = []
all_names = set(list(live_map.keys()) + list(ledger_entries.keys()))

# Add infrastructure processes from ledger that aren't crons
infra_names = {k for k, v in ledger_entries.items() if v.get("runs_on", "").startswith("Mac/Launch") or v.get("runs_on", "").startswith("Mac/Docker")}

for name in sorted(all_names - infra_names):
    live = live_map.get(name)
    ledger = ledger_entries.get(name)
    
    # Determine status
    if live and not ledger:
        status = "shadow"
        drift = "shadow_process"
    elif ledger and not live:
        if "disabled" in ledger.get("status", "").lower():
            status = "disabled"
            drift = None
        else:
            status = "missing"
            drift = "ledger_only"
    elif live and ledger:
        status = "ok" if live.get("enabled") else "disabled"
        # Check for schedule drift
        live_schedule = live.get("schedule", {}).get("expr", "")
        ledger_schedule = ledger.get("schedule", "")
        if live_schedule and ledger_schedule and live_schedule not in ledger_schedule:
            drift = "schedule_mismatch"
        elif "disabled" in ledger.get("status", "").lower() and live.get("enabled"):
            drift = "disabled_but_running"
        else:
            drift = None
    else:
        status = "unknown"
        drift = None
    
    # SLA calculation
    sla_days_left = None
    if ledger and ledger.get("last_reviewed"):
        try:
            reviewed = datetime.strptime(ledger["last_reviewed"].strip(), "%Y-%m-%d")
            days_since = (now - reviewed).days
            sla_days_left = 30 - days_since
        except:
            pass
    
    # Compute next run
    next_run = None
    last_run = None
    if live:
        state = live.get("state", {})
        if state.get("nextRunAtMs"):
            next_run = datetime.utcfromtimestamp(state["nextRunAtMs"] / 1000).strftime("%Y-%m-%dT%H:%M:%SZ")
        if state.get("lastRunAtMs"):
            last_run = datetime.utcfromtimestamp(state["lastRunAtMs"] / 1000).strftime("%Y-%m-%dT%H:%M:%SZ")
    
    process = {
        "name": name,
        "ledger_id": ledger["ledger_id"] if ledger else None,
        "host": "mac",
        "runtime": "openclaw-cron",
        "authority": ledger["authority"] if ledger else "UNKNOWN",
        "human_gate": ledger["human_gate"] if ledger else "UNKNOWN",
        "risk": ledger["risk"] if ledger else "UNKNOWN",
        "status": status,
        "drift": drift,
        "enabled": live.get("enabled") if live else None,
        "schedule_live": live.get("schedule", {}).get("expr") if live else None,
        "schedule_tz": live.get("schedule", {}).get("tz") if live else None,
        "schedule_ledger": ledger.get("schedule") if ledger else None,
        "model": live.get("model") if live else None,
        "timeout_seconds": live.get("timeout_seconds") if live else None,
        "session_target": live.get("session_target") if live else None,
        "next_run": next_run,
        "last_run": last_run,
        "sla_days_left": sla_days_left,
        "last_reviewed": ledger.get("last_reviewed") if ledger else None,
        "cron_id": live.get("id") if live else None,
    }
    processes.append(process)

# Add infrastructure processes
for name in sorted(infra_names):
    ledger = ledger_entries[name]
    processes.append({
        "name": name,
        "ledger_id": ledger["ledger_id"],
        "host": "mac",
        "runtime": "launchd" if "Launch" in ledger.get("runs_on", "") else "docker",
        "authority": ledger["authority"],
        "human_gate": ledger.get("human_gate", "—"),
        "risk": ledger.get("risk", "—"),
        "status": "running",
        "drift": None,
        "enabled": True,
        "schedule_live": "always-on",
        "schedule_ledger": ledger.get("schedule"),
        "next_run": None,
        "last_run": None,
        "sla_days_left": None,
        "last_reviewed": ledger.get("last_reviewed"),
        "cron_id": None,
    })

# Build findings
findings = []
for p in processes:
    if p["drift"]:
        severity = "HIGH" if p["drift"] in ("shadow_process", "disabled_but_running") else "WARN"
        findings.append({
            "severity": severity,
            "type": p["drift"],
            "process": p["name"],
            "detail": f"{p['name']}: {p['drift']}",
        })
    if p.get("sla_days_left") is not None and p["sla_days_left"] <= 0 and p["authority"] in ("B", "C"):
        findings.append({
            "severity": "CRITICAL",
            "type": "sla_breach",
            "process": p["name"],
            "detail": f"{p['name']}: Authority {p['authority']} SLA breached ({abs(p['sla_days_left'])} days overdue)",
        })
    elif p.get("sla_days_left") is not None and p["sla_days_left"] <= 9 and p["authority"] in ("B", "C"):
        findings.append({
            "severity": "WARN",
            "type": "sla_warning",
            "process": p["name"],
            "detail": f"{p['name']}: Authority {p['authority']} review due in {p['sla_days_left']} days",
        })

# Summary stats
stats = {
    "total": len(processes),
    "ok": sum(1 for p in processes if p["status"] == "ok"),
    "running": sum(1 for p in processes if p["status"] == "running"),
    "disabled": sum(1 for p in processes if p["status"] == "disabled"),
    "shadow": sum(1 for p in processes if p["status"] == "shadow"),
    "missing": sum(1 for p in processes if p["status"] == "missing"),
    "drift_count": sum(1 for p in processes if p["drift"]),
    "authority_a": sum(1 for p in processes if p["authority"] == "A"),
    "authority_b": sum(1 for p in processes if p["authority"] == "B"),
    "authority_c": sum(1 for p in processes if p["authority"] == "C"),
    "authority_infra": sum(1 for p in processes if p["authority"] == "—"),
}

snapshot = {
    "generated_at": now_iso,
    "host": "moltbot-macbook-pro",
    "stats": stats,
    "processes": processes,
    "findings": findings,
    "infrastructure": {
        "launchd": launchd_services,
        "docker": docker_containers,
    },
}

# Write latest
with open(snap_dir + "/gov_scan_latest.json", "w") as f:
    json.dump(snapshot, f, indent=2)

# Write timestamped copy
ts = now.strftime("%Y%m%d_%H%M")
with open(snap_dir + f"/gov_scan_{ts}.json", "w") as f:
    json.dump(snapshot, f, indent=2)

print(json.dumps(stats, indent=2))
PYEOF

echo "Scan complete: $SNAP_DIR/gov_scan_latest.json"
