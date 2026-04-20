#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting EDM Drinking Games content (Updated)."""

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

# 4 unique EDM/Festival tweets
tweets = [
    "Coachella W2 is wrapping up, but the festival season is just starting! 🎡🌵\n\nLevel up your next pregame with our new EDM Drinking Games guide: Beats, Drops & Neon Dares. ⚡️🎧\n\nFull guide: https://blog.xdares.com/edm-drinking-games-2026-2/",
    
    "Neon Dares & Bass Drops: The perfect festival combo. 🌈🚨\n\nWe just dropped 15+ EDM-themed drinking games and dares for your next rave pregame.\n\nWhich one are you trying first? 😈\n\nhttps://blog.xdares.com/edm-drinking-games-2026-2/",
    
    "Rave pregaming? 🎶🍻 Check out 'Munchie Roulette' and 'The Drop' sip in our latest festival party guide.\n\nKeep the vibes high and the energy electric. ⚡️\n\nhttps://blog.xdares.com/edm-drinking-games-2026-2/",
    
    "2026 Festival Season is HERE. 🎡 Check out our full guide for EDM games and dares that actually keep the party moving.\n\nhttps://blog.xdares.com/edm-drinking-games-2026-2/"
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
            'id': str(tweet_id),
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
log_file = os.path.join(log_dir, 'tweets-edm-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json')
with open(log_file, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_file}")
