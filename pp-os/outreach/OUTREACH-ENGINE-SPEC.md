# PP Outreach Engine — System Spec

*Closed-loop, self-improving LinkedIn outreach system for Permission Protocol.*

**Status:** DRAFT — awaiting Rod's review
**Date:** 2026-03-06
**Owner:** Charles (execution), Rod (approval + LinkedIn account)

---

## 1. Goal

Find PP's first 3-5 design partners by running signal-driven LinkedIn outreach through Rod's personal account, with automated delivery (Expandi) and a feedback loop that optimizes messaging over time.

**Success metric:** 3 qualified calls booked within 60 days of launch.

---

## 2. System Overview

```
DETECT → GENERATE → DELIVER → TRACK → LEARN → repeat
```

Five components, each described below.

---

## 3. Components

### 3.1 Signal Detection (existing — scout crons)

Already running. Scout crons monitor:
- HN front page (AI agent incidents, governance discussions)
- Twitter/X (deployment failures, AI safety discourse)
- GitHub (new AI agent frameworks, security issues)
- News (funding rounds, regulatory moves, breaches)

**Output per signal:**
```json
{
  "signal_id": "sig_20260306_001",
  "type": "production_incident | funding | hiring | regulatory | public_complaint | launch",
  "source": "hn | twitter | github | news",
  "company": "Acme AI",
  "summary": "Acme's AI agent deleted prod database, CEO tweeted apology",
  "url": "https://...",
  "detected_at": "2026-03-06T10:00:00Z",
  "urgency": "hot | warm | cold"
}
```

**Change needed:** Enrich signal output with target person lookup (see 3.1.1).

#### 3.1.1 Target Enrichment

After signal detection, resolve to a specific person:
- LinkedIn profile URL (required for Expandi)
- Name, title, company
- ICP segment: founder | cto | vp_eng | devops_lead | head_of_security

**Methods (in priority order):**
1. LinkedIn Sales Navigator search (manual for now, automate later)
2. Company website → leadership page → LinkedIn search
3. GitHub org → top committers → LinkedIn profiles
4. Apollo.io or similar enrichment API (future — adds cost)

**Output:**
```json
{
  "target_id": "tgt_20260306_001",
  "signal_id": "sig_20260306_001",
  "name": "Jane Smith",
  "title": "CTO",
  "company": "Acme AI",
  "linkedin_url": "https://linkedin.com/in/janesmith",
  "segment": "cto",
  "enriched_at": "2026-03-06T10:30:00Z"
}
```

---

### 3.2 Message Generation

I generate outreach using the **Message Playbook** (see Section 4) and signal context.

