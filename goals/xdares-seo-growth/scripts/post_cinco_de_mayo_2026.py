import json
import tweepy
import time
from datetime import datetime

# Load credentials
with open('/Users/moltbot/.openclaw/secrets/x-api.json', 'r') as f:
    creds = json.load(f)

# Initialize client
client = tweepy.Client(
    consumer_key=creds['oauth1']['consumer_key'],
    consumer_secret=creds['oauth1']['consumer_secret'],
    access_token=creds['oauth1']['access_token'],
    access_token_secret=creds['oauth1']['access_token_secret']
)

tweets = [
    "Cinco de Mayo is around the corner! 🌮🍹\n\nDon't just stick to tacos. Level up your fiesta with these 6 classic Mexican party games:\n\n1. Lotería (Mexican Bingo)\n2. Toma Todo (The spinning top game)\n3. Dudo (Liar's Dice)\n4. Piñata Dares\n\nFull guide: https://blog.xdares.com/cinco-de-mayo-party-games-2026/",
    "Ever played Toma Todo? 🌀\n\nIt's a traditional Mexican game that's deceptively simple but high-stakes. Spin the Perinola and pray you don't hit 'Toma Todo' (unless you're ready for that communal pitcher!)\n\nRules for this & more: https://blog.xdares.com/cinco-de-mayo-party-games-2026/",
    "Cinco de Mayo 2026: Piñata Dares 🪅\n\nPro tip: Fill your piñata with dare slips instead of just candy. \n\n'Do a 30-second Grito'\n'Blindfolded taco eating contest'\n'Teach everyone a salsa move'\n\nGet the full dare list: https://blog.xdares.com/cinco-de-mayo-party-games-2026/",
    "Dudo (Liar's Dice) is the ultimate bluffing game for your Cinco de Mayo fiesta. 🎲\n\nAdd a 'margarita challenge' twist to keep the stakes high. \n\nCheck out the full rules: https://blog.xdares.com/cinco-de-mayo-party-games-2026/"
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
        if i < len(tweets):
            time.sleep(5)
    except Exception as e:
        print(f"❌ Tweet {i} failed: {e}")
        errors.append({'index': i, 'error': str(e)})

results = {
    'timestamp': datetime.now().isoformat(),
    'posted': posted,
    'errors': errors,
    'total_posted': len(posted)
}

with open('/Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/logs/tweets-cinco-de-mayo-20260409.json', 'w') as f:
    json.dump(results, f, indent=2)

print(f"SUCCESS: {len(posted)}/4 tweets posted.")
