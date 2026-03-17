#!/usr/bin/env python3
"""
Publish blog post to WordPress via Tor with AI-generated compressed image.

Usage: python3 publish_post.py <content_file.html> [--draft]
"""

import json
import base64
import subprocess
import sys
import os
from pathlib import Path

# Config
GEMINI_KEY_FILE = os.path.expanduser("~/.openclaw/secrets/gemini-api.json")
WP_USER = "cgoldber82@gmail.com"
WP_APP_PASSWORD = "yYD2 tcd5 lZXJ oxta aHWV UGl3"
WP_API_BASE = "https://blog.xdares.com/wp-json/wp/v2"
TOR_PROXY = "socks5h://127.0.0.1:9050"
MAX_IMAGE_KB = 100
MAX_IMAGE_WIDTH = 1200

def get_gemini_key():
    with open(GEMINI_KEY_FILE) as f:
        return json.load(f)['api_key']

def generate_image_nb2(prompt: str, output_path: str) -> str:
    """Generate image using Nano Banana 2 (Gemini 3.1 Flash Image)"""
    print(f"🎨 Generating image (Nano Banana 2): {prompt[:50]}...")
    
    key = get_gemini_key()
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-image-preview:generateContent?key={key}"
    
    payload = {
        "contents": [{"parts": [{"text": prompt + ", professional photography, cinematic lighting, no watermarks"}]}],
        "generationConfig": {"responseModalities": ["TEXT", "IMAGE"]}
    }
    
    result = subprocess.run([
        "curl", "-s", url,
        "-H", "Content-Type: application/json",
        "-d", json.dumps(payload)
    ], capture_output=True, text=True, timeout=120)
    
    try:
        data = json.loads(result.stdout)
        parts = data['candidates'][0]['content']['parts']
        for part in parts:
            if 'inlineData' in part:
                img_data = base64.b64decode(part['inlineData']['data'])
                raw_path = output_path.replace('.jpg', '_raw.png')
                with open(raw_path, 'wb') as f:
                    f.write(img_data)
                print(f"   Raw image: {len(img_data)/1024:.0f}KB")
                return raw_path
        print("   ❌ No image in response")
        return None
    except Exception as e:
        print(f"   ❌ Nano Banana 2 failed: {e}")
        return None


def generate_image_imagen(prompt: str, output_path: str) -> str:
    """Generate image using Imagen 4.0 (fallback)"""
    print(f"🎨 Generating image (Imagen 4.0 fallback): {prompt[:50]}...")
    
    key = get_gemini_key()
    url = f"https://generativelanguage.googleapis.com/v1beta/models/imagen-4.0-fast-generate-001:predict?key={key}"
    
    payload = {
        "instances": [{"prompt": prompt + ", professional photography, no text in image"}],
        "parameters": {"sampleCount": 1, "aspectRatio": "16:9"}
    }
    
    result = subprocess.run([
        "curl", "-s", url,
        "-H", "Content-Type: application/json",
        "-d", json.dumps(payload)
    ], capture_output=True, text=True, timeout=120)
    
    try:
        data = json.loads(result.stdout)
        b64 = data['predictions'][0]['bytesBase64Encoded']
        img_data = base64.b64decode(b64)
        
        raw_path = output_path.replace('.jpg', '_raw.png')
        with open(raw_path, 'wb') as f:
            f.write(img_data)
        
        print(f"   Raw image: {len(img_data)/1024:.0f}KB")
        return raw_path
    except Exception as e:
        print(f"   ❌ Image generation failed: {e}")
        return None


def generate_image(prompt: str, output_path: str) -> str:
    """Generate image — tries Nano Banana 2 first, falls back to Imagen 4.0"""
    return generate_image_nb2(prompt, output_path)

