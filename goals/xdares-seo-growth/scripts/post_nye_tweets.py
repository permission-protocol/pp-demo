#!/usr/bin/env python3
"""Post NYE 2026 promo tweets to @xdares_."""

import json
import tweepy
import time
from datetime import datetime
import os

# Set working directory to project root
os.chdir('/Users/moltbot/.openclaw/workspace/')

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

# 5 engaging tweets with NYE 2026 hooks
tweets = [
    # 1. Main Guide hook
    "NYE 2026 is almost here! 🥂\n\nDon't just wait for the ball to drop. We've compiled the ultimate New Year's Eve party games:\n\n✨ Midnight Dares\n🎲 Resolution Roulette\n🍹 Drinking Game Challenges\n\nFull list: https://blog.xdares.com/nye-party-games-2026/",
    
    # 2. Drinking game specific
    "Planning an NYE pre-game? 🍻\n\nThese 10 drinking games are designed for the final countdown:\n\n• The Resolution Drink\n• Midnight Shot Challenge\n• Year-In-Review Bingo\n\nDrink responsibly, play recklessly 🥂\n\nhttps://blog.xdares.com/nye-party-games-2026/",
    
    # 3. Midnight Dares hook
    "Who's getting the first dare of 2026? 😈\n\nOur NYE dare list is live:\n\n✓ The 'Kiss a Stranger' Challenge\n✓ Resolution Regrets\n✓ Midnight Confessions\n\nUpgrade your countdown: https://blog.xdares.com/nye-party-games-2026/",
    
    # 4. Group game focus
    "Hosting a big group for New Year's? 🕺\n\nAvoid the 'what do we do now' slump before midnight. Try these 15 group games:\n\n🎮 High-Energy Dares\n💬 Resolution Trivia\n🏆 Best of 2025 Awards\n\nFull guide: https://blog.xdares.com/nye-party-games-2026/",
    
    # 5. Core content / Link-in-bio style
    "The 2026 NYE Playbook is LIVE 🎯\n\nEverything you need for the perfect party:\n\n✓ Truth or Dare: NYE Edition\n✓ 18+ Drinking Games\n✓ Clean Party Games for Groups\n\nMake it a night to remember: https://blog.xdares.com/nye-party-games-2026/"
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
        # Wait between tweets to avoid rate limits
        if i < len(tweets):
            time.sleep(3)
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

log_dir = 'goals/xdares-seo-growth/logs'
if not os.path.exists(log_dir):
    os.makedirs(log_dir)

log_path = os.path.join(log_dir, 'tweets-nye-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json')
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
