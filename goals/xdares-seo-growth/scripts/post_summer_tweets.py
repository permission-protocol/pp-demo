#!/usr/bin/env python3
"""Post Summer and July 4th promo tweets to @xdares_."""

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

# 4 promo tweets
tweets = [
    "Independence Day 2026 is going to be HUGE! 🇺🇸 Celebrate America's 250th birthday with these 40+ epic patriotic games: https://blog.xdares.com/fourth-of-july-party-games-2026/",
    "Planning a backyard BBQ? 🍔 Here are the best summer drinking games for 2026: https://blog.xdares.com/summer-bbq-drinking-games-2026/",
    "Stay cool this summer with 25+ adult pool party games! ☀️🏊‍♂️ From floating beer pong to water balloon wars: https://blog.xdares.com/summer-pool-party-games-2026/",
    "Going to summer camp? 🏕️ (Or just wish you were?) Here are the best adult-only camp drinking games for 2026: https://blog.xdares.com/summer-camp-drinking-games-2026/"
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
log_path = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-summer-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
