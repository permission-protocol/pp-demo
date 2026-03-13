#!/usr/bin/env python3
"""
PP Signer Gap Engine — Daily Packet Renderer (Job 4)
Reads scored records, renders a founder-readable daily packet.

Usage:
  python3 packet.py            # render today's packet
  python3 packet.py --weekly   # render weekly summary
"""

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path
from utils import load_records, PACKETS_DIR, query_model, SYSTEM

DAILY_DIR = PACKETS_DIR / "daily"
WEEKLY_DIR = PACKETS_DIR / "weekly"
DAILY_DIR.mkdir(parents=True, exist_ok=True)
WEEKLY_DIR.mkdir(parents=True, exist_ok=True)


def render_daily(records: list[dict]) -> str:
    """Render a daily founder packet from scored records."""
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")

    # Sort by priority
    scored = [r for r in records if r.get("priority_score")]
    scored.sort(key=lambda r: r.get("priority_score", 0), reverse=True)

    if not scored:
        return f"# PP Spark — Daily Packet ({today})\n\nNo scored records found. Pipeline may not have run yet.\n"

    # Top gaps
    top_gaps = scored[:5]

    # Categorize by highest dimension
    product_picks = sorted(scored, key=lambda r: r.get("product_leverage", 0), reverse=True)[:3]
    demo_picks = sorted(scored, key=lambda r: r.get("demo_value", 0), reverse=True)[:2]
    gtm_picks = sorted(scored, key=lambda r: r.get("gtm_value", 0), reverse=True)[:2]
    ops_picks = sorted(scored, key=lambda r: r.get("ops_value", 0), reverse=True)[:2]

    lines = [
        f"# PP Spark — Daily Packet ({today})",
        f"*{len(scored)} scored records | top priority: {scored[0].get('priority_score', 0):.1f}*\n",
        "---\n",
        "## Top Signer Gaps\n",
    ]

    for i, r in enumerate(top_gaps, 1):
        lines.append(f"### {i}. {r.get('title', 'Untitled')}")
        lines.append(f"**Priority:** {r.get('priority_score', 0):.1f} | "
                      f"**Severity:** {r.get('severity', '?')}/10 | "
                      f"**Demo:** {r.get('demo_value', '?')}/10")
        lines.append(f"**Workflow:** {r.get('workflow', '?')}")
        lines.append(f"**Gap:** {r.get('why_internal_auth_fails', '?')}")
        lines.append(f"**PP inserts at:** {r.get('pp_insertion_point', '?')}")
        lines.append(f"**Next step:** {r.get('recommended_next_step', '?')}")
        lines.append("")

    lines.append("---\n")
    lines.append("## Product Moves\n")
    seen = set()
    for r in product_picks:
        t = r.get("title", "")
        if t not in seen:
            seen.add(t)
            lines.append(f"- **{t}** (product leverage: {r.get('product_leverage', '?')}/10)")
            fields = r.get("required_receipt_fields", [])
            if fields:
                lines.append(f"  - Receipt fields: {', '.join(fields[:5])}")
            lines.append(f"  - Enforcement: {', '.join(r.get('required_enforcement_surface', ['?']))}")
            lines.append("")

    lines.append("## GTM Angles\n")
    seen = set()
    for r in gtm_picks:
        t = r.get("title", "")
        if t not in seen:
            seen.add(t)
            lines.append(f"- **{t}** (GTM: {r.get('gtm_value', '?')}/10)")
            bp = r.get("bypass_path", [])
            if bp:
                lines.append(f"  - Lead with: \"{bp[0]}\"")
            lines.append("")

    lines.append("## Demo Ideas\n")
    seen = set()
    for r in demo_picks:
        t = r.get("title", "")
        if t not in seen:
            seen.add(t)
            lines.append(f"- **{t}** (demo: {r.get('demo_value', '?')}/10)")
            lines.append(f"  - Show: {r.get('action_taken', '?')} → PP blocks → receipt required → authorized")
            lines.append("")

    lines.append("## Internal Ops Fixes\n")
    seen = set()
    for r in ops_picks:
        t = r.get("title", "")
        if t not in seen and r.get("ops_value", 0) >= 5:
            seen.add(t)
            lines.append(f"- **{t}** (ops: {r.get('ops_value', '?')}/10)")
            lines.append("")

    if not any(r.get("ops_value", 0) >= 5 for r in ops_picks):
        lines.append("*No high-priority internal ops fixes today.*\n")

    lines.append("---")
    lines.append(f"*Generated: {datetime.now(timezone.utc).isoformat()}*")

    return "\n".join(lines)


def render_weekly(records: list[dict]) -> str:
    """Render a weekly summary with trends and conversion targets."""
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    scored = [r for r in records if r.get("priority_score")]
    scored.sort(key=lambda r: r.get("priority_score", 0), reverse=True)

    total = len(scored)
    avg_priority = sum(r.get("priority_score", 0) for r in scored) / total if total else 0
    top5 = scored[:5]

    lines = [
        f"# PP Spark — Weekly Summary ({today})",
        f"*{total} total records | avg priority: {avg_priority:.1f}*\n",
        "---\n",
        "## This Week's Top 5\n",
    ]

    for i, r in enumerate(top5, 1):
        lines.append(f"{i}. **{r.get('title', '?')}** — priority {r.get('priority_score', 0):.1f}")

    lines.append("\n## Conversion Targets\n")
    lines.append("*Pick at least one from each category to convert this week:*\n")
    lines.append("### → Product Decision")
    if top5:
        lines.append(f"- Convert: {top5[0].get('title', '?')}")
        lines.append(f"- Action: {top5[0].get('recommended_next_step', '?')}")

    lines.append("\n### → Demo Addition")
    demo_top = sorted(scored, key=lambda r: r.get("demo_value", 0), reverse=True)
    if demo_top:
        lines.append(f"- Convert: {demo_top[0].get('title', '?')}")

    lines.append("\n### → GTM Experiment")
    gtm_top = sorted(scored, key=lambda r: r.get("gtm_value", 0), reverse=True)
    if gtm_top:
        lines.append(f"- Convert: {gtm_top[0].get('title', '?')}")

    lines.append(f"\n---\n*Generated: {datetime.now(timezone.utc).isoformat()}*")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="PP Signer Gap Engine — Packet Renderer")
    parser.add_argument("--weekly", action="store_true", help="Render weekly summary")
    args = parser.parse_args()

    records = load_records()
    print(f"Loaded {len(records)} records")

    if args.weekly:
        content = render_weekly(records)
        today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        path = WEEKLY_DIR / f"{today}.md"
        path.write_text(content)
        print(f"Weekly packet written to {path}")
    else:
        content = render_daily(records)
        today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        path = DAILY_DIR / f"{today}.md"
        path.write_text(content)
        print(f"Daily packet written to {path}")

    print("\n" + content)


if __name__ == "__main__":
    main()
