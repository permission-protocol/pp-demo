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
    "4/20 is coming! 🌿 Level up your celebration with the ultimate guide to high-energy dares and games.\n\nFrom 'The Cloud Sculptor' to 'Munchie Mastermind', we've got you covered.\n\nFull guide: https://blog.xdares.com/420-party-guide-2026/",
    
    "The 'Slow-Mo' Challenge for 4/20: Everyone talks and moves in half-speed for 10 mins. 😂\n\nFirst to break character takes a penalty (or a dare!)\n\nMore ideas for your session: https://blog.xdares.com/420-party-guide-2026/",
    
    "Munchie Menu Roulette: Order a random item on a delivery app. 🍕🍟\n\nThe group invents a dare for whoever eats it!\n\n18+ stoner challenges: https://blog.xdares.com/420-party-guide-2026/",
    
    "Weed-Trivia Dares: Miss a question about stoner cinema? 🎬🍿\n\nYou're doing the 'Ghost' dare or explaining gravity in one sentence.\n\nHappy 4/20: https://blog.xdares.com/420-party-guide-2026/",
    
    "Stay safe and have fun this 4/20! Check out our full guide for 2026 for games and dares that don't suck.\n\n🌬️🎮 https://blog.xdares.com/420-party-guide-2026/"
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
