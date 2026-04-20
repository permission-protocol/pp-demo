import requests
import json
import base64
import sys

# Constants
WP_URL = "https://blog.xdares.com"
WP_USER = "cgoldber82@gmail.com"
WP_PASS = "yYD2 tcd5 lZXJ oxta aHWV UGl3"
MD_FILE = "/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/drafts/backyard-beer-olympics-2026.md"
PROXY = "socks5h://127.0.0.1:9050"

def publish():
    try:
        with open(MD_FILE, 'r') as f:
            content = f.read()
        
        # Prepare auth
        token = base64.b64encode(f"{WP_USER}:{WP_PASS}".encode()).decode()
        headers = {
            'Authorization': f'Basic {token}',
            'Content-Type': 'application/json'
        }
        
        # Prepare post data
        post_data = {
            'title': "Backyard Beer Olympics 2026: Rules, Games & Winning Strategy",
            'content': content,
            'status': 'publish',
            'slug': 'backyard-beer-olympics-2026'
        }
        
        print(f"Publishing Beer Olympics to {WP_URL} via Tor...")
        
        proxies = {'http': PROXY, 'https': PROXY}
        
        response = requests.post(
            f"{WP_URL}/wp-json/wp/v2/posts",
            headers=headers,
            json=post_data,
            proxies=proxies,
            timeout=300
        )
        
        if response.status_code == 201:
            post_link = response.json().get('link')
            print(f"SUCCESS! Published at: {post_link}")
            return True, post_link
        else:
            print(f"FAILED! Status: {response.status_code}")
            print(f"Error: {response.text}")
            return False, response.text
            
    except Exception as e:
        print(f"EXCEPTION: {str(e)}")
        return False, str(e)

if __name__ == "__main__":
    success, result = publish()
    if not success:
        sys.exit(1)
