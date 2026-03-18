#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting the new Extreme Dares post."""

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

# Extreme Dares tweets
tweets = [
    "Ready to push your limits? 😈\n\nWe just published our ultimate guide to 50+ Extreme Dares for Adults. These are NOT for the faint of heart.\n\n✓ Wild Challenges\n✓ Social Experiments\n✓ Physical Feats\n✓ Spicy Variations\n\nDare to read? https://blog.xdares.com/extreme-dares-for-adults-2/ #extremedares #partygames",
    "Hosting a wild house party? 🏠\n\nMost dare games are boring. Ours are designed to test your courage and create unforgettable memories.\n\nCheck out the 2026 update to our Extreme Dares list:\n\nhttps://blog.xdares.com/extreme-dares-for-adults-2/ #partyideas #dares",
    "From public embarrassment to hilarious physical challenges, our new Extreme Dares guide covers it all.\n\nWarning: Only for those who aren't afraid to look a little crazy! 🤪\n\nFull list here:\n\nhttps://blog.xdares.com/extreme-dares-for-adults-2/ #challenge #dare"
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

log_path = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-extreme-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
