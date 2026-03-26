#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting 500+ Truth or Dare Questions for Adults."""

import json
import tweepy
import time
import os
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

# Target URL
post_url = "https://blog.xdares.com/truth-or-dare-questions-for-adults/"

# Targeted tweets for this specific post
tweets = [
    # 1. Broad listicle hook
    f"500+ Truth or Dare Questions for Adults 🎯\n\nWe spent weeks compiling the ultimate party guide:\n\n🔥 Spicy truth questions\n😂 Hilarious dares\n💬 Deep confessions\n🤫 Embarrassing secrets\n\nUpgrade your next game night 👇\n\n{post_url}",
    
    # 2. Curiosity/Engagement hook
    f"What's the most embarrassing thing you've done while drunk? 🍻\n\nWe have 50 funny truth questions (and 450+ more) to get the room talking.\n\nFrom flirty to wild, find your next challenge here:\n\n{post_url}",
    
    # 3. Dares-focused hook
    f"Eat a raw egg? Call your boss and 'quit'? 🍳📱\n\nOur Extreme Dares section is not for the weak.\n\n500+ questions and dares for your next adult party or date night:\n\n{post_url}\n\n#TruthOrDare #PartyGames #AdultGames",
    
    # 4. Couples-specific hook
    f"Spice up your next date night with 50+ dares specifically for couples 💕\n\nPart of our massive 500+ Truth or Dare collection for adults.\n\nCheck out the full list:\n{post_url}\n\n#RelationshipGoals #DateNightIdeas"
]

posted = []
errors = []

print(f"🚀 Starting tweet promotion for: {post_url}")

for i, tweet_text in enumerate(tweets, 1):
    try:
        # Actually execute tweet posting
        response = client.create_tweet(text=tweet_text)
        tweet_id = response.data['id']
        # tweet_id = f"simulated_{int(time.time())}_{i}"
        tweet_url = f"https://x.com/xdares_/status/{tweet_id}"
        
        print(f"✅ Tweet {i} posted: {tweet_url}")
        posted.append({
            'index': i,
            'id': tweet_id,
            'url': tweet_url,
            'text': tweet_text[:50] + '...'
        })
        # Wait between tweets
        if i < len(tweets):
            time.sleep(2)
    except Exception as e:
        print(f"❌ Tweet {i} failed: {e}")
        errors.append({'index': i, 'error': str(e)})

print(f"\n📊 Results: {len(posted)}/{len(tweets)} tweets posted")

# Save results to the specified log directory
log_dir = "/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs"
log_file = os.path.join(log_dir, f"tweets-truth-or-dare-500-{datetime.now().strftime('%Y%m%d-%H%M%S')}.json")

results = {
    'timestamp': datetime.now().isoformat(),
    'url': post_url,
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

with open(log_file, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_file}")
