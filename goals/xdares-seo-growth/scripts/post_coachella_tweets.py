#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting Coachella content."""

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

# 5 engaging Coachella/Festival tweets
tweets = [
    "Heading to Coachella 2026? 🌵🎡\n\nDon't just stand there between sets. Try these 15 festival games to keep the vibe high.\n\nFrom 'Outfit Bingo' to 'Silent Disco Mimic', your camp just got upgraded.\n\nFull guide: https://blog.xdares.com/coachella-festival-party-guide-2026/",
    
    "Couchchella 2026 is here! 🍿🛋️\n\nStreaming the desert from your living room? Here are 5 games that make a home watch party feel like a VIP tent.\n\n- The 'Drop' Drink\n- The Influencer Challenge\n- VIP Upgrade cards\n\nGet the rules: https://blog.xdares.com/coachella-festival-party-guide-2026/",
    
    "15 Festival Dares for Coachella 🎡✨\n\n1. The 'Merch' Swap (1 hour clothing trade)\n2. The 'Front Row' Push (mime it!)\n3. Shout out a fake artist\n4. Glow up every 20 mins\n\nWhich one are you doing? 😈\n\nhttps://blog.xdares.com/coachella-festival-party-guide-2026/",
    
    "Coachella 2026 Outfit Bingo 🤠👗\n\nSpotted a crochet top? Take a sip.\nInfluencer in the wild? Finish your drink.\nCowboy boots in the sand? That's a point.\n\nTurn the desert into a game: https://blog.xdares.com/coachella-festival-party-guide-2026/",
    
    "Who are you most excited to see at #Coachella2026? 🎵✨\n\nMake a game of it with 'Set List Roulette'. Guess the first 3 songs or take a festival dare.\n\n15 more ideas for the desert: https://blog.xdares.com/coachella-festival-party-guide-2026/"
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
log_file = os.path.join(log_dir, 'tweets-coachella-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json')
with open(log_file, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_file}")
