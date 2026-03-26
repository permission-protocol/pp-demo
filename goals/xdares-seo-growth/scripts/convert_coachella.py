import markdown
import sys
import os

def convert(md_file, html_file):
    with open(md_file, 'r') as f:
        md_content = f.read()
    
    html_content = markdown.markdown(md_content)
    
    # Simple HTML boilerplate
    title = os.path.basename(md_file).replace('.md', '').replace('-', ' ').title()
    full_html = f"<!DOCTYPE html>\n<html>\n<head>\n<title>{title}</title>\n</head>\n<body>\n{html_content}\n</body>\n</html>"
    
    with open(html_file, 'w') as f:
        f.write(full_html)
    print(f"Converted {md_file} to {html_file}")

if __name__ == "__main__":
    md_file = "/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/drafts/coachella-festival-party-guide-2026.md"
    html_file = "/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/content/coachella-festival-party-guide-2026.html"
    convert(md_file, html_file)