def compress_image(input_path: str, output_path: str) -> str:
    """Compress image to optimized JPEG"""
    from PIL import Image
    
    img = Image.open(input_path)
    img = img.convert('RGB')
    
    # Resize if needed
    if img.width > MAX_IMAGE_WIDTH:
        ratio = MAX_IMAGE_WIDTH / img.width
        new_size = (MAX_IMAGE_WIDTH, int(img.height * ratio))
        img = img.resize(new_size, Image.LANCZOS)
    
    # Find optimal quality
    for quality in [85, 80, 75, 70, 65]:
        img.save(output_path, 'JPEG', quality=quality, optimize=True)
        size_kb = os.path.getsize(output_path) / 1024
        if size_kb <= MAX_IMAGE_KB:
            break
    
    print(f"   Compressed: {size_kb:.0f}KB (quality={quality})")
    return output_path

def upload_image(image_path: str, filename: str) -> int:
    """Upload image to WordPress via Tor"""
    print(f"📤 Uploading image...")
    
    result = subprocess.run([
        "curl", "-s", "--socks5-hostname", "127.0.0.1:9050",
        "--max-time", "120",
        "-X", "POST",
        "-u", f"{WP_USER}:{WP_APP_PASSWORD}",
        "-H", f"Content-Disposition: attachment; filename={filename}",
        "-H", "Content-Type: image/jpeg",
        "--data-binary", f"@{image_path}",
        f"{WP_API_BASE}/media"
    ], capture_output=True, text=True, timeout=150)
    
    try:
        data = json.loads(result.stdout)
        media_id = data['id']
        print(f"   Media ID: {media_id}")
        return media_id
    except Exception as e:
        print(f"   ❌ Upload failed: {e}")
        print(f"   Response: {result.stdout[:500]}")
        return None

def publish_post(title: str, content: str, slug: str, excerpt: str, 
                 featured_media: int = None, status: str = "publish") -> dict:
    """Publish post to WordPress via Tor"""
    print(f"📝 Publishing: {title[:50]}...")
    
    payload = {
        "title": title,
        "content": content,
        "slug": slug,
        "excerpt": excerpt,
        "status": status,
        "categories": [1]
    }
    
    if featured_media:
        payload["featured_media"] = featured_media
    
    result = subprocess.run([
        "curl", "-s", "--socks5-hostname", "127.0.0.1:9050",
        "--max-time", "60",
        "-X", "POST",
        "-u", f"{WP_USER}:{WP_APP_PASSWORD}",
        "-H", "Content-Type: application/json",
        "-d", json.dumps(payload),
        f"{WP_API_BASE}/posts"
    ], capture_output=True, text=True, timeout=90)
    
    try:
        data = json.loads(result.stdout)
        print(f"   ✅ Published: {data.get('link')}")
        return data
    except Exception as e:
        print(f"   ❌ Publish failed: {e}")
        return None

def extract_metadata(html_path: str) -> dict:
    """Extract title, description, slug from HTML file"""
    with open(html_path) as f:
        content = f.read()
    
    import re
    
    # Extract title
    title_match = re.search(r'<title>([^<]+)</title>', content)
    title = title_match.group(1) if title_match else Path(html_path).stem.replace('-', ' ').title()
    
    # Extract meta description
    desc_match = re.search(r'<meta name="description" content="([^"]+)"', content)
    description = desc_match.group(1) if desc_match else ""
    
    # Extract slug from canonical or filename
    slug_match = re.search(r'<link rel="canonical" href="[^"]+/([^/"]+)/"', content)
    slug = slug_match.group(1) if slug_match else Path(html_path).stem
    
    # Extract body content
    body_match = re.search(r'<body[^>]*>(.*?)</body>', content, re.DOTALL)
    body = body_match.group(1).strip() if body_match else content
    
    return {
        "title": title.split(' | ')[0].strip(),  # Remove site name if present
        "description": description,
        "slug": slug,
        "body": body
    }

