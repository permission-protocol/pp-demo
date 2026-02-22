#!/usr/bin/env python3
"""
X/Twitter posting utility using OAuth 1.0a
Usage: python3 x_post.py "Tweet text here"
       python3 x_post.py --reply-to 123456789 "Reply text"
"""

import sys
import json
import argparse
import tweepy

CREDS_PATH = '/Users/moltbot/.openclaw/secrets/x-api.json'

def get_client():
    with open(CREDS_PATH) as f:
        creds = json.load(f)
    
    return tweepy.Client(
        consumer_key=creds['oauth1']['consumer_key'],
        consumer_secret=creds['oauth1']['consumer_secret'],
        access_token=creds['oauth1']['access_token'],
        access_token_secret=creds['oauth1']['access_token_secret']
    )

def post_tweet(text, reply_to=None):
    client = get_client()
    kwargs = {'text': text}
    if reply_to:
        kwargs['in_reply_to_tweet_id'] = reply_to
    
    response = client.create_tweet(**kwargs)
    tweet_id = response.data['id']
    return {
        'success': True,
        'tweet_id': tweet_id,
        'url': f'https://x.com/xdares_/status/{tweet_id}'
    }

def main():
    parser = argparse.ArgumentParser(description='Post to X/Twitter')
    parser.add_argument('text', help='Tweet text')
    parser.add_argument('--reply-to', help='Tweet ID to reply to')
    args = parser.parse_args()
    
    try:
        result = post_tweet(args.text, args.reply_to)
        print(f"✅ Posted: {result['url']}")
        return 0
    except Exception as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        return 1

if __name__ == '__main__':
    sys.exit(main())
