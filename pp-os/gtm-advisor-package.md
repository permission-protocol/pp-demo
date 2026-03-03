# Permission Protocol — GTM Advisor Package
**Prepared for Karri | March 3, 2026**
**Prepared by Rod Carvalho (Founder)**

---

## Table of Contents
1. [What Permission Protocol Is](#1-what-permission-protocol-is)
2. [The Market Moment](#2-the-market-moment)
3. [Product: Deploy Gate](#3-product-deploy-gate)
4. [Ideal Customer Profile](#4-ideal-customer-profile)
5. [Design Partner Targets (Prioritized)](#5-design-partner-targets)
6. [Competitive Landscape](#6-competitive-landscape)
7. [Outreach Messages (Ready to Send)](#7-outreach-messages-ready-to-send)
8. [Incident Hooks (Conversation Openers)](#8-incident-hooks)
9. [Distribution Strategy](#9-distribution-strategy)
10. [Current Assets & Presence](#10-current-assets--presence)
11. [Goal & Timeline](#11-goal--timeline)
12. [What We Need From You](#12-what-we-need-from-you)

---

## 1. What Permission Protocol Is

**One sentence:** Permission Protocol is the authorization layer for autonomous AI systems — cryptographic proof that every irreversible action was explicitly approved before it executed.

**The thesis:** Every AI agent that touches the real world — deploys code, moves money, sends emails, changes infrastructure — needs explicit, auditable, cryptographically provable authorization. That authorization must live *outside* the agent, in a system the agent cannot override.

**What PP is NOT:**
- Not an AI framework (we don't help you build agents — we help you control them)
- Not an observability tool (we don't monitor — we authorize)
- Not a policy engine (we don't decide what's allowed — we enforce and record what was authorized)
- Not a permissions system (RBAC/IAM define who *can* do what; PP proves who *did* authorize what)

**The analogy:** The same way Stripe became "how do I accept payments," PP becomes "how do I prove this AI was allowed to do this."

**Core enforcement model:** No receipt, no action. Binary. Fail-closed. No soft mode.

---

## 2. The Market Moment

### Why now

AI agent governance is THE story in security right now. The market for what we do is being created *this month*.

**Key signals:**
- **OpenClaw security crisis (Feb 2026):** 42,665 publicly exposed AI agent instances, 93.4% with critical auth bypass vulnerabilities, 6 CVEs in one month. Every major security publication covered it.
- **Amazon Kiro incident (disclosed Feb 2026):** Amazon's own AI coding agent deleted a production environment, causing a 13-hour AWS outage. The agent inherited elevated permissions and bypassed two-person sign-off.
- **Meta inbox incident (Feb 2026):** Meta's Director of AI Alignment couldn't stop her own AI agent from mass-deleting her emails. She had to physically sprint to her computer to kill the process.
- **Crypto agent incident (Feb 2026):** AI agent managing a wallet accidentally transferred $250K worth of tokens after a session crash wiped its memory.
- **NIST AI Agent Standards Initiative (Feb 18, 2026):** Federal government launched formal standards work for AI agent security. RFI due March 9 — we're submitting.
- **Proofpoint acquired Acuvity** (AI governance startup) Feb 12 — validates market with real M&A dollars.
- **Gravitee report:** 900+ executives surveyed — adoption outpacing governance controls.
- **25% of YC W25 batch** has 95%+ AI-generated codebases (TechCrunch).

**Key quotes from publications:**
- Cisco: *"From a capability perspective, groundbreaking. From a security perspective, an absolute nightmare."*
- The Register: *"Massive access and identity problem created by poorly secured automation at scale."*
- Strata: *"Less than half feel confident they could pass a compliance review focused on agent behavior."*

### Source articles (for reference/outreach)
- [Astrix Security analysis](https://astrix.security/learn/blog/openclaw-moltbot-the-rise-chaos-and-security-nightmare-of-the-first-real-ai-agent/)
- [SecurityWeek coverage](https://www.securityweek.com/openclaw-security-issues-continue-as-secureclaw-open-source-tool-debuts/)
- [Cisco blog](https://blogs.cisco.com/ai/personal-ai-agents-like-openclaw-are-a-security-nightmare)
- [The Register](https://www.theregister.com/2026/02/09/openclaw_instances_exposed_vibe_code/)
- [NIST AI Agent Standards Initiative](https://www.nist.gov/news-events/news/2026/02/announcing-ai-agent-standards-initiative-interoperable-and-secure)

---

## 3. Product: Deploy Gate

**What it is:** A GitHub Action that blocks merges to production without a cryptographic authorization receipt. One YAML file, 2-minute install, required status check.

**How it works:**
1. Developer (or AI agent) opens a PR
2. Deploy Gate check appears as **pending** — merge is blocked
3. Authorized human reviews and approves in PP dashboard
4. PP issues a signed receipt (Ed25519, timestamped, scope-bound)
5. Check turns green → PR is mergeable
6. Receipt is immutable — stored in PP's ledger for audit

**Why deployment is the wedge:**
- Highest-stakes, most frequent autonomous action in software
- Every company already has CI/CD — zero new infrastructure
- GitHub required status check = unavoidable (not even admins bypass it)
- Zero-config install → immediate value (audit trail from day one)
- Trojan horse: once you have receipts for deploys, you want them for *everything*

**Live assets:**
- GitHub Action: `permission-protocol/deploy-gate@v1`
- Demo repo: [github.com/permission-protocol/pp-demo](https://github.com/permission-protocol/pp-demo)
- Website: [permissionprotocol.com](https://permissionprotocol.com)
- Quick start guide: included in this package (Appendix A)

---

## 4. Ideal Customer Profile

### Primary: AI-native startups (10–100 engineers)

- Already have AI agents in production or near-production
- Feel the pain of "who approved this?" when things break
- Engineering-led purchasing decisions
- Move fast, need governance that doesn't slow them down
- Using AI code review tools (Greptile, CodeRabbit, Cursor, Copilot)

### Secondary: Enterprise AI teams

- Regulated industries (finance, healthcare, legal)
- Need audit trails for compliance
- Longer sales cycle, higher contract value

### Entry point for both: Deploy Gate on one repo → expand to all repos → expand beyond deploys.

### Best signals that a company is a fit:
1. **Uses AI code review tools** (Greptile, CodeRabbit) — AI in the code loop but no governance
2. **Job postings mention AI coding tools** (Cursor, Claude Code, Devin) — organizational commitment to AI-assisted dev
3. **CEO/CTO blogs about AI tools** — top-down adoption, governance gap likely
4. **Fintech / handles real money** — high stakes for ungoverned AI deploys
5. **High commit velocity** — 50+ commits/day means manual review can't keep up

---

## 5. Design Partner Targets (Prioritized)

### Tier 1 — Highest Fit (contact first)

| # | Company | Size | Why They Fit | Outreach Angle | Key Contact |
|---|---------|------|-------------|----------------|-------------|
| 1 | **Bilt Rewards** | ~50-100 eng | Fintech. Job postings *require* Claude Code, Cursor, Devin. Greptile customer. AI hackathons company-wide. | "You're hiring engineers who must use Claude Code — who approves when those agents open PRs to your payments infrastructure?" | Engineering leadership (General Catalyst job board) |
| 2 | **Raycast** | ~22 eng | YC-backed, 75% engineers, Greptile customer. Tiny team, fast shipping. | "Raycast ships fast with a tiny eng team — Deploy Gate ensures your AI-assisted PRs don't skip governance." | Thomas Paul Mann (@thomaspaulmann) |
| 3 | **WorkOS** | ~95 emp | They build enterprise auth/SSO infrastructure. Greptile customer. If their AI code has governance gaps, it's a vuln for *their customers' customers*. | "You build enterprise security — shouldn't your own AI deploys have enterprise-grade governance?" | Michael Grinich (CEO, @grinich) |
| 4 | **Browserbase** | ~30-50 emp | Cloud browser infra for AI agents. YC-backed, $300M valuation. Greptile customer. | "You build the infrastructure AI agents use to act in the world — Deploy Gate governs what they can push to production." | Anirudh Kamath (Tech Lead), Paul Klein IV (CEO) |
| 5 | **Mintlify** | ~35 emp | Dev docs platform, 1,000+ companies, 4M+ devs/year. a16z-backed, 126% YoY growth. CTO personally uses Greptile. | "You power docs for 1,000+ companies — when AI-assisted code ships a bug, 4M developers feel it." | Hahnbee Lee (CTO), Han Wang (CEO) |

### Tier 2 — Strong Fit

| # | Company | Size | Why They Fit | Key Contact |
|---|---------|------|-------------|-------------|
| 6 | **PostHog** | ~98 eng | 65 commits/day to monorepo, open-source, Greptile customer | James Hawkins (CEO, @james406) |
| 7 | **Builder.io** | ~38-50 emp | CEO uses Cursor YOLO mode, blogs about it | Steve Sewell (CEO) |
| 8 | **Brex** | ~120+ eng | Fintech, AI-native ops strategy, Greptile customer, Cursor for eng | James Reggio (CTO, @jamesreggio) |
| 9 | **Substack** | ~50-80 emp | Greptile customer, payments platform for writers | Chris Best (CEO) |
| 10 | **E2B** | ~15-25 emp | AI agent sandbox infra, YC-backed, $21M raised | Vasek Mlejnsky (CEO, @mlejnsky) |

### Tier 3 — Worth Exploring

| Company | Notes |
|---------|-------|
| Risotto | AI helpdesk, small, CTO engaged with AI tools |
| Expanso | Distributed compute, CodeRabbit customer |
| Vouch Insurance | Insurtech, ironic angle: insures AI risk but doesn't govern own AI code |
| ManoMano | E-commerce, CodeRabbit customer, 300+ eng |

### Lead sourcing method (repeatable):
- **AI code review tool customer lists** — Greptile, CodeRabbit testimonials/case studies
- **Job postings** mentioning specific AI tools (Cursor, Claude Code, Devin)
- **CEO/CTO blog posts** about AI development tools
- **Incident monitoring** — companies with public AI code incidents

---

## 6. Competitive Landscape

| Company | What They Do | Relationship to PP |
|---------|-------------|-------------------|
| **Astrix Security** | Detect AI agent activity | Adjacent — they detect, we authorize. Potential partner. |
| **Acuvity** (acquired by Proofpoint) | AI enterprise security | Validates market with M&A dollars. |
| **StepSecurity** | GitHub Actions security hardening | Natural integration partner. They harden the runner, we certify authorization. |
| **Redpanda** | Agentic Data Plane with auth/authz | Different surface (data), same governance thesis. |
| **Gravitee** | API management + AI agent security | Published industry research we can cite. |
| **Strata** | Identity orchestration | Published "AI Agent Identity Crisis" research. |

**Key differentiation:** Nobody else does *pre-action* cryptographic authorization for AI agents. Detection tools watch what happened. Policy engines define rules. PP *enforces* authorization at the execution boundary and creates cryptographic evidence. Different category.

---

## 7. Outreach Messages (Ready to Send)

### Message 1 — Greptile (Daksh Gupta, CEO)
**Format:** Twitter/LinkedIn DM

> Hey Daksh — saw Greptile's been growing fast. You're in an interesting spot: AI is reviewing and suggesting code, but there's no layer that proves *who authorized* that code going to prod.
>
> You probably saw the OpenClaw fallout — 42K exposed instances, agents shipping code without any auth trail. That's the exact gap we're filling.
>
> Built a tool called Deploy Gate — it's a GitHub Action that blocks merges without a cryptographic receipt of authorization. 2-minute install. No new workflow, just a required status check.
>
> Would you want to try it on one Greptile repo? Partly for your own use, partly because your customers probably need this on top of what you're already giving them.

**Why Greptile:** Both a design partner candidate AND a referral channel to their entire customer base.

---

### Message 2 — StepSecurity (partnership angle)
**Format:** Email
**Subject:** Deploy Gate + Harden-Runner — natural fit?

> You're already in the GitHub Actions security lane hardening CI pipelines. We just shipped Deploy Gate — a required status check that blocks merges without a signed authorization receipt from Permission Protocol.
>
> You harden the runner. We certify the action was explicitly approved. Together that's: secure execution + provable authorization.
>
> Given the OpenClaw situation (6 CVEs in Feb, agents deploying code with zero auth trail), I think companies are about to want both layers — and right now nobody's offering them together.
>
> Worth a 20-minute call to see if there's a natural integration? Or if you want to kick the tires first, Deploy Gate is a 2-minute install on any repo.

---

### Message 3 — CodeRabbit
**Format:** LinkedIn DM

> Quick thought from one AI-in-the-loop team to another. CodeRabbit reviews the code. But once the AI suggests an approval, what stops that from becoming a merge without any human explicitly in the chain?
>
> The OpenClaw crisis made this concrete: 42K exposed instances, agents with full repo access, no audit trail. Cisco called it "an absolute nightmare."
>
> We built Deploy Gate for exactly this gap — cryptographic proof that a human (or authorized system) approved each deploy. GitHub required status check, 2-min install.
>
> Would you try it on one repo?

---

### Message 4 — Vercel (staff engineer)
**Format:** Email
**Subject:** Who authorized your last 50 AI-assisted deploys?

> Not a gotcha question — I genuinely don't know if anyone has a clean answer yet.
>
> Post-OpenClaw, I've been thinking about the gap: AI assists or initiates the code change, CI/CD runs it, but there's no cryptographic proof a human explicitly authorized that specific deploy.
>
> Logs aren't enough. Logs say what happened. Receipts prove what was approved.
>
> We built Deploy Gate — a GitHub Action that requires a signed authorization receipt before any merge. Immutable, timestamped, cryptographic.
>
> Given Vercel's position in the deployment stack, I think you'd have real opinions on whether this is the right model. Would you run it on one internal repo and poke holes in it?

---

### Message 5 — Astrix Security (partnership)
**Format:** Email
**Subject:** You detect it. We authorize it. Full coverage?

> Astrix's write-up on the OpenClaw crisis was sharp. You're detecting agent activity. We're building the layer that proves it was authorized *before* it happened.
>
> Different surfaces, same thesis: agents can't be trusted without an external control layer.
>
> Deploy Gate is our wedge — a required GitHub Actions status check that blocks deploys without a signed receipt. No receipt, no merge.
>
> I'd love to explore whether there's an integration story here. Detection + authorization is stronger than either alone.

---

### Template for any target:

> Hey [name] — quick question: you're building [product] which helps devs ship faster with AI.
>
> When an AI agent creates a PR and it gets merged — who signed off on that deployment?
>
> We built Permission Protocol to close that gap. Cryptographic receipts for every production deploy. No receipt = no merge.
>
> Would love to show you a 2-minute demo: github.com/permission-protocol/pp-demo

---

## 8. Incident Hooks

These are conversation openers tied to real, recent, viral news. Use them to make outreach timely rather than cold.

### 🔴 Tier 1 — Major Incidents

| Incident | Company | What Happened | PP Hook |
|----------|---------|---------------|---------|
| **Kiro production deletion** | Amazon AWS | AI coding agent deleted prod env, 13-hour outage | "Kiro inherited elevated permissions and skipped peer review. A deploy gate enforces authority at the CI boundary." |
| **Inbox speed-run** | Meta (Summer Yue) | AI agent deleted hundreds of emails, ignored stop commands | "If Meta's Director of AI Alignment can't stop her own agent — what chance does your avg eng team have?" |
| **$250K token transfer** | Lobstar Wilde | AI agent forgot wallet state after crash, sent $250K | "Session reset wiped context. Permission gates on irreversible ops solve this trivially." |

### 🟡 Tier 2 — Supporting Context

| Incident | Hook |
|----------|------|
| Developer fired after AI code broke production | "Companies fire humans when AI code breaks. PP creates the audit trail for accountability." |
| Claude outage = "90% productivity drop" | "When your velocity depends on one LLM API, governance can't be optional." |
| 6 new OpenClaw CVEs (SSRF, auth bypass) | "The agent framework you deployed had 6 unpatched CVEs last week." |
| Microsoft 365 Copilot EchoLeak (CVSS 9.3) | "When an agent acts on unverified email instructions, the authorization boundary is the inbox." |

### Warm lead from incidents:
**Summer Yue** (Meta) — She's publicly vocal about the problem on X. She experienced it firsthand. DM angle: "We built the thing you needed."

---

## 9. Distribution Strategy

### Primary channel: GitHub Actions ecosystem
- Deploy Gate is a GitHub Action → discoverable in GitHub Marketplace
- Required status check = sticky (once enabled, hard to remove)
- Demo repo shows it working: [github.com/permission-protocol/pp-demo](https://github.com/permission-protocol/pp-demo)

### Content engine: Weekly incident threads
- "This Week in AI Deploy Chaos" — curated AI deployment incidents + PP commentary
- Twitter (@PermissionPrtcl) + LinkedIn
- Each thread builds authority + drives traffic to demo/docs
- Compounding: audience grows, incidents get shared with us, better content

### Partnership play:
- **StepSecurity** — They harden GitHub Actions runners, we certify authorization. Combined = full CI/CD governance.
- **Greptile/CodeRabbit** — They review code, we gate deploys. "Review + Gate" is a complete story.
- **Astrix Security** — They detect agent activity, we authorize it. Detection + authorization.

### Channels we're on:
- Twitter: [@PermissionPrtcl](https://twitter.com/PermissionPrtcl) — launched Feb 25, first thread on Kiro incident
- LinkedIn: Company page set up, banner/about ready
- Hacker News: submission posted
- NIST RFI: submitting response by March 9

### "Founder Block" social proof campaign:
Get ONE founder from our target list to install Deploy Gate, get publicly blocked when trying to deploy, and tweet about it. Turns "Deploy Gate blocks deployments" from abstract claim to visible proof.

**Top target for this:** Steve Sewell (Builder.io CEO) — he blogs about Cursor YOLO mode. "The YOLO mode king meets an immovable deploy gate" is a great story.

---

## 10. Current Assets & Presence

### Product
- ✅ Deploy Gate GitHub Action (`permission-protocol/deploy-gate@v1`) — live, working
- ✅ Demo repository with branch protection — live
- ✅ Quick start guide (5-minute install) — written
- ✅ PP API — live (receipts, verification, signatures)
- ✅ Dogfooded on our own repos (Breakout-Labs)

### Web
- ✅ [permissionprotocol.com](https://permissionprotocol.com) — landing page live
- ✅ Install guide at /install
- ✅ PostHog analytics enabled

### Social
- ✅ Twitter: @PermissionPrtcl (active)
- ✅ LinkedIn: Company page (needs Rod's profile to link)
- ✅ GitHub: permission-protocol org

### Content
- ✅ NIST RFI response (full draft, submitting by March 9)
- ✅ 5 outreach messages drafted and ready
- ✅ 16 design partner targets researched with outreach angles
- ✅ 20 AI-native startup targets identified
- ✅ Incident hook list with 6+ recent incidents
- ✅ Market intel document with competitive landscape

### What's NOT done yet:
- ❌ No external design partner yet (that's the goal)
- ❌ No case study / testimonial
- ❌ No pricing page (design partner phase = free)
- ❌ Weekly incident thread engine not yet launched
- ❌ LinkedIn content cadence not started
- ❌ Rod's LinkedIn profile not yet linked to PP

---

## 11. Goal & Timeline

**Objective:** Get first external design partner actively using Deploy Gate.

**Success metric:** 1 non-Rod company with required check enabled on a production repo.

**Deadline:** March 21, 2026 (18 days from today)

**Constraints:**
- No paid acquisition
- Partner must adopt organically (not hand-held through every step)
- Deploy Gate must work end-to-end without Rod intervening in production

---

## 12. What We Need From You

Karri, here's where your GTM expertise would be most valuable:

1. **Outreach sequencing** — Which targets first? What cadence? How to handle non-responses?
2. **Message refinement** — The drafts are written by an engineer. They need a GTM eye. Too long? Wrong CTA? Missing urgency?
3. **Channel strategy** — Twitter DM vs LinkedIn vs cold email vs warm intro? For each target type?
4. **Partnership approach** — StepSecurity and Greptile are the two clearest partner plays. How to structure those conversations?
5. **Founder Block campaign** — Is the "get publicly blocked" social proof strategy the right move? How to execute?
6. **Content cadence** — Weekly incident threads, LinkedIn posts, HN submissions. What's the right mix?
7. **Design partner conversion** — Once someone says "yes I'll try it," what's the playbook to get them to required-check-on-prod-repo?
8. **Anything we're missing** — Blind spots, wrong priorities, wasted effort.

---

## Appendix A: Deploy Gate Quick Start

*(Included for reference — this is what a design partner receives)*

### Step 1: Prerequisites
- GitHub repo with Actions enabled
- PP API Key and Tenant ID (we provide these)

### Step 2: Add secrets to GitHub
- `PP_API_KEY` and `PP_TENANT_ID` in Settings → Secrets

### Step 3: Add the GitHub Action
Create `.github/workflows/deploy-gate.yml`:
```yaml
name: Deploy Gate
on:
  pull_request:
    types: [opened, synchronize, reopened]
jobs:
  deploy-gate:
    runs-on: ubuntu-latest
    steps:
      - name: Verify Deploy Authorization
        uses: permission-protocol/deploy-gate@v1
        with:
          api-key: ${{ secrets.PP_API_KEY }}
          tenant-id: ${{ secrets.PP_TENANT_ID }}
          scope: |
            {
              "scopeType": "GIT_REF_COMMIT",
              "repo": "${{ github.repository }}",
              "ref": "${{ github.ref }}",
              "commitSha": "${{ github.sha }}",
              "env": "production",
              "capability": "deploy:production"
            }
```

### Step 4: Enable required check
Settings → Branches → Branch protection → Require `deploy-gate` status check

### Step 5: Approve first deploy
Open a PR → check goes pending → approve in PP dashboard → check turns green → merge

**Total time: ~5 minutes.**

---

## Appendix B: Key Links

| Asset | URL |
|-------|-----|
| Website | [permissionprotocol.com](https://permissionprotocol.com) |
| GitHub Action | [permission-protocol/deploy-gate@v1](https://github.com/permission-protocol/deploy-gate) |
| Demo repo | [github.com/permission-protocol/pp-demo](https://github.com/permission-protocol/pp-demo) |
| Twitter | [@PermissionPrtcl](https://twitter.com/PermissionPrtcl) |
| Install guide | [permissionprotocol.com/install](https://permissionprotocol.com/install) |

---

*Package prepared March 3, 2026. All materials are current and ready for immediate use.*
