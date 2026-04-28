import json
import tweepy
import time
from datetime import datetime
import os

with open('/Users/moltbot/.openclaw/secrets/x-api.json', 'r') as f:
    creds = json.load(f)

client = tweepy.Client(
    consumer_key=creds['oauth1']['consumer_key'],
    consumer_secret=creds['oauth1']['consumer_secret'],
    access_token=creds['oauth1']['access_token'],
    access_token_secret=creds['oauth1']['access_token_secret']
)

tweets = [
    "Summer Kickoff 2026! 🇺🇸🍔\n\nWe just published the ultimate guide to 65+ Memorial Day Party Games & BBQ Drinking Games for Adults.\n\nFrom backyard Olympics to patriotic toasts, we've got you covered.\n\nRead more: https://blog.xdares.com/65-memorial-day-party-games-bbq-drinking-games-2026/",
    "Planning your Memorial Day BBQ? 🌭🍻\n\nDon't settle for just cornhole. Level up your party with these 50+ games and dares specifically for the holiday weekend.\n\nCheck it out: https://blog.xdares.com/65-memorial-day-party-games-bbq-drinking-games-2026/",
    "Patriotic Drinking Games for 2026! 🇺🇸🍻\n\nCelebrate the long weekend with our favorite red, white, and blue drinking games.\n\nSee the full list: https://blog.xdares.com/65-memorial-day-party-games-bbq-drinking-games-2026/"
]

posted = []
for i, text in enumerate(tweets, 1):
    try:
        response = client.create_tweet(text=text)
        url = f"https://x.com/xdares_/status/{response.data['id']}"
        print(f"✅ Posted: {url}")
        posted.append(url)
        if i < len(tweets): time.sleep(10)
    except Exception as e:
        print(f"❌ Failed: {e}")

log_file = f"/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-memorial-{datetime.now().strftime('%Y%m%d-%H%M%S')}.json"
with open(log_file, 'w') as f:
    json.dump({'timestamp': datetime.now().isoformat(), 'posted': posted}, f)
