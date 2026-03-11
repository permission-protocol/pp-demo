#!/bin/bash
# Standalone QA Review — no LLM agent needed.
# Queries Done items from PP Product Board, runs deterministic checks,
# pipes ambiguous items to R1 on Spark, moves items accordingly.
# Designed to run as a cron webhook or manual trigger.

set -uo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
QA_DIR="$WORKSPACE/qa"
SCRIPTS="$WORKSPACE/scripts"
GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt 2>/dev/null || echo "")
export GH_TOKEN

# Load board IDs
BOARD_IDS="$QA_DIR/board-ids.json"
PROJECT_ID=$(python3 -c "import json; print(json.load(open('$BOARD_IDS'))['project_id'])")
STATUS_FIELD=$(python3 -c "import json; print(json.load(open('$BOARD_IDS'))['status_field_id'])")
DONE_ID=$(python3 -c "import json; print(json.load(open('$BOARD_IDS'))['statuses']['done'])")
QA_REVIEW_ID=$(python3 -c "import json; print(json.load(open('$BOARD_IDS'))['statuses']['qa_review'])")
READY_ID=$(python3 -c "import json; print(json.load(open('$BOARD_IDS'))['statuses']['ready'])")
VERIFIED_ID=$(python3 -c "import json; print(json.load(open('$BOARD_IDS'))['statuses']['verified'])")

REPO="permission-protocol/app"

# Stats
VERIFIED=0
REOPENED=0
NEED_AC=0
AWAITING=0
ERRORS=0

move_item() {
  local item_id="$1"
  local status_id="$2"
  GH_TOKEN="$GH_TOKEN" gh api graphql -f query='
    mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $value: String!) {
      updateProjectV2ItemFieldValue(input: {
        projectId: $projectId
        itemId: $itemId
        fieldId: $fieldId
        value: {singleSelectOptionId: $value}
      }) { projectV2Item { id } }
    }' -f projectId="$PROJECT_ID" -f itemId="$item_id" -f fieldId="$STATUS_FIELD" -f value="$status_id" 2>/dev/null
}

comment_issue() {
  local issue_num="$1"
  local body="$2"
  GH_TOKEN="$GH_TOKEN" gh issue comment "$issue_num" -R "$REPO" -b "$body" 2>/dev/null
}

echo "$(date '+%H:%M:%S') 🔍 QA Review starting..."

