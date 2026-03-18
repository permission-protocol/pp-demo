#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting the new Icebreaker Games post."""

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

# Icebreaker tweets
tweets = [
    "Meeting new people doesn't have to be awkward! 🤝\n\nWe've compiled 35 Best Icebreaker Games for Adults that actually work. No corporate fluff, just real fun.\n\n✓ Professional Networking\n✓ Casual Parties\n✓ Team Building\n✓ Digital-First Ideas\n\nFull guide: https://blog.xdares.com/icebreaker-games-for-adults-blog-post-3/ #icebreakers #socialgames",
    "Hosting a meetup or workshop? 🏫\n\nThe right icebreaker sets the tone for the entire event. Our latest guide features games for every group size and vibe.\n\nCheck out the 2026 update to our Icebreaker list:\n\nhttps://blog.xdares.com/icebreaker-games-for-adults-blog-post-3/ #networking #teamwork",
    "From classic get-to-know-you games to high-energy group activities, we've got you covered for your next social gathering.\n\nStop the awkward silence and start the fun! ✨\n\nFull list here:\n\nhttps://blog.xdares.com/icebreaker-games-for-adults-blog-post-3/ #socialgathering #fun"
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

log_path = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-icebreaker-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
