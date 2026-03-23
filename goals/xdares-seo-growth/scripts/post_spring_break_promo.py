#!/usr/bin/env python3
"""Post 4 tweets promoting the new Spring Break drinking games content."""

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
    """🔥 100+ Best Spring Break Drinking Games for 2026 🔥

From beach hubs to pool parties, we've got the ultimate guide to your vacation:

🏖️ Beach volleyball drinking rules
🍹 Tropical pool float challenges
🚢 Spring Break cruise games
🎉 Hotel pregame starters

Full list: https://blog.xdares.com/spring-break-drinking-games/

#SpringBreak #DrinkingGames #Party2026""",

    """Planning your Spring Break 2026? ☀️

Don't settle for just beer pong. Check out these 100+ drinking games for every setting:

🏄 Surf-side drinking challenges
🧊 Poolside icebreakers
🌆 Nightlife pregame ideas

Read the full guide: https://blog.xdares.com/spring-break-drinking-games/

#SpringBreak2026 #PartyGames #Vacation""",

    """Spring Break 2026 is almost here! 🏖️🍹

Make sure your group is ready with the best games for:
• Cancun 🇲🇽
• Miami 🇺🇸
• Cabo 🌴
• Bahamas 🚢

100+ games with full rules: https://blog.xdares.com/spring-break-drinking-games/

#SpringBreak #PartyMode #DrinkingGames""",

    """Ultimate Spring Break 2026 Drinking Game Guide 🍻

We researched the top party hubs and trends to bring you:
✅ 100+ games
✅ Beach, pool & hotel rules
✅ Pro tips for vacation games

Upgrade your trip: https://blog.xdares.com/spring-break-drinking-games/

#SpringBreak #PartyTips #2026"""
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
            time.sleep(10)  # Rate limit protection
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
log_path = Path("goals/xdares-seo-growth/logs") / f"tweets-spring-break-{timestamp}.json"
log_path.parent.mkdir(parents=True, exist_ok=True)
with open(log_path, "w") as f:
    json.dump({
        "timestamp": datetime.now().isoformat(),
        "account": "@xdares_",
        "theme": "Spring Break 2026 Promotion",
        "tweets": results
    }, f, indent=2)

print(f"\nResults saved to: {log_path}")
print(f"Posted: {sum(1 for r in results if r['status'] == 'posted')}/{len(tweets)}")
