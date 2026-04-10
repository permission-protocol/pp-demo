#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting the new Graduation Party Games post."""

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

url = "https://blog.xdares.com/graduation-party-games-2026/"

tweets = [
    f"Class of 2026! 🎓\n\nDon't settle for boring graduation parties. We just dropped the ultimate guide to 35+ epic games for high school & college grads.\n\nFrom 'Diploma Flip Cup' to 'Senior Superlatives' 🍻\n\nFull list: {url}",
    
    f"Hosting a graduation party soon? 🎓\n\nWe've got you covered with games for all ages:\n\n🎯 Ring Toss the Diploma\n📷 Photo Scavenger Hunt\n🎓 Life After Graduation Bingo\n\nMake it a party they'll actually remember 👇\n\n{url}",
    
    f"The 21+ crowd needs more than just a cake 🎓🍻\n\nTry these graduation drinking games:\n\n• Textbook Trivia Shots\n• 'Finally Done' Roulette\n• Degree Requirements\n\nCelebrate the grind correctly 🥂\n\n{url}",
    
    f"Graduation season is peak backyard party time 🌭🍔\n\nLevel up your lawn games:\n\n🥏 Grad Cap Frisbee\n🎯 Cornhole: Future Edition\n🏐 Balloon Relay\n\n35+ games for the Class of 2026: {url}",
    
    f"Want to keep the party going after the ceremony? 🎓🔥\n\nCheck out our latest guide to Graduation Party Games 2026. 35+ ways to celebrate the grads in style.\n\nPlus: Download @TruthOrDare500 for the ultimate party companion 📱\n\n{url}"
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
            time.sleep(3)
    except Exception as e:
        print(f"❌ Tweet {i} failed: {e}")
        errors.append({'index': i, 'error': str(e)})

results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

log_path = f"/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-graduation-{datetime.now().strftime('%Y%m%d-%H%M%S')}.json"
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
