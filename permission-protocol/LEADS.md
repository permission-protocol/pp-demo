# Permission Protocol: Deploy Owner Leads

## Qualification Criteria

Must be able to finish: *"If an agent pushed a bad change to prod, I would be involved in explaining it."*

**Route through blame, not tools.**

---

## Tier 1: Warmest Paths (via your network)

### Ask Your Investors/Advisors
- Who in their portfolio is using Cursor/Copilot/Devin for production code?
- Who has complained about AI-generated PRs breaking things?
- Who owns deploy pipelines at their portfolio companies?

### Your Direct Network
Filter by: "owns deploys + on-call rotation"
- Former colleagues at infra/platform roles
- Founders of dev tools startups (they dogfood)
- Anyone who's posted incident postmortems publicly

---

## Tier 2: High-Signal Companies

Companies known to be early AI coding adopters with real production stakes:

| Company | Why | Who to Find |
|---------|-----|-------------|
| **Vercel** | Heavy AI integration, ship fast, visible deploys | Platform/Infra lead |
| **Supabase** | OSS-first, fast shipping, public incidents | Deploy owner / SRE lead |
| **Linear** | Known Cursor users, quality bar | Platform engineer |
| **Resend** | Small team, ships fast with AI | Founder or senior eng |
| **Clerk** | Auth = high stakes, fast shipping | Platform lead |
| **Neon** | DB = high stakes, infra-heavy | SRE / Platform |
| **Railway** | Deploy platform = meta-problem | Platform team |
| **Render** | Deploy platform, sees customer pain | Infra lead |
| **Fly.io** | Infra, public incident culture | SRE team |
| **PlanetScale** | DB + fast shipping | Platform eng |
| **Turso** | Small team, edge DB | Senior eng / founder |

### Why These Companies
- Ship frequently (high deploy volume)
- Small-ish teams (deploy owner is identifiable)
- Public engineering culture (will talk)
- High stakes (DB, auth, infra = can't break prod)
- AI-forward (likely using coding agents)

---

## Tier 3: OSS Maintainers

People who maintain deploy/CI tooling have the problem AND the audience.

| Project | Maintainer to Find |
|---------|-------------------|
| **GitHub Actions** (popular actions) | Maintainers of `actions/deploy-pages`, `docker/build-push-action` |
| **semantic-release** | Core maintainers |
| **release-it** | Core maintainers |
| **changesets** | Core maintainers (likely Thinkmill folks) |
| **ArgoCD** | CNCF maintainers (later, bigger orgs) |
| **Flux** | CNCF maintainers |
| **Atlantis** (Terraform) | Maintainers |

### Why OSS Maintainers
- They see the problem at scale across users
- They get issues filed about "how do I gate this"
- They have distribution if they adopt

---

## Tier 4: Incident Postmortem Authors

People who've written public postmortems about bad deploys:

**Where to find:**
- Hacker News "postmortem" searches
- company engineering blogs
- incident.io case studies
- Statuspage history of high-profile outages

**What to look for:**
- "A config change was pushed..."
- "An automated deploy..."
- "A PR was merged without..."

These people KNOW the pain. They've already explained a bad deploy.

---

## Tier 5: DevOps/Platform Influencers

People with audience who talk about deploy safety:

| Person | Platform | Why |
|--------|----------|-----|
| **Kelsey Hightower** | Twitter/conf | K8s, deploys, opinions |
| **Charity Majors** | Twitter/blog | Observability, deploy culture |
| **Liz Fong-Jones** | Twitter/conf | SRE, incidents |
| **Emily Freeman** | Twitter/conf | DevOps, platform eng |
| **DevOps Twitter** | General | #devops, #platformengineering |

**Use for:** Signal boost after you have proof, not for v1 validation.

---

## Anti-Targets (Skip for v1)

| Who | Why Skip |
|-----|----------|
| AI/ML teams | Don't own deploys |
| Innovation labs | No prod responsibility |
| Security teams (broad) | Too early, will slow you down |
| Generic platform leaders | Need specific deploy pain |
| Investors | Want to fund, not use |
| Enterprise architects | Too many stakeholders |

---

## Outreach Script (Non-Pitch)

Don't pitch. Diagnose.

**LinkedIn/Email opener:**
> I'm researching how teams handle approval for AI-assisted deploys. You came up because [specific reason: postmortem you wrote / company's deploy culture / OSS project].
> 
> Not selling anything—trying to understand: when an agent-generated PR goes to prod, who approves it and how do you know later that approval happened?
> 
> 15 min call if you're open to it.

**What you're extracting:**
1. What's your deploy approval flow today?
2. Has an AI-assisted change ever broken prod? What happened?
3. If it did, how would you explain "who approved this" in the postmortem?
4. What would a receipt for that approval need to contain?

---

## Prioritized Hit List (Start Here)

### Week 1: Warm Intros
1. Ask 3 investors: "Who in portfolio owns deploys and is using AI coding tools?"
2. Ask 3 founder friends: "Who's your deploy owner? Can I talk to them?"
3. Post in any private Slack/Discord: "Looking for platform/SRE folks using Cursor in prod"

### Week 2: Cold Outreach (High-Signal)
1. Find deploy/platform leads at: Vercel, Supabase, Linear, Resend
2. Find maintainers of: semantic-release, changesets
3. Search "site:news.ycombinator.com postmortem deploy" for recent authors

### Week 3: Expand Based on Signal
- If pattern emerges (e.g., "everyone uses GitHub environments") → focus there
- If objection emerges (e.g., "we already use branch protection") → address in positioning

---

## Tracking

| Lead | Company/Project | Source | Status | Notes |
|------|-----------------|--------|--------|-------|
| | | | | |

---

*Fill in as you go. 5 quality conversations > 50 spray-and-pray.*
