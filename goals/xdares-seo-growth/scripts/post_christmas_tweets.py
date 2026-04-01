#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting Christmas Party Games 2026 content."""

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

# 5 engaging Christmas 2026 tweets
tweets = [
    "The Ultimate Christmas Party Games Guide 2026 is here! 75+ Festive Ideas for Adults. 🎄🥂\n\nVR Sleigh Ride Dares, AI-Generated Roast Trivia, and TikTok 'Wrap Battles'.\n\nFull guide: https://blog.xdares.com/christmas-party-games-2026-2/",
    
    "Christmas Drinking Games 2026: 12 Days of Drinking (The 2026 Remix) 🎅🍻\n\nDay 5: 'Five Gold Rungs'\nDay 9: 'Nine Ladies Dancing'\nDay 12: 'Twelve Drummers Drumming'\n\nWhich one are you doing? 😈\n\nhttps://blog.xdares.com/christmas-party-games-2026-2/",
    
    "Naughty Santa (18+) is the only gift exchange that matters in 2026. 🎁😈\n\nGag gifts, adult items, and high-stakes dares. Get the rules for your next party:\n\nhttps://blog.xdares.com/christmas-party-games-2026-2/",
    
    "2026 Holiday Movie Drinking Games: 'The Grinch' (Live Action) 🎬🍿\n\nDrink every time the Grinch breaks the fourth wall or Max looks at the camera. Finish your drink when the heart grows 3 sizes!\n\nhttps://blog.xdares.com/christmas-party-games-2026-2/",
    
    "Office Party Survival 2026: 'Not-So-Secret' Santa 🏢🎅\n\nGuess your Santa correctly or you're wearing a reindeer headband for the rest of the meeting. Full list of hybrid-friendly games:\n\nhttps://blog.xdares.com/christmas-party-games-2026-2/"
]

posted = []
errors = []

for i, tweet_text in enumerate(tweets, 1):
    try:
        # Post to X
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
log_file = os.path.join(log_dir, 'tweets-christmas-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json')
with open(log_file, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_file}")
