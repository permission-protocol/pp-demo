import sys
import json
import os
import requests

def get_tweet_details(tweet_id, bearer_token):
    url = f"https://api.twitter.com/2/tweets?ids={tweet_id}&tweet.fields=created_at,public_metrics,author_id&expansions=author_id&user.fields=public_metrics"
    headers = {"Authorization": f"Bearer {bearer_token}"}
    response = requests.get(url, headers=headers)
    return response.json()

if __name__ == "__main__":
    tweet_id = sys.argv[1]
    with open(os.path.expanduser("~/.openclaw/secrets/x-pp-api.json")) as f:
        secrets = json.load(f)
        bearer_token = secrets["bearer_token"]
    
    details = get_tweet_details(tweet_id, bearer_token)
    print(json.dumps(details, indent=2))
