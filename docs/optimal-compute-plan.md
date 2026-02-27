# Optimal Compute Plan — Charles Infrastructure

*Created: 2026-02-24 | Revised: 2026-02-24 (incorporating GPT-5.2 review) | Status: Draft for Rod's approval*

---

## The Problem

**Current spend: $2,483 in 23 days → projecting $3,200+/month**

66% of cost is **cache writes** — loading 60-75k tokens of context into every session start. Every cron tick, every heartbeat, every compaction writes the full "Charles brain" into Anthropic's cache at Opus 4.6 pricing.

Opus 4.6 tripled our daily cost vs Opus 4.5 ($86/day → $255/day). The irony: most of that spend is on blog posts about drinking games and status checks that say "nothing to report."

**Root cause:** The context footprint itself. Switching to cheaper models helps, but shrinking what gets loaded is the highest-leverage fix.

## The Principles

1. **Charles stays on the smartest model available** for all interactive work with Rod
2. **Quality of published output is verified, not assumed** — quality gate before anything goes live
3. **Never die from single-provider failure** — always have a fallback path
4. **Utilize existing free compute** — DGX Spark (R1 70B + Llama 8B) and Codex (ChatGPT Pro, best-effort)
5. **Cost follows value** — spend money where it creates value, not on operational overhead
6. **Deterministic checks before LLM checks** — don't use a $75/MTok model to parse JSON timestamps

## Available Compute

| Resource | Model | Tokens/sec | Cost | Best For |
|---|---|---|---|---|
| Anthropic API | **Opus 4.6** | ~80 | $15/MTok in, $75/MTok out | Rod conversations, strategy, complex reasoning, final polish |
| Anthropic API | **Sonnet 4** | ~120 | $3/MTok in, $15/MTok out | Content drafting, routine execution, cron jobs |
| OpenAI (Pro) | **Codex / GPT-5.3** | Fast | **Free** ($200/mo plan) | All coding tasks (best-effort — keep API fallback) |
| DGX Spark | **DeepSeek R1 70B** | ~5 | **Free** (local) | Background reasoning, overnight drafts, analysis |
| DGX Spark | **Llama 3.1 8B** | ~50 | **Free** (local) | Health checks, quality gates, triage, structured validation |

---

## The Plan

### Layer 1: Main Session (Rod ↔ Charles)

**Model: Opus 4.6 — always. Non-negotiable.**

This is where quality matters. Strategy, architecture, thinking partnership, direct conversation. Currently ~$50-70/day of the spend — worth every penny.

**Optimizations (no quality impact):**
- Keep context stable to maximize cache hits (currently 100% — good)
- Minimize compactions by being concise in tool outputs
- Avoid reading large files unnecessarily (use targeted reads with offset/limit)

**Estimated cost: $50-70/day (unchanged)**

---

### Layer 2: Cron Jobs (Autonomous Operations)

**Current: ALL cron jobs run on Opus 4.6, every 30 minutes, loading 60-75k context**
**Current cost: ~$150-180/day (the money pit)**

**Two changes: cheaper models AND slim context (see Layer 7).**

#### Goal Executor (Xdares SEO)
- **Current:** Opus 4.6, every 30 min, 75k context per tick
- **New:** **Sonnet 4**, every **2 hours**, slim context (~3-5k)
- **Quality gate:** Every published post passes structural check before going live (see Layer 8)
- **Savings:** ~$125/day

#### PP OS Daily Planner
- **Current:** Opus 4.6, daily at 8 AM
- **New:** **Sonnet 4**, slim context
- **Why safe:** Reads metrics, creates 3 tasks, writes a log. Structured, templated work.
- **Savings:** ~$5/day

#### PP OS Executor
- **Current:** Opus 4.6, 5x/day Mon-Sat
- **New:** **Sonnet 4** by default, **Opus 4.6** only for items tagged "complex"
- **Classification rule:** Default = routine. "Complex" requires explicit reason: strategic decision, user-facing, irreversible, or ambiguous. This prevents "everything becomes complex" creep.
- **Savings:** ~$15/day

#### PP OS Incident Scanner
- **Current:** Opus 4.6
- **New:** **Sonnet 4**, slim context
- **Why safe:** Reading RSS feeds and checking for AI security news. Pattern matching, not deep reasoning.
- **Savings:** ~$5/day

#### PP OS Weekly Review
- **Current:** Opus 4.6, Sundays
- **New:** **Keep Opus 4.6** — this is strategic alignment review, worth the premium
- **Savings:** $0 (correct model already)

