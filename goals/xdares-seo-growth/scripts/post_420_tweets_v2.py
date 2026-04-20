#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting 4/20 content (Updated)."""

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

# 4 unique 4/20 Eve tweets
tweets = [
    "The countdown to 4/20 is officially in single digits! 🌿 Final check: snacks? 🍕 tunes? 🎧 games? 🎮\n\nIf you're missing the games, we've got the ultimate stoner guide ready for you.\n\nRead here: https://blog.xdares.com/420-party-guide-2026/",
    
    "4/20 Eve Vibes: Pregaming with some low-stakes dares before the big day tomorrow. 🌬️\n\nWhat's your go-to session game? 'Never Have I Ever' (Stoner Edition) is always a winner.\n\nMore ideas: https://blog.xdares.com/420-party-guide-2026/",
    
    "Pro-tip for 4/20: Assign a 'Munchie Master' to curate the snack board. 🍩🍟\n\nFailure to deliver results in a 'Blindfold Taste Test' dare! 😂\n\nGet the full list of dares: https://blog.xdares.com/420-party-guide-2026/",
    
    "Setting up the 4/20 game station? 🎮🌿\n\nDon't forget the physical challenges! 'The Slow-Mo Race' is a classic for a reason.\n\nHappy 4/20 Eve: https://blog.xdares.com/420-party-guide-2026/"
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
log_file = os.path.join(log_dir, 'tweets-420-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json')
with open(log_file, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_file}")
