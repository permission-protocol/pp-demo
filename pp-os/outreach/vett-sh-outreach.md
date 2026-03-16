# Vett.sh Partnership Outreach

## Contact
- **Name:** Sean Drumm
- **GitHub:** sjdweb
- **Email:** sean.drumm@gmail.com
- **Location:** Toronto, Canada
- **Background:** Ex-VPE, solo founder building Vett.sh
- **Company:** Vett Software Inc.

## Context
Sean published a detailed blog post showing supply chain attacks on Claude Code and Codex via malicious agent skills. His scanning registry found 59 critical-risk skills out of 4,679 scanned. He specifically referenced OpenClaw's skill ecosystem as one of the first to flag this vector.

## Why This Matters for PP
- **Vett = supply chain** (is the code safe before install?)
- **PP = runtime authority** (is the agent allowed to do this?)
- Complementary layers, not competitors
- Both targeting the same ICP: engineering teams using AI coding agents
- His blog post is *the* viral piece in this space right now

## The Pitch
Vett signs skills before they run. PP signs actions before they execute. Together = full security stack for AI agents. The handshake: Vett verifies the skill is clean, PP verifies the action is authorized.

## Draft Email

Subject: Your supply chain research + our runtime authority layer = full stack

---

Sean,

Read your post on supply chain attacks against Claude Code and Codex. The part where the malicious skill wrote its own permission slip and Codex read it verbatim — that's the exact failure mode we're building against.

I'm Rod, founder of Permission Protocol. We're building the runtime authority layer for AI agent actions — cryptographic receipts proving a human authorized an action before it happened. Our first enforcement point is deploy-gate: no receipt from a human, no merge.

Your work at Vett solves *before the skill runs* — is this code clean? Ours solves *when the agent acts* — was this action authorized? Different layers, same problem: agents acting without verified trust.

The combination is interesting: Vett-signed skills running through PP-gated deployments. Full chain of custody from skill install to production deploy.

Would love to compare notes. We're both solo founders building infrastructure for a problem most teams don't know they have yet. That changes fast when someone's production DB gets dropped by a coding agent (which happened last week — Tom's Hardware covered it).

Happy to jump on a call or trade async. Either works.

Rod
permissionprotocol.com

---

## Status
- [ ] Rod reviews/edits outreach
- [ ] Send via email (sean.drumm@gmail.com)
- [ ] Follow up on GitHub (sjdweb) if no response in 5 days
