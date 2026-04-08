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
# PP Status — Last Updated: 2026-04-02 8:20 AM MDT

## Active Right Now
- **Mode:** Week 4 (FINAL sprint week) — **Apr 4 deadline is 2 DAYS AWAY**
- **Sprint Goal:** 5 external users with deploy-gate installed + 1 complete loop
- **Pricing Redesign:** ✅ COMPLETE — 4-tier pricing (Free, $79, $299, Enterprise) live.
- **Mobile UX:** ✅ COMPLETE — PR #284 merged Apr 1. Sticky action bar + VerdictBanner polish.
- **Demo Polish:** ✅ COMPLETE — PR #285 merged Apr 1. Progress indicators + speed copy.

## ACTIVE Ideas (in-flight, do today)
- **idea-085** — Demo PR approval count audit (URGENT — Rod: query PostHog/PP DB + Stripe)
- **idea-087** — Week 4 decision brief (OVERDUE — write after idea-085 data, 2 days left)
- **idea-088** — 5 external users (primary sprint goal — HN follow-up, Discord, alumni)
- **idea-089** — First complete loop user (secondary — monitor non-PP orgs in PP app)

## BLOCKED (needs Rod)
- **idea-082** — X API write permissions (needs Rod: upgrade X Dev account tier)
- **idea-086** — Paperclip port 3100 (needs Rod: SSH into pp-scout-sfo2)
- **idea-092** — Sycamore/Sri Viswanath LinkedIn pitch (needs Rod approval to send)

## Backlog Ready (priority order)
1. **idea-042** — Actionable error UX (M-size)
2. **idea-079** — Week 1 changelog (HN feedback, S-size)
3. **idea-080** — PostHog event names (S-size)
4. **idea-083** — Mobile Safari SameSite cookie fix (S-size)
5. **idea-030** — AI-Generated Code Summary (M-size)
6. **idea-002** — Blast radius indicator (M-size)
7. **idea-084** — MCP Guard v0.2 spec (M-size)
8. **idea-081** — PullMatch viral loop feature (M-size)

## Key Decisions & Recent
- **4-Tier Pricing:** $0 / $79 / $299 / Custom. Optimized for "Buyer" segmentation.
- **Mobile Density:** ~30% reduction in vertical rhythm shipped.
- **Demo UX:** Zero-friction static demo is core wedge. No DB, <1s LCP.
- **Apr 4 deadline:** Final decision point — double down, feature pivot, or channel pivot.
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
  "last_hotline_run": "2026-04-02T19:03:17Z",
  "last_outreach_run": "2026-03-07T15:00:00Z",
  "last_response_check": "2026-03-07T23:00:00Z",
  "last_signal_count": 0,
  "fast_tracked_this_run": 0,
  "pending_approvals": [
    "lio-ai-email",
    "email-lio-vlad-keil",
    "meta-sev1-reachout-strategy",
    "interloom-founder-outreach",
    "sycamore-sri-viswanath-linkedin"
  ],
  "blocked": {
    "tweet_write": {
      "issue": "X API 403 Forbidden on create_tweet — app missing write permissions",
      "fix": "developer.twitter.com → App settings → User auth settings → enable Read+Write → regenerate access tokens → update ~/.openclaw/secrets/x-pp-api.json",
      "affected": [
        "tweet-reply-2029949555169710488 (regtech/kill-switch, @MelodyLishuo)",
        "tweet-reply-2029982761310732480 (@DavidElze, 7th layer governance)",
        "tweet-reply-2030008301334016474 (@Absolcasso, bi-directional receipt / response poisoning)",
        "tweet-reply-2030013150754373637 (@EUAIACTGUY, 3rd reply — game-day drills) — SEND THIS ONE FIRST",
        "tweet-reply-2030028270549295248 (@wickedpands, dynamic capability-based auth / 'why' framing)",
        "tweet-reply-mit-study-2026-03-06 (MIT study original tweet)",
        "tweet-reply-al-grigor-db-wipe-2029889772181934425 (SCORE 5, 2.4M impressions — SEND URGENTLY)",
        "tweet-reply-bitcoinnewscom-alibaba-2026-03-07 (SCORE 5, Alibaba Cloud rogue agent — spreading)",
        "tweet-reply-absolcasso-response-layer-2030087847471141006 (response layer poisoning)"
      ],
      "flagged": "2026-03-06T17:05Z",
      "re-flagged": "2026-03-07T03:00Z",
      "status": "X API fix is #1 operational blocker."
    }
  },
  "auto_sent_this_run": [],
  "open_leads": [
    "lio-ai",
    "interloom",
    "sycamore"
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
  "notes": "2026-04-02 19:03Z hotline scan: no new immediate-action triggers validated. Web verification did not surface a fresh Permission Protocol mention, a named AI-agent breach inside the 6-hour window, a >$10M agent-company funding round inside the 24-hour window, a new regulatory action on AI agents, or a Hacker News agent-security story above the 50-point threshold. Carry-forward only: Sycamore remains the active fast-track lead pending Rod approval. Existing outbound blockers still halt outbound execution: X API write access is blocked and HN login is unavailable."
}
```

## Recent Hotline Signals
Command: `python3 -c "from datetime import date; from pathlib import Path; p = Path('/Users/moltbot/.openclaw/workspace/pp-os/scout/signals') / f'{date.today().isoformat()}.jsonl'; print(p.read_text() if p.exists() else '[]')"`

```
[]
```

