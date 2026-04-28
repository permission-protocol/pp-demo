#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting Backyard Beer Olympics 2026."""

import json
import tweepy
import time
from datetime import datetime

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

# 3 engaging tweets for Backyard Beer Olympics
tweets = [
    "Ready to take your backyard parties to the next level? 🍻\n\nHost your own Backyard Beer Olympics with our 2026 guide! Rules, scoresheets, and winning strategies included 🏆\n\nRead more: https://blog.xdares.com/backyard-beer-olympics-2026/",
    "From Flip Cup relays to the modified Beer Mile, we've got the ultimate lineup for your next competitive hangout 🎯\n\nCheck out the full rulebook for the 2026 Backyard Beer Olympics:\n\nhttps://blog.xdares.com/backyard-beer-olympics-2026/",
    "Team themes, opening ceremonies, and professional scoresheets. Your summer party just turned into a legendary event 🏅\n\nEverything you need to host a Beer Olympics is right here:\n\nhttps://blog.xdares.com/backyard-beer-olympics-2026/"
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

print(f"\n📊 Results: {len(posted)}/3 tweets posted")

# Save results
results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

log_filename = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-backyard-beer-olympics-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'
with open(log_filename, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_filename}")
