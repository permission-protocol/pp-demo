#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting Coachella content - V2 with fresh copy."""

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

# 5 fresh Coachella/Festival tweets to avoid "Duplicate Content" error
tweets = [
    "Coachella 2026 survival tip: It's not just about the sets, it's about the camp vibes. 🌵✨\n\nWe dropped a fresh playbook with 15 games designed for the desert.\n\nFrom 'Silent Disco Mimic' to 'Outfit Bingo', don't be the boring camp.\n\nCheck it: https://blog.xdares.com/coachella-festival-party-guide-2026/",
    
    "Watching Coachella from your couch? 🛋️🌵\n\nTurn the stream into a competition with our 'Couchchella' games.\n\n- The Influencer Drink-Off\n- VIP Upgrade challenges\n- Setlist Roulette\n\nMake home feel like the Front Row: https://blog.xdares.com/coachella-festival-party-guide-2026/",
    
    "15 Wild Dares for the Desert 🎡🔥\n\nCoachella 2026 is here. Are you ready to level up?\n\n- The 'Merch Swap' (1 hour clothing trade)\n- Shout out a fake headliner\n- The 'Dust Mask' Dare\n\nDare your group here: https://blog.xdares.com/coachella-festival-party-guide-2026/",
    
    "Coachella 2026 Outfit Bingo is LIVE! 👗🤠\n\nSpotted: \n✅ Crochet top\n✅ Cowboy boots in the mud\n✅ Influencer doing a 360 spin\n\nPlay along with the full rules here: https://blog.xdares.com/coachella-festival-party-guide-2026/",
    
    "Who's winning the Coachella 2026 fashion game? 🕶️✨\n\nWhile you wait for the headliners, try 'Set List Roulette' with your crew.\n\nGuess the first song or take a festival dare. 😈\n\n15 more ways to play: https://blog.xdares.com/coachella-festival-party-guide-2026/"
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
            time.sleep(5) # Slightly longer delay
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
log_file = os.path.join(log_dir, 'tweets-coachella-v2-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json')
with open(log_file, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_file}")
