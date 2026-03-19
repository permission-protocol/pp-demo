#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting the new Adult Party Games hub post."""

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
    "Stop throwing boring parties. 🛑\n\nWe just released the ULTIMATE guide to Adult Party Games: 150+ ideas for every occasion.\n\n✓ Icebreakers\n✓ Dinner Party Games\n✓ Drinking Games\n✓ Office/Team Building\n\nUpgrade your game night: https://blog.xdares.com/adult-party-games/ #partygames #adults",
    "Hosting a large group? (20+ people) 👥\n\nStandard board games won't work. You need games that scale.\n\nFrom Minute to Win It to massive Mafia games, check our latest guide for the best large group activities:\n\nhttps://blog.xdares.com/adult-party-games/#large-groups #partyideas #games",
    "Dinner parties don't have to be just small talk. 🍷\n\nAdd strategic entertainment that flows with the meal.\n\n✓ Blind Wine Tasting\n✓ Low-Stakes Debates\n✓ Murder Mystery\n\n55+ dinner party ideas here:\n\nhttps://blog.xdares.com/adult-party-games/#dinner-party #dinnerparty #entertainment"
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
with open(os.path.join(log_dir, 'tweets-adult-party-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'), 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to logs/")