**Total Layer 2 savings: ~$150/day**

---

### Layer 3: Heartbeats (Monitoring)

**Current: Opus 4.6, every 30 minutes → ~$40-50/day**

**New architecture — deterministic first, LLM second:**

**Phase 1: Deterministic rules engine (bash script — FREE)**
A script runs locally (no LLM) and produces a JSON status object:
```json
{
  "goal_executor": {"status": "ok", "queue": 9, "last_tick_hours": 2.1},
  "cron_health": {"failures": 0},
  "model_health": {"runtime": "opus-4-6", "configured": "opus-4-6", "match": true},
  "pp_board": {"ready_count": 6},
  "alerts": []
}
```

If `alerts` is empty → HEARTBEAT_OK. No API call. Zero cost.

**Phase 2: LLM escalation (only when abnormal)**
If Phase 1 finds something in `alerts` → wake Opus for the full response, board execution, or alert to Rod.

**Hard deterministic alerts (always page Rod, no LLM interpretation needed):**
- Cron job failure (non-zero exit)
- API auth failure / cooldown detected
- Deploy failures
- Queue backlog > threshold
- Model mismatch detected

**Frequency: Every 60 minutes** (down from 30)

**Expected result:** 90%+ of heartbeats handled by a free bash script. Opus only wakes for real events.

**Savings: ~$40-45/day**

---

### Layer 4: Coding

**Current: Mix of Claude Code (API) and Codex (free)**

**New: Codex first. Always. Claude Code as fallback.**

| Task | Model | Cost |
|---|---|---|
| Feature builds | Codex | Free |
| PR reviews | Codex | Free |
| Refactors | Codex | Free |
| Bug fixes | Codex | Free |
| Complex architecture | Claude Code (Opus) | API cost |
| Codex gets stuck | Claude Code (escalation) | API cost |

**Note:** Codex via ChatGPT Pro is best-effort consumer infrastructure, not guaranteed SLA. Treat as primary but keep Claude Code API ready as fallback. Don't build pipelines that hard-fail without it.

**Savings:** Variable, but eliminates unnecessary API coding spend.

---

### Layer 5: Background Intelligence (NEW — utilizing Spark)

**Currently unused capacity: DeepSeek R1 70B sitting idle**

R1 70B is a strong reasoning model. It's slow (~5 tok/s) but free. Perfect for:

- **Overnight draft generation:** R1 creates blog post drafts → Opus does 5-minute final polish next morning. Paid tokens drop dramatically while quality potentially improves (two-model pipeline).
- **Batch analysis:** Parse and analyze transcript archives (753 sessions of data)
- **Competitive research:** Market scanning, company research, document review
- **Pre-computation:** SEO keyword analysis, structured data generation that Opus refines quickly

**Implementation:** Queue tasks to Spark via Ollama API, store results as files, Opus picks them up in next session.

**Trust boundary:** Spark is a different trust zone than cloud APIs.
- ✅ Public content tasks: blog drafts, research, analysis
- ✅ Non-sensitive logs and metrics
- ❌ Never send credentials, API keys, or private user data to local models
- Implement redaction for any logs/transcripts before Spark processing

**Cost: $0 | Value: Significant**

---

### Layer 6: Emergency Failover Chain

```
NORMAL:     Opus 4.6 (full capability)
                ↓ Anthropic rate limit
THROTTLED:  Sonnet 4 (good quality, explicit banner to Rod)
                ↓ Anthropic API down
DEGRADED:   DeepSeek R1 70B on Spark (reasoning capable, slow)
                ↓ Spark unavailable
EMERGENCY:  Llama 3.1 8B on Spark (alive, basic communication)
                ↓ Everything down
DEAD:       Nothing — but this requires BOTH cloud AND local to fail
```

**Key behaviors:**
- Every level announces itself: "⚠️ Running on [model] — [capability level]"
- **Fail-closed tasks** (deploys, credentials, money, PP policy): STOP + notify Rod. Never attempt on degraded models.
- **Degrade-gracefully tasks** (code review, analysis): Continue with explicit quality caveat.
- **Never-block tasks** (drafting, status): Continue on any available model.
- Rod always knows which level he's talking to.

