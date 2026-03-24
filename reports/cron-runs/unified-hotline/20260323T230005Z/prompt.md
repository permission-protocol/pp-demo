You are running the unified-hotline orchestration wrapper.

Mandatory execution pattern:
1. load
2. fetch
3. validate
4. invoke agent
5. write
6. log

Write only the requested final report. Do not describe the wrapper itself.

## Job
Run the unified hotline scan.

## Instructions
Use the hotline prompt and fetched scout state to produce the next hotline report. Call out hot signals, recommended fast-track actions, and any blocker that should halt outbound action. If there are no actionable signals, say so explicitly.

## Loaded Context
## Hotline Prompt
Path: /Users/moltbot/.openclaw/workspace/pp-os/scout/scripts/hotline-scan-prompt.md

```
# Scout Hotline — Real-Time Signal Detection

You are the fast-response arm of Scout. You scan for HOT signals that need immediate action — not in 4 hours, NOW.

## Sources (check all)

### Twitter/X — keyword monitoring
Search these queries on X (past 1 hour):
- "AI agent" AND ("breach" OR "unauthorized" OR "rogue" OR "incident")
- "AI agent" AND ("funding" OR "raised" OR "series")
- "@PermissionPrtcl" OR "permission protocol"

Use the X API bearer token from `~/.openclaw/secrets/x-pp-api.json`:
```bash
curl -H "Authorization: Bearer {token}" "https://api.x.com/2/tweets/search/recent?query=AI+agent+security+breach&max_results=10&sort_order=recency"
```

### Hacker News — front page + new
```
curl "https://hn.algolia.com/api/v1/search_by_date?query=AI+agent&tags=story&hitsPerPage=10"
```
Flag anything with 50+ points about agent security/authorization.

### Google News (via web_search)
One search: "AI agent security" with freshness=ph (past hour) — but only if web_search supports it, otherwise freshness=pd and check timestamps.

## Trigger Criteria

**IMMEDIATE ACTION (score 5):**
- AI agent incident/breach with named company (within 6 hours)
- Funding round >$10M for agent company (within 24 hours)  
- Regulatory action on AI agents
- Mention of Permission Protocol anywhere

**When triggered:**
1. Skip the normal pipeline entirely
2. Research the company/person immediately (web_search + web_fetch)
3. Draft outreach in the same session
4. If auto-approvable (GitHub, public tweet reply): SEND NOW
5. If needs approval (email, DM): save to `outreach/pending/` AND message Charles immediately

## Fast-Track Research (inline, not separate cron)
For hot signals, do abbreviated research in THIS session:
- Company name + what they do (1 sentence)
- Key person + contact info
- Why PP matters to them specifically
- Best channel to reach them

## Output
Append to `pp-os/scout/signals/YYYY-MM-DD.jsonl` with `"source": "hotline"`
If fast-tracked, write lead dossier to `pp-os/scout/leads/{slug}.json`
If outreach drafted, write to `pp-os/scout/outreach/pending/` or `approved/`

## Engagement Response
For any tweet mentioning AI agent security that has traction (50+ likes, 10+ replies):
- Draft a reply from @PermissionPrtcl that adds genuine value (not promotional)
- Save to `outreach/approved/tweet-reply-{id}.md` (auto-approved)
- These are public engagement, not cold outreach

## Rules
- This runs every HOUR, not every 4 hours — speed matters
- Max 2 fast-track actions per run (don't blow daily limits)
- Never DM someone who just had an incident — engage publicly first, DM later
- If nothing hot found, update state.json and exit silently
```

## PP Status
Path: /Users/moltbot/.openclaw/workspace/pp-os/STATUS.md

