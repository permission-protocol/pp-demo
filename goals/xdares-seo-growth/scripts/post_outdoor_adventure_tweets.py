#!/usr/bin/env python3
import json
import os
import tweepy
import time
from datetime import datetime

# Load credentials
with open(os.path.expanduser('~/.openclaw/secrets/x-api.json'), 'r') as f:
    creds = json.load(f)

# Initialize client with OAuth 1.0a for posting
client = tweepy.Client(
    consumer_key=creds['oauth1']['consumer_key'],
    consumer_secret=creds['oauth1']['consumer_secret'],
    access_token=creds['oauth1']['access_token'],
    access_token_secret=creds['oauth1']['access_token_secret']
)

tweets = [
    "Planning a camping trip or a bonfire night? 🌲🔥 Elevate the vibe with these 15 outdoor adventure games and nature dares! #OutdoorAdventure #CampingGames #NatureDares",
    "The 'Flashlight Tag' Evolution: Add dares to every tag! 🔦🏃‍♂️ It's not just a game, it's a gauntlet. #NightGames #OutdoorDares",
    "Hiking with the crew? Turn the trail into a competition with Scavenger Dares. First one to find a uniquely shaped rock picks the next dare! 🥾⛰️ #HikingLife #AdventureGames",
    "Bonfire Truth or Dare: There's nothing like a crackling fire to get the deepest confessions and the wildest dares. 🔥💬 #BonfireNight #TruthOrDare",
    "Check out our full guide to Outdoor Adventure Games for 2026: https://blog.xdares.com/outdoor-adventure-games-2026/ 🌲🎮 #GameNight #Xdares"
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

print(f"\n📊 Results: {len(posted)}/5 tweets posted")

# Save results
results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

log_timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
log_path = f"/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-outdoor-adventure-{log_timestamp}.json"
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
