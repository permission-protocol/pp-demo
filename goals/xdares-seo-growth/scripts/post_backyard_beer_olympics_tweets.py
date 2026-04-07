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

url = "https://blog.xdares.com/backyard-beer-olympics-2026-rules-scoresheets-winning-strategy/"

tweets = [
    f"Summer is coming! ☀️🍻 Host the ultimate Backyard Beer Olympics with our 2026 guide: {url} #BeerOlympics #SummerVibes #PartyGames",
    f"From Beer Pong to Flip Cup, we've got the rules and scoresheets you need for a legendary backyard tournament 🏆🎯 {url} #DrinkingGames #HostWithTheMost",
    f"Want to win the Beer Olympics? 🥇 We've got the winning strategies and team name ideas to get you started! {url} #BeerOlympics #WinnerWinner",
    f"Don't just host a party, host an OLYMPIC EVENT. 🏟️🍺 Download our free scoresheets and get the party started! {url} #BackyardParty #Summer2026",
    f"Check out our full guide to Backyard Beer Olympics for 2026: {url} 🍻🎮 #GameNight #Xdares #BeerGames"
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
log_path = f"/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-backyard-beer-olympics-{log_timestamp}.json"
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
