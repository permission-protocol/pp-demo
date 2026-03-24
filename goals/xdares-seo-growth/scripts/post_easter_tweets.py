#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting the new Easter party games blog post."""

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

# 5 engaging tweets for Easter / Spring games
tweets = [
    # 1. Broad Easter hook
    "Easter isn't just for kids anymore 🐰🥚\n\nWhile the little ones hunt for candy, the adults are in the back with mimosas and boozy egg hunts.\n\nWe just compiled 55+ Easter party games for adults:\n\n→ Peeps Pong\n→ Boozy Egg Hunt\n→ Mimosa Pong\n→ Bunny Hop Challenges\n\nFull guide: https://blog.xdares.com/easter-party-games-drinking/",
    
    # 2. Drinking game focus
    "Hosting an Easter party next week? 🥂\n\nYou need better games than just 'hanging out'.\n\nTry these festive drinking games:\n🍹 Easter Basket Roulette\n🍺 Egg Flip Cup\n🐰 Resurrection (Never Have I Ever: Easter Edition)\n🍭 Jelly Bean Shots\n\nRules and 50+ more ideas here: https://blog.xdares.com/easter-party-games-drinking/",
    
    # 3. Adult Egg Hunt focus
    "How to host an epic adult Easter egg hunt: 💰🥃\n\n1. Mini bottles (Fireball/Smirnoff)\n2. Lottery tickets & scratch-offs\n3. Cash eggs ($5 - $20)\n4. Dare slips for shots\n5. The Golden Egg (grand prize)\n\nWe've got 5 different adult egg hunt variations in our latest guide:\n\nhttps://blog.xdares.com/easter-party-games-drinking/",
    
    # 4. Brunch hook
    "Planning an Easter brunch? 🥞🥂\n\nDon't let it be boring. Add these games to your spread:\n\n✨ Mimosa Pong\n✨ Brunch Bingo\n✨ Two Truths and a Lie: Spring Edition\n✨ Easter Bonnet Fashion Show\n\nYour guests will thank you: https://blog.xdares.com/easter-party-games-drinking/",
    
    # 5. Outdoor fun hook
    "Spring weather = Yard game season! 🌷☀️\n\nOur favorite outdoor Easter games for adults:\n\n⛳️ Easter Croquet\n🏆 Egg Toss Competition\n🏀 Spring Kickball\n🎈 Water Balloon Egg Fight\n\n55+ total ideas to make this holiday unforgettable: https://blog.xdares.com/easter-party-games-drinking/"
]

posted = []
errors = []

for i, tweet_text in enumerate(tweets, 1):
    try:
        response = client.create_tweet(text=tweet_text)
        tweet_id = response.data['id']
        tweet_url = f"https://x.com/xdaresOfficial/status/{tweet_id}"
        print(f"✅ Tweet {i} posted: {tweet_url}")
        posted.append({
            'index': i,
            'id': tweet_id,
            'url': tweet_url,
            'text': tweet_text[:50] + '...'
        })
        # Wait between tweets
        if i < len(tweets):
            time.sleep(5)
    except Exception as e:
        print(f"❌ Tweet {i} failed: {e}")
        errors.append({'index': i, 'error': str(e)})

print(f"\n📊 Results: {len(posted)}/5 tweets posted")

# Save results to logs
results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

log_filename = f"/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/nhie-tweets-{datetime.now().strftime('%Y%m%d-%H%M%S')}.json"
# Wait, let's use a better name
log_filename = f"/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-easter-drinking-games-{datetime.now().strftime('%Y%m%d-%H%M%S')}.json"

with open(log_filename, 'w') as f:
    json.dump(results, f, indent=2)

print(f"Results saved to: {log_filename}")
