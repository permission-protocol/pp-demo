#!/usr/bin/env python3
"""Post 5 tweets promoting GetDare alternative + new party content."""

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
    # 1. GetDare Alternative - main push
    """Miss GetDare? 👀

It shut down, but the dare community lives on.

Xdares is the new home for:
• Truth or Dare challenges
• Adult dares with real stakes
• Community-verified completions

Your next dare awaits 👉 xdares.com

#GetDare #TruthOrDare #Dares""",

    # 2. GetDare nostalgia + alternative
    """GetDare may be gone, but the spirit isn't dead.

Looking for a new dare community? Same energy, better platform.

Full breakdown of what's changed: blog.xdares.com/getdare-alternative-landing-page-2/

#GetDareAlternative #DareCommunity""",

    # 3. Extreme Dares content
    """50+ Extreme Dares for Adults 🔥

From "brave" to "absolutely insane":

• Midnight challenges
• Public dares (with witnesses)
• Fear-conquering stunts
• Spicy dares for couples 😏

Only for the bold: blog.xdares.com/extreme-dares-for-adults-2/

#ExtremeDares #Dares #Challenge""",

    # 4. Icebreaker Games
    """Icebreakers that don't make everyone cringe.

35 games for:
✓ Work events (professional)
✓ House parties (fun)
✓ Couples (romantic)
✓ Large groups (chaos)

blog.xdares.com/icebreaker-games-for-adults-blog-post-2/

#Icebreakers #PartyGames #TeamBuilding""",

    # 5. Community engagement
    """What's the wildest dare you've ever completed?

Bonus points if there's video evidence 😂

Drop it below 👇

#Dares #TruthOrDare #Challenge #Stories"""
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
log_path = Path("goals/xdares-seo-growth/logs") / f"tweets-getdare-{timestamp}.json"
log_path.parent.mkdir(parents=True, exist_ok=True)
with open(log_path, "w") as f:
    json.dump({
        "timestamp": datetime.now().isoformat(),
        "account": "@xdares_",
        "theme": "GetDare Alternative + New Party Content",
        "tweets": results
    }, f, indent=2)

print(f"\nResults saved to: {log_path}")
print(f"Posted: {sum(1 for r in results if r['status'] == 'posted')}/{len(tweets)}")
