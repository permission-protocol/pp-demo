#!/usr/bin/env python3
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
    "Ready for the grill? 🍔🍻\n\nWe just dropped the ultimate guide to Summer BBQ Drinking Games for 2026.\n\nFrom 'Cornhole Booze Rules' to 'Burger Building Races', your backyard just got a whole lot more interesting.\n\nCheck it out: https://blog.xdares.com/summer-bbq-drinking-games-2026/",
    "35+ Backyard Grilling Games for 2026! ☀️🔥\n\nTurn your next cookout into an Olympic event with these lawn games and grill-themed competitions.\n\nWho's ready to be crowned the 'Grill Master'? 👑🍔\n\nRead more: https://blog.xdares.com/summer-bbq-drinking-games-2026/",
    "BBQ Drinking Game Alert! 🚨🍻\n\nHave you ever tried 'Condiment Roulette' or 'Hot Dog Holding'? 🌭😈\n\nGet the rules for these and 33 more summer favorites:\nhttps://blog.xdares.com/summer-bbq-drinking-games-2026/"
]

posted = []
for i, text in enumerate(tweets, 1):
    try:
        response = client.create_tweet(text=text)
        url = f"https://x.com/xdares_/status/{response.data['id']}"
        print(f"✅ Posted: {url}")
        posted.append(url)
        if i < len(tweets): time.sleep(3)
    except Exception as e:
        print(f"❌ Failed: {e}")

log_file = f"/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-bbq-{datetime.now().strftime('%Y%m%d-%H%M%S')}.json"
with open(log_file, 'w') as f:
    json.dump({"timestamp": datetime.now().isoformat(), "posted": posted}, f)
