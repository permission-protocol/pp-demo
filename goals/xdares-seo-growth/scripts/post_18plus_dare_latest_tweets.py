#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting the 18+ Dare Latest 2026 post."""

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
    "Staying ahead of the game? 📈\n\nDiscover the 18+ Dare Latest trends for 2026. From public social bravery to high-octane truth or dare variations.\n\nSee what's trending: https://blog.xdares.com/18-plus-dare-latest-2026-2/ #dares #trending2026 #Xdares",
    "Public confidence dares are taking over in 2026. 🏙️\n\nCould you do the 'Stranger High Five' gauntlet? 10 strangers in 5 minutes.\n\nCheck out the top social bravery dares:\n\nhttps://blog.xdares.com/18-plus-dare-latest-2026-2/#public #socialbravery #challenge",
    "Want to build your brand as a creator? 🎥\n\nThe '24-Hour Dare-Stream' is the #1 way to engage fans and go viral this year.\n\nLearn how to launch your dare channel: https://blog.xdares.com/18-plus-dare-latest-2026-2/#creators #Xdares #creatorgrowth",
    "The era of staged challenges is over. 🚫\n\n2026 is about 'unfiltered' and 'raw' content. Genuine embarrassment, real courage.\n\nDive into the state of adult daring: https://blog.xdares.com/18-plus-dare-latest-2026-2/ #authenticity #unfiltered #Xdares"
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
with open(os.path.join(log_dir, 'tweets-18plus-dare-latest-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'), 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to logs/")
