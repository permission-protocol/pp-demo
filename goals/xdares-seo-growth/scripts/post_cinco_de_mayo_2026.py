#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting Cinco de Mayo content."""

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

# 3 engaging Cinco de Mayo tweets
tweets = [
    "Cinco de Mayo 2026 is around the corner! 🌮🇲🇽\n\nDon't just do the same old taco bar. Level up your fiesta with traditional Mexican games like Dudo and Toma Todo (with a drinking twist!)\n\nFull guide: https://blog.xdares.com/cinco-de-mayo-2026-the-ultimate-fiesta-games-drinking-guide/",
    
    "Mexican Dice (Dudo) is the high-stakes bluffing game your Cinco de Mayo party needs. 🎲🍻\n\nCall 'Dudo!' on your friends or take a shot. The ultimate test of your poker face.\n\nMore fiesta game ideas: https://blog.xdares.com/cinco-de-mayo-2026-the-ultimate-fiesta-games-drinking-guide/",
    
    "Lotería (Mexican Bingo) but make it a drinking game! 🎰🍹\n\nEvery time 'El Borracho' is called, everyone drinks. First to shout ¡Lotería! assigns the tequila penalties.\n\nRules here: https://blog.xdares.com/cinco-de-mayo-2026-the-ultimate-fiesta-games-drinking-guide/"
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
log_file = os.path.join(log_dir, 'tweets-cinco-de-mayo-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json')
with open(log_file, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_file}")
