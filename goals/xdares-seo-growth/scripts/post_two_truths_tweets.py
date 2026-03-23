#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting Two Truths and a Lie guide."""

import json
import tweepy
import time
from datetime import datetime
import os

# Load credentials
secrets_path = os.path.expanduser('~/.openclaw/secrets/x-api.json')
with open(secrets_path, 'r') as f:
    creds = json.load(f)

# Initialize client with OAuth 1.0a for posting
client = tweepy.Client(
    consumer_key=creds['oauth1']['consumer_key'],
    consumer_secret=creds['oauth1']['consumer_secret'],
    access_token=creds['oauth1']['access_token'],
    access_token_secret=creds['oauth1']['access_token_secret']
)

# 4 engaging tweets for Two Truths and a Lie
tweets = [
    # 1. The Strategy Hook
    "Winning 'Two Truths and a Lie' isn't about lying—it's about storytelling 🎭\n\n3 pro tips for an undefeated game:\n\n1️⃣ Use the 'Outrageous Truth' (nobody will believe it)\n2️⃣ Keep your body language neutral\n3️⃣ Stick to mundane lies\n\nFull strategy guide + 150 examples:\n\nhttps://blog.xdares.com/two-truths-and-a-lie-party-guide/",
    
    # 2. The Drinking Game Hook
    "Ready to turn your icebreaker into a proper party game? 🍻\n\nTwo Truths and a Lie: Drinking Edition Rules:\n\n✅ Guess right? Speaker drinks.\n❌ Guess wrong? You drink.\n🚫 NO ONE guesses? Group drinks 2x.\n\nFull rules & punishment shots:\n\nhttps://blog.xdares.com/two-truths-and-a-lie-party-guide/",
    
    # 3. The Inspiration Hook
    "Brain gone blank? 🤯 When it's your turn in Two Truths and a Lie, use these 150+ field-tested examples:\n\n😂 Embarrassing mishaps\n🌍 Travel adventures\n👶 Weird childhood facts\n💼 Office 'secrets'\n\nStop being the boring one in the circle:\n\nhttps://blog.xdares.com/two-truths-and-a-lie-party-guide/",
    
    # 4. The Direct Call to Action
    "The ultimate Two Truths and a Lie toolkit is live! 🎯\n\n• Master the basic rules\n• 150+ categorized examples\n• Winning strategies\n• Drinking game variations\n\nLevel up your next game night here 👇\n\nhttps://blog.xdares.com/two-truths-and-a-lie-party-guide/"
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

print(f"\n📊 Results: {len(posted)}/4 tweets posted")
if errors:
    print(f"Errors: {errors}")

# Save results
results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

log_filename = f"/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-two-truths-{datetime.now().strftime('%Y%m%d-%H%M%S')}.json"
with open(log_filename, 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to {log_filename}")
