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

# Teen Truth or Dare tweets
tweets = [
    "Planning a sleepover or teen party? 🍕\n\nWe've got you covered with 200+ Truth or Dare questions that are fun, slightly embarrassing, and 100% clean.\n\nFrom funny truths to hilarious dares, keep the group laughing all night long! 👇\n\nhttps://blog.xdares.com/truth-or-dare-questions-for-teens/",
    "Truth or Dare: Sleepover Edition 🛌✨\n\nDon't settle for boring questions. We've curated the best teen-appropriate Truth or Dare ideas:\n\n✅ 100+ Funny Truths\n✅ 50+ Hilarious Dares\n✅ 30+ Social Media Challenges\n\nGame on: https://blog.xdares.com/truth-or-dare-questions-for-teens/",
    "What's the most embarrassing thing in your search history? 🔍💻\n\nJust one of the 100+ truth questions in our ultimate guide for teens.\n\nFind your next game night obsession here: https://blog.xdares.com/truth-or-dare-questions-for-teens/"
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
        # Wait between tweets
        if i < len(tweets):
            time.sleep(3)
    except Exception as e:
        print(f"❌ Tweet {i} failed: {e}")
        errors.append({'index': i, 'error': str(e)})

print(f"\n📊 Results: {len(posted)}/{len(tweets)} tweets posted")
