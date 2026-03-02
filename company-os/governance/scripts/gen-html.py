#!/usr/bin/env python3
"""Generate governance dashboard HTML from gov_scan_latest.json"""

import json, os, html as h
from datetime import datetime, timezone, timedelta

HOME = os.environ["HOME"]
snap_path = f"{HOME}/.openclaw/workspace/company-os/governance/snapshots/gov_scan_latest.json"
html_out = f"{HOME}/.openclaw/workspace/company-os/governance/dashboard.html"

with open(snap_path) as f:
    snap = json.load(f)

stats = snap["stats"]
processes = snap["processes"]
findings = snap["findings"]
generated = snap["generated_at"]

MST = timedelta(hours=-7)

def fmt_time(iso_str, short=False):
    if not iso_str or iso_str == "—":
        return "—"
    try:
        dt = datetime.strptime(iso_str, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
        local = dt + MST
        day = local.strftime("%a")
        hr = local.hour
        mi = local.minute
        ap = "a" if hr < 12 else "p"
        if hr == 0: hr = 12
        elif hr > 12: hr -= 12
        t = f"{hr}:{mi:02d}{ap}" if mi else f"{hr}{ap}"
        if short:
            return f"{local.month}/{local.day} {t}"
        return f"{day} {local.month}/{local.day} {t}"
    except:
        return iso_str[:16]

def fmt_ms(ms):
    if not ms:
        return "—"
    s = ms // 1000
    if s < 60:
        return f"{s}s"
    return f"{s//60}m{s%60}s"

def fmt_ms_time(ms):
    if not ms:
        return "—"
    try:
        dt = datetime.utcfromtimestamp(ms / 1000).replace(tzinfo=timezone.utc)
        return fmt_time(dt.strftime("%Y-%m-%dT%H:%M:%SZ"))
    except:
        return "—"

def esc(text):
    return h.escape(str(text)) if text else ""

auth_order = {"C": 0, "B": 1, "A": 2, "UNKNOWN": 3, "—": 4}
status_order = {"shadow": 0, "missing": 1, "ok": 2, "running": 3, "disabled": 4}
processes.sort(key=lambda p: (0 if p.get("drift") else 1, auth_order.get(p["authority"],5), status_order.get(p["status"],5), p["name"]))

gen_local = fmt_time(generated)

out = f'''<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>Governance Dashboard</title><meta name="viewport" content="width=device-width">
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{background:#151520;color:#e0e0e0;font-family:Inter,system-ui,sans-serif;padding:24px;font-size:13px}}
h1{{color:#fff;font-size:20px;margin-bottom:4px}}
.ts{{color:#8a8a9a;font-size:13px;margin-bottom:20px}}
.stats{{display:flex;gap:16px;margin-bottom:20px;flex-wrap:wrap}}
.stat{{background:#1e1e30;padding:12px 16px;border-radius:6px}}
.stat .n{{font-size:24px;font-weight:700;color:#fff}}
.stat .l{{font-size:11px;color:#8a8a9a;text-transform:uppercase;letter-spacing:.5px}}
.findings{{background:#2a1a1a;border:1px solid #ff6b5b44;border-radius:6px;padding:12px 16px;margin-bottom:20px}}
.findings h3{{color:#ff6b5b;font-size:13px;margin-bottom:8px}}
table{{width:100%;border-collapse:collapse}}
th{{text-align:left;color:#8a8a9a;font-size:11px;text-transform:uppercase;letter-spacing:.5px;padding:8px 10px;border-bottom:1px solid #2a2a40;white-space:nowrap;cursor:pointer;user-select:none}}
th:hover{{color:#fff}}
th .arrow{{font-size:9px;margin-left:4px;opacity:0.4}}
th.sorted .arrow{{opacity:1;color:#ff6b5b}}
td{{padding:8px 10px;border-bottom:1px solid #1e1e30;white-space:nowrap}}
tr.row{{cursor:pointer}}
tr.row:hover{{background:#1a1a2e}}
tr.row.selected{{background:#1a1a2e;border-left:3px solid #ff6b5b}}
.ok,.running{{color:#4ade80}}.disabled{{color:#666}}.shadow{{color:#ff6b5b;font-weight:700}}.missing{{color:#ff6b5b}}
.auth-C{{color:#ff6b5b;font-weight:700}}.auth-B{{color:#f0ad4e}}.auth-A{{color:#8a8a9a}}
.drift{{color:#ff6b5b}}.sla-ok{{color:#4ade80}}.sla-warn{{color:#f0ad4e}}.sla-breach{{color:#ff6b5b}}
.dim{{color:#555}}
.bar{{height:4px;background:#ff6b5b;border-radius:2px;margin-top:20px}}

.detail{{display:none;background:#1a1a2e;border-left:3px solid #ff6b5b}}
.detail td{{white-space:normal;padding:0}}
.detail-inner{{padding:16px 24px;display:grid;grid-template-columns:1fr 1fr;gap:20px}}
.detail-section{{}}
.detail-section h3{{color:#ff6b5b;font-size:12px;text-transform:uppercase;letter-spacing:.5px;margin-bottom:8px}}
.detail-section .label{{color:#8a8a9a;font-size:11px;text-transform:uppercase;margin-top:10px}}
.detail-section .value{{color:#e0e0e0;margin-top:2px;line-height:1.5}}
.detail-section .value.dim{{color:#666}}
.scope-item{{color:#e0e0e0;font-size:12px;padding:2px 0}}
.run-entry{{background:#151520;border-radius:4px;padding:10px 12px;margin-top:6px}}
.run-header{{display:flex;gap:12px;align-items:center;margin-bottom:6px}}
.run-status{{display:inline-block;width:8px;height:8px;border-radius:50%}}
.run-status.ok{{background:#4ade80}}.run-status.error{{background:#ff6b5b}}
.run-summary{{color:#aaa;font-size:12px;line-height:1.5;white-space:pre-wrap}}
.run-meta{{color:#666;font-size:11px}}
.prompt-box{{background:#151520;border-radius:4px;padding:10px 12px;color:#aaa;font-size:12px;line-height:1.5;white-space:pre-wrap;max-height:200px;overflow-y:auto;margin-top:4px}}
</style></head><body>
<h1>Governance Dashboard</h1>
<div class="ts">{gen_local} (Denver) · moltbot-macbook-pro</div>
<div class="stats">
<div class="stat"><div class="n">{stats['total']}</div><div class="l">Processes</div></div>
<div class="stat"><div class="n" style="color:#4ade80">{stats['ok']+stats['running']}</div><div class="l">OK</div></div>
<div class="stat"><div class="n" style="color:#666">{stats['disabled']}</div><div class="l">Disabled</div></div>
<div class="stat"><div class="n" style="color:#ff6b5b">{stats['shadow']}</div><div class="l">Shadow</div></div>
<div class="stat"><div class="n" style="color:#f0ad4e">{stats['drift_count']}</div><div class="l">Drift</div></div>
<div class="stat"><div class="n">{stats['authority_c']}</div><div class="l">Auth C</div></div>
<div class="stat"><div class="n">{stats['authority_b']}</div><div class="l">Auth B</div></div>
<div class="stat"><div class="n">{stats['authority_a']}</div><div class="l">Auth A</div></div>
</div>'''

if findings:
    out += '<div class="findings"><h3>⚠ Findings</h3>'
    for f in findings:
        out += f'<div style="color:{"#ff6b5b" if f["severity"] in ("HIGH","CRITICAL") else "#f0ad4e"};padding:2px 0">[{f["severity"]}] {esc(f["detail"])}</div>'
    out += '</div>'

cols = ["●","ID","Name","Auth","Gate","Status","Schedule","Last Run","Next Run","SLA","Drift"]
out += '<table id="gov"><thead><tr>'
for i, col in enumerate(cols):
    out += f'<th onclick="sortTable({i})">{col}<span class="arrow">▼</span></th>'
out += '</tr></thead><tbody>'

for idx, p in enumerate(processes):
    st = p["status"]
    auth = p["authority"]
    sla = p.get("sla_days_left")
    drift = p.get("drift") or "—"
    sched = p.get("schedule_live") or p.get("schedule_ledger") or "—"
    next_r = fmt_time(p.get("next_run"))
    last_r = fmt_time(p.get("last_run"))
    lid = p.get("ledger_id") or "—"
    gate = p.get("human_gate") or "—"
    icon = "●" if st in ("ok","running") else "○" if st=="disabled" else "◉" if st=="shadow" else "✗"
    sla_cls = "sla-ok" if sla and sla>9 else "sla-warn" if sla and sla>0 else "sla-breach" if sla is not None else "dim"
    sla_text = f"{sla}d" if sla is not None else "—"

    auth_sort = str(auth_order.get(auth, 9))
    status_sort = str(status_order.get(st, 9))
    sla_sort = str(sla) if sla is not None else "999"
    next_sort = p.get("next_run") or "9999"
    last_sort = p.get("last_run") or "0000"

    out += f'<tr class="row" onclick="toggleDetail({idx})">'
    out += f'<td class="{st}" data-sort="{status_sort}">{icon}</td>'
    out += f'<td data-sort="{lid}">{lid}</td>'
    out += f'<td data-sort="{esc(p["name"])}">{esc(p["name"])}</td>'
    out += f'<td class="auth-{auth}" data-sort="{auth_sort}">{auth}</td>'
    out += f'<td data-sort="{esc(gate)}">{esc(gate)}</td>'
    out += f'<td class="{st}" data-sort="{status_sort}">{st}</td>'
    out += f'<td data-sort="{esc(sched)}">{esc(sched)}</td>'
    out += f'<td data-sort="{last_sort}">{last_r}</td>'
    out += f'<td data-sort="{next_sort}">{next_r}</td>'
    out += f'<td class="{sla_cls}" data-sort="{sla_sort}">{sla_text}</td>'
    out += f'<td class="{"drift" if drift!="—" else "dim"}" data-sort="{0 if drift!="—" else 1}">{esc(drift)}</td>'
    out += '</tr>'

    # Detail row
    what = esc(p.get("what", "No description available"))
    model_detail = esc(p.get("model_detail", p.get("model") or "—"))
    risk_detail = esc(p.get("risk_detail", p.get("risk") or "—"))
    fail_closed = esc(p.get("fail_closed", "—"))
    scope = p.get("scope", [])
    recent_runs = p.get("recent_runs", [])
    cron_msg = esc(p.get("cron_message", ""))
    timeout = p.get("timeout_seconds")
    timeout_str = f"{timeout}s" if timeout else "—"
    runtime = p.get("runtime", "—")
    session = p.get("session_target", "—")
    tz = p.get("schedule_tz", "—") or "UTC"

    out += f'<tr class="detail" id="detail-{idx}"><td colspan="11"><div class="detail-inner">'

    # Left column: What / How / Why
    out += '<div class="detail-section">'
    out += '<h3>What It Does</h3>'
    out += f'<div class="value">{what}</div>'

    out += '<div class="label">How It Works</div>'
    out += f'<div class="value">Runtime: {runtime} · Session: {session} · Timezone: {tz}</div>'
    out += f'<div class="value">Model: {model_detail} · Timeout: {timeout_str}</div>'
    if fail_closed and fail_closed != "—":
        out += f'<div class="value">Fail-closed: {fail_closed}</div>'

    if scope:
        out += '<div class="label">Scope (What It Can Touch)</div>'
        for s in scope:
            out += f'<div class="scope-item">{esc(s)}</div>'

    out += '<div class="label">Why It Exists</div>'
    out += f'<div class="value">Authority: {auth} · Risk: {risk_detail} · Gate: {esc(gate)}</div>'

    if cron_msg:
        out += '<div class="label">Cron Prompt (first 300 chars)</div>'
        out += f'<div class="prompt-box">{cron_msg}</div>'

    out += '</div>'

    # Right column: Last runs
    out += '<div class="detail-section">'
    out += '<h3>Recent Runs</h3>'

    if recent_runs:
        for run in reversed(recent_runs):
            run_time = fmt_ms_time(run.get("timestamp"))
            run_dur = fmt_ms(run.get("duration_ms"))
            run_st = run.get("status", "?")
            run_tokens = run.get("tokens")
            run_model = run.get("model", "")
            summary = esc(run.get("summary", "No summary"))

            out += '<div class="run-entry">'
            out += '<div class="run-header">'
            out += f'<span class="run-status {"ok" if run_st=="ok" else "error"}"></span>'
            out += f'<strong>{run_time}</strong>'
            out += f'<span class="run-meta">{run_dur} · {run_model}'
            if run_tokens:
                out += f' · {run_tokens:,} tokens'
            out += '</span></div>'
            out += f'<div class="run-summary">{summary}</div>'
            out += '</div>'
    else:
        out += '<div class="value dim">No run history available</div>'

    out += '</div></div></td></tr>'

out += '''</tbody></table>
<div class="bar"></div>

<script>
function toggleDetail(idx) {
  const detail = document.getElementById("detail-" + idx);
  const row = detail.previousElementSibling;
  const wasOpen = detail.style.display === "table-row";
  
  // Close all
  document.querySelectorAll(".detail").forEach(d => d.style.display = "none");
  document.querySelectorAll(".row").forEach(r => r.classList.remove("selected"));
  
  if (!wasOpen) {
    detail.style.display = "table-row";
    row.classList.add("selected");
  }
}

let sortDir = {};
function sortTable(col) {
  const table = document.getElementById("gov");
  const tbody = table.querySelector("tbody");
  const headers = table.querySelectorAll("th");
  
  // Collect row pairs (data row + detail row)
  const pairs = [];
  const rows = Array.from(tbody.children);
  for (let i = 0; i < rows.length; i += 2) {
    pairs.push([rows[i], rows[i+1]]);
  }
  
  sortDir[col] = sortDir[col] === "asc" ? "desc" : "asc";
  const dir = sortDir[col];
  
  headers.forEach((h, i) => {
    h.classList.toggle("sorted", i === col);
    const arrow = h.querySelector(".arrow");
    if (i === col) arrow.textContent = dir === "asc" ? "▲" : "▼";
    else arrow.textContent = "▼";
  });
  
  pairs.sort((a, b) => {
    let aVal = a[0].cells[col].getAttribute("data-sort") || a[0].cells[col].textContent;
    let bVal = b[0].cells[col].getAttribute("data-sort") || b[0].cells[col].textContent;
    let aNum = parseFloat(aVal), bNum = parseFloat(bVal);
    if (!isNaN(aNum) && !isNaN(bNum))
      return dir === "asc" ? aNum - bNum : bNum - aNum;
    return dir === "asc" ? aVal.localeCompare(bVal) : bVal.localeCompare(aVal);
  });
  
  // Close all details
  document.querySelectorAll(".detail").forEach(d => d.style.display = "none");
  document.querySelectorAll(".row").forEach(r => r.classList.remove("selected"));
  
  pairs.forEach(([row, detail]) => {
    tbody.appendChild(row);
    tbody.appendChild(detail);
  });
}
</script>
</body></html>'''

with open(html_out, "w") as f:
    f.write(out)
print(f"Dashboard: {html_out}")
