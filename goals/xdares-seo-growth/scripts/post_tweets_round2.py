#!/usr/bin/env python3
"""Post more tweets to @xdares_ - Round 2 with new content angles."""

import json
import tweepy
import time
from datetime import datetime

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

# 5 new engaging tweets with different angles
tweets = [
    # 1. Beer Pong tournament angle
    "Beer pong isn't just a game—it's a tournament 🏆\n\nComplete rules + challenge variations:\n\n• Island rule\n• Bounce shots (2 cups!)\n• Redemption rules\n• Trick shot bonuses\n• Team formats\n\nBecome the champion 🍺\n\nhttps://blog.xdares.com/beer-pong-rules-tournament-variations/",
    
    # 2. Team building for the work crowd
    "\"Let's do icebreakers\"\n\n*collective groan*\n\nHere are team building games that DON'T suck:\n\n🧠 Problem-solving challenges\n🎭 Creative improv\n⚡ Quick energizers\n💬 Conversation starters\n\nYour next meeting, upgraded 👇\n\nhttps://blog.xdares.com/team-building-games-that-work/",
    
    # 3. LDR couples content
    "Long distance relationships are hard.\n\nThese games make it easier 💕\n\n📱 Video call activities\n🎮 Multiplayer games to play together\n💬 Deep conversation games\n🔥 Spicy challenges (yes, those too)\n\n25 ideas for staying connected:\n\nhttps://blog.xdares.com/long-distance-relationship-games/",
    
    # 4. Bachelor party hook
    "Planning a bachelor party? 🎉\n\nForget the boring stuff. Here's what you need:\n\n🍻 Bar crawl challenges\n🎲 Drinking game rules\n😂 Embarrassing groom dares\n🏆 Competition formats\n\n40+ ideas guaranteed to create stories 👇\n\nhttps://blog.xdares.com/bachelor-party-games-and-dares/",
    
    # 5. GetDare alternative positioning
    "Miss GetDare? 👀\n\nWe built something better.\n\nXdares: The 18+ dare platform where you can:\n\n✓ Challenge anyone to anything\n✓ Put real $ on the line\n✓ Verify with video proof\n✓ Safe disputes & escrow\n\nDares with stakes 🔥\n\nhttps://xdares.com"
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

log_path = f'goals/xdares-seo-growth/logs/tweets-round2-{datetime.now().strftime("%Y%m%d-%H%M%S")}.json'
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
