#!/bin/bash
# Generate static governance dashboard HTML from gov_scan_latest.json
# Output: permissionprotocol-site/admin/governance.html
set -euo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
SCAN="$WORKSPACE/company-os/governance/snapshots/gov_scan_latest.json"
PP_SITE="$HOME/repos/permissionprotocol-site"
OUT_DIR="$PP_SITE/admin"
OUT="$OUT_DIR/governance.html"

if [ ! -f "$SCAN" ]; then
  echo "ERROR: No scan data. Run gov-scan.sh first."
  exit 1
fi

mkdir -p "$OUT_DIR"

python3 << 'PYEOF'
import json, os, html as h
from datetime import datetime

scan_path = os.environ["HOME"] + "/.openclaw/workspace/company-os/governance/snapshots/gov_scan_latest.json"
out_path = os.environ["HOME"] + "/repos/permissionprotocol-site/admin/governance.html"

with open(scan_path) as f:
    data = json.load(f)

generated = data["generated_at"]
stats = data["stats"]
processes = data["processes"]
findings = data["findings"]
infra = data.get("infrastructure", {})

def sort_key(p):
    has_issue = 1 if p.get("drift") else 2
    lid = p.get("ledger_id") or "ZZZ"
    return (has_issue, lid)

processes.sort(key=sort_key)

def auth_badge(auth):
    colors = {"A": "#22c55e", "B": "#eab308", "C": "#ef4444", "—": "#6b7280", "UNKNOWN": "#6b7280"}
    c = colors.get(auth, "#6b7280")
    return f'<span class="badge" style="background:{c}20;color:{c}">{auth}</span>'

def status_badge(status):
    colors = {"ok": "#22c55e", "running": "#22c55e", "disabled": "#6b7280", "shadow": "#ef4444", "missing": "#ef4444", "idle": "#eab308"}
    icons = {"ok": "●", "running": "●", "disabled": "○", "shadow": "⚠", "missing": "✕", "idle": "◐"}
    c = colors.get(status, "#6b7280")
    return f'<span style="color:{c};font-weight:500">{icons.get(status,"?")} {status}</span>'

def sla_cell(days):
    if days is None: return '<span class="dim">—</span>'
    if days <= 0: return f'<span style="color:#ef4444;font-weight:700">BREACH ({abs(days)}d)</span>'
    if days <= 9: return f'<span style="color:#eab308;font-weight:600">{days}d</span>'
    return f'<span style="color:#22c55e">{days}d</span>'

def drift_cell(drift):
    if not drift: return '—'
    colors = {"shadow_process": "#ef4444", "disabled_but_running": "#ef4444", "schedule_mismatch": "#eab308", "ledger_only": "#eab308"}
    c = colors.get(drift, "#eab308")
    return f'<span style="color:{c};font-weight:600">{drift.replace("_"," ")}</span>'

def fmt_time(iso):
    if not iso: return '—'
    try:
        dt = datetime.strptime(iso, "%Y-%m-%dT%H:%M:%SZ")
        return dt.strftime("%b %d %H:%M UTC")
    except: return iso

def detail_row(p, idx):
    """Build expandable detail content for a process."""
    items = []
    if p.get("human_gate") and p["human_gate"] != "None" and p["human_gate"] != "UNKNOWN":
        items.append(f'<div class="detail-item"><span class="detail-label">Human Gate</span><span>{h.escape(str(p["human_gate"]))}</span></div>')
    if p.get("model"):
        items.append(f'<div class="detail-item"><span class="detail-label">Model</span><code>{h.escape(str(p["model"]))}</code></div>')
    if p.get("timeout_seconds"):
        items.append(f'<div class="detail-item"><span class="detail-label">Timeout</span><span>{p["timeout_seconds"]}s</span></div>')
    if p.get("session_target"):
        items.append(f'<div class="detail-item"><span class="detail-label">Session</span><span>{h.escape(str(p["session_target"]))}</span></div>')
    if p.get("schedule_tz"):
        items.append(f'<div class="detail-item"><span class="detail-label">Timezone</span><span>{h.escape(str(p["schedule_tz"]))}</span></div>')
    if p.get("schedule_ledger"):
        items.append(f'<div class="detail-item"><span class="detail-label">Ledger Schedule</span><code>{h.escape(str(p["schedule_ledger"]))}</code></div>')
    if p.get("last_reviewed"):
        items.append(f'<div class="detail-item"><span class="detail-label">Last Reviewed</span><span>{h.escape(str(p["last_reviewed"]))}</span></div>')
    if p.get("cron_id"):
        items.append(f'<div class="detail-item"><span class="detail-label">Cron ID</span><code class="dim">{p["cron_id"][:12]}…</code></div>')
    if p.get("risk") and p["risk"] != "UNKNOWN":
        items.append(f'<div class="detail-item"><span class="detail-label">Risk</span><span>{h.escape(str(p["risk"]))}</span></div>')
    
    if not items:
        items.append('<div class="detail-item"><span class="dim">No additional details available</span></div>')
    
    return f'<tr class="detail-row" id="detail-{idx}" style="display:none"><td colspan="9"><div class="detail-grid">{"".join(items)}</div></td></tr>'

