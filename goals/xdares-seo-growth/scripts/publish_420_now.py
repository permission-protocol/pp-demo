import markdown
import sys
import os
import requests

def publish():
    md_file = "/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/drafts/420-party-guide-2026.md"
    wp_url = "https://blog.xdares.com/wp-json/wp/v2"
    wp_user = "cgoldber82@gmail.com"
    wp_pass = "yYD2 tcd5 lZXJ oxta aHWV UGl3"
    
    with open(md_file, 'r') as f:
        md_content = f.read()
    
    html_content = markdown.markdown(md_content)
    
    # Extract title from MD
    title = "The Ultimate 4/20 Party Guide 2026: Games, Stoner Dares & 18+ Fun"
    if md_content.startswith("# "):
        title = md_content.split("\n")[0].replace("# ", "").strip()
    
    slug = "420-party-guide-2026"
    
    response = requests.post(
        f"{wp_url}/posts",
        auth=(wp_user, wp_pass),
        json={
            'title': title,
            'content': html_content,
            'status': 'publish',
            'slug': slug
        },
        proxies={'http': 'socks5h://127.0.0.1:9050', 'https': 'socks5h://127.0.0.1:9050'}
    )
    
    if response.status_code == 201:
        print(f"SUCCESS: {response.json().get('link')}")
    else:
        print(f"Error: {response.status_code} - {response.text}")
        sys.exit(1)

if __name__ == "__main__":
    publish()
