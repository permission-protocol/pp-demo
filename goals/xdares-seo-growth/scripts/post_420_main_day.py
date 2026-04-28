#!/usr/bin/env python3
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

# Fresh 4/20 Main Day tweets
tweets = [
    "It's finally here! Happy 4/20 🌿 Elevate your session today with the ultimate guide to stoner dares and high-energy games. From 'Munchie Roulette' to 'Slow-Mo Challenges', we've got the vibes covered. 🌬️🎮\n\nFull Guide: https://blog.xdares.com/420-party-guide-2026/",
    "4/20 Pro-Tip: The 'Slow-Mo Race' is the ultimate way to test your focus today. Talk and move in half-speed—first to break character loses! 😂\n\nCheck out 40+ more game ideas: https://blog.xdares.com/420-party-guide-2026/",
    "Hungry yet? 🍕 Try 'Munchie Roulette' this 4/20. Order something random and let the group decide the dare for whoever eats it! #420 #PartyGames\n\nMore stoner challenges: https://blog.xdares.com/420-party-guide-2026/",
    "Don't just sit there—make it a party! 🌿 Our 2026 4/20 Guide is live with the best dares and group activities for your celebration. Stay safe and have fun! 🌬️✨\n\nRead more: https://blog.xdares.com/420-party-guide-2026/"
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
        if i < len(tweets):
            time.sleep(10)
    except Exception as e:
        print(f"❌ Tweet {i} failed: {e}")
        errors.append({'index': i, 'error': str(e)})

# Save results
results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

log_dir = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs'
log_file = os.path.join(log_dir, 'tweets-420-main-day-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json')
with open(log_file, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_file}")
