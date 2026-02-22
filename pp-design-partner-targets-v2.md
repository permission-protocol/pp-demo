# Permission Protocol — Design Partner Targets v2
*Research date: 2026-02-21*

## Top 10 Targets (Ranked by Fit)

---

### 1. 🥇 Bilt Rewards
- **URL:** https://www.biltrewards.com
- **What they build:** Rewards platform for paying rent with points; loyalty/fintech
- **AI coding tools used:** Claude Code, Cursor, Devin (explicitly required in job postings), Greptile for code review
- **Evidence:** [Job posting requiring AI-augmented development](https://jobs.generalcatalyst.com/companies/bilt-rewards-2/jobs/64572699-senior-full-stack-engineer) — "Embrace an AI-augmented development workflow—you actively use tools like Claude Code, Cursor, and/or Devin"; [Greptile customer](https://www.greptile.com/blog/series-a)
- **Size:** ~50-100 engineers (small eng team, lean data team of 3)
- **Key contact:** Engineering leadership via General Catalyst job board
- **Why PP fits:** They're requiring AI coding tools for all hires but have no governance layer for AI-generated deploys. Fintech = high stakes for bad code reaching production. They run AI hackathons company-wide — code governance gap is widening fast.
- **Outreach angle:** "You're hiring engineers who must use Claude Code and Cursor — but who approves when those agents open PRs to your payments infrastructure?"

---

### 2. 🥈 Raycast
- **URL:** https://www.raycast.com
- **What they build:** Productivity/launcher app for Mac (expanding to Windows/iOS)
- **AI coding tools used:** Greptile for AI code review (confirmed customer)
- **Evidence:** [Greptile YC page lists Raycast as customer](https://www.ycombinator.com/companies/greptile); [Greptile landing page](https://www.greptile.com/yc)
- **Size:** ~30 employees, 75% engineers (~22 engineers)
- **Key contact:** Founded by Thomas Paul Mann (@thomaspaulmann) and Petr Nikolaev
- **Why PP fits:** Perfect size (tiny, eng-led), shipping fast, YC-backed. Already using AI review but no deploy governance. Small team = fast decisions. High-velocity shipping on a single codebase.
- **Outreach angle:** "Raycast ships fast with a tiny eng team — Deploy Gate ensures your AI-assisted PRs don't skip the governance your users trust you for."

---

### 3. 🥉 WorkOS
- **URL:** https://workos.com
- **What they build:** Enterprise-readiness APIs (SSO, SCIM, directory sync) for SaaS apps
- **AI coding tools used:** Greptile for AI code review (confirmed — eng manager quoted on Greptile site)
- **Evidence:** [Greptile homepage testimonial](https://www.greptile.com/) — "Greptile has tightened our feedback loops" from WorkOS Eng. Manager
- **Size:** ~95 employees, engineering-led culture
- **Key contact:** Michael Grinich (CEO, @grinich on Twitter)
- **Why PP fits:** They literally build enterprise auth/security infrastructure. Their customers are enterprises that care deeply about governance. If WorkOS ships a bug via AI-generated code, it's an SSO/auth vulnerability for their customers' customers. They should dogfood governance.
- **Outreach angle:** "You build enterprise security infrastructure — shouldn't your own AI-generated deploys have enterprise-grade governance?"

---

### 4. PostHog
- **URL:** https://posthog.com
- **What they build:** Open-source product analytics platform for engineers
- **AI coding tools used:** Greptile for AI code review (confirmed); likely Copilot/Cursor given eng culture
- **Evidence:** [Greptile customer](https://www.greptile.com/yc); 98 engineers, 65 commits/day to monorepo, [22,477 tests](https://www.mendral.com/blog/ci-at-scale)
- **Size:** ~141 employees, ~98 engineers
- **Key contact:** James Hawkins (CEO, @james406 on Twitter/GitHub)
- **Why PP fits:** Extremely high-velocity shipping (65 commits/day). Open-source culture means they'd be vocal advocates. At 98 engineers they're at the edge of "too big" but their flat structure means fast decisions. Their monorepo with 22K tests is a perfect Deploy Gate integration point.
- **Outreach angle:** "65 commits/day to a monorepo — Deploy Gate adds the governance layer between AI-generated code and your open-source users' data."

---

### 5. Builder.io
- **URL:** https://www.builder.io
- **What they build:** Visual CMS / headless page builder for developers
- **AI coding tools used:** Cursor (Steve Sewell, CEO, published detailed Cursor tips blog including YOLO mode)
- **Evidence:** [Blog post: "How I use Cursor (+ my best tips)"](https://www.builder.io/blog/cursor-tips) — covers YOLO mode, TDD with AI, debugging; [Cursor vs Copilot comparison](https://www.builder.io/blog/cursor-vs-github-copilot)
- **Size:** ~38-50 employees (LinkedIn says 11-50, Tracxn says 38)
- **Key contact:** Steve Sewell (CEO, @anthropic fan, blogs about Cursor)
- **Why PP fits:** CEO personally uses Cursor YOLO mode (auto-runs commands without approval). Tiny team, shipping fast. If the CEO is vibing with YOLO mode, there's a governance gap from the top down.
- **Outreach angle:** "You blogged about Cursor YOLO mode — Deploy Gate is the safety net that makes YOLO actually safe for production."

---

### 6. Brex
- **URL:** https://www.brex.com
- **What they build:** Corporate cards and spend management platform (fintech)
- **AI coding tools used:** Cursor for engineering, Claude for writing, Greptile for code review
- **Evidence:** [Brex blog: "How we're building AI-native operations"](https://www.brex.com/journal/brex-ai-native-operations) — explicitly names Cursor for engineering; [Greptile Series A blog](https://www.greptile.com/blog/series-a) lists Brex as customer; [Latent Space podcast with CTO James Reggio](https://www.latent.space/p/brex)
- **Size:** ~120+ engineers across 15 teams
- **Key contact:** James Reggio (CTO, @jamesreggio)
- **Why PP fits:** Fintech handling real money. AI-native operations strategy from leadership. 120 engineers across 15 teams = hard to maintain governance consistency. Slightly larger than ideal but their aggressive AI-first culture makes them a great lighthouse customer.
- **Outreach angle:** "Brex is going AI-native across 15 eng teams — Deploy Gate ensures consistent governance as AI-generated code touches financial infrastructure."

---

### 7. Substack
- **URL:** https://substack.com
- **What they build:** Newsletter/publishing platform for writers
- **AI coding tools used:** Greptile for AI code review (confirmed customer)
- **Evidence:** [Greptile Series A blog](https://www.greptile.com/blog/series-a) lists Substack as customer
- **Size:** ~50-80 employees (lean team, well-funded)
- **Key contact:** Chris Best (CEO), Hamish McKenzie (co-founder)
- **Why PP fits:** Platform handling payments, subscriptions, and content delivery for millions of writers. Lean team using AI review tools — governance gap between review and deploy. A bug in payments/subscription logic from AI code would be high-impact.
- **Outreach angle:** "Your writers trust Substack with their income — Deploy Gate ensures AI-assisted code changes to payments don't ship without proper sign-off."

---

### 8. ManoMano
- **URL:** https://www.manomano.com
- **What they build:** European online marketplace for DIY/home improvement
- **AI coding tools used:** CodeRabbit for AI code review
- **Evidence:** [Blog post on Medium: "AI Code Review with CodeRabbit"](https://medium.com/manomano-tech/ai-code-review-with-coderabbit-ed6ed610f481) by Kuldeep Singh from ManoMano Tech team
- **Size:** ~300+ engineers (larger company, but engineering blog shows active culture)
- **Key contact:** Kuldeep Singh (authored CodeRabbit blog); ManoMano Tech blog team
- **Why PP fits:** E-commerce with payments — AI code review is step 1, deploy governance is step 2. They've publicly written about adopting AI review, showing openness to AI governance tooling. Larger but engineering-led with public tech blog.
- **Outreach angle:** "You adopted CodeRabbit for AI review — Deploy Gate completes the loop by governing what AI-reviewed code actually ships to production."

---

### 9. Vouch Insurance
- **URL:** https://www.vouch.us
- **What they build:** Business insurance for startups (insurtech)
- **AI coding tools used:** Greptile for AI code review (confirmed customer)
- **Evidence:** [Greptile YC page](https://www.ycombinator.com/companies/greptile) lists Vouch as customer
- **Size:** ~190 employees (YC data), engineering team likely 30-50
- **Key contact:** Sam Hodges (CEO/founder)
- **Why PP fits:** Insurance company = highly regulated. They literally sell AI Insurance to other companies. If their own AI-generated code has governance gaps, that's both a reputational risk and potential compliance issue. Ironic angle: "the company insuring AI risk should govern their own AI code."
- **Outreach angle:** "You insure companies against AI risk — Deploy Gate helps you govern the AI-generated code in your own insurance platform."

---

### 10. E2B
- **URL:** https://e2b.dev
- **What they build:** Cloud sandboxes for AI agent code execution
- **AI coding tools used:** Likely heavy users of their own sandboxes + standard AI coding tools (deeply embedded in AI agent ecosystem)
- **Evidence:** [GitHub org](https://github.com/e2b-dev) shows active open-source development; [Series A blog](https://e2b.dev/blog/series-a) — $21M raised, serving Fortune 500; YC-backed
- **Size:** ~15-25 employees (startup stage, YC W23)
- **Key contact:** Vasek Mlejnsky (CEO, @maboroshi on GitHub/Twitter)
- **Why PP fits:** They provide infrastructure for AI agents to execute code — they understand the risk surface better than anyone. Small team, fast-moving, YC-backed. Would be a credibility-boosting design partner ("even the company that runs AI code sandboxes uses Deploy Gate").
- **Outreach angle:** "You give AI agents a sandbox to run code — Deploy Gate gives engineering teams a governance layer before that code reaches production."

---

## Methodology

### Sources Searched
1. **Greptile customer lists** — Most productive source. Greptile's YC page, homepage testimonials, and Series A blog post explicitly name customers: PostHog, Raycast, Vouch, Podium, Brex, Substack, Bilt, WorkOS, NVIDIA, Coinbase
2. **CodeRabbit users** — Found ManoMano via Medium tech blog
3. **GitHub Copilot coding agent announcements** — Found Carvana quote (too large), general ecosystem mapping
4. **Job postings** — Bilt Rewards' job posting explicitly requiring Claude Code/Cursor/Devin was the strongest signal found
5. **Company blogs** — Builder.io's CEO blogging about Cursor YOLO mode; Brex's AI-native operations blog naming Cursor
6. **TechCrunch/YC batch analysis** — "25% of YC W25 have 95% AI-generated codebases" confirmed the macro trend
7. **Reddit/HN discussions** — Found anecdotes about AI-generated code incidents but no specific company names
8. **OpenHands/Sweep GitHub** — These tools' public users are mostly individual developers, not easily traceable to companies via GitHub search

### What Worked Best
- **AI code review tool customer lists** (Greptile, CodeRabbit) were the most reliable source of companies actively using AI in their development workflow
- **Job postings** mentioning specific AI tools (Bilt requiring Claude Code/Cursor) are strong signals of organizational commitment
- **CEO/CTO blog posts** about AI tools indicate top-down adoption

### What Didn't Work Well
- GitHub workflow file searches for "openhands-resolver.yml" outside the tool's own repos yielded no results — most adoption is through the GitHub App, not workflow files
- Sweep has pivoted to a JetBrains plugin, reducing GitHub workflow evidence
- Twitter/X search was not accessible through the available search tools
- Most companies using AI coding tools don't publicly disclose it in searchable ways

### Gaps & Follow-Up Opportunities
- **No confirmed incident found** — The "golden" target (company that had an AI-code incident) wasn't findable via public search. The Reddit post about "shipping 10-15 AI-generated PRs/day" and breaking prod is the closest but didn't name companies.
- **Carvana** was quoted using Copilot coding agent but is too large (~25K employees)
- **NVIDIA and Coinbase** use Greptile but are enterprise-scale
- **Linear** is building AI agent features and likely uses AI tools internally — worth investigating
- **Podium** (1000 employees) was excluded as too large for first design partner
