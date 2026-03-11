#!/usr/bin/env python3
"""Post tweets, replies, or threads via X API v2 with OAuth 1.0a.

Usage:
    python3 post-tweet.py tweet "Your tweet text"
    python3 post-tweet.py reply TWEET_ID "Your reply text"
    python3 post-tweet.py thread "Tweet 1" "Tweet 2" "Tweet 3"
    python3 post-tweet.py delete TWEET_ID
"""
import json, sys, os

from requests_oauthlib import OAuth1Session

KEYS_PATH = os.path.expanduser("~/.openclaw/secrets/x-pp-api.json")

def get_oauth():
    with open(KEYS_PATH) as f:
        keys = json.load(f)
    return OAuth1Session(
        keys["oauth1"]["consumer_key"],
        client_secret=keys["oauth1"]["consumer_secret"],
        resource_owner_key=keys["oauth1"]["access_token"],
        resource_owner_secret=keys["oauth1"]["access_token_secret"],
    )

def post_tweet(text, reply_to=None, quote_id=None):
    oauth = get_oauth()
    payload = {"text": text}
    if reply_to:
        payload["reply"] = {"in_reply_to_tweet_id": reply_to}
    if quote_id:
        payload["quote_tweet_id"] = quote_id
    resp = oauth.post("https://api.x.com/2/tweets", json=payload)
    data = resp.json()
    if resp.status_code in (200, 201):
        tweet_id = data["data"]["id"]
        print(f"OK: https://x.com/PermissionPrtcl/status/{tweet_id}")
        return tweet_id
    else:
        print(f"ERROR {resp.status_code}: {json.dumps(data, indent=2)}")
        return None

def post_thread(tweets):
    prev_id = None
    for i, text in enumerate(tweets):
        print(f"\n--- Tweet {i+1}/{len(tweets)} ---")
        tweet_id = post_tweet(text, reply_to=prev_id)
        if not tweet_id:
            print(f"Thread broken at tweet {i+1}")
            return
        prev_id = tweet_id

def delete_tweet(tweet_id):
    oauth = get_oauth()
    resp = oauth.delete(f"https://api.x.com/2/tweets/{tweet_id}")
    print(f"Delete {tweet_id}: {resp.status_code} {resp.json()}")

if __name__ == "__main__":
    mode = sys.argv[1]
    if mode == "tweet":
        post_tweet(sys.argv[2])
    elif mode == "reply":
        post_tweet(sys.argv[3], reply_to=sys.argv[2])
    elif mode == "quote":
        post_tweet(sys.argv[3], quote_id=sys.argv[2])
    elif mode == "thread":
        post_thread(sys.argv[2:])
    elif mode == "delete":
        delete_tweet(sys.argv[2])
    elif mode == "follow":
        oauth = get_oauth()
        user_id = sys.argv[2]
        payload = {"target_user_id": user_id}
        resp = oauth.post(f"https://api.x.com/2/users/2026663150540697603/following", json=payload)
        print(f"Follow {user_id}: {resp.status_code} {resp.json()}")
    else:
        print(f"Unknown mode: {mode}")
        print(__doc__)
