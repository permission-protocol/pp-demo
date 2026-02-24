#!/bin/bash
# QA Test Runner — deterministic verification of Done board items.
# Parses AC block, runs checks per template, produces proof map JSON.
#
# Usage: qa-test-runner.sh <issue-number> [template-type|auto]
# Exit: 0 = all proven (PASS), 1 = fail (FAIL), 2 = unproven items (AMBIGUOUS)

set -uo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
QA_DIR="$WORKSPACE/qa"
GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt 2>/dev/null || echo "")
REPO="Roca-Ventures/Breakout-Labs"

ISSUE_NUM="${1:-}"
TEMPLATE_TYPE="${2:-auto}"

if [ -z "$ISSUE_NUM" ]; then
    echo "Usage: qa-test-runner.sh <issue-number> [template-type|auto]"
    exit 2
fi

# ─── Fetch issue ───
ISSUE_JSON=$(GH_TOKEN="$GH_TOKEN" gh issue view "$ISSUE_NUM" -R "$REPO" --json title,body,labels,state 2>/dev/null)
if [ -z "$ISSUE_JSON" ]; then
    echo '{"error": "Could not fetch issue '$ISSUE_NUM'"}'
    exit 1
fi

TITLE=$(echo "$ISSUE_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin)['title'])")
BODY=$(echo "$ISSUE_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin)['body'])")
LABELS=$(echo "$ISSUE_JSON" | python3 -c "import json,sys; print(','.join(l['name'] for l in json.load(sys.stdin)['labels']))")
ISSUE_STATE=$(echo "$ISSUE_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin).get('state','UNKNOWN'))")

