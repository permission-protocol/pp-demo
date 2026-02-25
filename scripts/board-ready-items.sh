#!/bin/bash
# Fetch Ready items from PP Product Board
# Output: JSON array of {number, title, state, priority} sorted by priority
set -uo pipefail

GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt)

GH_TOKEN="$GH_TOKEN" gh api graphql -f query='query {
  organization(login: "Roca-Ventures") {
    projectV2(number: 2) {
      items(first: 100) {
        nodes {
          fieldValueByName(name: "Status") {
            ... on ProjectV2ItemFieldSingleSelectValue { name optionId }
          }
          content {
            ... on Issue { title number state labels(first:10) { nodes { name } } }
            ... on DraftIssue { title }
          }
        }
      }
    }
  }
}' --jq '[.data.organization.projectV2.items.nodes[] | select(.fieldValueByName.name == "Ready") | select(.content.number != null) | {number: .content.number, title: .content.title, state: .content.state, labels: [.content.labels.nodes[].name]}]' 2>/dev/null | python3 -c "
import json, sys
items = json.load(sys.stdin)

def priority(item):
    title = item['title']
    if '🔴' in title or 'P0' in title: return 0
    if '🟡' in title or 'P1' in title: return 1
    if '🟢' in title or 'P2' in title: return 2
    return 3

items.sort(key=priority)
print(json.dumps(items, indent=2))
"
