#!/usr/bin/env python3
"""Post 4 tweets promoting the GetDare 2026 alternative post."""

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
    # 1. GetDare Alternative 2026 - main push
    """Looking for a GetDare alternative in 2026? 👀

The community has moved to Xdares.

✓ Instant payouts (Dare-to-Earn)
✓ Verified video proof
✓ End-to-end encrypted adult content

Full 2026 guide: https://blog.xdares.com/get-dare-alternative-2026/

#GetDare #TruthOrDare #AdultGames""",

    # 2. Comparison angle
    """How does Xdares compare to the legacy GetDare? ⚖️

We broke down the key differences for 2026:
• Mobile-first experience 📱
• Automated verification 🤖
• Real money stakes 💸

See why the daring community is switching:
https://blog.xdares.com/get-dare-alternative-2026/

#Dares #Challenge #Xdares""",

    # 3. Privacy angle
    """Adult daring should be personal and secure. 🔒

In 2026, Xdares is the only GetDare alternative with:
• Encrypted private dares
• Locked content for fans
• Metadata proof verification

Privacy-first daring is here 👉 https://blog.xdares.com/get-dare-alternative-2026/

#Privacy #Safety #AdultContent""",

    # 4. Final CTA
    """Stop doing dares for likes. Start doing them for LIVES. 🚀

Xdares turns your courage into a community (and an income).

Join the 2026 movement:
https://blog.xdares.com/get-dare-alternative-2026/

#GetDareAlternative #DareEconomy #EarnFromDares"""
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
            time.sleep(5)  # Quick delay
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
log_path = Path("/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs") / f"tweets-getdare-2026-{timestamp}.json"
log_path.parent.mkdir(parents=True, exist_ok=True)
with open(log_path, "w") as f:
    json.dump({
        "timestamp": datetime.now().isoformat(),
        "account": "@xdares_",
        "theme": "GetDare Alternative 2026 Promotion",
        "tweets": results
    }, f, indent=2)

print(f"\nResults saved to: {log_path}")
print(f"Posted: {sum(1 for r in results if r['status'] == 'posted')}/{len(tweets)}")
