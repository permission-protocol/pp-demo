#!/usr/bin/env python3
"""
Rate-limited Twitter poster for @PermissionPrtcl.

Usage:
  python3 pp-tweet.py "Tweet text here"
  python3 pp-tweet.py --file /path/to/draft.md
  python3 pp-tweet.py --check  (check rate limit status)

Rate limits (free tier):
  - 17 tweets/day max (we cap at 10 for safety)
  - 1 tweet per 15 min (we enforce 16 min gaps)
  - No replies allowed on free tier
"""

import json, os, sys, time, argparse
from datetime import datetime, timezone
from pathlib import Path

CREDS_PATH = os.path.expanduser("~/.openclaw/secrets/x-api-permissionprtcl.json")
STATE_PATH = os.path.expanduser("~/.openclaw/workspace/pp-os/scout/outreach/tweet-state.json")
DAILY_CAP = 10
MIN_GAP_SECONDS = 960  # 16 minutes

def load_state():
    if os.path.exists(STATE_PATH):
        with open(STATE_PATH) as f:
            return json.load(f)
    return {"tweets_today": [], "last_post_ts": 0}

def save_state(state):
    os.makedirs(os.path.dirname(STATE_PATH), exist_ok=True)
    with open(STATE_PATH, "w") as f:
        json.dump(state, f, indent=2)

def prune_old_tweets(state):
    """Remove tweets older than 24 hours from the daily counter."""
    now = time.time()
    state["tweets_today"] = [
        t for t in state["tweets_today"]
        if now - t["ts"] < 86400
    ]
    return state

def check_rate_limit(state):
    """Returns (can_post: bool, wait_seconds: int, reason: str)"""
    state = prune_old_tweets(state)
    
    if len(state["tweets_today"]) >= DAILY_CAP:
        return False, 0, f"Daily cap reached ({len(state['tweets_today'])}/{DAILY_CAP})"
    
    now = time.time()
    gap = now - state["last_post_ts"]
    if gap < MIN_GAP_SECONDS:
        wait = int(MIN_GAP_SECONDS - gap)
        return False, wait, f"Rate limit: wait {wait}s ({int(wait/60)}m {wait%60}s)"
    
    return True, 0, f"OK — {len(state['tweets_today'])}/{DAILY_CAP} today"

def post_tweet(text):
    try:
        import requests
        from requests_oauthlib import OAuth1
    except ImportError:
        print("ERROR: pip install requests requests_oauthlib")
        sys.exit(1)
    
    with open(CREDS_PATH) as f:
        creds = json.load(f)
    
    o1 = creds["oauth1"]
    auth = OAuth1(o1["consumer_key"], o1["consumer_secret"], 
                  o1["access_token"], o1["access_token_secret"])
    
    r = requests.post("https://api.twitter.com/2/tweets", json={"text": text}, auth=auth)
    return r.status_code, r.json() if r.status_code in (200, 201) else r.text

def extract_tweets_from_md(filepath):
    """Extract tweet texts from a markdown draft file (## Tweet N sections)."""
    with open(filepath) as f:
        content = f.read()
    
    tweets = []
    current = []
    in_tweet = False
    
    for line in content.split("\n"):
        if line.startswith("## Tweet"):
            if current and in_tweet:
                tweets.append("\n".join(current).strip())
            current = []
            in_tweet = True
        elif line.startswith("## ") or line.startswith("---"):
            if current and in_tweet:
                tweets.append("\n".join(current).strip())
            current = []
            in_tweet = False
        elif in_tweet:
            current.append(line)
    
    if current and in_tweet:
        tweets.append("\n".join(current).strip())
    
    return tweets

def main():
    parser = argparse.ArgumentParser(description="Rate-limited @PermissionPrtcl tweeter")
    parser.add_argument("text", nargs="?", help="Tweet text")
    parser.add_argument("--file", help="Post tweets from markdown file")
    parser.add_argument("--check", action="store_true", help="Check rate limit status")
    parser.add_argument("--force", action="store_true", help="Skip rate limit check")
    parser.add_argument("--dry-run", action="store_true", help="Print without posting")
    args = parser.parse_args()
    
    state = load_state()
    state = prune_old_tweets(state)
    
    if args.check:
        can_post, wait, reason = check_rate_limit(state)
        print(f"Status: {reason}")
        print(f"Posts in last 24h: {len(state['tweets_today'])}/{DAILY_CAP}")
        if state["last_post_ts"]:
            ago = int(time.time() - state["last_post_ts"])
            print(f"Last post: {ago//60}m {ago%60}s ago")
        sys.exit(0)
    
    tweets = []
    if args.file:
        tweets = extract_tweets_from_md(args.file)
        if not tweets:
            print(f"ERROR: No tweets found in {args.file}")
            sys.exit(1)
        print(f"Found {len(tweets)} tweets in {args.file}")
    elif args.text:
        tweets = [args.text]
    else:
        parser.print_help()
        sys.exit(1)
    
    for i, tweet in enumerate(tweets):
        print(f"\n--- Tweet {i+1}/{len(tweets)} ---")
        print(tweet[:100] + "..." if len(tweet) > 100 else tweet)
        
        if len(tweet) > 280:
            print(f"WARNING: Tweet is {len(tweet)} chars (max 280)")
        
        if args.dry_run:
            print("[DRY RUN] Would post.")
            continue
        
        if not args.force:
            can_post, wait, reason = check_rate_limit(state)
            if not can_post:
                if wait > 0 and len(tweets) > 1:
                    print(f"Rate limited. Waiting {wait}s...")
                    time.sleep(wait)
                elif wait == 0:
                    print(f"BLOCKED: {reason}")
                    sys.exit(1)
        
        status, result = post_tweet(tweet)
        
        if status == 201:
            tweet_id = result["data"]["id"]
            print(f"✅ Posted: https://x.com/PermissionPrtcl/status/{tweet_id}")
            
            state["last_post_ts"] = time.time()
            state["tweets_today"].append({
                "ts": time.time(),
                "id": tweet_id,
                "text": tweet[:50]
            })
            save_state(state)
        else:
            print(f"❌ Failed ({status}): {result}")
            if "rate" in str(result).lower() or status == 429:
                print("Rate limited by Twitter. Stopping.")
                save_state(state)
                sys.exit(1)
            elif status == 403:
                print("403 Forbidden — likely rate limited. Waiting 16 min...")
                if i < len(tweets) - 1:
                    time.sleep(MIN_GAP_SECONDS)
                    # Retry
                    status2, result2 = post_tweet(tweet)
                    if status2 == 201:
                        tweet_id = result2["data"]["id"]
                        print(f"✅ Retry succeeded: https://x.com/PermissionPrtcl/status/{tweet_id}")
                        state["last_post_ts"] = time.time()
                        state["tweets_today"].append({"ts": time.time(), "id": tweet_id, "text": tweet[:50]})
                        save_state(state)
                    else:
                        print(f"❌ Retry failed ({status2}). Giving up on this tweet.")
                        save_state(state)

    save_state(state)
    print("\nDone.")

if __name__ == "__main__":
    main()