# Fetch Done items
DONE_ITEMS=$(GH_TOKEN="$GH_TOKEN" gh api graphql -f query='
query {
  organization(login: "Roca-Ventures") {
    projectV2(number: 2) {
      items(first: 50) {
        nodes {
          id
          fieldValueByName(name: "Status") {
            ... on ProjectV2ItemFieldSingleSelectValue { name optionId }
          }
          content {
            ... on Issue { title number url }
            ... on DraftIssue { title }
          }
        }
      }
    }
  }
}' 2>/dev/null)

# Filter to Done items with issue numbers
ITEMS=$(echo "$DONE_ITEMS" | python3 -c "
import json, sys
data = json.load(sys.stdin)
items = data['data']['organization']['projectV2']['items']['nodes']
done = []
for item in items:
    fv = item.get('fieldValueByName')
    if not fv or fv.get('name') != 'QA Review':
        continue
    content = item.get('content', {})
    num = content.get('number')
    if num:
        done.append({'item_id': item['id'], 'number': num, 'title': content.get('title', '')})
print(json.dumps(done))
")

COUNT=$(echo "$ITEMS" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")
echo "$(date '+%H:%M:%S') Found $COUNT items in Done"

if [ "$COUNT" = "0" ]; then
  echo "$(date '+%H:%M:%S') ✅ Nothing to review"
  echo "QA reviewed 0 items. Board is clean."
  exit 0
fi

# Process each item
# Write items to temp file to avoid subshell counter issues
ITEM_LIST=$(mktemp)
echo "$ITEMS" | python3 -c "
import json, sys
for item in json.load(sys.stdin):
    print(f\"{item['item_id']}|{item['number']}|{item['title']}\")
" | head -20 > "$ITEM_LIST"

while IFS='|' read -r ITEM_ID ISSUE_NUM TITLE; do
  echo "$(date '+%H:%M:%S') 📋 Reviewing #$ISSUE_NUM: $TITLE"

  # Run deterministic tests
  PROOF_MAP=$(bash "$SCRIPTS/qa-test-runner.sh" "$ISSUE_NUM" auto 2>/dev/null)
  TEST_EXIT=$?

  if [ $TEST_EXIT -eq 0 ]; then
    # PASS — all proven
    echo "$(date '+%H:%M:%S') ✅ #$ISSUE_NUM: PASS"
    move_item "$ITEM_ID" "$VERIFIED_ID"
    comment_issue "$ISSUE_NUM" "🤖 **QA Verified** (automated)

All acceptance criteria verified by deterministic checks.

<details><summary>Proof map</summary>

\`\`\`json
$PROOF_MAP
\`\`\`
</details>"
    VERIFIED=$((VERIFIED + 1))

  elif [ $TEST_EXIT -eq 1 ]; then
    # FAIL — check if it's missing AC
    HAS_NO_AC=$(echo "$PROOF_MAP" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print('yes' if 'No AC block' in data.get('reason', '') else 'no')
" 2>/dev/null)

    if [ "$HAS_NO_AC" = "yes" ]; then
      echo "$(date '+%H:%M:%S') ⚠️  #$ISSUE_NUM: No AC block"
      move_item "$ITEM_ID" "$READY_ID"
      comment_issue "$ISSUE_NUM" "🤖 **QA Blocked** — No AC block found.

Add an \`## AC:\` section with checkboxes and a \`How to verify:\` section, then move back to Done."
      NEED_AC=$((NEED_AC + 1))
    else
      echo "$(date '+%H:%M:%S') ❌ #$ISSUE_NUM: FAIL"
      move_item "$ITEM_ID" "$READY_ID"
      comment_issue "$ISSUE_NUM" "🤖 **QA Failed** (automated)

<details><summary>Proof map</summary>

\`\`\`json
$PROOF_MAP
\`\`\`
</details>"
      REOPENED=$((REOPENED + 1))
    fi

  elif [ $TEST_EXIT -eq 2 ]; then
    # AMBIGUOUS — pipe to R1
    echo "$(date '+%H:%M:%S') 🤔 #$ISSUE_NUM: AMBIGUOUS — asking R1..."
    R1_VERDICT=$(echo "$PROOF_MAP" | bash "$SCRIPTS/qa-r1-judge.sh" 2>/dev/null)
    R1_EXIT=$?

    if [ $R1_EXIT -eq 0 ]; then
      echo "$(date '+%H:%M:%S') ✅ #$ISSUE_NUM: R1 says PASS"
      move_item "$ITEM_ID" "$VERIFIED_ID"
      comment_issue "$ISSUE_NUM" "🤖 **QA Verified** (R1 judgment)

Deterministic checks were inconclusive. R1 70B reviewed and approved.

<details><summary>R1 verdict</summary>

\`\`\`json
$R1_VERDICT
\`\`\`
</details>"
      VERIFIED=$((VERIFIED + 1))

    elif [ $R1_EXIT -eq 1 ]; then
      echo "$(date '+%H:%M:%S') ❌ #$ISSUE_NUM: R1 says FAIL"
      move_item "$ITEM_ID" "$READY_ID"
      comment_issue "$ISSUE_NUM" "🤖 **QA Failed** (R1 judgment)

<details><summary>R1 verdict</summary>

\`\`\`json
$R1_VERDICT
\`\`\`
</details>"
      REOPENED=$((REOPENED + 1))

    else
      # R1 system error — keep in QA Review
      echo "$(date '+%H:%M:%S') ⏳ #$ISSUE_NUM: R1 unavailable, staying in QA Review"
      comment_issue "$ISSUE_NUM" "🤖 **QA Pending** — Spark/R1 unavailable for judgment. Will retry next cycle."
      AWAITING=$((AWAITING + 1))
    fi
  fi

  # Save receipt
  RECEIPT_DIR="$QA_DIR/receipts/$(date '+%Y-%m')"
  mkdir -p "$RECEIPT_DIR"
  echo "$PROOF_MAP" > "$RECEIPT_DIR/issue-${ISSUE_NUM}.json"
done < "$ITEM_LIST"
rm -f "$ITEM_LIST"

echo ""
echo "========================================="
echo "QA reviewed $COUNT items: $VERIFIED verified, $REOPENED reopened, $NEED_AC need AC, $AWAITING awaiting Spark"
echo "========================================="
