#!/usr/bin/env python3
"""Post Graduation Party Games promo tweets to @xdares_."""

import json
import tweepy
import time
from datetime import datetime

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

# 3 Graduation promo tweets
tweets = [
    "Class of 2026! 🎓 Celebrate your big achievement with 35+ epic graduation party games for all ages: https://blog.xdares.com/graduation-party-games-2026/",
    "Hosting a graduation after-party? 🍻 Turn it into a legendary night with these 10 graduation drinking games for the 21+ crowd: https://blog.xdares.com/graduation-party-games-drinking/",
    "Want to make your grad party unforgettable? 📸 Try these 15 creative graduation dares and photo scavenger hunts: https://blog.xdares.com/graduation-party-games-2026/"
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
log_path = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-graduation-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