# ─── Parse AC block ───
AC_BLOCK=$(echo "$BODY" | python3 -c "
import sys, re
body = sys.stdin.read()
# Find AC: section
match = re.search(r'## AC:?\s*\n(.*?)(?=\n## |\Z)', body, re.DOTALL)
if not match:
    match = re.search(r'(?:Acceptance Criteria|AC):\s*\n(.*?)(?=\n## |\Z)', body, re.DOTALL | re.IGNORECASE)
if match:
    criteria = re.findall(r'- \[[ x]\] (.+)', match.group(1))
    for c in criteria:
        print(c)
else:
    print('NO_AC')
" 2>/dev/null)

if [ "$AC_BLOCK" = "NO_AC" ] || [ -z "$AC_BLOCK" ]; then
    python3 -c "
import json, datetime
print(json.dumps({
    'issue': $ISSUE_NUM,
    'title': '''$TITLE''',
    'template': 'none',
    'timestamp': datetime.datetime.now().isoformat(),
    'result': 'FAIL',
    'reason': 'No AC block found. Add ## AC: section with checkboxes and verification targets.',
    'criteria': []
}, indent=2))
"
    exit 1
fi

# ─── Parse verification targets ───
VERIFY_URL=$(echo "$BODY" | python3 -c "
import sys, re
body = sys.stdin.read()
urls = re.findall(r'(?:URL|url|Verify|verify|Check|check):\s*(https?://\S+)', body)
if urls:
    print(urls[0])
else:
    # Try to find any URL in How to verify section
    match = re.search(r'How to verify.*?\n(.*?)(?=\n## |\Z)', body, re.DOTALL | re.IGNORECASE)
    if match:
        urls = re.findall(r'https?://\S+', match.group(1))
        if urls:
            print(urls[0])
" 2>/dev/null)

# ─── Template detection ───
if [ "$TEMPLATE_TYPE" = "auto" ]; then
    TEMPLATE_TYPE=$(python3 -c "
import json, os

labels = '$LABELS'.split(',')
title = '''$TITLE'''.lower()
template_dir = '$QA_DIR/templates'

# Label-first
for f in os.listdir(template_dir):
    if not f.endswith('.json'): continue
    with open(os.path.join(template_dir, f)) as fh:
        t = json.load(fh)
    for label in t.get('labels', []):
        if label in labels:
            print(t['type'])
            exit()

# Title-keyword second
for f in os.listdir(template_dir):
    if not f.endswith('.json'): continue
    with open(os.path.join(template_dir, f)) as fh:
        t = json.load(fh)
    for kw in t.get('title_keywords', []):
        if kw.lower() in title:
            print(t['type'])
            exit()

print('unknown')
" 2>/dev/null)
fi

if [ "$TEMPLATE_TYPE" = "unknown" ]; then
    python3 -c "
import json, datetime
print(json.dumps({
    'issue': $ISSUE_NUM,
    'title': '''$TITLE''',
    'template': 'unknown',
    'timestamp': datetime.datetime.now().isoformat(),
    'result': 'AMBIGUOUS',
    'reason': 'Could not determine template type from labels or title. Add a type:* label.',
    'criteria': []
}, indent=2))
"
    exit 2
fi

# ─── Run deterministic checks per AC item ───
# Read AC items into array
# macOS zsh doesn't have mapfile — use while read
AC_ITEMS=()
while IFS= read -r line; do
    [ -n "$line" ] && AC_ITEMS+=("$line")
done <<< "$AC_BLOCK"

PROOF_MAP=$(python3 << PYEOF
import json, subprocess, re, datetime, sys, os, urllib.request

issue_num = $ISSUE_NUM
title = '''$TITLE'''
template_type = "$TEMPLATE_TYPE"
verify_url = "$VERIFY_URL"
issue_state = "$ISSUE_STATE"
ac_items = $(python3 -c "
import sys
items = []
for line in '''$AC_BLOCK'''.strip().split('\n'):
    if line.strip():
        items.append(line.strip())
import json
print(json.dumps(items))
")

criteria = []

for ac in ac_items:
    ac_lower = ac.lower()
    status = "unproven"
    evidence = []
    
    # ── HTTP status checks ──
    if verify_url and any(kw in ac_lower for kw in ["returns 200", "page load", "loads", "live", "accessible", "200"]):
        try:
            req = urllib.request.Request(verify_url, method='HEAD')
            req.add_header('User-Agent', 'QA-Test-Runner/1.0')
            resp = urllib.request.urlopen(req, timeout=15)
            code = resp.getcode()
            if code == 200:
                status = "proven"
                evidence.append(f"HTTP {code} from {verify_url}")
            else:
                status = "false"
                evidence.append(f"HTTP {code} (expected 200) from {verify_url}")
        except Exception as e:
            status = "false"
            evidence.append(f"Request failed: {str(e)[:100]}")
    
    # ── CSS color/font checks ──
    elif any(kw in ac_lower for kw in ["color", "palette", "font", "typography", "space grotesk"]):
        if verify_url:
            try:
                # Fetch page and check for CSS values
                req = urllib.request.Request(verify_url)
                req.add_header('User-Agent', 'QA-Test-Runner/1.0')
                resp = urllib.request.urlopen(req, timeout=15)
                html = resp.read().decode('utf-8', errors='replace')
                
                spec_path = os.path.join('$QA_DIR', 'pp-brand-spec.json')
                if os.path.exists(spec_path):
                    with open(spec_path) as f:
                        spec = json.load(f)
                    
                    if "color" in ac_lower or "palette" in ac_lower:
                        colors = spec['brand']['colors']
                        found = []
                        missing = []
                        for name, value in colors.items():
                            if value.lower() in html.lower():
                                found.append(f"--{name}: {value}")
                            else:
                                missing.append(f"--{name}: {value}")
                        if not missing:
                            status = "proven"
                            evidence.append(f"All brand colors found: {', '.join(found)}")
                        elif len(found) > len(missing):
                            status = "unproven"
                            evidence.append(f"Found: {', '.join(found)}. Missing: {', '.join(missing)}")
                        else:
                            status = "false"
                            evidence.append(f"Missing colors: {', '.join(missing)}")
                    
                    if "font" in ac_lower or "typography" in ac_lower or "grotesk" in ac_lower:
                        expected_font = spec['brand']['fonts']['primary']
                        if expected_font.lower() in html.lower():
                            status = "proven"
                            evidence.append(f"Font '{expected_font}' found in page source")
                        else:
                            status = "unproven"
                            evidence.append(f"Font '{expected_font}' not found in page source (may load via CSS)")
            except Exception as e:
                evidence.append(f"CSS check error: {str(e)[:100]}")
    
    # ── PR checks ──
    elif any(kw in ac_lower for kw in ["pr merged", "pull request", "merged"]):
        # Try to find PR number in issue body
        pr_match = re.findall(r'#(\d+)|pull/(\d+)', '''$BODY''')
        if pr_match:
            pr_num = pr_match[0][0] or pr_match[0][1]
            try:
                result = subprocess.run(
                    ['gh', 'pr', 'view', pr_num, '-R', '$REPO', '--json', 'state', '-q', '.state'],
                    capture_output=True, text=True, timeout=15,
                    env={**os.environ, 'GH_TOKEN': '$GH_TOKEN'}
                )
                state = result.stdout.strip()
                if state == "MERGED":
                    status = "proven"
                    evidence.append(f"PR #{pr_num} state: MERGED")
                else:
                    status = "false"
                    evidence.append(f"PR #{pr_num} state: {state} (expected MERGED)")
            except Exception as e:
                evidence.append(f"PR check error: {str(e)[:100]}")
        else:
            evidence.append("No PR reference found in issue body")

    # ── CI checks ──
    elif any(kw in ac_lower for kw in ["ci pass", "checks pass", "build pass", "pipeline"]):
        try:
            result = subprocess.run(
                ['gh', 'run', 'list', '-R', '$REPO', '--limit', '1', '--json', 'conclusion', '-q', '.[0].conclusion'],
                capture_output=True, text=True, timeout=15,
                env={**os.environ, 'GH_TOKEN': '$GH_TOKEN'}
            )
            conclusion = result.stdout.strip()
            if conclusion == "success":
                status = "proven"
                evidence.append(f"Latest CI run: {conclusion}")
            else:
                status = "unproven"
                evidence.append(f"Latest CI run: {conclusion}")
        except Exception as e:
            evidence.append(f"CI check error: {str(e)[:100]}")
    
    # ── Quality gate (blog posts) ──
    elif any(kw in ac_lower for kw in ["quality gate", "quality check"]):
        evidence.append("Quality gate requires local HTML file — run separately")
    
    # ── Link checks ──
    elif any(kw in ac_lower for kw in ["link", "404", "internal link"]):
        if verify_url:
            try:
                req = urllib.request.Request(verify_url)
                req.add_header('User-Agent', 'QA-Test-Runner/1.0')
                resp = urllib.request.urlopen(req, timeout=15)
                html = resp.read().decode('utf-8', errors='replace')
                internal = re.findall(r'href="((?:https?://)?(?:blog\.)?xdares\.com[^"]*|/[^"]*)"', html)
                if internal:
                    status = "proven"
                    evidence.append(f"Found {len(internal)} internal links")
                else:
                    status = "false"
                    evidence.append("No internal links found")
            except Exception as e:
                evidence.append(f"Link check error: {str(e)[:100]}")
    
    # ── Fallback: unproven ──
    if not evidence:
        evidence.append("No deterministic check available for this criterion")
    
    criteria.append({
        "ac": ac,
        "status": status,
        "evidence": evidence
    })

# Summary
proven = sum(1 for c in criteria if c['status'] == 'proven')
unproven = sum(1 for c in criteria if c['status'] == 'unproven')
false_count = sum(1 for c in criteria if c['status'] == 'false')

warnings = []
if issue_state == "OPEN":
    warnings.append("Issue is still OPEN — suspicious for a Done item")

if false_count > 0:
    result = "FAIL"
elif unproven > 0:
    result = "AMBIGUOUS"
else:
    result = "PASS"

proof_map = {
    "issue": issue_num,
    "title": title,
    "template": template_type,
    "issue_state": issue_state,
    "timestamp": datetime.datetime.now().isoformat(),
    "result": result,
    "criteria": criteria,
    "summary": {
        "proven": proven,
        "unproven": unproven,
        "false": false_count
    }
}
if warnings:
    proof_map["warnings"] = warnings

print(json.dumps(proof_map, indent=2))

# Exit code
if result == "FAIL":
    sys.exit(1)
elif result == "AMBIGUOUS":
    sys.exit(2)
else:
    sys.exit(0)
PYEOF
)

echo "$PROOF_MAP"
exit ${PIPESTATUS[0]}
