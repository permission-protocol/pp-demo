#!/usr/bin/env python3
"""Post April Fool's promo tweets to @xdares_."""

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

# 5 engaging tweets for April Fool's
tweets = [
    "April Fool's Day is coming up! 🤡 Tired of basic pranks? Turn your April 1st into a legendary party with these 25+ hilarious drinking games and dares! 🍻\n\nFull guide: https://blog.xdares.com/april-fools-drinking-games-2026-2/",
    "Ever tried Reverse Beer Pong? 🍺 On April Fool's Day, everything is backwards! Make the shot, and YOU drink. Miss, and everyone else drinks! 🎯\n\nFull rules and 24 other prank-filled games & dares: https://blog.xdares.com/april-fools-drinking-games-2026-2/",
    "The 'Salt or Sugar' Shot Roulette: The ultimate high-stakes April Fool's game. 5 shots of water, 1 shot of salt water. Who's getting the prank? 😂\n\nDiscover more crazy ideas for your next party: https://blog.xdares.com/april-fools-drinking-games-2026-2/",
    "Test your friends' ability to spot a lie with the 'Fake Fact' Pub Quiz! 🧐 Obscure real facts vs. convincing prank ones. Guess wrong and you drink double! 🍹\n\nPerfect for a chaotic April Fool's night: https://blog.xdares.com/april-fools-drinking-games-2026-2/",
    "Stop doing boring pranks. Start playing April Fool's drinking games and doing hilarious dares! 🎭 From the Mirror Challenge to the 'Invisible Friend' dare, we've got your April 1st covered. 🥂\n\nFull list: https://blog.xdares.com/april-fools-drinking-games-2026-2/"
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

log_path = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-april-fools-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