# Build process rows
rows = ""
for i, p in enumerate(processes):
    # Data attributes for sorting
    auth_order = {"C": 0, "B": 1, "A": 2, "—": 3, "UNKNOWN": 4}.get(p.get("authority","—"), 4)
    status_order = {"shadow": 0, "missing": 1, "disabled": 2, "idle": 3, "ok": 4, "running": 5}.get(p.get("status",""), 3)
    sla_val = p.get("sla_days_left") if p.get("sla_days_left") is not None else 999
    last_run_ts = p.get("last_run") or "0"
    next_run_ts = p.get("next_run") or "9"
    
    rows += f"""<tr class="process-row" data-idx="{i}" data-id="{p.get('ledger_id') or 'ZZZ'}" data-name="{h.escape(p['name'])}" data-auth="{auth_order}" data-status="{status_order}" data-sla="{sla_val}" data-lastrun="{last_run_ts}" data-nextrun="{next_run_ts}" onclick="toggleDetail({i})" style="cursor:pointer">
  <td><code>{p.get('ledger_id') or '—'}</code></td>
  <td><strong>{p['name']}</strong><br><span class="dim" style="font-size:0.8rem">{p.get('runtime','')}</span></td>
  <td>{auth_badge(p.get('authority','—'))}</td>
  <td>{status_badge(p['status'])}</td>
  <td>{drift_cell(p.get('drift'))}</td>
  <td style="font-size:0.85rem"><code>{p.get('schedule_live') or '—'}</code></td>
  <td style="font-size:0.85rem">{fmt_time(p.get('last_run'))}</td>
  <td style="font-size:0.85rem">{fmt_time(p.get('next_run'))}</td>
  <td>{sla_cell(p.get('sla_days_left'))}</td>
</tr>
{detail_row(p, i)}"""

# Findings rows
finding_rows = ""
if findings:
    for f in findings:
        sev_color = {"CRITICAL": "#ef4444", "HIGH": "#ef4444", "WARN": "#eab308"}.get(f["severity"], "#6b7280")
        finding_rows += f'<tr><td><span style="color:{sev_color};font-weight:700">{f["severity"]}</span></td><td>{f["type"].replace("_"," ")}</td><td><code>{f["process"]}</code></td><td>{f["detail"]}</td></tr>'
else:
    finding_rows = '<tr><td colspan="4" style="text-align:center;color:#22c55e;padding:1rem">✅ No findings</td></tr>'

# Infra rows
infra_rows = ""
for s in infra.get("launchd", []):
    pid = s.get("pid") or "—"
    sc = "#22c55e" if pid != "—" else "#6b7280"
    infra_rows += f'<tr><td><span style="color:{sc}">● </span>{s["label"]}</td><td>launchd</td><td>{pid}</td><td>exit {s.get("exit_code","—")}</td></tr>'
for c in infra.get("docker", []):
    infra_rows += f'<tr><td><span style="color:#22c55e">● </span>{c["name"]}</td><td>docker</td><td>{c.get("image","—")}</td><td>{c.get("status","—")}</td></tr>'

