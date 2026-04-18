#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting 4/20 content."""

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

# 5 engaging 4/20 tweets
tweets = [
    "Only 3 days until 4/20! 🌿 Make sure your session is legendary with our ultimate guide to high-energy dares and games.\n\nFrom 'The Cloud Sculptor' to 'Munchie Mastermind', we've got you covered.\n\nFull guide: https://blog.xdares.com/420-party-guide-2026/",
    
    "Ever tried the 'Slow-Mo' challenge during a 4/20 session? 🌿 Talking and moving in half-speed is way harder than it looks! 😂\n\nMore ideas for your session: https://blog.xdares.com/420-party-guide-2026/",
    
    "Munchie Roulette is the only way to order food this 4/20. 🍕🍟\n\nThe group invents a dare for whoever eats the random delivery item!\n\n18+ stoner challenges: https://blog.xdares.com/420-party-guide-2026/",
    
    "Stoner Cinema Trivia: The high-stakes way to celebrate 4/20. 🎬🍿\n\nMiss a question? You're doing the 'Ghost' dare or explaining gravity in one sentence.\n\nHappy 4/20: https://blog.xdares.com/420-party-guide-2026/",
    
    "2026 is the year of better 4/20 parties. 🌬️🎮 Check out our full guide for games and dares that actually keep the energy up.\n\nhttps://blog.xdares.com/420-party-guide-2026/"
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
        # Wait between tweets
        if i < len(tweets):
            time.sleep(10)
    except Exception as e:
        print(f"❌ Tweet {i} failed: {e}")
        errors.append({'index': i, 'error': str(e)})

print(f"\n📊 Results: {len(posted)}/5 tweets posted")
if errors:
    print(f"Errors: {errors}")

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
