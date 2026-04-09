#!/usr/bin/env bash
# scripts/promote-bounties.sh
# Syncs P0/P1 bounties from factory/ideas.jsonl to the GitHub Project Board

set -e

GH_TOKEN=$(cat "$HOME/.openclaw/secrets/github-pat-projects.txt")
IDEAS_FILE="$HOME/.openclaw/workspace/factory/ideas.jsonl"
PROJECT_ID="PVT_kwDOD2Ims84BRQBA"
OWNER="permission-protocol"
PROJECT_NUMBER=1

# Field IDs
STATUS_FIELD="PVTSSF_lADOD2Ims84BRQBAzg_IfZ8"
READY_OPTION="61e4505c"
PRIORITY_FIELD="PVTSSF_lADOD2Ims84BRQBAzg_IfwY"
P0_OPTION="79628723"
P1_OPTION="0a877460"

if [[ ! -f "$IDEAS_FILE" ]]; then
  echo "No ideas file found."
  exit 0
fi

echo "Promoting P0/P1 bounties to 'Ready' on Project Board..."

# Use python to extract URLs of P0/P1 items in 'ready' status
URLS=$(python3 -c "
import json, os
ideas_file = '$IDEAS_FILE'
if os.path.exists(ideas_file):
    with open(ideas_file, 'r') as f:
        for line in f:
            if not line.strip(): continue
            try:
                b = json.loads(line)
                if b.get('status') == 'ready' and b.get('priority') in ['p0', 'p1']:
                    url = b.get('github_url')
                    if url:
                        print(f\"{url}|{b.get('priority')}\")
            except:
                pass
")

for entry in $URLS; do
  URL=$(echo "$entry" | cut -d'|' -f1)
  PRIORITY=$(echo "$entry" | cut -d'|' -f2)
  
  echo "Syncing $URL (Priority: $PRIORITY)..."
  
  # Add item to project
  ITEM_ID=$(GH_TOKEN="$GH_TOKEN" gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$URL" --format json | python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))")
  
  if [[ -n "$ITEM_ID" ]]; then
    # Set Status to Ready
    GH_TOKEN="$GH_TOKEN" gh project item-edit --id "$ITEM_ID" --project-id "$PROJECT_ID" --field-id "$STATUS_FIELD" --single-select-option-id "$READY_OPTION" > /dev/null
    
    # Set Priority
    PRIO_OPTION="$P1_OPTION"
    if [[ "$PRIORITY" == "p0" ]]; then PRIO_OPTION="$P0_OPTION"; fi
    GH_TOKEN="$GH_TOKEN" gh project item-edit --id "$ITEM_ID" --project-id "$PROJECT_ID" --field-id "$PRIORITY_FIELD" --single-select-option-id "$PRIO_OPTION" > /dev/null
    
    echo "  Successfully promoted to board."
  fi
done

echo "Done."