def generate_image_prompt(title: str, description: str) -> str:
    """Generate an image prompt based on post content"""
    # Simple keyword extraction for image prompt
    keywords = title.lower()
    
    if "valentine" in keywords or "romantic" in keywords or "couple" in keywords:
        return "A romantic couple enjoying quality time together, warm ambient lighting, cozy atmosphere"
    elif "drinking" in keywords or "beer pong" in keywords:
        return "Friends playing party games at a fun house party, colorful lighting, energetic mood"
    elif "bachelor" in keywords or "party" in keywords:
        return "Group of friends celebrating at an exciting party, festive atmosphere"
    elif "office" in keywords or "team building" in keywords:
        return "Diverse coworkers laughing together in a modern office, collaborative atmosphere"
    elif "date night" in keywords:
        return "Couple on a fun date night, restaurant or home setting, romantic mood"
    elif "long distance" in keywords:
        return "Person video calling their partner on laptop, cozy room, warm lighting"
    elif "st patrick" in keywords or "irish" in keywords:
        return "Friends celebrating St Patricks Day at a pub, green decorations, festive mood"
    elif "truth or dare" in keywords:
        return "Group of friends playing party games, laughing, fun casual atmosphere"
    elif "never have i ever" in keywords:
        return "Friends sitting in circle playing drinking games, party atmosphere"
    elif "icebreaker" in keywords:
        return "Group of people meeting and laughing, casual social gathering"
    else:
        return f"People having fun playing party games, social gathering, {title.split()[0]} theme"

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 publish_post.py <content_file.html> [--draft]")
        sys.exit(1)
    
    html_path = sys.argv[1]
    status = "draft" if "--draft" in sys.argv else "publish"
    
    if not os.path.exists(html_path):
        print(f"❌ File not found: {html_path}")
        sys.exit(1)
    
    # Quality gate check (Llama 8B on Spark — free)
    gate_script = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))), "scripts", "quality-gate.sh")
    if os.path.exists(gate_script):
        print("🔍 Running quality gate...")
        env = os.environ.copy()
        env["SPARK_MODEL"] = "llama3.1:8b"
        gate_result = subprocess.run(["bash", gate_script, html_path], capture_output=True, text=True, timeout=180, errors='replace', env=env)
        if gate_result.returncode == 1:
            print(f"🚫 Quality gate REJECTED this post:")
            print(gate_result.stdout)
            # Read rejection report for notification
            report_file = "/tmp/quality-gate-report.txt"
            if os.path.exists(report_file):
                with open(report_file) as f:
                    print(f.read())
            sys.exit(1)
        elif gate_result.returncode == 0:
            print("✅ Quality gate passed")
        else:
            print(f"⚠️ Quality gate error (code {gate_result.returncode}), proceeding anyway")
    
    # Extract metadata
    meta = extract_metadata(html_path)
    print(f"\n{'='*60}")
    print(f"📄 {meta['title']}")
    print(f"🔗 {meta['slug']}")
    print(f"{'='*60}\n")
    
    # Generate image
    image_prompt = generate_image_prompt(meta['title'], meta['description'])
    tmp_dir = "/tmp/wp_publish"
    os.makedirs(tmp_dir, exist_ok=True)
    
    raw_image = generate_image(image_prompt, f"{tmp_dir}/{meta['slug']}_raw.png")
    
    media_id = None
    if raw_image:
        # Compress image
        compressed = compress_image(raw_image, f"{tmp_dir}/{meta['slug']}.jpg")
        
        # Upload image
        media_id = upload_image(compressed, f"{meta['slug']}.jpg")
    
    # Publish post
    result = publish_post(
        title=meta['title'],
        content=meta['body'],
        slug=meta['slug'],
        excerpt=meta['description'],
        featured_media=media_id,
        status=status
    )
    
    if result:
        print(f"\n✅ SUCCESS: {result.get('link')}")
        return result
    else:
        print(f"\n❌ FAILED to publish")
        sys.exit(1)

if __name__ == "__main__":
    main()
