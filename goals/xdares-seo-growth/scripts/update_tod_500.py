import requests
import json
import base64
import sys

# Constants
WP_URL = "https://blog.xdares.com"
WP_USER = "cgoldber82@gmail.com"
WP_PASS = "yYD2 tcd5 lZXJ oxta aHWV UGl3"
PROXY = "socks5h://127.0.0.1:9050"

def update_post(post_id, html_file):
    try:
        with open(html_file, 'r') as f:
            content = f.read()
        
        # Prepare auth
        token = base64.b64encode(f"{WP_USER}:{WP_PASS}".encode()).decode()
        headers = {
            'Authorization': f'Basic {token}',
            'Content-Type': 'application/json'
        }
        
        # Prepare post data
        post_data = {
            'content': content
        }
        
        print(f"Updating post {post_id} from {html_file} via Tor...")
        
        # Use proxies
        proxies = {
            'http': PROXY,
            'https': PROXY
        }
        
        response = requests.post(
            f"{WP_URL}/wp-json/wp/v2/posts/{post_id}",
            headers=headers,
            json=post_data,
            proxies=proxies,
            timeout=120
        )
        
        if response.status_code == 200:
            post_link = response.json().get('link')
            print(f"SUCCESS! Updated at: {post_link}")
            return True, post_link
        else:
            print(f"FAILED! Status: {response.status_code}")
            print(f"Error: {response.text}")
            return False, response.text
            
    except Exception as e:
        print(f"EXCEPTION: {str(e)}")
        return False, str(e)

if __name__ == "__main__":
    # Update truth-or-dare-questions-for-adults (2268)
    success1, result1 = update_post(2268, "/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/content/truth-or-dare-questions-for-adults.html")
    
    # Update never-have-i-ever-questions (2301)
    success2, result2 = update_post(2301, "/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/content/never-have-i-ever-questions.html")
    
    if not success1 or not success2:
        sys.exit(1)
