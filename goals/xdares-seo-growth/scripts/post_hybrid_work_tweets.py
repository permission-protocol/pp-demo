#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting hybrid work game night content."""

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

# 4 engaging tweets targeting HR/team-leads
tweets = [
    "Hybrid work doesn't have to be just \"checking in\" on Slack 💻\n\nBuild real culture with 50+ remote-friendly Truth or Dare questions for your next virtual happy hour.\n\nProfessional, fun, and Zoom-ready 🎯\n\nhttps://blog.xdares.com/hybrid-work-game-night/",
    
    "\"Are you actually wearing pants right now?\" 👖\n\nThe ultimate hybrid work truth or dare is here.\n\n✓ 10 Zoom-friendly dares\n✓ 10 Office-appropriate truths\n✓ Slack/Async challenges\n\nBreak the ice without the awkwardness:\n\nhttps://blog.xdares.com/hybrid-work-game-night/",
    
    "Remote teams: Stop doing the same \"forced fun\" icebreakers.\n\nTry these interactive Truth or Dare prompts:\n\n• Show your cluttered \"off-camera\" desk 📸\n• QVC pitch for the closest office supply 📎\n• Dramatic reading of your last email 📧\n\n50+ ideas: https://blog.xdares.com/hybrid-work-game-night/",
    
    "HR & Team Leads: Looking for low-pressure team building that actually works? 🚀\n\nWe've curated 50+ Truth or Dare questions designed specifically for hybrid and remote work culture.\n\nBuild trust across time zones 🌍\n\nhttps://blog.xdares.com/hybrid-work-game-night/"
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
            time.sleep(5)
    except Exception as e:
        print(f"❌ Tweet {i} failed: {e}")
        errors.append({'index': i, 'error': str(e)})

print(f"\n📊 Results: {len(posted)}/4 tweets posted")
if errors:
    print(f"Errors: {errors}")

# Save results to the correct absolute path
log_dir = "/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs"
os.makedirs(log_dir, exist_ok=True)
log_file = os.path.join(log_dir, 'tweets-hybrid-work-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json')

results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

with open(log_file, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_file}")
