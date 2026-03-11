import json, sys, os
from requests_oauthlib import OAuth1Session

KEYS_PATH = os.path.expanduser("~/.openclaw/secrets/x-pp-api.json")

def get_oauth():
    with open(KEYS_PATH) as f:
        keys = json.load(f)
    return OAuth1Session(
        keys["oauth1"]["consumer_key"],
        client_secret=keys["oauth1"]["consumer_secret"],
        resource_owner_key=keys["oauth1"]["access_token"],
        resource_owner_secret=keys["oauth1"]["access_token_secret"],
    )

def follow_user(target_id):
    oauth = get_oauth()
    with open(KEYS_PATH) as f:
        keys = json.load(f)
    # Get own user ID from token if not in keys
    own_id = "2026663150540697603" 
    payload = {"target_user_id": str(target_id)}
    resp = oauth.post(f"https://api.x.com/2/users/{own_id}/following", json=payload)
    if resp.status_code == 200:
        print(f"Followed {target_id}: {resp.json()['data']['following']}")
    else:
        print(f"Error {resp.status_code}: {resp.text}")

if __name__ == "__main__":
    follow_user(sys.argv[1])
