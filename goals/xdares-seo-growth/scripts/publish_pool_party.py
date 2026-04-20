import markdown
import sys
import os
import requests

def publish():
    md_file = "/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/drafts/summer-pool-party-games-2026.md"
    wp_url = "https://blog.xdares.com/wp-json/wp/v2"
    wp_user = "cgoldber82@gmail.com"
    wp_pass = "yYD2 tcd5 lZXJ oxta aHWV UGl3"
    
    if not os.path.exists(md_file):
        print(f"File not found: {md_file}")
        sys.exit(1)

    with open(md_file, 'r') as f:
        md_content = f.read()
    
    html_content = markdown.markdown(md_content)
    
    title = "Summer Pool Party Games 2026: 35+ Epic Water Games for Adults"
    slug = "summer-pool-party-games-2026"
    
    # Simple Tor proxy check
    proxies = {
        'http': 'socks5h://127.0.0.1:9050',
        'https': 'socks5h://127.0.0.1:9050'
    }

    try:
        response = requests.post(
            f"{wp_url}/posts",
            auth=(wp_user, wp_pass),
            json={
                'title': title,
                'content': html_content,
                'status': 'publish',
                'slug': slug
            },
            proxies=proxies,
            timeout=30
        )
        
        if response.status_code == 201:
            print(f"SUCCESS: {response.json().get('link')}")
        else:
            print(f"Error: {response.status_code} - {response.text}")
            sys.exit(1)
    except Exception as e:
        print(f"Exception: {e}")
        sys.exit(1)

if __name__ == "__main__":
    publish()
