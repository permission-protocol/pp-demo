# Scout Warm-Up Engine

Before cold outreach, make @PermissionPrtcl a familiar name. This is the difference between spam and a conversation.

## Process

### 1. Load Outreach-Ready Leads
Read `pp-os/scout/leads/index.json` — find leads with status `outreach_ready` or `researched`.
Load their dossiers from `leads/{slug}.json`.

### 2. Find Their Public Activity
For each lead, search for recent public posts:

**Twitter/X:**
```bash
# Search their tweets (use bearer token)
curl -H "Authorization: Bearer {token}" "https://api.x.com/2/tweets/search/recent?query=from:{handle}&max_results=5"
```

**GitHub:**
```bash
gh search repos --owner {username} --sort updated --limit 3
# Or check their recent issues/comments
```

**LinkedIn posts:** (via web_search)
```
web_search "{name} {company} site:linkedin.com/posts"
```

### 3. Engage Genuinely (NOT promotionally)

**Twitter engagement actions (pick 1-2 per lead):**
- **Like** a recent relevant tweet (costs nothing, they see it)
- **Reply** with genuine value: share a related article, add a technical insight, ask a smart question
- **Retweet** with brief commentary if their post aligns with PP's thesis
- **DO NOT** mention Permission Protocol in warm-up replies. Zero promotion. Just be a smart person in their mentions.

**GitHub engagement:**
- **Star** their repos
- **Open a useful issue** (bug report, feature suggestion — genuinely helpful, not as a pretext)
- **Comment** on an existing issue with a real technical contribution

**LinkedIn:**
- **Like** their recent post
- **Comment** with a substantive take (not "Great post!")

### 4. Track Warm-Up Status
Update lead dossier with:
```json
{
  "warmup": {
    "started": "ISO date",
    "actions": [
      {"type": "twitter_like", "target": "tweet_id", "date": "ISO"},
      {"type": "twitter_reply", "target": "tweet_id", "text": "...", "date": "ISO"},
      {"type": "github_star", "target": "repo", "date": "ISO"}
    ],
    "ready_for_outreach": false
  }
}
```

### 5. Graduation Rules
A lead is "warm" and ready for cold outreach when:
- At least **2 public engagements** completed
- At least **24 hours** since first engagement
- At most **72 hours** since first engagement (don't wait too long)
- They have NOT blocked or ignored engagement

When a lead graduates:
- Update status to `warm_outreach_ready`
- The outreach drafter picks them up in the next cycle
- The DM/email can reference the public interaction: "Saw your tweet about X — we built the solution for that"

### 6. Engagement Quality Rules
**DO:**
- Add real insight to conversations
- Share relevant third-party content (not PP's)
- Ask genuine technical questions
- Compliment specific technical decisions

**DON'T:**
- Mention Permission Protocol
- Be promotional in any way
- Like/reply to more than 2 posts per person (creepy)
- Engage with posts older than 7 days
- Use the same reply template twice

## Output
Update lead dossiers with warmup status.
Create `pp-os/scout/warmup/YYYY-MM-DD.json` with all actions taken.
If any leads graduated to `warm_outreach_ready`, message Charles.

## Schedule
Runs twice daily: 8AM and 3PM MST (before the outreach drafter runs)
