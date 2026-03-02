#!/bin/bash
# Governance Dashboard — terminal viewer for gov_scan_latest.json
# Usage: governance-dashboard.sh [--html output.html]

set -uo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
SNAP="$WORKSPACE/company-os/governance/snapshots/gov_scan_latest.json"
HTML_OUT=""

if [ "${1:-}" = "--html" ]; then
  HTML_OUT="${2:-$WORKSPACE/company-os/governance/dashboard.html}"
fi

if [ ! -f "$SNAP" ]; then
  echo "No snapshot found. Run gov-scan.sh first."
  exit 1
fi

# Terminal output
python3 << 'PYEOF'
import json, sys, os

snap_path = os.environ["HOME"] + "/.openclaw/workspace/company-os/governance/snapshots/gov_scan_latest.json"
html_out = sys.argv[1] if len(sys.argv) > 1 else ""

with open(snap_path) as f:
    snap = json.load(f)

stats = snap["stats"]
processes = snap["processes"]
findings = snap["findings"]
generated = snap["generated_at"]

# Sort: drift first, then authority C > B > A > infra, then by name
auth_order = {"C": 0, "B": 1, "A": 2, "UNKNOWN": 3, "—": 4}
status_order = {"shadow": 0, "missing": 1, "ok": 2, "running": 3, "disabled": 4}

processes.sort(key=lambda p: (
    0 if p["drift"] else 1,
    auth_order.get(p["authority"], 5),
    status_order.get(p["status"], 5),
    p["name"]
))

# Terminal colors
RED = "\033[91m"
YEL = "\033[93m"
GRN = "\033[92m"
DIM = "\033[2m"
BOLD = "\033[1m"
RST = "\033[0m"
CYAN = "\033[96m"

def c(text, color):
    return f"{color}{text}{RST}"

# Header
print()
print(c("═══════════════════════════════════════════════════════════════════════════════", CYAN))
print(c("  GOVERNANCE DASHBOARD", BOLD) + f"  │  {generated}")
print(c("═══════════════════════════════════════════════════════════════════════════════", CYAN))
print()

# Stats bar
print(f"  {c(stats['total'], BOLD)} processes  │  "
      f"{c(str(stats['ok']+stats['running']), GRN)} ok  │  "
      f"{c(str(stats['disabled']), DIM)} disabled  │  "
      f"{c(str(stats['shadow']), RED)} shadow  │  "
      f"{c(str(stats['drift_count']), YEL)} drift  │  "
      f"Authority: {c('A', DIM)}={stats['authority_a']}  {c('B', YEL)}={stats['authority_b']}  {c('C', RED)}={stats['authority_c']}  ∞={stats['authority_infra']}")
print()

# Findings
if findings:
    print(c("  ⚠ FINDINGS", RED))
    for f in findings:
        sev_color = RED if f["severity"] in ("HIGH", "CRITICAL") else YEL
        print(f"    {c('['+f['severity']+']', sev_color)} {f['detail']}")
    print()

# Process table
hdr = f"  {'':2} {'ID':8} {'Name':30} {'Auth':4} {'Status':10} {'Schedule':28} {'Next Run':20} {'SLA':5} {'Drift':15}"
print(c(hdr, DIM))
print(c("  " + "─" * 130, DIM))

for p in processes:
    # Status icon
    st = p["status"]
    if st == "ok" or st == "running":
        icon = c("●", GRN)
        st_text = c(st, GRN)
    elif st == "disabled":
        icon = c("○", DIM)
        st_text = c(st, DIM)
    elif st == "shadow":
        icon = c("◉", RED)
        st_text = c(st, RED)
    elif st == "missing":
        icon = c("✗", RED)
        st_text = c(st, RED)
    else:
        icon = "?"
        st_text = st

    # Authority coloring
    auth = p["authority"]
    if auth == "C":
        auth_text = c(auth, RED)
    elif auth == "B":
        auth_text = c(auth, YEL)
    else:
        auth_text = c(auth, DIM)

    # SLA
    sla = p.get("sla_days_left")
    if sla is not None:
        if sla <= 0:
            sla_text = c(f"{sla}d", RED)
        elif sla <= 9:
            sla_text = c(f"{sla}d", YEL)
        else:
            sla_text = c(f"{sla}d", GRN)
    else:
        sla_text = c("—", DIM)

    # Drift
    drift = p.get("drift")
    if drift:
        drift_text = c(drift, RED)
    else:
        drift_text = c("—", DIM)

    # Schedule
    sched = p.get("schedule_live") or p.get("schedule_ledger") or "—"
    if len(sched) > 28:
        sched = sched[:25] + "..."

    # Next run
    next_r = p.get("next_run", "—") or "—"
    if next_r != "—":
        next_r = next_r[5:16].replace("T", " ")  # compact: MM-DD HH:MM

    lid = p.get("ledger_id") or "—"
    name = p["name"]
    if len(name) > 30:
        name = name[:27] + "..."

    print(f"  {icon} {lid:8} {name:30} {auth_text:>4}  {st_text:10}  {sched:28} {next_r:20} {sla_text:>5} {drift_text}")

print()
print(c("  " + "─" * 130, DIM))
print(f"  Ledger: company-os/governance/AUTONOMOUS_PROCESS_LEDGER.md")
print(f"  Snapshot: company-os/governance/snapshots/gov_scan_latest.json")
print()

# HTML output
if html_out:
    html = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Governance Dashboard</title>
