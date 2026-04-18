#!/usr/bin/env python3
"""Post Festival Hub promo tweets to @xdares_."""

import json
import tweepy
import time
from datetime import datetime
import os

# Load credentials
with open('/Users/moltbot/.openclaw/secrets/x-api.json', 'r') as f:
    creds = json.load(f)

# Initialize client
client = tweepy.Client(
    consumer_key=creds['oauth1']['consumer_key'],
    consumer_secret=creds['oauth1']['consumer_secret'],
    access_token=creds['oauth1']['access_token'],
    access_token_secret=creds['oauth1']['access_token_secret']
)

# 3 Festival Hub promo tweets
tweets = [
    "Coachella Weekend 2 is HERE! 🌵🎡 Whether you're in the desert or watching from home, level up your weekend with our new Festival Games Hub.\n\nFrom EDM dares to campsite icebreakers, we've got you covered: https://blog.xdares.com/music-festival-party-games/",
    "Trade the small talk for high-stakes dares this festival season. 🕺✨ Our 2026 Guide to Music Festival Games is live: https://blog.xdares.com/music-festival-party-games/",
    "Campsite icebreakers, rave drinking games, and neon dares. 🏕️ Get the full list for your next festival: https://blog.xdares.com/music-festival-party-games/"
]

posted = []
errors = []

for i, tweet_text in enumerate(tweets, 1):
    try:
        response = client.create_tweet(text=tweet_text)
        tweet_id = response.data['id']
        tweet_url = f"https://x.com/xdares_/status/{tweet_id}"
        print(f"✅ Tweet {i} posted: {tweet_url}")
        posted.append({'index': i, 'id': str(tweet_id), 'url': tweet_url, 'text': tweet_text[:50] + '...'})
        if i < len(tweets):
            time.sleep(10)
    except Exception as e:
        print(f"❌ Tweet {i} failed: {e}")
        errors.append({'index': i, 'error': str(e)})

# Save results
results = {'timestamp': datetime.now().isoformat(), 'posted': posted, 'errors': errors, 'total_posted': len(posted)}
log_filename = 'tweets-festival-hub-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'
log_path = os.path.join('/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs', log_filename)
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