html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="robots" content="noindex, nofollow">
  <title>Governance Dashboard — Permission Protocol</title>
  <style>
    :root {{
      --bg: #0a0a0a;
      --surface: #151520;
      --surface-2: #1a1a2e;
      --surface-3: #12121e;
      --border: #2a2a3e;
      --border-light: #353550;
      --text: #e0e0e0;
      --text-dim: #8888aa;
      --coral: #FF6B5B;
      --green: #22c55e;
      --yellow: #eab308;
      --red: #ef4444;
      --font: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
      --mono: 'SF Mono', 'Fira Code', Menlo, monospace;
    }}
    * {{ margin: 0; padding: 0; box-sizing: border-box; }}
    body {{
      font-family: var(--font);
      background: var(--bg);
      color: var(--text);
      line-height: 1.5;
      padding: 2rem;
      max-width: 1400px;
      margin: 0 auto;
    }}
    h1 {{ font-size: 1.5rem; font-weight: 600; margin-bottom: 0.25rem; color: var(--coral); }}
    .subtitle {{ color: var(--text-dim); font-size: 0.85rem; margin-bottom: 2rem; }}
    .stats {{
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
      gap: 1rem;
      margin-bottom: 2rem;
    }}
    .stat {{
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 1rem;
      text-align: center;
    }}
    .stat-value {{ font-size: 1.75rem; font-weight: 700; font-family: var(--mono); }}
    .stat-label {{ font-size: 0.75rem; color: var(--text-dim); text-transform: uppercase; letter-spacing: 0.05em; }}
    h2 {{ font-size: 1.1rem; font-weight: 600; margin: 2rem 0 0.75rem; color: var(--text); }}
    table {{ width: 100%; border-collapse: collapse; font-size: 0.85rem; }}
    th {{
      text-align: left;
      padding: 0.5rem 0.75rem;
      border-bottom: 2px solid var(--border);
      color: var(--text-dim);
      font-weight: 500;
      font-size: 0.75rem;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      white-space: nowrap;
    }}
    th.sortable {{
      cursor: pointer;
      user-select: none;
      position: relative;
      padding-right: 1.5rem;
    }}
    th.sortable:hover {{ color: var(--coral); }}
    th.sortable::after {{
      content: '⇅';
      position: absolute;
      right: 0.25rem;
      opacity: 0.3;
      font-size: 0.7rem;
    }}
    th.sortable.asc::after {{ content: '↑'; opacity: 0.8; color: var(--coral); }}
    th.sortable.desc::after {{ content: '↓'; opacity: 0.8; color: var(--coral); }}
    td {{
      padding: 0.5rem 0.75rem;
      border-bottom: 1px solid var(--border);
      vertical-align: top;
    }}
    .process-row:hover {{ background: var(--surface-2); }}
    .process-row {{ transition: background 0.15s; }}
    .process-row.expanded {{ background: var(--surface); border-bottom-color: transparent; }}
    .detail-row td {{
      padding: 0.75rem 1rem 1rem 1rem;
      background: var(--surface-3);
      border-bottom: 1px solid var(--border-light);
    }}
    .detail-grid {{
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 0.5rem 2rem;
    }}
    .detail-item {{
      display: flex;
      flex-direction: column;
      gap: 0.15rem;
    }}
    .detail-label {{
      font-size: 0.7rem;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: var(--text-dim);
    }}
    code {{
      font-family: var(--mono);
      font-size: 0.8rem;
      background: var(--surface-2);
      padding: 1px 4px;
      border-radius: 3px;
    }}
    .badge {{
      padding: 2px 8px;
      border-radius: 4px;
      font-weight: 600;
      font-size: 0.8rem;
    }}
    .dim {{ color: var(--text-dim); }}
    .section {{
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 1.5rem;
      margin-bottom: 1.5rem;
      overflow-x: auto;
    }}
    .footer {{
      margin-top: 3rem;
      padding-top: 1rem;
      border-top: 1px solid var(--border);
      color: var(--text-dim);
      font-size: 0.75rem;
      text-align: center;
    }}
    .footer a {{ color: var(--coral); text-decoration: none; }}
  </style>