<meta name="viewport" content="width=device-width">
<style>
  * {{ margin:0; padding:0; box-sizing:border-box; }}
  body {{ background:#151520; color:#e0e0e0; font-family:'Inter',system-ui,sans-serif; padding:24px; }}
  h1 {{ color:#fff; font-size:20px; margin-bottom:4px; }}
  .ts {{ color:#8a8a9a; font-size:13px; margin-bottom:20px; }}
  .stats {{ display:flex; gap:16px; margin-bottom:20px; flex-wrap:wrap; }}
  .stat {{ background:#1e1e30; padding:12px 16px; border-radius:6px; }}
  .stat .n {{ font-size:24px; font-weight:700; color:#fff; }}
  .stat .l {{ font-size:11px; color:#8a8a9a; text-transform:uppercase; letter-spacing:0.5px; }}
  .findings {{ background:#2a1a1a; border:1px solid #ff6b5b44; border-radius:6px; padding:12px 16px; margin-bottom:20px; }}
  .findings h3 {{ color:#ff6b5b; font-size:13px; margin-bottom:8px; }}
  .finding {{ font-size:13px; padding:2px 0; }}
  .finding.HIGH,.finding.CRITICAL {{ color:#ff6b5b; }}
  .finding.WARN {{ color:#f0ad4e; }}
  table {{ width:100%; border-collapse:collapse; font-size:13px; }}
  th {{ text-align:left; color:#8a8a9a; font-size:11px; text-transform:uppercase; letter-spacing:0.5px; padding:8px 10px; border-bottom:1px solid #2a2a40; }}
  td {{ padding:8px 10px; border-bottom:1px solid #1e1e30; }}
  tr:hover {{ background:#1a1a2e; }}
  .ok {{ color:#4ade80; }}
  .running {{ color:#4ade80; }}
  .disabled {{ color:#666; }}
  .shadow {{ color:#ff6b5b; font-weight:700; }}
  .missing {{ color:#ff6b5b; }}
  .auth-C {{ color:#ff6b5b; font-weight:700; }}
  .auth-B {{ color:#f0ad4e; }}
  .auth-A {{ color:#8a8a9a; }}
  .drift {{ color:#ff6b5b; }}
  .sla-ok {{ color:#4ade80; }}
  .sla-warn {{ color:#f0ad4e; }}
  .sla-breach {{ color:#ff6b5b; }}
  .bar {{ height:4px; background:#ff6b5b; border-radius:2px; margin-top:20px; }}
</style>
</head>
<body>
<h1>Governance Dashboard</h1>
<div class="ts">{generated} · moltbot-macbook-pro</div>

<div class="stats">
  <div class="stat"><div class="n">{stats['total']}</div><div class="l">Processes</div></div>
  <div class="stat"><div class="n" style="color:#4ade80">{stats['ok']+stats['running']}</div><div class="l">OK</div></div>
  <div class="stat"><div class="n" style="color:#666">{stats['disabled']}</div><div class="l">Disabled</div></div>
  <div class="stat"><div class="n" style="color:#ff6b5b">{stats['shadow']}</div><div class="l">Shadow</div></div>
  <div class="stat"><div class="n" style="color:#f0ad4e">{stats['drift_count']}</div><div class="l">Drift</div></div>
  <div class="stat"><div class="n">{stats['authority_c']}</div><div class="l">Auth C</div></div>
  <div class="stat"><div class="n">{stats['authority_b']}</div><div class="l">Auth B</div></div>
  <div class="stat"><div class="n">{stats['authority_a']}</div><div class="l">Auth A</div></div>
</div>
"""
    if findings:
        html += '<div class="findings"><h3>⚠ Findings</h3>'
        for f in findings:
            html += f'<div class="finding {f["severity"]}">[{f["severity"]}] {f["detail"]}</div>'
        html += '</div>'

    html += """<table>
<tr><th>●</th><th>ID</th><th>Name</th><th>Auth</th><th>Gate</th><th>Status</th><th>Schedule</th><th>Next Run</th><th>SLA</th><th>Drift</th></tr>
"""
    for p in processes:
        st = p["status"]
        auth = p["authority"]
        sla = p.get("sla_days_left")
        drift = p.get("drift") or "—"
        sched = p.get("schedule_live") or p.get("schedule_ledger") or "—"
        next_r = p.get("next_run") or "—"
        if next_r != "—":
            next_r = next_r[5:16].replace("T", " ")
        lid = p.get("ledger_id") or "—"
        gate = p.get("human_gate") or "—"

        icon = "●" if st in ("ok","running") else "○" if st == "disabled" else "◉" if st == "shadow" else "✗"
        sla_cls = "sla-ok" if sla and sla > 9 else "sla-warn" if sla and sla > 0 else "sla-breach" if sla is not None else ""
        sla_text = f"{sla}d" if sla is not None else "—"

        html += f'<tr><td class="{st}">{icon}</td><td>{lid}</td><td>{p["name"]}</td>'
        html += f'<td class="auth-{auth}">{auth}</td><td>{gate}</td>'
        html += f'<td class="{st}">{st}</td><td>{sched}</td><td>{next_r}</td>'
        html += f'<td class="{sla_cls}">{sla_text}</td>'
        html += f'<td class="{"drift" if drift != "—" else ""}">{drift}</td></tr>\n'

    html += """</table>
<div class="bar"></div>
</body></html>"""

    with open(html_out, "w") as f:
        f.write(html)
    print(f"HTML dashboard: {html_out}")

PYEOF
