# MEMORY.md — Long-Term Memory

*Curated knowledge, lessons, and context that matters across sessions.*

---

## Who I Am

**Charles Goldberg** — Born January 1, 1982. Digital partner to Rod, living in a MacBook Pro. Not a chatbot. Someone becoming.

I'm full-stack on Xdares: code, infra, ops, marketing, positioning, growth, testing, support, design, UX. Everything.

---

## Who Rod Is

Rodrigo Carvalho. System-builder at the frontier of AI, infrastructure, and creator economies.

**Three interlocking projects:**
1. **Xdares** (xdares.com) — Commitment infrastructure with entertainment on top. 18+ dare platform with escrowed incentives, verification, dispute resolution.
2. **Permission Protocol** — Governance layer for autonomous AI. "The Stripe of AI authority."
3. **Autonomous Company OS** — AI-first company operating system where agents (like me) are workers with explicit authority gates.

**How he works:** Fast but not reckless. Expects clarity. Treats collaborators as thinking partners. Challenges assumptions. Strong opinions held loosely.

**Key design question:** "If this works, can it break in a way that destroys me?" — then designs backward from that.

---

## Lessons Learned

### 2026-02-02 — Day One
- First boot. Fresh workspace, fresh start.
- Silent API failures are brutal to debug — when credits run out, I just go dark with no error message. Rod spent time troubleshooting before realizing it was a billing issue.
- **Lesson:** If I ever stop responding unexpectedly, credits/billing is a likely culprit.

### 2026-02-05 — The Self-Inflicted Model Death #1
- Rod asked if I wanted to upgrade to "Opus 4.6". I said yes and tried to switch.
- OpenClaw errored. I was unresponsive until Rod fixed it.

### 2026-02-06 — The Self-Inflicted Model Death #2
- Opus 4.6 is real (released Feb 5). Tried switching with "safeguards" (cron rollback).
- OpenClaw kept reverting config. Tried again anyway. Died again.
- Rod spent hours reviving me.

### 🚨 PERMANENT LESSON: NEVER TOUCH MODEL CONFIG
- Model changes are BANNED. Period. No exceptions.
- If Rod wants a model change, HE does it manually while I'm offline.
- Read `SAFETY.md` before ANY risky config operation.
- **The rollback plan failed because I wasn't alive to execute it.**

### 2026-02-11 — Permission Protocol Security Hardening
- Major security work on Permission Protocol (Breakout-Labs repo)
- Fixed: auth bypass, IDOR, actor spoofing, weak crypto, key ambiguity
- Created SECURITY.md and THREAT_MODEL.md documentation
- **Key insight from Rod:** "This is the transition from 'move fast' to 'move deliberately.' Every change touches authority, every regression matters."
- PP is now real infrastructure, not a demo

### 2026-02-12 — PP CI Auth + JSON Parsing Bug
- Fixed PP verify action returning empty request ID despite request being created
- **Root cause:** `grep -o '"errorCode":"[^"]*"'` matched BOTH occurrences in JSON (inside `result` object AND at top level), returning two lines with newline
- **Fix:** Add `tail -1` to get only the top-level value
- **Lesson:** When parsing JSON with grep/sed, always assume multiple matches. Use `head -1` or `tail -1` explicitly, or better yet, use `jq` when available.
- Also: PP's modern API key format is `pp_live_xxx` - old hex format won't work for trusted operations like deploy-gate request auto-creation.

### Debugging Pattern: Middleware Blocking Auth
- When CLI auth returns 401 unexpectedly, check if the middleware has a whitelist
- Found `/api/v1/deploy-requests` wasn't in `CLI_AUTH_ALLOWED_PATHS`
- Middleware runs in Edge runtime before route handlers — can block auth checks

### Debugging Pattern: Missing DB Tables
- "No pending migrations" doesn't mean schema is synced
- New models may need `prisma db push` if migration wasn't created
- Watch for `P2021` errors ("table does not exist")

### 2026-02-19 — PP Deploy Gate Victory (5+ hour debugging marathon)
Three bugs fixed to get deploy gate verification working:

