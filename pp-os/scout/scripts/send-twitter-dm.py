#!/usr/bin/env python3
"""
Send a Twitter DM from @PermissionPrtcl

Usage:
  python3 send-twitter-dm.py @username "message text"
  python3 send-twitter-dm.py --user-id 12345 "message text"
"""

import json, os, sys
from requests_oauthlib import OAuth1Session

CREDS_FILE = os.path.expanduser("~/.openclaw/secrets/x-pp-api.json")

def get_oauth():
    creds = json.load(open(CREDS_FILE))
    return OAuth1Session(
        creds["oauth1"]["consumer_key"],
        creds["oauth1"]["consumer_secret"],
        creds["oauth1"]["access_token"],
        creds["oauth1"]["access_token_secret"],
    )

def lookup_user_id(oauth, username):
    """Get user ID from username"""
    username = username.lstrip("@")
    resp = oauth.get(f"https://api.x.com/2/users/by/username/{username}")
    if resp.status_code == 200:
        return resp.json()["data"]["id"]
    else:
        print(f"Error looking up @{username}: {resp.status_code} {resp.text}")
        return None

def send_dm(oauth, user_id, text):
    """Send a DM to a user"""
    resp = oauth.post(
        f"https://api.x.com/2/dm_conversations/with/{user_id}/messages",
        json={"text": text}
    )
    if resp.status_code in (200, 201):
        data = resp.json()
        print(f"DM sent. Event ID: {data.get('data', {}).get('dm_event_id', 'unknown')}")
        return data
    else:
        print(f"DM failed: {resp.status_code} {resp.text}")
        return None

def post_tweet_with_image(oauth, text, image_path=None):
    """Post a tweet, optionally with an image"""
    payload = {"text": text}
    
    if image_path and os.path.exists(image_path):
        # Upload image
        with open(image_path, "rb") as f:
            resp = oauth.post("https://upload.twitter.com/1.1/media/upload.json", files={"media": f})
        if resp.status_code in (200, 201, 202):
            media_id = resp.json()["media_id_string"]
            payload["media"] = {"media_ids": [media_id]}
            print(f"Image uploaded: {media_id}")
        else:
            print(f"Image upload failed: {resp.status_code}")
    
    resp = oauth.post("https://api.x.com/2/tweets", json=payload)
    if resp.status_code in (200, 201):
        tweet_id = resp.json()["data"]["id"]
        print(f"Tweet posted: https://x.com/PermissionPrtcl/status/{tweet_id}")
        return tweet_id
    else:
        print(f"Tweet failed: {resp.status_code} {resp.text}")
        return None


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 send-twitter-dm.py @username 'message'")
        sys.exit(1)
    
    oauth = get_oauth()
    
    if sys.argv[1] == "--user-id":
        user_id = sys.argv[2]
        message = sys.argv[3]
    else:
        user_id = lookup_user_id(oauth, sys.argv[1])
        message = sys.argv[2]
    
    if user_id:
        send_dm(oauth, user_id, message)
