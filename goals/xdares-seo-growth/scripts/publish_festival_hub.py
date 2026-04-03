import requests
import json
import base64
import sys
import re

# Constants
WP_URL = "https://blog.xdares.com"
WP_USER = "cgoldber82@gmail.com"
WP_PASS = "yYD2 tcd5 lZXJ oxta aHWV UGl3"
HTML_FILE = "/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/content/festival-party-games-hub.html"
PROXY = "socks5h://127.0.0.1:9050"

def publish():
    try:
        with open(HTML_FILE, 'r') as f:
            content = f.read()
        
        # Extract title
        title_match = re.search(r'<title>(.*?)</title>', content)
        title = title_match.group(1) if title_match else "The Ultimate Guide to Music Festival Games: Coachella, EDM & Rave 2026"
        
        # Prepare auth
        token = base64.b64encode(f"{WP_USER}:{WP_PASS}".encode()).decode()
        headers = {
            'Authorization': f'Basic {token}',
            'Content-Type': 'application/json'
        }
        
        # Prepare post data
        post_data = {
            'title': title,
            'content': content,
            'status': 'publish',
            'categories': [1], # Assuming general category
            'slug': 'music-festival-party-games'
        }
        
        print(f"Publishing '{title}' to {WP_URL} via Tor...")
        
        # Use proxies
        proxies = {
            'http': PROXY,
            'https': PROXY
        }
        
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
