#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting the new Bingo post."""

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

# Bingo tweets
tweets = [
    "Bingo is the ultimate party game because ANYONE can play 🍻\n\nTurn your next game night into a high-energy drinking event with our guide to Bingo Drinking Games:\n\n✓ Traditional Rules\n✓ Movie/TV Bingo\n✓ Bar Crawl Edition\n✓ Virtual Bingo Tips\n\nFull guide: https://blog.xdares.com/bingo-drinking-games-rules-2/ #partygames #drinkinggames",
    "Hosting a watch party? 📺\n\nBingo is perfect for themed nights! Create cards with tropes from your favorite show and drink every time they happen.\n\nLearn how to spice up your next movie night with our latest guide:\n\nhttps://blog.xdares.com/bingo-drinking-games-rules-2/ #bingo #movienight",
    "Bar Crawl Bingo is the only way to do a pub crawl 🍺\n\nCreate a list of bar sightings (spilled drink, bad karaoke, tray of shots) and the first to Bingo wins!\n\nCheck out the full rules and more ideas here:\n\nhttps://blog.xdares.com/bingo-drinking-games-rules-2/ #pubcrawl #barcrawl"
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

log_path = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-bingo-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
