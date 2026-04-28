#!/usr/bin/env python3
"""Post Kentucky Derby 2026 promo tweets to @xdares_."""

import json
import tweepy
import time
from datetime import datetime

with open('/Users/moltbot/.openclaw/secrets/x-api.json', 'r') as f:
    creds = json.load(f)

client = tweepy.Client(
    consumer_key=creds['oauth1']['consumer_key'],
    consumer_secret=creds['oauth1']['consumer_secret'],
    access_token=creds['oauth1']['access_token'],
    access_token_secret=creds['oauth1']['access_token_secret']
)

url = "https://blog.xdares.com/kentucky-derby-2026-drinking-games/"

tweets = [
    f"🐎 Kentucky Derby 2026 is THIS SATURDAY! We made the ultimate party guide — 40+ drinking games, betting pools, hat contests & mint julep challenges: {url}",
    f"The most exciting 2 minutes in sports deserves the most exciting party 🏆 Here's how to make Derby Day 2026 legendary: {url}",
    f"Kentucky Derby watch party checklist ✅:\n🍹 Mint julep taste-off\n🎩 Hat contest\n🎲 Trifecta fantasy draft\n🃏 Truth or dare\n\nFull guide: {url}",
    f"Post position shots, Derby bingo, and the official @xdares_ race-day drinking rules 🐴🥃 Get ready for May 2nd: {url}",
]

posted = []
errors = []

for i, tweet_text in enumerate(tweets, 1):
    try:
        response = client.create_tweet(text=tweet_text)
        tweet_id = response.data['id']
        tweet_url = f"https://x.com/xdares_/status/{tweet_id}"
        print(f"✅ Tweet {i} posted: {tweet_url}")
        posted.append({'index': i, 'id': tweet_id, 'url': tweet_url, 'text': tweet_text[:60] + '...'})
        if i < len(tweets):
            time.sleep(4)
    except Exception as e:
        print(f"❌ Tweet {i} failed: {e}")
        errors.append({'index': i, 'error': str(e)})

results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}
log_path = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-kentucky-derby-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nDone. {len(posted)}/{len(tweets)} tweets posted. Log: {log_path}")