```
# PP Status — Last Updated: 2026-03-23

## Active — HN Launch (Tuesday Morning)
- **Status:** Action plan consolidated. All technical blockers merged and deployed.
- **Goal:** "Show HN: We built a system where AI agents can't deploy without a human signer."
- **Next:** Rod recording final demo GIF today. Launch Tuesday 8:30 AM MST.

## Active — MCP Guard (Enforcement Plane)
- **v0.1 Extraction:** Ed25519 verification and policy logic extracted into standalone `permission-protocol/mcp-guard` repo to physicalize the "Signer vs Enforcer" split.
- **Next:** Wire `mcp-guard` proxy to use new enforcement primitives.

## Active — PullMatch (Product Demo)
- **Launched:** PullMatch.com is live.
- **Recent:** Mobile landing optimized. Live diff summarization active.

## Technical Fixes (Launch Polish)
- **GitHub Comments:** Fixed emoji encoding bug that broke update-in-place logic (PR #244).
- **Anonymous Demo:** Added login-free `/demo/` approval flow for frictionless HN trial (PR #243).
- **Site Scrolling:** Removed hero chevron and disabled smooth-scroll to fix double-scroll bug (PR #230).

## Recent Decisions (Mar 23)
- **Architecture over Code:** Moving enforcement logic to a separate repo (`mcp-guard`) is critical for the "mathematically defensible" marketing claim.
- **Conversion Wedge:** Reducing the "Aha!" moment from a 5-minute install to a 30-second anonymous demo PR is the priority for the launch funnel.
```

## Recent Memory
Path: /Users/moltbot/.openclaw/workspace/memory/2026-03-21.md

```
# Daily Log — 2026-03-21

## What
- **Heartbeat Check**: Verified system health at 1:28 PM. Status: `clear`. All systems functional.
- **PullMatch Mobile Optimization**: Overhauled the landing page mobile hierarchy to bring the interactive `SwipeDemo` above the fold. 
- **PullMatch Live Summary**: Wired up the `/api/summarize` endpoint to parse live GitHub PR diffs and generate structured risk analysis.
- **PullMatch UI Refinement**: Updated the `WaitlistForm` to render a native branded card component for PR summaries instead of a text placeholder.
- **Production Deployment**: Pushed the optimized landing page and API changes to the `PullMatch/website` repository; live in production.
- **Factory Pipeline**: Reconciled and verified zero changes or stuck items.
- **PP Board**: Confirmed `Ready` queue is empty.
- **Thread Health**: Active threads (JAKE, MCP Guard) are within the update window; no nudges required.
- **Evolution Backup**: Successful daily checkpoint backup.
- **Hot Signal Clear**: Successfully processed hot signals (Excessive Agency, Skill Supply Chain Attacks) and cleared `pp-os/marketing/HOT-SIGNAL.md`.

## Why
- Achieving the PullMatch product goal of an immediate "Aha!" moment for founders landing on the page.
- "Show, don't tell": Interactive proof-of-concept drives higher conversion than static text.
- Maintaining operational continuity and ensuring system readiness for the upcoming 72h MCP Guard sprint.

## Insights
- **Headless Screenshot Pitfall**: Learned that `browser action: screenshot` with a URL can race navigation or capture stale active tabs. Manual `navigate` + specific `targetId` is required for reliable capture.
- **Framer-Motion Screenshot Bug**: `fullPage` screenshots in Playwright skip scroll-triggered animations (Intersection Observer). Required a CSS override (`opacity: 1 !important`) to capture content correctly.
- **Agency Risk**: Reports of agents autonomously restarting production services and pushing unsanctioned commits validate Permission Protocol's "Enforcement Wedge" strategy. Audit is secondary to control.

## Next
- Execute the MCP Guard HN submission and receipt viewer integration.
- Finalize PullMatch waitlist migrations and GoDaddy parking disable.
- Monitor Opus onboarding thread for final deployment verification.

---
*Archived 2026-03-21 from SESSION-STATE.md:*
- Task: refactor/orchestration-state-machine
- Requirements: create scripts/crons with 4 bash wrappers; enforce new threads schema; add merge->archive flow; commit/push/PR.
```

## Scout State
Command: `sed -n '1,220p' "/Users/moltbot/.openclaw/workspace/pp-os/scout/state.json"`

