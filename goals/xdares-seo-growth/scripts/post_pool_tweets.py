import json
import tweepy
import time
import os
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

url = "https://blog.xdares.com/summer-pool-party-games-2026/"

tweets = [
    f"Summer 2026 is loading... ☀️🌊\n\nDon't let your pool parties be basic. We just dropped the ultimate guide to 35+ epic water games for adults.\n\nFrom Chicken Fight Championships to Floaty Flip Cup 🍻\n\nFull list: {url}",
    f"The only pool party supply list you need for 2026:\n\n1. Inflatable pong set\n2. Pool noodles (multi-color)\n3. Waterproof speakers\n4. 35+ game ideas from our latest guide 👇\n\n{url}",
    f"Pro-tip for your next pool day: Greased Watermelon 🍉💦\n\nIt's chaotic, it's slippery, and it's the best workout you'll get all summer. Rules and 34 other game ideas here:\n\n{url}"
]

posted = []
errors = []

for i, tweet_text in enumerate(tweets, 1):
    try:
        response = client.create_tweet(text=tweet_text)
        tweet_id = response.data['id']
        tweet_url = f"https://x.com/xdares_/status/{{tweet_id}}"
        print(f"✅ Tweet {{i}} posted: {{tweet_url}}")
        posted.append({
            'index': i,
            'id': tweet_id,
            'url': tweet_url
        })
        if i < len(tweets):
            time.sleep(2)
    except Exception as e:
        print(f"❌ Tweet {{i}} failed: {{e}}")
        errors.append({'index': i, 'error': str(e)})

# Save results
results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

log_path = f"/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-pool-2026-{{datetime.now().strftime('%Y%m%d-%H%M%S')}}.json"
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"Results saved to {{log_path}}")
