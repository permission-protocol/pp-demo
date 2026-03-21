#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting the new Dirty Dares for Couples post."""

import json
import tweepy
import time
from datetime import datetime
import os

# Load credentials
with open('/Users/moltbot/.openclaw/secrets/x-api.json', 'r') as f:
    creds = json.load(f)

# Initialize client with OAuth 1.0a for posting
client = tweepy.Client(
    consumer_key=creds['oauth1']['consumer_key'],
    consumer_secret=creds['oauth1']['consumer_secret'],
    access_token=creds['oauth1']['access_token'],
    access_token_secret=creds['oauth1']['access_token_secret']
)

# Dirty Dares tweets
tweets = [
    "Date night getting predictable? 🕯️\n\nSpice things up with our ultimate list of 100+ Dirty Dares for Couples. From mild flirtation to wild challenges 🔥\n\nLevel up your intimacy tonight:\n\nhttps://blog.xdares.com/dirty-dares-for-couples/ #couples #dirtydares #relationshipgoals",
    "Dares aren't just for parties 🎲\n\nWe've compiled over 100 spicy dares specifically for couples to transform a boring evening into something unforgettable.\n\nReady to play?\n\nhttps://blog.xdares.com/dirty-dares-for-couples/ #truthordare #spicydares #datingtips",
    "Stop scrolling, start playing 🌶️\n\nOur latest guide features 100+ dirty dares to keep the spark alive and the night exciting.\n\nCheck them out:\n\nhttps://blog.xdares.com/dirty-dares-for-couples/ #couplesgames #partygames #datenight"
]

posted = []
errors = []

for i, tweet_text in enumerate(tweets, 1):
    try:
        response = client.create_tweet(text=tweet_text)
        tweet_id = response.data['id']
        tweet_url = f"https://x.com/xdares_/status/{tweet_id}"
        print(f"✅ Tweet {i} posted: {tweet_url}")
        posted.append({
            'index': i,
            'id': tweet_id,
            'url': tweet_url,
            'text': tweet_text[:50] + '...'
        })
        # Wait between tweets to avoid rate limits
        if i < len(tweets):
            time.sleep(3)
    except Exception as e:
        print(f"❌ Tweet {i} failed: {e}")
        errors.append({'index': i, 'error': str(e)})

print(f"\n📊 Results: {len(posted)}/{len(tweets)} tweets posted")

# Save results
results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

log_path = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-dirty-dares-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
