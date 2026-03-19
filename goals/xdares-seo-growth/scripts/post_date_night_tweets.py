#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting the new Date Night Games post."""

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

# Tweets
tweets = [
    "Stop asking \"what do you want to watch?\" every Friday night. 🛑\n\nWe just released 30 Date Night Games to spice up your relationship. From deep connection to spicy challenges.\n\nMake your next date unforgettable: https://blog.xdares.com/date-night-games-3/ #datenight #relationshipgoals",
    "Deep connection doesn't happen by accident. ❤️\n\nTry the '36 Questions Game' or 'The Rose, Bud, Thorn' ritual to truly connect with your partner.\n\n5 connection-focused games for your next date night:\n\nhttps://blog.xdares.com/date-night-games-3/#connection #couples #connection",
    "Feeling adventurous? 🔥\n\nTake your date night to the next level with spicy Truth or Dare and the 'Fantasy Game'.\n\nExplore our guide for adventurous couples:\n\nhttps://blog.xdares.com/date-night-games-3/#spicy #datenightideas #spicy"
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
        if i < len(tweets):
            time.sleep(10)
    except Exception as e:
        print(f"❌ Tweet {i} failed: {e}")
        errors.append({'index': i, 'error': str(e)})

# Save results
results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

log_dir = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs'
os.makedirs(log_dir, exist_ok=True)
with open(os.path.join(log_dir, 'tweets-date-night-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'), 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to logs/")
