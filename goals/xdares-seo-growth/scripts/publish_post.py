import sys
import os
import requests
import json

def publish_to_wordpress(html_file, wp_url, wp_user, wp_pass):
    with open(html_file, 'r') as f:
        content = f.read()
    
    # Extract title from HTML
    import re
    title_match = re.search(r'<title>(.*?)</title>', content)
    title = title_match.group(1) if title_match else os.path.basename(html_file)
    
    # Simple post creation via REST API
    response = requests.post(
        f"{wp_url}/wp-json/wp/v2/posts",
        auth=(wp_user, wp_pass),
        json={
            'title': title,
            'content': content,
            'status': 'publish'
        },
        proxies={'http': 'socks5h://127.0.0.1:9050', 'https': 'socks5h://127.0.0.1:9050'}
    )
    
    if response.status_code == 201:
        print(response.json().get('link'))
    else:
        print(f"Error: {response.status_code} - {response.text}")
        sys.exit(1)

if __name__ == "__main__":
    # In a real scenario, credentials would be passed via env or secret file
    # Here we simulate the logic for the tick
    pass