**Inputs:**
- Signal data (what happened, when, how severe)
- Target data (who they are, what they'd care about)
- Current best-performing playbook variant

**Outputs per target:**
```json
{
  "outreach_id": "out_20260306_001",
  "target_id": "tgt_20260306_001",
  "signal_id": "sig_20260306_001",
  "connection_note": "Hey Jane — saw the Acme incident thread on HN. We built something that would've caught that before it hit prod. Mind if I share?",
  "message_1": "...",
  "followup_1": "...",
  "followup_2": "...",
  "variant": {
    "angle": "incident_response",
    "opener": "pain_point",
    "tone": "peer_founder"
  },
  "generated_at": "2026-03-06T11:00:00Z"
}
```

**Connection note:** Max 300 chars (LinkedIn limit). This is the highest-leverage text — it determines accept rate.

**Message sequence (post-accept):**
1. **Message 1** (immediate after accept): Value-forward, specific to their signal. No pitch. Ask a question.
2. **Follow-up 1** (3 days, no reply): Different angle, add social proof or specific example.
3. **Follow-up 2** (5 days, no reply): Direct ask — "Worth a 15-min call?" with easy calendar link.

**Rules:**
- Never mention "Permission Protocol" in the connection note (too salesy)
- Lead with THEIR problem, not our product
- Every message must reference something specific to them (signal, company, role)
- Keep messages under 500 chars (LinkedIn DMs that are too long don't get read)

---

### 3.3 Expandi Delivery

**Account:** Rod's personal LinkedIn
**Cost:** $99/mo (Business plan)
**Trial:** 7-day free, no card

#### Campaign Structure

One **master campaign** with dynamic placeholders, not separate campaigns per signal. This keeps management simple and allows Expandi's dedup to work.

**Placeholders injected via reversed webhook:**
- `{connection_note}` — personalized connection request text
- `{message_1}` — first message after accept
- `{followup_1}` — first follow-up
- `{followup_2}` — second follow-up
- `{signal_type}` — for internal tracking
- `{angle}` — which playbook variant
- `{opener}` — which opener style
- `{outreach_id}` — links back to our tracking

**Sequence in Expandi builder:**
```
1. Visit Profile
   ↓ (wait 1 day)
2. Send Connection Request + {connection_note}
   ↓ (wait for accept, max 14 days)
   │
   ├─ IF accepted:
   │  3. Send {message_1}
   │     ↓ (wait 3 days, if no reply)
   │  4. Send {followup_1}
   │     ↓ (wait 5 days, if no reply)
   │  5. Send {followup_2}
   │
   └─ IF not accepted after 14 days:
      → End (don't waste the slot)
```

#### Injecting Leads

**Reversed webhook POST:**
```
POST https://app.expandi.io/api/v1/campaign/{campaign_id}/add
Content-Type: application/json

{
  "profile_url": "https://linkedin.com/in/janesmith",
  "connection_note": "Hey Jane — saw the Acme incident...",
  "message_1": "...",
  "followup_1": "...",
  "followup_2": "...",
  "signal_type": "production_incident",
  "angle": "incident_response",
  "opener": "pain_point",
  "outreach_id": "out_20260306_001"
}
```

*(Exact endpoint format TBD after Expandi account setup — their reversed webhook URL is campaign-specific.)*

#### Safety Limits
- **Max 20-25 connection requests/day** (Expandi warm-up handles this)
- **Max 50 messages/day**
- **Active hours:** 8 AM - 6 PM MST (Rod's timezone, looks natural)
- **Weekdays only** (optional — test weekend vs weekday)

---

### 3.4 Outcome Tracking

#### Webhook Receiver

Expandi webhooks fire HTTP POST to our endpoint on each event.

**Solution:** Express/Fastify server on the dedicated PP droplet (pp-scout-sfo2). Full control, no third-party limits, co-located with Scout agent and SQLite database. See Section 7 for infrastructure details.

#### Event Schema

Every Expandi webhook event gets logged:
```json
{
  "event_id": "evt_20260306_001",
  "outreach_id": "out_20260306_001",
  "target_id": "tgt_20260306_001",
  "event_type": "connection_sent | connection_accepted | message_sent | replied | replied_first | disconnected | campaign_finished",
  "timestamp": "2026-03-06T14:00:00Z",
  "expandi_data": { /* raw webhook payload */ }
}
```

#### Derived Metrics (computed, not stored)

Per outreach:
- `time_to_accept` — hours from connection_sent to accepted
- `time_to_reply` — hours from message_sent to first reply
- `outcome` — `no_response | accepted_no_reply | replied | meeting_booked | disconnected`

Per variant:
- `accept_rate` — accepted / connection_sent
- `reply_rate` — replied / message_sent  
- `meeting_rate` — meeting_booked / replied (manually tagged)
- `disconnect_rate` — disconnected / connection_sent

Per dimension:
- By `angle` (incident_response, deploy_safety, compliance, agent_control)
- By `opener` (pain_point, social_proof, curiosity, peer)
- By `signal_type` (production_incident, funding, hiring, regulatory, launch)
- By `segment` (founder, cto, vp_eng, devops_lead)

#### Reply Classification

When a reply webhook fires, I need to classify it:
- **Positive** — interest expressed, wants to talk, asks questions
- **Neutral** — polite acknowledgment, no clear interest
- **Negative** — not interested, wrong person, unsubscribe
- **Meeting** — explicitly agreed to a call (manually confirmed)

**How:** I read the reply content from Expandi (included in webhook payload) and classify automatically. Post to #outreach-log with classification + the reply text for Rod to see.

---

### 3.5 Feedback & Optimization

#### Weekly Analysis (cron — Sunday night)

Automated cron job runs analysis:

1. **Pull all events from the past week**
2. **Compute win rates** per angle, opener, signal type, segment
3. **Statistical significance check** — need ≥20 sends per variant before drawing conclusions (below that, flag as "insufficient data")
4. **Generate recommendations:**
   - RETIRE: variants with <5% reply rate (and ≥20 sends)
   - PROMOTE: variants with >15% reply rate
   - GENERATE: new variants inspired by top performers
   - ADJUST: segment-specific insights ("CTOs respond to X, founders to Y")
5. **Update Message Playbook** (Section 4)
6. **Post summary to #outreach-log**

#### Playbook Update Rules

- Never retire ALL variants (always keep ≥2 active)
- New variants get a "probation" period — 20 sends before judging
- Winning variants get higher weight (60% of sends) but never 100% (always explore)
- Keep a "graveyard" of retired variants with data — might resurface with different segments

#### Monthly Review (with Rod)

Once a month, I compile:
- Total outreach volume + outcomes
- Best/worst performing dimensions
- Cost per reply, cost per meeting (Expandi cost / meetings)
- Playbook evolution (what changed and why)
- Recommendations for ICP adjustments

---

## 4. Message Playbook v1

Starting variants. These will evolve based on data.

### Angles (what we lead with)

| ID | Angle | Hypothesis |
|---|---|---|
| A1 | `incident_response` | "We saw your incident — here's how to prevent the next one" |
| A2 | `deploy_safety` | "Your AI agents ship code without approval — that's a timebomb" |
| A3 | `accountability_gap` | "When your agent breaks prod, who's accountable? We solve that" |
| A4 | `competitive_edge` | "Your competitors are adding AI guardrails — you should too" |

### Openers (how we start the connection note)

| ID | Opener | Example start |
|---|---|---|
| O1 | `pain_point` | "Saw the [incident] — that's exactly the problem we're solving..." |
| O2 | `social_proof` | "We just submitted to NIST on AI agent security — your work at [company] came up..." |
| O3 | `curiosity` | "Quick question about how [company] handles agent permissions..." |
| O4 | `peer` | "Fellow founder here — building in the AI safety space, thought you'd find this interesting..." |

### Tone

Always `peer_founder` from Rod's account. Never salesy, never corporate. Think: one founder DM'ing another founder about a shared problem.

### Initial Rotation

Week 1-2: Equal distribution across all 4 angles × 4 openers = 16 combinations.
At ~25 sends/day × 10 weekdays = ~250 sends. Each combo gets ~15 sends.
Week 3: First meaningful data. Begin retiring losers, promoting winners.

---

## 5. Data Storage

### Location
`pp-os/outreach/data/`

### Files
```
pp-os/outreach/
├── OUTREACH-ENGINE-SPEC.md    ← this file
├── playbook.json              ← current message playbook + variant weights
├── data/
│   ├── signals.jsonl          ← all detected signals
│   ├── targets.jsonl          ← enriched targets
│   ├── outreach.jsonl         ← generated messages + variant tags
│   ├── events.jsonl           ← Expandi webhook events
│   └── analysis/
│       ├── weekly-YYYY-MM-DD.json   ← weekly analysis snapshots
│       └── playbook-history.jsonl   ← playbook changes over time
```

All JSONL (one JSON object per line) — easy to append, easy to grep, easy to analyze.

---

## 6. Discord Integration

### #outreach-log receives:

**On lead injection:**
> 🎯 **New outreach:** Jane Smith (CTO, Acme AI)
> Signal: Production incident (HN thread)
> Angle: incident_response | Opener: pain_point
> Connection note: "Hey Jane — saw the Acme incident..."

**On reply (auto-classified):**
> 💬 **Reply from Jane Smith** (Acme AI) — **POSITIVE**
> "Yeah that's exactly what we've been struggling with. What does your solution look like?"
> → Rod: reply in LinkedIn

**On meeting booked (Rod manually confirms):**
> 🏆 **Meeting booked:** Jane Smith, Acme AI — Mar 12, 2pm MST
> Signal: production_incident | Angle: incident_response

**Weekly summary:**
> 📊 **Week 2 Performance**
> Sent: 47 | Accepted: 23 (49%) | Replied: 8 (17%) | Meetings: 2
> Best angle: incident_response (28% reply)
> Retiring: competitive_edge (0% reply, 22 sends)
> New variants: incident_response + social_proof hybrid
> Playbook updated ✅

---

## 7. Infrastructure — PP Droplet

Dedicated DigitalOcean droplet for all PP operational infrastructure. Keeps PP cleanly separated from Xdares (Maria) and Charles's Mac.

### Droplet Spec
- **Plan:** s-2vcpu-2gb ($12/mo) — 2 vCPU, 2GB RAM, 60GB disk
- **Region:** SFO2 (same as Maria, low latency to DO backbone)
- **OS:** Ubuntu 24.04 LTS
- **Access:** Tailscale only (no public SSH). Firewall: allow 443 inbound (webhook receiver via Caddy/nginx), deny everything else except Tailscale
- **Name:** `pp-scout-sfo2`

### What Runs Here

```
pp-scout-sfo2 ($12/mo)
│
├── /opt/pp-scout/
│   ├── OpenClaw instance (Scout agent — signal detection + enrichment)
│   ├── workspace/ (scout crons, enrichment scripts, company research)
│   └── Runs as: dedicated bot on Discord (#scout-alerts, #outreach-log)
│
├── /opt/pp-outreach/
│   ├── webhook-server/ (Express/Fastify, port 3100, reverse-proxied via Caddy)
│   │   ├── POST /hooks/expandi → log to SQLite + notify Discord
│   │   ├── GET /health → uptime check
│   │   └── Auth: shared secret header from Expandi
│   ├── db/
│   │   └── outreach.sqlite (signals, targets, outreach, events, analysis)
│   └── scripts/
│       ├── analyze.sh (weekly feedback loop — Sunday 10 PM MST)
│       ├── update-playbook.sh (auto-update variant weights)
│       └── export-report.sh (monthly summary generator)
│
└── /opt/pp-shared/
    ├── config/
    │   ├── discord-webhooks.json (channel webhook URLs)
    │   └── expandi-creds.json (API keys, campaign IDs)
    └── backups/ (daily SQLite backup, 7-day retention)
```

### What Moves Off Charles's Mac
- Scout cron jobs → run on droplet (always-on, 24/7)
- Webhook receiving → droplet
- Analysis crons → droplet
- Outreach data storage → droplet (SQLite)

### What Stays on Charles's Mac
- Message generation (Charles writes personalized outreach)
- Rod interactions (Discord, approvals, reviews)
- PP website/product work (Codex, Claude Code agents)
- Playbook authoring (pushed to droplet after updates)

### Provisioning Checklist
- [ ] Create droplet on DO (pp-scout-sfo2, s-2vcpu-2gb, Ubuntu 24.04)
- [ ] Install Tailscale, join tailnet, disable public SSH
- [ ] Configure UFW: deny all inbound except 443 (webhook) + Tailscale
- [ ] Install Node.js 22, Docker (for OpenClaw)
- [ ] Set up OpenClaw for Scout agent (Docker, same pattern as Maria)
- [ ] Create Discord bot for Scout (or reuse Charles bot with separate config)
- [ ] Deploy webhook receiver (Express + Caddy reverse proxy + Let's Encrypt)
- [ ] Create SQLite schema (signals, targets, outreach, events tables)
- [ ] Set up daily SQLite backup cron (local + optional S3/Spaces)
- [ ] Migrate scout cron jobs from Mac → droplet
- [ ] Test end-to-end: signal → scout → outreach-log notification
- [ ] Connect Expandi webhooks to https://pp-scout-sfo2.[tailnet-domain]/hooks/expandi

---

## 8. Implementation Plan

### Phase 0 — Message Validation (this week, $0)
- [ ] Finalize this spec (Rod review) ✅
- [ ] Create playbook.json with v1 variants
- [ ] Create data/ directory + schemas
- [ ] Write message generation logic (uses playbook + signal context)
- [ ] **Manual test: Generate 5 outreach messages for current leads, Rod sends manually**
- [ ] Validate message quality before automating delivery

### Phase 1 — PP Droplet + Scout Migration (week 1-2, $12/mo starts)
- [ ] Provision PP droplet (see checklist above)
- [ ] Install + configure Scout agent (OpenClaw on Docker)
- [ ] Deploy webhook receiver + SQLite schema
- [ ] Migrate scout crons from Mac → droplet
- [ ] Verify signals flow: detection → enrichment → #scout-alerts

### Phase 2 — Expandi Integration (week 2-3, +$99/mo)
- [ ] Rod signs up for Expandi 7-day trial
- [ ] Connect Rod's LinkedIn account
- [ ] Create master campaign with placeholder sequence
- [ ] Set up reversed webhook (Charles → Expandi lead injection)
- [ ] Set up outbound webhooks (Expandi → droplet event tracking)
- [ ] Wire full pipeline: signal → message generation → Expandi injection
- [ ] Test with 5 leads, verify full loop works

### Phase 3 — Feedback Loop (week 3-4)
- [ ] Build weekly analysis cron job (runs on droplet)
- [ ] Build reply classification logic
- [ ] Build playbook auto-updater
- [ ] Wire Discord notifications for all events
- [ ] Run first full week at volume (~15-25/day)
- [ ] First weekly analysis + playbook update

### Phase 4 — Optimization (month 2+)
- [ ] Enough data for statistical significance on top variants
- [ ] Begin segment-specific messaging
- [ ] Add email as secondary channel (Expandi supports multichannel)
- [ ] Evaluate: add Apollo.io for enrichment? (depends on manual enrichment bottleneck)
- [ ] Monthly review with Rod

---

## 8. Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Rod's LinkedIn account gets restricted | High — lose the outreach channel | Expandi warm-up + conservative limits (20/day). Never exceed LinkedIn's weekly cap. Monitor account health. |
| Low reply rates across all variants | Medium — wasted time | Phase 0 manual test validates message quality before spending on Expandi. Pivot messaging if <5% reply after 100 sends. |
| Signal detection misses good targets | Medium — missed opportunities | Expand signal sources over time. Add Google Alerts, Reddit, LinkedIn posts. |
| Expandi webhook delays (replies sync every few hours) | Low — slower feedback | Acceptable. We're not running a call center. Same-day notification is fine. |
| Playbook converges on local optimum | Low — stale messaging | Always keep 20% exploration budget on new variants. Monthly manual review. |

---

## 10. Cost Summary

| Item | Monthly Cost | Notes |
|---|---|---|
| PP Droplet (pp-scout-sfo2) | $12 | Scout agent + webhook receiver + data store |
| Expandi Business | $99 | Rod's LinkedIn account |
| LinkedIn (free tier) | $0 | Sales Navigator ($99/mo) optional later |
| Message generation | $0 | Charles (me) |
| Analysis & optimization | $0 | Charles (me) |
| **Total** | **$111/mo** | |

Optional future adds:
- LinkedIn Sales Navigator: +$99/mo (better search filters)
- Apollo.io enrichment: +$49/mo (auto LinkedIn URL lookup)

---

## 11. Decision Points for Rod

1. **Approve spec?** → I start Phase 0 immediately
2. **When to start Expandi trial?** → I recommend after Phase 0 manual test validates messages (end of week 1)
3. **DO droplet creation** → Rod creates via DO dashboard, shares Tailscale join key. Or gives me DO API token to provision.
4. **Scout bot identity** → New Discord bot for Scout? Or reuse Charles bot with separate OpenClaw instance?
5. **LinkedIn Sales Navigator?** → Not needed yet. Revisit after Phase 2 if manual enrichment is a bottleneck
6. **Daily send volume?** → Recommend starting at 15/day, ramping to 25/day after warm-up

---

*This system gets smarter every week. By month 3, we'll know exactly which signals, angles, and segments produce meetings — and the system will be generating messages tuned to that data automatically.*
