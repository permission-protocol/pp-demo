#!/usr/bin/env python3
"""Post tweets to @xdares_ promoting blog content."""

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

# 5 engaging tweets with party game hooks
tweets = [
    # 1. Valentine's Day timely hook
    "Valentine's Day is 1 week away 💕\n\nForget dinner reservations. Try these 25 romantic dares instead:\n\n→ Blindfolded taste test\n→ Write a love letter in 2 minutes\n→ Dance to your first song\n→ 30-second compliment challenge\n\nFull list: https://blog.xdares.com/romantic-dares-for-couples-valentines-day/",
    
    # 2. Never Have I Ever viral hook
    "Never Have I Ever questions that will absolutely destroy your friend group 😈\n\n150+ questions from mild to wild:\n• Warm-up\n• Embarrassing\n• Spicy\n• Deep confessions\n\nYour next party just got interesting 👀\n\nhttps://blog.xdares.com/never-have-i-ever-questions-that-will-shock-your-friends/",
    
    # 3. Party games listicle
    "Hosting a party soon?\n\nHere are 15 drinking games beyond beer pong that actually work:\n\n1. Kings Cup\n2. Flip Cup\n3. Power Hour\n4. Drunk Jenga\n5. Quarters\n\n...and 10 more with full rules 🍻\n\nhttps://blog.xdares.com/best-drinking-games-for-parties/",
    
    # 4. Date night engagement
    "30 date night games that don't require leaving the couch:\n\n🎮 2-player challenges\n💬 Deep conversation starters\n🔥 Spicy truth or dare\n🎨 Creative activities\n\nWay better than \"what do you want to watch?\"\n\nhttps://blog.xdares.com/date-night-games-to-spice-up-your-relationship/",
    
    # 5. Truth or Dare core content
    "Adult Truth or Dare hits different 🎯\n\nWe compiled 200+ questions and dares:\n\n✓ Flirty truths\n✓ Embarrassing confessions  \n✓ Hilarious dares\n✓ Couples edition\n✓ Party mode\n\nYour game night upgrade 👇\n\nhttps://blog.xdares.com/truth-or-dare-questions-for-adults/"
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

print(f"\n📊 Results: {len(posted)}/5 tweets posted")
if errors:
    print(f"Errors: {errors}")

# Save results
results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

with open('goals/xdares-seo-growth/logs/tweets-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.json', 'w') as f:
    json.dump(results, f, indent=2)

print(f"\nResults saved to logs/")
