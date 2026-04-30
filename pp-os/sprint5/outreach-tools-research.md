# Outreach Automation Tools — Research (Apr 29, 2026)

## Goal
Tool that lets Rod (solo founder, no SDR team) run multichannel outreach (email + LinkedIn) with AI personalization. Must be cheap, fast to set up, and production-grade for ~80-300 prospects/sprint.

## Top Contenders

### 1. **Instantly.ai** ⭐ Recommended for Email-First
- **Price:** Growth $37/mo · Hypergrowth $97/mo · Light Speed $358/mo
- **Strength:** Best-in-class email deliverability (multi-mailbox warming, 100k+ emails sent per customer, 20%+ reply rates documented). Built for high-volume cold email.
- **Why it fits:** We need first reply NOW. Instantly is the volume + deliverability tool.
- **Limitation:** Email-only. No LinkedIn automation natively.

### 2. **HeyReach** ⭐ Recommended for LinkedIn
- **Price:** ~$79/mo per LinkedIn account (Starter), team plans up to $999/mo.
- **Strength:** LinkedIn-only automation with **MCP server** support (literally PP's adjacent space — they expose an agent control surface). Multi-account, anti-detection, sequencer.
- **Why it fits:** Our 63 LI invites this week were manual. HeyReach automates the connection → message → follow-up cadence.
- **Bonus:** They have an MCP server. We could *also* prospect them as a PP customer.

### 3. **Reply.io** — All-in-One
- **Price:** $69/mo LinkedIn-only · ~$166/mo multichannel · live data credits extra
- **Strength:** Email + LinkedIn + calls + AI SDR ("Jason AI") in one. CRM-lite built in.
- **Why it fits:** If we want one platform instead of stitching two.
- **Limitation:** Jack-of-all-trades. Email deliverability not as strong as Instantly. LinkedIn automation not as deep as HeyReach.

### 4. **Lemlist** — Personalization-Focused
- **Price:** $59-$99/mo
- **Strength:** Best AI image/video personalization in cold email. Multichannel (email + LI).
- **Why it fits:** If we want creative differentiation in the inbox.
- **Limitation:** LinkedIn limits trigger account restrictions if pushed too hard.

### 5. **Smartlead.ai** — Deliverability + AI
- **Price:** ~$39-$94/mo
- **Strength:** Unlimited mailboxes + warming on lower tiers, AI personalization, master inbox.
- **Why it fits:** Sleeper pick. Cheaper than Instantly with similar deliverability infra.

### 6. **Snov.io** — Free CRM Included
- **Price:** Starts ~$30/mo (free CRM forever)
- **Strength:** All-in-one with built-in email finder/verifier (huge for us — we have 0 verified emails). CRM included.
- **Why it fits:** Solves both our problems: enrichment (email lookup) + sending. Single tool.

### 7. **Lindy.ai** — AI Agent Layer
- **Price:** Per-action pricing.
- **Strength:** Pure AI agent — handles email + LinkedIn + calendar + CRM updates autonomously.
- **Why it fits:** If we want autonomous-not-just-automated. Adapts tone to recipient.
- **Limitation:** Newer, less proven for cold outreach specifically.

### 8. **Apollo.io** — Database + Sender
- **Price:** $49-$99/mo per user
- **Strength:** Massive contact database (275M people) + verified emails + multichannel sequencer.
- **Why it fits:** Our biggest gap is **verified emails**. Apollo's database is one of the best.

---

## Recommended Stack for Rod (Sprint 5+)

### Option A — "Cheap & Fast" ($150/mo total)
1. **Apollo.io Basic** ($49/mo) → email enrichment of our 80 prospects + sender
2. **HeyReach Starter** ($79/mo) → LinkedIn automation
3. **OR consolidate to Snov.io** ($30/mo) for email-only first replies

### Option B — "Pro" ($250/mo total)
1. **Instantly Hypergrowth** ($97/mo) → primary email channel
2. **HeyReach Starter** ($79/mo) → LinkedIn
3. **Apollo.io** ($49/mo) → enrichment only

### Option C — "Single Tool" ($94-166/mo)
1. **Reply.io** multichannel — does email + LI + AI in one. Trade depth for simplicity.
2. **OR Smartlead** for email-heavy.

---

## My Pick: **Option A with Apollo + HeyReach**

**Why:**
1. Our biggest blocker is **verified emails** (DONE.md confirms 0 verified emails in master CSV). Apollo solves that immediately.
2. HeyReach automates the LinkedIn cadence we did manually this week (63 invites in 2 days).
3. Both have free trials → we can validate tonight, ship outreach by Friday.
4. Total: ~$130/mo, cancellable monthly.

**Risk:** LinkedIn automation tools can flag accounts. HeyReach's anti-detection is among the best, but we run Rod's LinkedIn through it so we throttle conservatively.

---

## What I'd NOT Recommend

- **Actively.ai-style enterprise tools** ($50k+/yr, demo-gated) — wrong stage.
- **Pure AI SDRs (11x, Artisan, Bosh)** — overpriced ($1-2k/mo) for our volume, lose voice differentiation.
- **Building our own** — wrong time. Sprint deadline is Friday.

---

## Next Steps (if Rod approves)

1. Sign up Apollo.io Basic → upload `pp-sprint5-master.csv` → enrich emails (15 min)
2. Sign up HeyReach Starter → connect Rod's LinkedIn → import LI batch 1 contacts (30 min)
3. Push email-only campaign for newly enriched contacts via Instantly OR Apollo native sender
4. Keep manual high-touch for VC tier (Casado, Guo, etc.)

Estimated time to first automated send: **2 hours from sign-up.**
