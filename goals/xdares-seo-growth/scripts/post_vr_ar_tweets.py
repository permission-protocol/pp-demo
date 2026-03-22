#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting the VR/AR dare post."""

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

tweets = [
    "The future of truth or dare is here and it's IMMERSIVE 🥽\n\nWe just dropped the ultimate guide to 50+ VR and AR dare ideas for 2026.\n\nFrom VRChat pranks to AR filter social stunts:\n\nhttps://blog.xdares.com/vr-ar-dare-ideas/",
    "Ever tried an 'Avatar Swap' gauntlet in VR? 🎭\n\nIt's one of the top trending dares of 2026.\n\nLearn how to leverage VR and AR for your next game night or Xdares stream:\n\nhttps://blog.xdares.com/vr-ar-dare-ideas/",
    "AR 'dare chains' are officially taking over 📱✨\n\nDigital magic meets real-world bravery.\n\nCheck out our latest post on how to use AR glasses and mobile filters for the ultimate dare experience:\n\nhttps://blog.xdares.com/vr-ar-dare-ideas/",
    "Is your next social event ready for the metaverse? 🌌\n\n50+ ways to level up your social game with VR/AR technology.\n\n✓ Social hubs\n✓ AR public stunts\n✓ Immersive roleplay\n\nRead more: https://blog.xdares.com/vr-ar-dare-ideas/"
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
            time.sleep(1)
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
log_path = os.path.join(log_dir, 'tweets-vr-ar-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json')
with open(log_path, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to: {log_path}")
