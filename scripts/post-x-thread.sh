#!/bin/bash
# Post an X thread from @PermissionPrtcl
# Usage: post-x-thread.sh thread-file.json [image-path]
#
# Thread file format (JSON array of strings):
# ["First tweet (hook)", "Second tweet", "Third tweet", ...]
#
# If image-path provided, attaches to first tweet.
#
# Examples:
#   post-x-thread.sh content/viral/thread.json
#   post-x-thread.sh content/viral/thread.json content/viral/image.png

set -euo pipefail

THREAD_FILE="$1"
IMAGE_PATH="${2:-}"

python3 -c "
import json, time, hmac, hashlib, base64, urllib.request, urllib.parse, uuid, os, sys

with open(os.path.expanduser('~/.openclaw/secrets/x-api-pp.json')) as f:
    keys = json.load(f)

CK, CS = keys['consumer_key'], keys['consumer_secret']
AT, ATS = keys['access_token'], keys['access_token_secret']

def oauth_sign(method, url, params, cs, ts):
    sp = '&'.join(f'{urllib.parse.quote(k, safe=\"\")}={urllib.parse.quote(v, safe=\"\")}' for k, v in sorted(params.items()))
    bs = f'{method}&{urllib.parse.quote(url, safe=\"\")}&{urllib.parse.quote(sp, safe=\"\")}'
    sk = f'{urllib.parse.quote(cs, safe=\"\")}&{urllib.parse.quote(ts, safe=\"\")}'
    return base64.b64encode(hmac.new(sk.encode(), bs.encode(), hashlib.sha256).digest()).decode()

def make_auth(method, url):
    op = {'oauth_consumer_key': CK, 'oauth_nonce': uuid.uuid4().hex, 'oauth_signature_method': 'HMAC-SHA256',
          'oauth_timestamp': str(int(time.time())), 'oauth_token': AT, 'oauth_version': '1.0'}
    op['oauth_signature'] = oauth_sign(method, url, op, CS, ATS)
    return 'OAuth ' + ', '.join(f'{urllib.parse.quote(k, safe=\"\")}=\"{urllib.parse.quote(v, safe=\"\")}\"' for k, v in sorted(op.items()))

def upload_media(filepath):
    url = 'https://upload.twitter.com/1.1/media/upload.json'
    with open(filepath, 'rb') as f: md = f.read()
    b = uuid.uuid4().hex
    body = f'--{b}\r\nContent-Disposition: form-data; name=\"media_data\"\r\n\r\n{base64.b64encode(md).decode()}\r\n--{b}--\r\n'.encode()
    req = urllib.request.Request(url, data=body, method='POST')
    req.add_header('Authorization', make_auth('POST', url))
    req.add_header('Content-Type', f'multipart/form-data; boundary={b}')
    return json.loads(urllib.request.urlopen(req, timeout=60).read())['media_id_string']

def tweet(text, reply_to=None, media_ids=None):
    url = 'https://api.twitter.com/2/tweets'
    p = {'text': text}
    if reply_to: p['reply'] = {'in_reply_to_tweet_id': reply_to}
    if media_ids: p['media'] = {'media_ids': media_ids}
    req = urllib.request.Request(url, data=json.dumps(p).encode(), method='POST')
    req.add_header('Authorization', make_auth('POST', url))
    req.add_header('Content-Type', 'application/json')
    r = json.loads(urllib.request.urlopen(req, timeout=30).read())
    tid = r['data']['id']
    print(f'https://x.com/PermissionPrtcl/status/{tid}')
    return tid

# Load thread
with open('$THREAD_FILE') as f:
    tweets_list = json.load(f)

# Upload image if provided
media_id = None
img = '$IMAGE_PATH'
if img:
    print('Uploading image...')
    media_id = upload_media(img)
    print(f'Media: {media_id}')

# Post thread
print('Posting thread...')
prev = None
for i, text in enumerate(tweets_list):
    m = [media_id] if (i == 0 and media_id) else None
    prev = tweet(text, reply_to=prev, media_ids=m)
    if i < len(tweets_list) - 1: time.sleep(2)

print(f'\nDone! {len(tweets_list)} tweets posted.')
"
