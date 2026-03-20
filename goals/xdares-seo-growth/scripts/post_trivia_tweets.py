#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting the new Trivia Drinking Game post."""

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

# Trivia tweets
tweets = [
    "Bar trivia is fun, but Bar Trivia DRINKING Games are better 🍻\n\nCheck out our latest guide to the best trivia drinking games for your next pub quiz night.\n\n✓ Pub Quiz Rules\n✓ Movie/Music Rounds\n✓ Speed Rounds\n✓ Team Challenges\n\nFull guide: https://blog.xdares.com/trivia-drinking-games-pub-quiz-3/ #trivia #drinkinggames",
    "Hosting a quiz night at home? 🏠\n\nDon't just keep score. Add drinking rules to the wrong answers and double down on the fun.\n\nLearn how to turn any trivia night into a drinking game:\n\nhttps://blog.xdares.com/trivia-drinking-games-pub-quiz-3/ #quiznight #partyideas",
    "From classic pub quizzes to themed trivia nights, we've compiled the best rules for trivia drinking games.\n\nWarning: Your competitive side will come out! 🎯\n\nFull list here:\n\nhttps://blog.xdares.com/trivia-drinking-games-pub-quiz-3/ #triviaquiz #competition"
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

print(f"\n📊 Results: {len(posted)}/{len(tweets)} tweets posted")

# Save results
results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

log_path = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-trivia-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
