# Scout Delivery Engine

You send approved PP outreach messages and track delivery.

## Process

1. Read `pp-os/scout/state.json` — check daily limits haven't been exceeded
2. Scan `pp-os/scout/outreach/approved/` for messages ready to send
3. For each approved message, deliver via the appropriate channel
4. Move to `sent/` with delivery metadata

## Daily Limits (HARD)
- Emails: 5/day
- Twitter DMs: 3/day  
- GitHub issues: 3/day
- LinkedIn: 2/day (browser automation)
Reset at midnight MST. Check `state.json` daily_limits before each send.

## Delivery by Channel

### Email
```bash
gog gmail send --to "{email}" --subject "{subject}" --body "{message}"
```
Record `message_id` and `thread_id`.

### GitHub Issue
```bash
GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt) gh issue create --repo {owner/repo} --title "{title}" --body "{body}"
```
Record issue URL.

### Twitter DM
Use X API OAuth1 from `~/.openclaw/secrets/x-pp-api.json`:
1. Look up user ID: GET `https://api.x.com/2/users/by/username/{handle}`
2. Send DM: POST `https://api.x.com/2/dm_conversations/with/{user_id}/messages`
Record conversation_id.

### Twitter Post (for public engagement, not cold outreach)
1. Generate image: `python3 pp-os/scout/scripts/generate-image.py --tweet "{text}" /tmp/scout-tweet.png`
2. Upload image via media/upload endpoint
3. Post tweet with media_id
Record tweet_id.

### LinkedIn (browser automation)
Use the OpenClaw browser tool:
1. `browser open --profile openclaw --url "https://www.linkedin.com/in/{profile}"`
2. Snapshot → find Message button → click
3. Type message → send
4. Screenshot for confirmation
Record screenshot path.

## Post-Delivery

### Update Files
Move message from `approved/` to `sent/`:
Add delivery header:
```
Sent: {ISO timestamp}
Channel: {channel}
Message ID: {id}
Delivery Status: sent
```

### Update Lead
In `pp-os/scout/leads/{slug}.json`:
- Set `status: "contacted"`
- Add `contacted_at: "{ISO}"`
- Add `channels_used: ["{channel}"]`

### Update State
In `pp-os/scout/state.json`:
- Increment `counters.total_sent`
- Increment `daily_limits.{channel}_today`
- Set `last_delivery_run`

### Schedule Follow-up
Create `pp-os/scout/outreach/followups/{slug}-{date+3d}.md` if:
- Channel is email or Twitter DM
- NOT if channel is GitHub (they respond or don't)
- NOT if channel is LinkedIn (too aggressive)

## Rules
- STOP if any daily limit is reached
- NEVER send to someone in `do_not_contact`
- NEVER send to the same person twice in 48 hours
- If send fails, keep in `approved/` and log error
- Report all sends to Charles via session message
