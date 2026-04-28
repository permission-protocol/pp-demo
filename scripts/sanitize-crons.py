import json
import os

path = os.path.expanduser('~/.openclaw/workspace/cron_list.json')
with open(path, 'r') as f:
    data = json.load(f)

for job in data['jobs']:
    # 1. Increase timeout for critical crons
    if job['name'] in ['system-health-monitor', 'factory-github-sensor', 'factory-error-sensor', 'Token Health Check']:
        if 'payload' in job and 'timeoutSeconds' in job['payload']:
            job['payload']['timeoutSeconds'] = 120
    
    # 2. Fix malformed channel for pp-outreach-weekly-analysis
    if job['name'] == 'pp-outreach-weekly-analysis':
        if job['delivery']['channel'] == '1479273618448846858':
             job['delivery']['channel'] = 'discord'
             job['delivery']['to'] = '1479273618448846858'

with open(path, 'w') as f:
    json.dump(data, f, indent=2)

print("Sanitized cron_list.json (v2)")
