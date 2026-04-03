#!/usr/bin/env python3
"""Post Easter promo 3-part thread to @xdares_."""

import json
import tweepy
import time
from datetime import datetime

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

# 3-part Easter promo thread
thread_tweets = [
    "Easter Brunch is almost here! 🥂 Forget the boring egg hunt. Here's how to host the ultimate last-minute adult brunch (with games). 🧵 (1/3) #Easter2026 #BrunchGames",
    "Step 1: Boozy Bingo. Every time someone mentions 'he is risen' or 'chocolate bunny', take a sip. Step 2: The Bunny Hop Dare. Best dance move wins the first mimosa. 🐣 (2/3) #EasterDares",
    "Full list of 40+ games and dares for your Easter Sunday: https://blog.xdares.com/easter-party-games-drinking/ #EasterParty #AdultGames (3/3)"
]

posted = []
errors = []
last_tweet_id = None

for i, tweet_text in enumerate(thread_tweets, 1):
    try:
        if last_tweet_id is None:
            response = client.create_tweet(text=tweet_text)
        else:
            response = client.create_tweet(text=tweet_text, in_reply_to_tweet_id=last_tweet_id)
        
        tweet_id = response.data['id']
        tweet_url = f"https://x.com/xdares_/status/{tweet_id}"
        print(f"✅ Thread part {i} posted: {tweet_url}")
        posted.append({'index': i, 'id': tweet_id, 'url': tweet_url, 'text': tweet_text[:50] + '...'})
        last_tweet_id = tweet_id
        time.sleep(3)
    except Exception as e:
        print(f"❌ Thread part {i} failed: {e}")
        errors.append({'index': i, 'error': str(e)})
        # Break if the first part fails
        if last_tweet_id is None:
            break

# Save results
results = {'timestamp': datetime.now().isoformat(), 'posted': posted, 'errors': errors, 'total_posted': len(posted), 'type': 'thread'}
log_path = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/nhie-tweets-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'
# Using nhie-tweets prefix as it seems to be used for general logs sometimes, but let's be more specific if we can.
# Actually, the logs directory has many prefixes. Let's use 'easter-thread'.
log_path = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/easter-thread-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json'

with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_path}")
