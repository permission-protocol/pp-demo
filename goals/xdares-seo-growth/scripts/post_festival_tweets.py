#!/usr/bin/env python3
"""Post Festival Party Games promo tweets to @xdares_."""

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

# 3 Festival promo tweets
tweets = [
    "Coachella starts in 2 days! 🌵🎡 Whether you're in the desert or hosting a watch party, level up your weekend with our Ultimate Guide to Music Festival Games: https://blog.xdares.com/the-ultimate-guide-to-music-festival-games-coachella-edm-rave-2026/",
    "Going to a rave? 🕺✨ Don't just pregame, make it legendary with these EDM drinking games and neon dares: https://blog.xdares.com/edm-drinking-games-2026/",
    "Festival campsite vibes are unmatched. 🏕️ Hook up with your neighbors using these 15 Coachella-specific games and icebreakers: https://blog.xdares.com/coachella-playbook/"
]

posted = []
errors = []

for i, tweet_text in enumerate(tweets, 1):
    try:
        response = client.create_tweet(text=tweet_text)
        tweet_id = response.data['id']
        tweet_url = f"https://x.com/xdares_/status/{tweet_id}"
        print(f"✅ Tweet {i} posted: {tweet_url}")
        posted.append({'index': i, 'id': tweet_id, 'url': tweet_url, 'text': tweet_text[:50] + '...'})
        if i < len(tweets):
            time.sleep(3)
    except Exception as e:
        print(f"❌ Tweet {i} failed: {e}")
        errors.append({'index': i, 'error': str(e)})

# Save results
results = {'timestamp': datetime.now().isoformat(), 'posted': posted, 'errors': errors, 'total_posted': len(posted)}
log_filename = 'tweets-festival-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'
log_path = os.path.join('/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs', log_filename)
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