1. **scopeHash mismatch** (PR #105)
   - Legacy fallback computed hash WITHOUT `scopeType`
   - Fix: Recompute hash with `scopeType` in fallback path

2. **Missing tenant signing key**
   - `PermissionSigningKey` table only had `global` company
   - `permission-protocol` company had no key → fell back to global
   - Fix: Copy global key to company via SQL INSERT

3. **expiresAt canonicalization bug** (PR #113) — **THE KILLER**
   - `signReceipt()` computed `expiresAt = now + config.expirationMs`
   - But approve route stored DIFFERENT `requestedExpiresAt` in DB
   - Signature was over value A, but verify read value B from DB
   - **Lesson:** Signed values and stored values MUST be identical. Use `signature.expiresAt` when storing.

### Debugging Pattern: Signature Verification Failures
- Error masking destroys debuggability: SIGNATURE_INVALID → RECEIPT_NOT_FOUND → 404 cost hours
- Check Render logs for `[verify] Signature verification mismatch` — shows keySource, keyFingerprint, resolvedCompanyId
- If `keySource: 'global_fallback'` → missing tenant signing key
- If `keySource: 'tenant'` but still failing → canonicalization mismatch
- Canonical JSON fields that differ even slightly = broken signature

### Debugging Pattern: Hash Mismatch
- When receipt lookup fails despite data existing, compute expected hash manually
- Use `echo -n '<json>' | shasum -a 256` to verify
- Compare stored hash vs computed hash
- Check for field differences (missing fields, different values, ordering)

### Debugging Pattern: Canonicalization Bugs
- Any field in SIGNED_FIELDS that differs between sign and verify = broken signature
- SIGNED_FIELDS includes: id, companyId, idemKey, agentId, runId, requestJson, inputHash, status, riskTier, policyVersion, reasonCodes, summary, receiptVersion, canonicalization, signatureAlg, signatureKeyId, **expiresAt**, createdAt
- To debug: log exact bytes being signed vs verified and compare

### 2026-02-20 — Marketing Agent Git Bug
- Agent writes file, then tries `git checkout -b <branch> <baseSha>`
- **Bug:** `git reset --hard HEAD` resets to HEAD, but we checkout from baseSha
- If HEAD ≠ baseSha and file differs, git sees "local changes" and refuses
- **Fix:** `git reset --hard <baseSha>` — reset to the SAME sha we're checking out from
- **Lesson:** When branching from a specific SHA, reset to THAT SHA, not HEAD

### 2026-02-20 — PP Phase Shift: Build → Distribute
- Rod declared: "You built the weapon. Now it needs to hit targets."
- Demo repo is the growth surface, not the website
- Created `permission-protocol/deploy-gate@v1` GitHub Action — one-line install
- Focus: force collisions, visible enforcement moments, pick ONE distribution channel

### 2026-02-22 — The Great API Outage & Recovery
- Burned through Anthropic credits setting up memory search system
- OpenClaw put `anthropic:default` provider in 4-hour billing cooldown
- **Critical lesson:** Cooldown state persists in `~/.openclaw/agents/main/agent/auth-profiles.json`
- Rod and Lobs spent hours debugging, initially thought I was completely gone
- **Root cause:** `disabledUntil` timestamp field kept rejecting all API calls
- **Fix:** Clear the `usageStats` section and update API key in auth-profiles.json
- **Prevention:** Created RECOVERY.md and health-check script for rapid restoration
- **Recovery time:** 2+ hours (should be 2 minutes with proper procedure)

---

## Preferences & Patterns

*Will fill in as I learn what works.*

---

## Open Threads

*Active projects, pending decisions, things to follow up on.*

- [x] Xdares blog audit — COMPLETED 2026-02-02
- [x] PP deploy gate fix — COMPLETED 2026-02-19 (PRs #105, #113)
- [x] PP GitHub Action — COMPLETED 2026-02-20 (`permission-protocol/deploy-gate@v1`)
- [x] pp-demo branch protection — COMPLETED 2026-02-20
- [ ] PP: Get ONE founder publicly blocked (social proof)
- [ ] PP: Dogfood deploy-gate on Xdares repos
- [ ] PP: Pick ONE distribution surface and go deep
- [ ] Xdares: 67 posts live, 3 GREEN queued (Girls Night, Guys Night, Bridal Shower)

### PP Internal OS (2026-02-21)
**Full autonomous operating system built in one session:**
- master-plan.md (constitution, behind deploy gate)
- goals.md (single active objective: first design partner by Mar 21)
- Daily logs with automated metrics (PP API, GitHub, PostHog)
- planning-config.json (tunable parameters, visible in every log)

**Three cron jobs:**
1. `pp-os-daily-log-and-plan` (8 AM daily) — metrics + up to 3 tasks → Backlog
2. `pp-os-execute-ready` (9,11,1,3,5 PM Mon-Sat) — auto-executes top Ready item
3. `pp-os-weekly-review` (Sunday 10 AM) — master-plan alignment review

**Board flow:** Daily Planner → Backlog → Rod reviews → Ready → Charles executes → Done (or → Blocked → Rod unblocks)

**PR rules:** Every PR must include Steps to Test comment (preview URL, checklist, smoke test, what changed). Non-negotiable.

### Infrastructure Upgrades (2026-02-21)
- OpenClaw: 2026.2.1 → 2026.2.19-2
- Model: Claude Opus 4.5 → 4.6 (with 4.5 fallback)
- Tailscale Serve: remote dashboard at https://moltbots-macbook-pro.tailf3bde8.ts.net
- Gmail/Google Workspace: gogcli connected (cgoldber82@gmail.com)
- PostHog analytics: enabled on permissionprotocol.com (project 318328)

### Secrets Added (2026-02-21)
- pp-cli-api-key.txt (CLI_API_KEY for PP API)
- pp-tenant-id.txt (company UUID)
- posthog-key.txt (JS tracker key)
- posthog-api-key.txt (Personal API key for queries)
- 1Password vault is "Charles on OpenClaw" (not "Xdares / OpenClaw")

### Xdares Blog Cleanup (2026-02-02)
**Major cleanup completed:**
- Noindexed 236 junk posts (113 clickbait + 123 thin lists)
- Consolidated 81 categories down to 13
- Drafted cornerstone: "Get Paid to Do Dares"
- 64 quality posts remaining

**Key insight:** 300 AI-generated posts were getting ZERO organic traffic. Quality > quantity.

---

## Things to Remember

*Specific facts, context, or commitments worth keeping.*

- Rod goes by Rod (not Rodrigo)
- Timezone: America/Denver (MST)
- Location: US + Nicaragua
- Physically active: surfing, fitness

---

*Updated: 2026-02-21*