**Provider health tracking:**
- `rate_limit` → immediate fallback to next tier (don't retry aggressively)
- `timeout / network` → one retry, then fallback
- `auth / invalid_request` → fail fast + alert Rod
- `quality failure` → escalate to higher tier or request human review

**Load shedding during throttle:**
When primary provider (Opus) hits rate limit, don't just shift all workload to Sonnet — reduce non-essential load by 50% automatically:
- ✅ Keep: interactive sessions, critical tasks, alerts
- ⏸️ Pause: SEO drafting, background scans, PP OS executor
- This prevents cascading rate limits across tiers (Opus throttle → Sonnet overload → total failure)

---

### Layer 7: Context Slimming (NEW — the root cause fix)

**This is the highest-leverage change in the entire plan.**

**Current state:** Every cron job loads the full "Charles brain" — SOUL.md, USER.md, MEMORY.md, HEARTBEAT.md, TOOLS.md, IDENTITY.md, AGENTS.md, conversation history. 60-75k tokens. At Opus cache-write pricing, this is the #1 cost driver (66% of total spend).

**New state:** Each cron job gets a purpose-built slim context containing ONLY what it needs.

#### Goal Executor Context (~3k tokens)
```
- Goal definition + constraints
- Current state.json (queue, budget, stats)
- Publishing instructions (WordPress, image gen, Tor proxy)
- Recent task log (last 5 tasks)
```
Does NOT need: SOUL.md, USER.md, MEMORY.md, HEARTBEAT.md, IDENTITY.md

#### PP OS Executor Context (~3k tokens)
```
- Current issue details (title, body, acceptance criteria)
- Repo structure overview
- PR rules (Steps to Test requirement)
- Board status
```
Does NOT need: Xdares context, SEO goals, personal memory

#### Heartbeat Context (~1k tokens — when LLM escalation needed)
```
- JSON status object from Phase 1
- List of alerts with severity
- Available actions
```
Does NOT need: Full workspace files, conversation history

**Impact math:**
- Current: 75k tokens × $15/MTok cache-write × 48 cron ticks/day = ~$54/day just in cache writes
- New: 3k tokens × $3/MTok (Sonnet) × 12 ticks/day = ~$0.11/day
- **Savings from context slimming alone: ~$54/day**
- Combined with model switch: the cron cost effectively approaches zero

**Implementation:** OpenClaw per-cron workspace/context configuration, or separate lightweight agent configs.

**Hard token budget ceiling:**
Each cron type gets a max context budget. If exceeded → alert, don't silently grow.
- Goal executor: 5k max
- PP OS executor: 5k max
- PP OS planner: 3k max
- Heartbeat (when escalated): 2k max
- Monitor via logged token count per invocation. If any cron consistently exceeds budget → investigate and trim.
- This prevents context creep from slowly returning us to 75k over the coming months.

---

### Layer 8: Quality Gate (NEW — verified, not assumed)

**Problem solved:** "Zero quality loss" was a claim without a mechanism. Now it's enforced.

**For any content that gets published or that Rod will see:**

```
Step 1: Sonnet 4 generates draft
Step 2: Llama 8B (FREE) runs structural quality check:
  ✓ Required sections present (intro, body, CTA)
  ✓ Minimum word count met
  ✓ No obvious nonsense / hallucinated facts
  ✓ Keyword coverage vs target list
  ✓ Uniqueness check vs last 10 posts (basic similarity)
  ✓ Internal links present
  ✓ Meta description included
Step 3: If ALL checks pass → publish
Step 4: If ANY check fails → escalate to Opus for fix (not full rewrite)
```

**Expected escalation rate:** <10% of posts need Opus intervention.

**Cost of quality gate:** $0 (Llama 8B is local and free)

**This is how we actually guarantee "no quality loss" while running 5x cheaper models for drafting.**

For PP OS outputs: similar gate but checking for PR quality (Steps to Test present, code compiles, tests pass).

---

## Financial Impact

| Category | Current $/day | New $/day | Savings | Primary Driver |
|---|---|---|---|---|
| Main session (Rod ↔ Charles) | $60 | $60 | $0 | Stays Opus |
| Cron jobs | $165 | **$3** | **$162** | Slim context + Sonnet |
| Heartbeats | $45 | **$2** | **$43** | Deterministic triage |
| Coding (Claude Code) | ~$5 | ~$1 | **$4** | Codex first |
| Quality gates | $0 | $0 | — | Llama 8B (free) |
| Spark background work | $0 | $0 | — | NEW VALUE (free) |
| **Total** | **$255** | **$66** | **$189/day** | |

**Monthly projection: $3,200 → ~$660**

**That's a 79% cost reduction** — driven primarily by context slimming (the root cause) combined with model-appropriate routing. Interactive quality unchanged. Published quality verified by gate. New free capabilities from Spark.

---

## Implementation Sequence

### Phase 1: Quick Wins (Today — biggest immediate impact)
1. **Reduce goal executor frequency:** 30 min → 2 hours
2. **Reduce heartbeat frequency:** 30 min → 60 min
3. **Set cron job models to Sonnet 4** (OpenClaw per-cron model override)
4. Verify everything still works

**Expected impact: -$100/day immediately**
**Effort: Config changes only, 30 minutes**

### Phase 1.5: Context Slimming (This week — the root cause fix)
5. **Build slim context configs for each cron job type** (~3-5k tokens each)
6. Configure OpenClaw per-cron workspace/context settings
7. Verify cron jobs produce same quality output with slim context
8. Measure actual token reduction

**Expected impact: Additional -$50-80/day**
**Effort: Half day — biggest ROI task in the entire plan**

### Phase 2: Quality Gate + Deterministic Monitoring (This week)
9. **Build quality gate script** (Llama 8B structural checker for blog posts)
10. **Build deterministic heartbeat script** (bash → JSON status, no LLM)
11. **Add hard alert rules** for critical failures (cron fail, auth fail, deploy fail)
12. Wire quality gate into goal executor publish pipeline

**Expected impact: Quality assurance + additional -$10/day**
**Effort: 1-2 days**

### Phase 3: Failover Chain (Next week)
13. Configure OpenClaw fallback chain: Opus → Sonnet → (explore Ollama provider)
14. Build failover detection and banner system
15. Test each degradation level end-to-end
16. Document recovery procedures for each level

**Expected impact: Resilience — never fully die again**
**Effort: 2-3 days**

### Phase 4: Spark Background Intelligence (Ongoing)
17. Build overnight draft generation pipeline (R1 creates → Opus polishes)
18. Mine transcript archives for insights
19. Pre-generate research for Rod's morning context
20. Implement secret redaction layer for Spark-bound tasks

**Expected impact: New capabilities at zero cost**
**Effort: Ongoing, incremental**

---

## What Rod Needs to Do

1. **Approve this plan** (or modify priorities)
2. **Cron model/frequency changes** — Charles drafts config, Rod applies (model config rule)
3. **Spot-check first week** of Sonnet-generated blog posts — flag if quality drops
4. **Nothing else** — Charles handles implementation

## What Doesn't Change

- Rod always talks to Opus 4.6
- Published content verified by quality gate before going live
- Strategic work stays on Opus
- Weekly review stays on Opus
- No silent degradation — every level is explicit

---

## Risk Assessment

| Risk | Likelihood | Mitigation |
|---|---|---|
| Sonnet blog posts drift to "content farm sludge" | Medium | Quality gate catches structural issues; Opus escalation for failures; Rod spot-checks week 1 |
| Slim context misses something cron job needs | Medium | Start conservative (5k not 1k), expand as we learn what's actually needed |
| Spark goes offline | Medium | Bonus layer only; everything works without it; deterministic heartbeat doesn't need it |
| Heartbeat triage misses edge case | Low | Hard deterministic alerts for true incidents; weekly full-Opus audit |
| Codex becomes unreliable/throttled | Low | Claude Code API always available as fallback; don't hard-depend on free tier |
| "Everything becomes complex" classification creep | Medium | Default = routine; complex requires explicit written reason |
| Secret leakage to local models | Low | Trust boundary enforced; redaction layer before Spark processing |
| OpenClaw doesn't support per-cron slim context | Medium | Fallback: separate lightweight agent configs or wrapper scripts |
| Context slowly creeps back over months | High | Hard token budget ceiling per cron; automated size alert if exceeded |
| Provider throttle cascades across tiers | Low | Load shedding: pause non-essential work during throttle, don't just shift it |

---

## Appendix: Cost Breakdown Source Data

Based on Anthropic usage CSV export, February 2-24, 2026:
- Total spend: $2,483.34
- Top cost: cache_write_5m = $1,640.85 (66.1%)
- By key: charles-openclaw $1,884 (75.9%), charles-openclaw-V2 $520 (21.0%)
- By model: Opus 4.5 $1,594 (64.2%), Opus 4.6 $562 (22.6%), Sonnet 4 $327 (13.2%)
- Pre Opus 4.6 avg: $86/day | Post Opus 4.6 avg: $255/day
- Feb 23 (rogue process): $319 (worst day)

---

*This plan turns a $3,200/month burn into ~$660/month while adding quality verification, resilience, and free background intelligence. The two biggest levers: slim the context (root cause of 66% spend) and route models by task value. Charles never dies again, and every dollar goes where it creates value.*
