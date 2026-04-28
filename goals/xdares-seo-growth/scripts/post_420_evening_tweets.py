#!/usr/bin/env python3
"""Post late afternoon/evening tweets to @xdares_ promoting 4/20 content."""

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

# 5 late-day 4/20 tweets
tweets = [
    "The 4/20 sun is setting, but the session is just getting started. \ud83c\udf12\ud83c\udf3f Keep the energy high with our collection of late-night dares and group games.\n\nFrom 'The Silent Stoner' to 'Abstract Art' challenges: https://blog.xdares.com/420-party-guide-2026/",
    
    "Is it even 4/20 if you haven't done a 'Ghost' dare yet? \ud83d\udcbb\ud83c\udf2c\ufe0f\n\nChallenge your friends to see who can pull off the smoothest clouds. Rules and 40+ more ideas here: https://blog.xdares.com/420-party-guide-2026/",
    
    "Late Night 4/20 Tip: Switch to low-energy, high-hilarity games. \ud83c\udfae\ud83c\udf2c\ufe0f\n\n'Truth or Dare' (Stoner Edition) never misses. Get the best questions for your late-day sesh: https://blog.xdares.com/420-party-guide-2026/",
    
    "Still going strong? \ud83c\udf3f\ud83d\udd25 Our 2026 4/20 Guide has a whole section for those 'deep conversation' dares that only work when the vibe is just right.\n\nCheck it out: https://blog.xdares.com/420-party-guide-2026/",
    
    "Ending 4/20 on a high note! \ud83c\udf1f\ud83c\udf3f Thanks for joining us today. If you're still looking for ways to make the night legendary, we've got you covered.\n\nStay safe and keep playing: https://blog.xdares.com/420-party-guide-2026/"
]

posted = []
errors = []

for i, tweet_text in enumerate(tweets, 1):
    try:
        response = client.create_tweet(text=tweet_text)
        tweet_id = response.data['id']
        tweet_url = f"https://x.com/xdares_/status/{tweet_id}"
        print(f"[\u2705] Tweet {i} posted: {tweet_url}")
        posted.append({
            'index': i,
            'id': str(tweet_id),
            'url': tweet_url,
            'text': tweet_text[:50] + '...'
        })
        if i < len(tweets):
            time.sleep(10)
    except Exception as e:
        print(f"[\u274c] Tweet {i} failed: {e}")
        errors.append({'index': i, 'error': str(e)})

# Save results
results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

log_dir = '/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs'
log_file = os.path.join(log_dir, 'tweets-420-evening-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json')
with open(log_file, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_file}")
