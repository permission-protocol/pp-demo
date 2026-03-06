#!/usr/bin/env python3
"""
Generate brand-aligned images for PP tweets using Nano Banana 2
(gemini-3.1-flash-image-preview)

Usage:
  python3 generate-image.py "prompt text" output.png
  python3 generate-image.py --tweet "tweet text" output.png  # auto-generates prompt from tweet
"""

import sys
import json
import os
import base64

GEMINI_KEY_FILE = os.path.expanduser("~/.openclaw/secrets/gemini-api.json")
MODEL = "gemini-3.1-flash-image-preview"

BRAND_PREFIX = (
    "Dark minimal tech illustration for Permission Protocol, "
    "an authorization infrastructure brand. "
    "Brand colors: teal (#44aa99) on void black (#0a0a0a). "
    "Clean geometric aesthetic, no text, no people. "
    "Moody editorial tech style. 16:9 aspect ratio. "
)

def get_api_key():
    with open(GEMINI_KEY_FILE) as f:
        return json.load(f)["api_key"]

def generate(prompt: str, output_path: str) -> str:
    from google import genai

    client = genai.Client(api_key=get_api_key())

    full_prompt = BRAND_PREFIX + prompt

    response = client.models.generate_content(
        model=MODEL,
        contents=[full_prompt],
        config={
            "response_modalities": ["TEXT", "IMAGE"],
        },
    )

    for part in response.candidates[0].content.parts:
        if hasattr(part, "inline_data") and part.inline_data:
            img_data = part.inline_data.data
            # If it's already bytes, write directly; if base64 string, decode
            if isinstance(img_data, str):
                img_data = base64.b64decode(img_data)
            with open(output_path, "wb") as f:
                f.write(img_data)
            print(f"Image saved: {output_path} ({len(img_data)//1024}KB)")
            return output_path

    print("Error: No image in response")
    for part in response.candidates[0].content.parts:
        if hasattr(part, "text") and part.text:
            print(f"Text: {part.text[:200]}")
    return None

def prompt_from_tweet(tweet_text: str) -> str:
    """Generate an image prompt that matches a tweet's content."""
    # Map common themes to visual concepts
    themes = {
        "receipt": "glowing teal cryptographic receipt floating in void, digital signature lines radiating outward",
        "authorization": "a shield-like authorization gate with teal energy flowing through circuit pathways",
        "monitor": "surveillance screens shattering while a single teal receipt remains solid and intact",
        "rogue": "a broken chain of command with scattered red nodes, one teal anchor point holding firm",
        "open-source": "interconnected teal nodes forming an open network pattern, code-like structures",
        "NIST": "official document with teal seal, government building silhouette, formal infrastructure",
        "SDK": "clean code blocks and package icons arranged in a teal-lit developer workspace",
        "agent": "autonomous robotic silhouette with teal authorization checkpoints along its action path",
        "payment": "financial transaction flow with teal verification checkpoints at each step",
        "deploy": "deployment pipeline with teal gates between each stage, infrastructure flowing",
    }

    prompt_parts = []
    tweet_lower = tweet_text.lower()
    for keyword, visual in themes.items():
        if keyword in tweet_lower:
            prompt_parts.append(visual)

    if not prompt_parts:
        prompt_parts.append("abstract teal energy patterns flowing through dark infrastructure grid")

    return ". ".join(prompt_parts[:2])


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 generate-image.py [--tweet] 'prompt' output.png")
        sys.exit(1)

    if sys.argv[1] == "--tweet":
        prompt = prompt_from_tweet(sys.argv[2])
        output = sys.argv[3] if len(sys.argv) > 3 else "/tmp/pp-tweet-image.png"
        print(f"Auto-prompt: {prompt}")
    else:
        prompt = sys.argv[1]
        output = sys.argv[2]

    generate(prompt, output)
