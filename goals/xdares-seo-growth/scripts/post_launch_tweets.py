#!/usr/bin/env python3
"""Post launch tweets to @xdares_ promoting the new Dirty Dares for Couples post."""

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

# Launch tweets
tweets = [
    "Date night getting predictable? 😴\n\nWe just dropped 100+ Dirty Dares for Couples to spice things up:\n\n🔥 Flirty warm-ups\n🔥 Romantic connection builders\n🔥 Spicy challenges\n🔥 Bedroom dares\n\nYour next date night starts here: https://blog.xdares.com/dirty-dares-for-couples-2/?utm_source=x&utm_medium=social&utm_campaign=launch",
    
    "The couples who stay exciting are the ones who play together. 😈\n\nBreak the routine with our new guide: 100+ Dirty Dares for Couples.\n\nFrom flirty to wild, we've got you covered. 🎯\n\nRead more: https://blog.xdares.com/dirty-dares-for-couples-2/?utm_source=x&utm_medium=social&utm_campaign=launch",
    
    "Singapore community! 🇸🇬\n\nWe've localized our top guides for your next night out in the Lion City. \n\nCheck out the updated Truth or Dare & Never Have I Ever guides with SG-specific dares. \n\nTruth or Dare: https://blog.xdares.com/truth-or-dare-questions-for-adults/\nNever Have I Ever: https://blog.xdares.com/never-have-i-ever-questions/"
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
            time.sleep(5)
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
with open(os.path.join(log_dir, 'tweets-launch-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'), 'w') as f:
    json.dump(results, f, indent=2)
