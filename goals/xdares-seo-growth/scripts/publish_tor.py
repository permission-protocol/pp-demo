import sys
import json
import base64
import subprocess

def publish_post(title, content_path, auth_base64):
    with open(content_path, 'r') as f:
        content = f.read()
    
    # Simple post payload
    data = {
        'title': title,
        'content': content,
        'status': 'publish',
        'categories': [5], # Party Games category from state logs
    }
    
    json_data = json.dumps(data)
    
    # Curl command via Tor
    cmd = [
        'curl', '-s', '--socks5-hostname', 'localhost:9050',
        '-X', 'POST',
        '-H', f'Authorization: Basic {auth_base64}',
        '-H', 'Content-Type: application/json',
        '-d', json_data,
        'https://blog.xdares.com/wp-json/wp/v2/posts'
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout

if __name__ == "__main__":
    # Inlined base64 to avoid interactive exec issues
    auth = "Y2dvbGRiZXI4MkBnbWFpbC5jb206eVlEMiB0Y2Q1IGxaWEogb3h0YSBhSFdWIFVHbDM="
    title = "Backyard Beer Olympics 2026: Rules, Scoresheets & Winning Strategy"
    path = "/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/drafts/backyard-beer-olympics-2026.md"
    
    print(publish_post(title, path, auth))