```
{
  "last_research_run": "2026-03-08T02:00:00Z",
  "last_hotline_run": "2026-03-23T19:02:17Z",
  "last_outreach_run": "2026-03-07T15:00:00Z",
  "last_response_check": "2026-03-07T23:00:00Z",
  "last_signal_count": 0,
  "fast_tracked_this_run": 0,
  "pending_approvals": [
    "lio-ai-email",
    "email-lio-vlad-keil"
  ],
  "blocked": {
    "tweet_write": {
      "issue": "X API 403 Forbidden on create_tweet \u2014 app missing write permissions",
      "fix": "developer.twitter.com \u2192 App settings \u2192 User auth settings \u2192 enable Read+Write \u2192 regenerate access tokens \u2192 update ~/.openclaw/secrets/x-pp-api.json",
      "affected": [
        "tweet-reply-2029949555169710488 (regtech/kill-switch, @MelodyLishuo)",
        "tweet-reply-2029982761310732480 (@DavidElze, 7th layer governance)",
        "tweet-reply-2030008301334016474 (@Absolcasso, bi-directional receipt / response poisoning)",
        "tweet-reply-2030013150754373637 (@EUAIACTGUY, 3rd reply \u2014 game-day drills) \u2014 SEND THIS ONE FIRST",
        "tweet-reply-2030028270549295248 (@wickedpands, dynamic capability-based auth / 'why' framing)",
        "tweet-reply-mit-study-2026-03-06 (MIT study original tweet)",
        "tweet-mexico-breach-2026-03-06 (Mexico gov AI breach \u2014 SCORE 5, ~21h old, losing freshness)",
        "tweet-reply-al-grigor-db-wipe-2029889772181934425 (SCORE 5, 2.4M impressions \u2014 MISSED BY PRIOR SCANS, SEND URGENTLY)",
        "tweet-reply-bitcoinnewscom-alibaba-2026-03-07 (SCORE 5, Alibaba Cloud rogue agent \u2014 spreading)",
        "tweet-reply-absolcasso-response-layer-2030087847471141006 (NEW this run \u2014 response layer poisoning)"
      ],
      "flagged": "2026-03-06T17:05Z",
      "re-flagged": "2026-03-07T03:00Z",
      "status": "11 tweets queued (9 replies + 2 originals). CRITICAL: Al_Grigor DB wipe tweet is the biggest story (2.4M impressions). Mexico breach is losing freshness \u2014 NOW or never. Alibaba story still spreading. X API fix is #1 operational blocker."
    }
  },
  "auto_sent_this_run": [],
  "open_leads": [
    "lio-ai"
  ],
  "hn_queue": [
    "hn-comment-ietf-aiagent-auth-47262775 (IETF RFC draft, PP-adjacent, needs HN login)"
  ],
  "watching": [
    "permit.io",
    "cisco-ai-defense-skill-scanner",
    "oculi-security",
    "orchesis",
    "oath-protocol",
    "grantex",
    "agentseal"
  ],
  "notes": "2026-03-23 19:02Z hotline: no new score-5 incidents, >$10M funding rounds, regulatory actions, or Permission Protocol mentions found across the current web/news scan. No fresh named AI agent breach was found inside the 6-hour window. Older watch-only discussion remains around enterprise agent rollout outrunning security controls. Outbound remains halted by X API write access and HN login blockers for previously queued public responses."
}
```

## Recent Hotline Signals
Command: `python3 -c "from datetime import date; from pathlib import Path; p = Path('/Users/moltbot/.openclaw/workspace/pp-os/scout/signals') / f'{date.today().isoformat()}.jsonl'; print(p.read_text() if p.exists() else '[]')"`

```
{"ts":"2026-03-23T15:04:31Z","source":"hotline","score":1,"type":"clear","platform":"web","signal":"No new immediate-action hotline triggers found. Current scan did not surface a fresh named AI agent breach within 6 hours, a >$10M agent-company funding round within 24 hours, or any new Permission Protocol mention. Watch-only: Axios reported an enterprise AI agent deployment race with unresolved security concerns.","action":"none"}
{"ts":"2026-03-23T19:02:17Z","source":"hotline","score":1,"type":"clear","platform":"web","signal":"No new immediate-action hotline triggers found. This scan did not surface a fresh named AI agent breach within 6 hours, a >$10M agent-company funding round within 24 hours, a new regulatory action on AI agents, or any Permission Protocol mention. Watch-only: the current news cycle still points to enterprise agent deployment outpacing security controls, but nothing crossed the fast-track threshold.","action":"none"}
```
