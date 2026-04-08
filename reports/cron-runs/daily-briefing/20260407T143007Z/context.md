## Focus
Path: /Users/moltbot/.openclaw/workspace/FOCUS.md

```
# FOCUS.md — 28-Day Sprint Filter

**Period:** March 8 → April 4, 2026  
**Single wedge:** AI coding agents (Codex, Cursor, Claude Code) deploying code **without Permission Protocol**

---

## The Question

Before doing ANY task, ask:

> **"Does this directly help AI coding agents use Permission Protocol's deploy-gate?"**

If no → it's paused. If yes → do it.

---

## Success Criteria

- 5+ external users with deploy-gate installed
- 1+ completing the full flow (install → request → approve → deploy)

---

## In Scope

- Deploy-gate product (webhook, review surface, API)
- Demo video of the deploy-gate flow
- Dogfooding on PP + Xdares repos
- Finding + onboarding design partners (AI agent users, devs)
- GitHub App for one-click repo connection (Phase B)
- Show HN post (Week 3)

## Out of Scope (Paused)

- Scout pipeline / outreach to general founders
- Marketing content, social posting (unless directly about deploy-gate)
- Xdares SEO / blog publishing
- Any new features unrelated to deploy-gate
- Brand polish, website redesign, etc.

---

## Week Plan

| Week | Focus |
|------|-------|
| 1 (Mar 8-14) | Deploy-gate perfection + demo video + dogfood on our repos |
| 2 (Mar 15-21) | Find 10 potential users, get 3 to try. Design partner deadline. |
| 3 (Mar 22-28) | Iterate on user feedback. Show HN. |
| 4 (Mar 29-Apr 4) | 5+ active users. Decision: double down or pivot. |

---

## Paused Crons (13 total)

scout-response-monitor, scout-delivery, scout-followup, scout-outreach-draft, scout-research, scout-active-learning, scout-campaign-monitor, marketing-publisher, marketing-engagement-monitor, marketing-content-draft, marketing-active-learning, unified-engagement

---

_Created: 2026-03-07. Update weekly with sprint progress._
```

## PP Status
Path: /Users/moltbot/.openclaw/workspace/pp-os/STATUS.md

```
# PP Status — Last Updated: 2026-04-07 8:20 AM MDT

## Active Right Now
- **Mode:** Week 5 Sprint — Distribution Push (Apr 5–11)
- **Sprint Goal:** 10 active external installations + Product Hunt launch.
- **Day 46 outreach drought:** The only thing that matters is unblocking outreach.
- **Onboarding status:** OPERATIONAL (PKCS#8 fix verified Apr 6).

## P0 — Requires Action Today

### 🔴 ROD ACTION REQUIRED
- **idea-092** — Sycamore/Sri Viswanath LinkedIn pitch is drafted and waiting approval. Day 46 at zero outreach. Approve or deny.
- **idea-085** — Re-auth GA4/Search Console tokens (expired).

### Charles (READY to execute)
- **idea-094** — Merge PR #314. Begin Product Hunt hunter identification (idea-095).
- **idea-097** — Shortlist 5 warm leads from 123-person list. Draft messages. Queue for Rod batch-approval.
- **idea-096** — Email dang@ycombinator.com re: HN account unban.

## BLOCKED (needs Rod)
- **idea-092** — Sycamore outreach (approval pending — Day 46)
- **idea-085** — PostHog/Stripe conversion audit (GA4 token expired)
- **idea-082** — X API write permissions (tier upgrade)
- **idea-086** — Paperclip port 3100 on pp-scout-sfo2 (SSH needed)

## Backlog
- **idea-030** — AI-generated code summary on approval screen (M)
- **idea-002** — Blast radius indicator on approval page (M)
- **idea-042** — Actionable error UX: every error has a fix path (M)
- **idea-080** — Fix PostHog generic event names (S)
- **idea-083** — Mobile Safari SameSite cookie fix (S)
- **idea-084** — MCP Guard v0.2 spec (M)
- **idea-081** — PullMatch viral risk profile card (M)

## Recent Decisions
- (Apr 7) ideas.jsonl created with proper state machine schema. 17 ideas tracked.
- (Apr 6) System prompt restructured (72% reduction). PKCS#8 auth fix deployed.
- (Apr 4) Sprint 3 closed. Onboarding overhaul (PR #288, #300) shipped.

## Recently Shipped
- PR #314: Launch alerts (READY to merge) ✅
- PR #309–#313: Race conditions, startup checks, logging, UX ✅
- Onboarding smoke test script ✅
- PKCS#8 GitHub App auth fix ✅
```

## Heartbeat Rules
Path: /Users/moltbot/.openclaw/workspace/HEARTBEAT.md

```
# HEARTBEAT.md Template

```markdown
# Keep this file empty (or with only comments) to skip heartbeat API calls.

# Add tasks below when you want the agent to check something periodically.
```
```

## Heartbeat Check
Command: `bash "/Users/moltbot/.openclaw/workspace/scripts/heartbeat-check.sh"`

```
{
  "status": "watch",
  "alerts": [],
  "warnings": [
    "cron:Token Health Check - 1 error(s): ",
    "cron:unified-hotline - 1 error(s): cron: job execution timed out",
    "cron:memory-consolidation - 2 error(s): ?? ?? Message failed",
    "cron:nightly-self-improvement - 2 error(s): ?? ? Edit failed",
    "cron:hn-recovery-article-finder - 1 error(s): Channel is required when multiple channels are configured: telegram, discord Set delivery.channel ex",
    "cron:pp-os-weekly-review - 1 error(s): cron: job execution timed out"
  ],
  "cron_errors": 6,
  "gateway_processes": 1,
  "disk_usage_pct": 12,
  "cooldown": "unknown"
}
```

