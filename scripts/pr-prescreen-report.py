#!/usr/bin/env python3
"""Assemble PR pre-screen report from lint and logic results.
Usage: pr-prescreen-report.py <lint_json> <logic_json> <repo> <pr> <title> <additions> <deletions>
Reads raw (possibly multi-line) output from each tier and extracts the JSON."""

import json, re, sys, os

def extract_json(raw):
    """Extract the last valid JSON object from raw output."""
    raw = raw.strip()
    # Try each line in reverse
    for line in reversed(raw.split('\n')):
        line = line.strip()
        if line.startswith('{'):
            try:
                return json.loads(line)
            except:
                pass
    # Try full text JSON extraction
    match = re.search(r'\{.*\}', raw, re.DOTALL)
    if match:
        try:
            return json.loads(match.group())
        except:
            pass
    # Try partial finding recovery
    findings = re.findall(
        r'\{\s*"severity"\s*:\s*"([^"]+)"\s*,\s*"file"\s*:\s*"([^"]+)"\s*,\s*"issue"\s*:\s*"([^"]*)"',
        raw, re.DOTALL
    )
    if findings:
        return {
            'findings': [{'severity': s, 'file': f, 'issue': i[:200]} for s,f,i in findings],
            'summary': f'Recovered {len(findings)} findings from partial JSON',
            'approval': 'request_changes',
            '_parsed_from': 'partial_recovery'
        }
    return {'findings': [], 'summary': raw[:200] if raw else 'No output', 'approval': 'comment'}

lint_file, logic_file = sys.argv[1], sys.argv[2]
repo, pr, title = sys.argv[3], int(sys.argv[4]), sys.argv[5]
additions, deletions = sys.argv[6], sys.argv[7]

with open(lint_file) as f:
    lint = extract_json(f.read())
with open(logic_file) as f:
    logic = extract_json(f.read())

report = {
    "repo": repo,
    "pr": pr,
    "title": title,
    "changes": f"+{additions}/-{deletions}",
    "tier1_lint": lint,
    "tier2_logic": logic,
    "overall": {
        "lint_issues": len(lint.get("findings", [])),
        "logic_issues": len(logic.get("findings", [])),
        "approval": logic.get("approval", "comment"),
        "summary": logic.get("summary", "Review complete")
    }
}

print(json.dumps(report, indent=2))

with open(f"/tmp/pr-prescreen-{pr}.json", "w") as f:
    json.dump(report, f, indent=2)
