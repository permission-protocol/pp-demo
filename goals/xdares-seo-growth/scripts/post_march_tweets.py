#!/usr/bin/env python3
"""Post 5 tweets promoting March Madness + seasonal content."""

import tweepy
import json
import time
from datetime import datetime
from pathlib import Path

# Load credentials
creds_path = Path.home() / ".openclaw/secrets/x-api.json"
with open(creds_path) as f:
    creds = json.load(f)

# OAuth1 for posting
client = tweepy.Client(
    consumer_key=creds["oauth1"]["consumer_key"],
    consumer_secret=creds["oauth1"]["consumer_secret"],
    access_token=creds["oauth1"]["access_token"],
    access_token_secret=creds["oauth1"]["access_token_secret"]
)

tweets = [
    # 1. March Madness drinking games
    """🏀 March Madness Drinking Games 🍺

25+ ways to turn every buzzer-beater into a party:

• Shot every 3-pointer
• Drink on fouls
• Bracket drinking bingo
• "Cinderella" bonus rules

Full rules: blog.xdares.com/march-madness-drinking-games-2/

#MarchMadness #DrinkingGames #Basketball""",

    # 2. Spring Break party games
    """☀️ Spring Break Party Games ☀️

30+ games for beach, pool & vacation:

🏖️ Beach volleyball drinking rules
🍹 Pool float challenges
🎉 Hotel pregame starters
✈️ Travel-friendly games

Your vacation just got better 👉 blog.xdares.com/spring-break-party-games/

#SpringBreak #PartyGames""",

    # 3. Tournament season hype
    """The brackets are coming. Your party better be ready.

March Madness + March drinking games = legendary nights.

Who's hosting watch parties this year? 🏀🍻

#MarchMadness2026 #Basketball #Party""",

    # 4. Flip Cup teaser
    """Flip Cup isn't just flipping cups.

There's Survivor Flip Cup. Strip Flip Cup. Landmine Flip Cup. Wizard Staff rules.

Full breakdown of 16 variations coming soon 🍺

What's YOUR house rule?

#FlipCup #DrinkingGames #PartyGames""",

    # 5. Power Hour teaser
    """Power Hour: 60 shots of beer in 60 minutes.

Sounds simple. Rarely completed.

Century Club (100 shots) is for legends only.

Ever finished one? 💀🍺

#PowerHour #DrinkingGames #Challenge"""
]

results = []
for i, tweet in enumerate(tweets):
    try:
        response = client.create_tweet(text=tweet)
        tweet_id = response.data['id']
        print(f"✓ Tweet {i+1} posted: {tweet_id}")
        results.append({
            "index": i + 1,
            "id": tweet_id,
            "text": tweet[:100] + "...",
            "status": "posted"
        })
        if i < len(tweets) - 1:
            time.sleep(30)  # Rate limit protection
    except Exception as e:
        print(f"✗ Tweet {i+1} failed: {e}")
        results.append({
            "index": i + 1,
            "text": tweet[:100] + "...",
            "status": "failed",
            "error": str(e)
        })

# Save results
timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
log_path = Path("goals/xdares-seo-growth/logs") / f"tweets-march-{timestamp}.json"
log_path.parent.mkdir(parents=True, exist_ok=True)
with open(log_path, "w") as f:
    json.dump({
        "timestamp": datetime.now().isoformat(),
        "account": "@xdares_",
        "theme": "March Madness + Seasonal Content",
        "tweets": results
    }, f, indent=2)

print(f"\nResults saved to: {log_path}")
print(f"Posted: {sum(1 for r in results if r['status'] == 'posted')}/{len(tweets)}")
