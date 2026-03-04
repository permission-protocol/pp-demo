#!/bin/bash
# Fetch Ready items from PP Product Board (with pagination)
# Output: JSON array of {number, title, state, priority} sorted by priority
set -uo pipefail

GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt)

# Use a Python script for clean pagination
GH_TOKEN="$GH_TOKEN" python3 -c "
import subprocess, json, os

def fetch_page(cursor=None):
    after = f', after: \"{cursor}\"' if cursor else ''
    query = '''query {
      organization(login: \"Roca-Ventures\") {
        projectV2(number: 2) {
          items(first: 100''' + after + ''') {
            pageInfo { hasNextPage endCursor }
            nodes {
              fieldValueByName(name: \"Status\") {
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
    }'''
    result = subprocess.run(
        ['gh', 'api', 'graphql', '-f', f'query={query}'],
        capture_output=True, text=True,
        env={**os.environ, 'GH_TOKEN': os.environ['GH_TOKEN']}
    )
    return json.loads(result.stdout)

ready_items = []
cursor = None

while True:
    data = fetch_page(cursor)
    items_data = data['data']['organization']['projectV2']['items']
    
    for node in items_data['nodes']:
        status = (node.get('fieldValueByName') or {}).get('name', '')
        content = node.get('content') or {}
        if status == 'Ready' and content.get('number'):
            ready_items.append({
                'number': content['number'],
                'title': content['title'],
                'state': content.get('state', ''),
                'labels': [l['name'] for l in content.get('labels', {}).get('nodes', [])]
            })
    
    if not items_data['pageInfo']['hasNextPage']:
        break
    cursor = items_data['pageInfo']['endCursor']

# Sort by priority
def priority(item):
    title = item['title']
    if '\U0001f534' in title or 'P0' in title: return 0
    if '\U0001f7e1' in title or 'P1' in title: return 1
    if '\U0001f7e2' in title or 'P2' in title: return 2
    return 3

ready_items.sort(key=priority)
print(json.dumps(ready_items, indent=2))
"
