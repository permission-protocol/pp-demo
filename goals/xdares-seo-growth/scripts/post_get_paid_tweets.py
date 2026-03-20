#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting 'Get Paid to Do Dares'."""

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

# Engaging tweets for the 'Get Paid to Do Dares' post
tweets = [
    "Wait, you can get PAID to do dares in 2026? 💸\n\nYes, really. We broke down the top platforms where your wild side pays the bills.\n\n→ Live streaming challenges\n→ Viral dare apps\n→ @xdares_ integration\n\nFull guide: https://blog.xdares.com/get-paid-to-do-dares-2026-2/",
    
    "Side hustle alert: The Dare Economy 🎯\n\nFrom $5 silly stunts to $500 extreme challenges, people are monetizing their social life like never before.\n\nHere's how to get started safely and maximize your earnings in 2026:\n\nhttps://blog.xdares.com/get-paid-to-do-dares-2026-2/",
    
    "Stop doing dares for free! 😤\n\nIf you're already the 'wild one' in the group, you're sitting on a goldmine. Learn how to turn those dares into dollars with our 2026 platform breakdown.\n\n💰 Top earners\n📱 Best apps\n⚡️ Safety first\n\nRead more: https://blog.xdares.com/get-paid-to-do-dares-2026-2/",
    
    "The 2026 Ultimate Guide to Earning with Dares is LIVE! 🚀\n\nEverything you need to know about the current landscape of paid challenges, audience building, and payout strategies.\n\nReady to get paid? 👇\n\nhttps://blog.xdares.com/get-paid-to-do-dares-2026-2/"
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

log_dir = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs'
os.makedirs(log_dir, exist_ok=True)
log_file = os.path.join(log_dir, 'tweets-get-paid-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json')

with open(log_file, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_file}")
