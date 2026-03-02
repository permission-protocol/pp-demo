#!/bin/bash
# Upload image to imgur, return URL
# Usage: imgur-upload.sh <image_path>
IMG_B64=$(base64 -i "$1")
curl -s -X POST 'https://api.imgur.com/3/image' \
  -H 'Authorization: Client-ID 546c25a59c58ad7' \
  -F "image=$IMG_B64" \
  -F "type=base64" | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',{}).get('link',''))"
