#!/usr/bin/env python3
"""Post Easter promo tweets to @xdares_."""

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

# 5 Easter promo tweets
tweets = [
    "Easter Brunch is almost here! 🥂 Forget the boring egg hunt. Try these 15 boozy brunch games for adults: https://blog.xdares.com/easter-party-games-drinking/",
    "Hop into the fun with these 25 Easter Dares for your next party: 🐣 https://blog.xdares.com/easter-party-games-for-adults/",
    "Easter isn't just for kids. 🐰 Here are the best drinking games for your Easter Sunday brunch: https://blog.xdares.com/easter-party-games-drinking/",
    "Looking for last-minute Easter party ideas? 🥚 We've got 40+ games and dares ready to go: https://blog.xdares.com/easter-party-games-for-adults/",
    "Make this Easter unforgettable with these hilarious dares and drinking games: 🍭 https://blog.xdares.com/easter-party-games-drinking/"
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
log_path = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-easter-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
