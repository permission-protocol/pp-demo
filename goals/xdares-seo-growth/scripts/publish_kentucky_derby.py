#!/usr/bin/env python3
"""Publish Kentucky Derby 2026 Drinking Games post to blog.xdares.com via Tor."""

import requests
import json
import base64
import re

WP_URL = "https://blog.xdares.com"
WP_USER = "cgoldber82@gmail.com"
WP_PASS = "yYD2 tcd5 lZXJ oxta aHWV UGl3"
HTML_FILE = "/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/content/kentucky-derby-2026-drinking-games.html"
PROXY = "socks5h://127.0.0.1:9050"

def publish():
    with open(HTML_FILE, 'r') as f:
        content = f.read()

    title_match = re.search(r'<title>(.*?)</title>', content)
    title = title_match.group(1) if title_match else "Kentucky Derby 2026 Drinking Games & Party Guide"

    token = base64.b64encode(f"{WP_USER}:{WP_PASS}".encode()).decode()
    headers = {
        'Authorization': f'Basic {token}',
        'Content-Type': 'application/json'
    }

    post_data = {
        'title': title,
        'content': content,
        'status': 'publish',
        'categories': [1],
        'slug': 'kentucky-derby-2026-drinking-games'
    }

    proxies = {'http': PROXY, 'https': PROXY}

    print(f"Publishing '{title}' via Tor...")
    response = requests.post(
        f"{WP_URL}/wp-json/wp/v2/posts",
        headers=headers,
        json=post_data,
        proxies=proxies,
        timeout=120
    )

    if response.status_code == 201:
        post_link = response.json().get('link')
        print(f"SUCCESS! Published at: {post_link}")
        return True, post_link
    elif response.status_code == 200:
        post_link = response.json().get('link')
        print(f"SUCCESS (200)! Published at: {post_link}")
        return True, post_link
    else:
        print(f"FAILED! Status: {response.status_code}")
        print(f"Error: {response.text[:500]}")
        return False, response.text

if __name__ == "__main__":
    success, result = publish()
    if not success:
        import sys
        sys.exit(1)
