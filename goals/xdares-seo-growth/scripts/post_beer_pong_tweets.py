#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting Beer Pong Rules."""

import json
import tweepy
import time
import os
from datetime import datetime

# Path to secrets relative to script location
SECRETS_PATH = os.path.expanduser('~/.openclaw/secrets/x-api.json')

# Load credentials
with open(SECRETS_PATH, 'r') as f:
    creds = json.load(f)

# Initialize client with OAuth 1.0a for posting
client = tweepy.Client(
    consumer_key=creds['oauth1']['consumer_key'],
    consumer_secret=creds['oauth1']['consumer_secret'],
    access_token=creds['oauth1']['access_token'],
    access_token_secret=creds['oauth1']['access_token_secret']
)

# 4 engaging tweets with Beer Pong hooks
tweets = [
    # 1. Main Guide hook
    "Master the official beer pong rules for your next party! 🍻\n\nWe've compiled everything you need:\n→ Setup & distances\n→ Pro tournament rules\n→ 15 game variations\n→ Bounce shots & re-racks\n\nCheck out the full guide here 👇\nhttps://blog.xdares.com/beer-pong-rules-tournament-variations-3/",
    
    # 2. Re-rack / Elbows hook
    "Do you follow the 'elbows behind the edge' rule? 🧐\n\nMost house rules do, but official WSOBP rules allow wrists. Plus, learn when to call for a re-rack (and which formations are actually legal).\n\nLevel up your game: https://blog.xdares.com/beer-pong-rules-tournament-variations-3/",
    
    # 3. Variations hook
    "Bored of standard 10-cup beer pong? 🥱\n\nTry these 15 crazy variations:\n🌪 Cyclone\n💥 Fireballs\n🏀 March Madness Bracket\n🛡 Civil War\n\nKeep the party going: https://blog.xdares.com/beer-pong-rules-tournament-variations-3/",
    
    # 4. Pro Tips hook
    "Want to win more? 🎯\n\nPro tips for your beer pong team:\n✓ Focus on the back cup\n✓ Arc your shots for better landing\n✓ Mastering the 'bounce' shot (when to risk it!)\n\nRead more: https://blog.xdares.com/beer-pong-rules-tournament-variations-3/"
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
if errors:
    print(f"Errors: {errors}")

# Save results
results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

log_filename = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-beer-pong-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'
with open(log_filename, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_filename}")
