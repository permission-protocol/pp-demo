#!/bin/bash
# Generate an image using Gemini 3.1 Flash Image Preview
# Usage: gen-image.sh "prompt" output-path.png
#
# Examples:
#   gen-image.sh "Dark tech illustration of a broken lock" /tmp/broken-lock.png
#   gen-image.sh "Gravestone with a cursor symbol" content/viral/image.png

set -euo pipefail

PROMPT="$1"
OUTPUT="${2:-/tmp/generated-image.png}"

# Prepend brand prefix
BRAND_PREFIX="Dark minimal tech illustration for Permission Protocol. Brand colors: teal (#44aa99) on void black (#0a0a0a). Clean geometric aesthetic, no text, no logos. Moody editorial tech style. 16:9 aspect ratio."

python3 -c "
import json, base64, urllib.request, os

with open(os.path.expanduser('~/.openclaw/secrets/gemini-api.json')) as f:
    api_key = json.load(f)['api_key']

URL = f'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-image-preview:generateContent?key={api_key}'

prompt = '''$BRAND_PREFIX $PROMPT'''

data = {
    'contents': [{'parts': [{'text': prompt}]}],
    'generationConfig': {'responseModalities': ['TEXT', 'IMAGE']}
}

req = urllib.request.Request(URL, data=json.dumps(data).encode(), headers={'Content-Type': 'application/json'}, method='POST')
resp = urllib.request.urlopen(req, timeout=120)
result = json.loads(resp.read())

for part in result['candidates'][0]['content']['parts']:
    if 'inlineData' in part:
        img_data = base64.b64decode(part['inlineData']['data'])
        outpath = '$OUTPUT'
        os.makedirs(os.path.dirname(outpath) or '.', exist_ok=True)
        with open(outpath, 'wb') as f:
            f.write(img_data)
        print(f'OK: {outpath} ({len(img_data)} bytes)')
        break
else:
    print('ERROR: No image in response')
    print(json.dumps(result, indent=2)[:2000])
    exit(1)
"
