# HN Comment — "Securing AI Agents: Why Traditional Authorization Isn't Enough"
**Post:** https://news.ycombinator.com/item?id=47278952
**Status:** APPROVED (auto — HN comments are auto-approved)
**Drafted:** 2026-03-06T23:05Z
**Points:** 2pts, posted 18:24Z today — still fresh
**Note:** BLOCKED on X API write; HN requires separate login. Rod/Charles to post manually.

---

## Target comment to reply to:
The "consent drift" comment (top comment, no username visible from HN preview):
> "...the user approved 'schedule a meeting' but the agent interpreted that as 'access my entire calendar, read all attendee info, send an external webhook, create a contact record.' Each step was technically within granted scope. The chain as a whole wasn't what was consented to. One failure mode I'd add: no kill switch..."

---

## Draft HN Comment

The consent drift problem you're describing has a structural cause that's worth naming: most frameworks authorize at the *session* boundary, not the *action* boundary.

Session-level auth says "this agent is allowed to run." Action-level auth says "this specific tool call, with this specific scope, is authorized by this principal at this moment."

The gap between those two is where all three of your failure modes live:

- **Temporal staleness**: session auth doesn't expire; action auth can carry a TTL
- **Scope inflation**: session scope is a ceiling, not a per-step constraint
- **No kill switch**: revoking a session doesn't stop in-flight actions that already "passed" auth

We've been working on this with Permission Protocol — the core primitive is a signed receipt that must be presented *before* each tool call executes. Receipts are scope-bound, time-limited, and individually revocable. Kill switch becomes: revoke the receipt type, all pending actions with that receipt fail closed.

The hard tradeoff is granularity vs. friction. Per-action auth with human approval doesn't scale past ~3-step workflows. The answer we landed on: distinguish pre-authorized classes (agent can auto-execute within defined bounds) from out-of-bound actions (require fresh approval). Basically, a dynamic allowlist with escalation paths rather than blanket session auth.

Open source if you want to poke at the implementation: https://github.com/permission-protocol

---

## Notes
- Genuine technical addition, not promotional — fits HN norms
- Mentions PP naturally at the end, not up front
- Replies to the most substantive comment, not the OP
- Length is appropriate for HN (not too long)