</head>
<body>
  <h1>⬡ Governance Dashboard</h1>
  <p class="subtitle">Autonomous Process Ledger — generated {generated} · {stats['total']} processes tracked · click a row for details</p>

  <div class="stats">
    <div class="stat"><div class="stat-value" style="color:var(--green)">{stats['ok'] + stats['running']}</div><div class="stat-label">Healthy</div></div>
    <div class="stat"><div class="stat-value" style="color:var(--text-dim)">{stats['disabled']}</div><div class="stat-label">Disabled</div></div>
    <div class="stat"><div class="stat-value" style="color:var(--red)">{stats['drift_count']}</div><div class="stat-label">Drift</div></div>
    <div class="stat"><div class="stat-value">{stats['authority_c']}</div><div class="stat-label">Authority C</div></div>
    <div class="stat"><div class="stat-value">{stats['authority_b']}</div><div class="stat-label">Authority B</div></div>
    <div class="stat"><div class="stat-value">{stats['authority_a']}</div><div class="stat-label">Authority A</div></div>
  </div>

  {"" if not findings else '<div class="section"><h2>⚠ Findings</h2><table><thead><tr><th>Severity</th><th>Type</th><th>Process</th><th>Detail</th></tr></thead><tbody>' + finding_rows + '</tbody></table></div>'}

  <div class="section">
    <h2>Processes</h2>
    <table id="process-table">
      <thead>
        <tr>
          <th class="sortable" data-sort="id" data-type="str">ID</th>
          <th class="sortable" data-sort="name" data-type="str">Name</th>
          <th class="sortable" data-sort="auth" data-type="num">Auth</th>
          <th class="sortable" data-sort="status" data-type="num">Status</th>
          <th>Drift</th>
          <th>Schedule</th>
          <th class="sortable" data-sort="lastrun" data-type="str">Last Run</th>
          <th class="sortable" data-sort="nextrun" data-type="str">Next Run</th>
          <th class="sortable" data-sort="sla" data-type="num">SLA</th>
        </tr>
      </thead>
      <tbody id="process-tbody">{rows}</tbody>
    </table>
  </div>

  <div class="section">
    <h2>Infrastructure</h2>
    <table>
      <thead><tr><th>Service</th><th>Runtime</th><th>PID / Image</th><th>Status</th></tr></thead>
      <tbody>{infra_rows}</tbody>
    </table>
  </div>

  <div class="footer">
    Permission Protocol · Autonomous Process Governance · <a href="https://permissionprotocol.com">permissionprotocol.com</a>
  </div>

  <script>
  // Toggle detail row
  function toggleDetail(idx) {{
    var detail = document.getElementById('detail-' + idx);
    var row = document.querySelector('[data-idx="' + idx + '"]');
    if (!detail) return;
    var visible = detail.style.display !== 'none';
    // Close all others
    document.querySelectorAll('.detail-row').forEach(function(r) {{ r.style.display = 'none'; }});
    document.querySelectorAll('.process-row').forEach(function(r) {{ r.classList.remove('expanded'); }});
    if (!visible) {{
      detail.style.display = '';
      row.classList.add('expanded');
    }}
  }}

  // Column sorting
  (function() {{
    var headers = document.querySelectorAll('th.sortable');
    var tbody = document.getElementById('process-tbody');
    var currentSort = null;
    var currentDir = 'asc';

    headers.forEach(function(th) {{
      th.addEventListener('click', function() {{
        var key = th.dataset.sort;
        var type = th.dataset.type;

        // Toggle direction
        if (currentSort === key) {{
          currentDir = currentDir === 'asc' ? 'desc' : 'asc';
        }} else {{
          currentDir = 'asc';
          currentSort = key;
        }}

        // Update header classes
        headers.forEach(function(h) {{ h.classList.remove('asc', 'desc'); }});
        th.classList.add(currentDir);

        // Collect row pairs (process-row + detail-row)
        var pairs = [];
        var rows = tbody.querySelectorAll('.process-row');
        rows.forEach(function(row) {{
          var idx = row.dataset.idx;
          var detail = document.getElementById('detail-' + idx);
          pairs.push({{ row: row, detail: detail, val: row.dataset[key] }});
        }});

        // Sort
        pairs.sort(function(a, b) {{
          var va = a.val, vb = b.val;
          if (type === 'num') {{
            va = parseFloat(va) || 0;
            vb = parseFloat(vb) || 0;
          }}
          var cmp = va < vb ? -1 : va > vb ? 1 : 0;
          return currentDir === 'desc' ? -cmp : cmp;
        }});

        // Re-append in order
        pairs.forEach(function(p) {{
          tbody.appendChild(p.row);
          if (p.detail) tbody.appendChild(p.detail);
        }});
      }});
    }});
  }})();
  </script>
</body>
</html>"""

with open(out_path, "w") as f:
    f.write(html)

print(f"Dashboard written to {out_path}")
print(f"  {stats['total']} processes, {len(findings)} findings")
PYEOF
