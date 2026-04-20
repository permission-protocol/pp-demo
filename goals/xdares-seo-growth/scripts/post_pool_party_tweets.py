#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting Pool Party content."""

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

# 5 engaging Pool Party tweets
tweets = [
    "Summer 2026 is calling! ☀️🏊 Is your pool party game ready? We just dropped the ultimate guide to 35+ epic water games for adults.\n\nFrom 'Floaty Musical Chairs' to 'Battleship Shots', check it out: https://blog.xdares.com/summer-pool-party-games-2026/",
    
    "Forget Marco Polo. Have you tried 'Greased Watermelon'? 🍉💦 It's pure chaos and the highlight of every camp-themed pool party.\n\nMore ideas for your summer bash: https://blog.xdares.com/summer-pool-party-games-2026/",
    
    "Pool Drinking Games (21+): Because everything is better with a floaty and a drink. 🍹👙\n\n1. Floaty Pong\n2. Battleship Shots\n3. Noodle Joust\n\nFull rules: https://blog.xdares.com/summer-pool-party-games-2026/",
    
    "Who said synchronized swimming can't be a party game? 👯‍♀️🌊 Team up and try to survive the synchronized challenge (audience drinks when you fail).\n\nSummer vibes: https://blog.xdares.com/summer-pool-party-games-2026/",
    
    "Make a splash this year. 🌊🎮 Our 2026 pool party guide is live with competitive games, chill floating vibes, and night party ideas.\n\nhttps://blog.xdares.com/summer-pool-party-games-2026/"
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
log_file = os.path.join(log_dir, 'tweets-pool-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json')
with open(log_file, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_file}")
