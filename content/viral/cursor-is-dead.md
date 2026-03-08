# Cursor is dead. Long live the agents.

*How a $29 billion company became obsolete in under three years — and what that means for everything you're building right now.*

---

Four MIT kids started Anysphere in 2022 with a $400K pre-seed and a simple bet: developers would pay for AI inside their editor. They launched Cursor in March 2023. By late 2025, they'd raised $2.3 billion at a $29.3 billion valuation with over a billion in annual recurring revenue.

Then the wheels came off.

## The speedrun

Here's the timeline that should make every founder uncomfortable:

- **2022:** Founded. Nobody notices.
- **March 2023:** Cursor launches. VS Code fork with AI autocomplete. Developers are intrigued.
- **Late 2023:** $8M seed. Word of mouth spreading. "Have you tried Cursor?" becomes the new "btw I use Arch."
- **August 2024:** $60M Series A. $400M valuation. Cursor is now *the* AI coding tool.
- **December 2024:** $105M Series B. $2.5 billion. $100M in revenue that year. Rocketship.
- **June 2025:** Series C. $9.9 billion. Less than a year from $400M to ten billion.
- **July 2025:** Pricing change. Poorly communicated. Mass cancellations. The subreddit catches fire.
- **November 2025:** $2.3B raised at $29.3 billion. Peak valuation. Peak confidence.
- **February 2026:** Users reporting Composer 1.5 as "an absolute garbage producing slop machine." Power users burning $300/month. Support bots hallucinating their own policies.
- **March 2026:** Developers aren't asking "Cursor or VS Code?" anymore. They're asking "Cursor or just... agents?"

From zero to $29 billion to existential crisis. Three years.

## What actually killed it

Cursor didn't get worse. The category it created got eaten from below.

The original pitch was elegant: take the editor developers already use, inject AI into the seams. Autocomplete on steroids. Chat in the sidebar. Inline editing with natural language. You still write code — the AI just makes you faster.

That pitch made perfect sense in 2023. The assumption underneath it was that developers would always be the ones typing. The AI assists. You drive.

Then the agents showed up.

OpenAI shipped Codex as a standalone coding agent. Anthropic released Claude Code. Both run in a terminal, take a prompt, and go — cloning repos, reading codebases, making coordinated changes across dozens of files, running tests, iterating on failures. No editor required. No human watching. You describe what you want, walk away, and come back to a pull request.

The shift wasn't "better autocomplete." It was a different paradigm entirely. Cursor optimized for the human-in-the-loop at every keystroke. Agents removed the human from the loop on execution and moved them to the loop on *decisions*.

That's not an incremental change. That's a category kill.

## The part that matters: this isn't about Cursor

Cursor's arc is interesting but the real story is what it tells us about product half-lives in the AI era.

Think about the traditional technology lifecycle. Mainframes dominated for decades. PCs had a good 20-year run as the center of computing. Smartphones have been the primary platform for about 15 years now. Web frameworks have roughly 5-7 year cycles. JavaScript build tools, maybe 3-4 years.

See the pattern? Each layer compresses the one above it.

Now look at AI tooling. Cursor went from "didn't exist" to "dominant and possibly past its peak" in under three years. GitHub Copilot went from revolutionary to table stakes in about 18 months. ChatGPT went from "the fastest-growing consumer product in history" to "I have like four better options" in under two years.

We're watching product lifecycles compress from years to months. A tool can go from launch to category leader to legacy technology in the time it used to take to close a Series B.

## What's actually durable

If your product is "nice UX on top of someone else's API," you don't have years to build a moat. You might not have months.

Cursor is fundamentally a UI wrapper. A very good one — polished, thoughtful, well-integrated. But the intelligence lives in the models underneath, and those models now have their own interfaces that skip the wrapper entirely. When Claude can just... code directly, what's the editor buying you?

The things that survive lifecycle compression are the layers that everything else depends on. Databases. Auth providers. Payment infrastructure. The things that are painful to switch away from because they hold your data, your state, your trust relationships.

Stripe didn't get replaced when mobile payments took off. AWS didn't get replaced when serverless emerged. The infrastructure underneath stayed. The UI layers got churned.

## So what do you do?

If you're building something right now, the Cursor timeline is a stress test for your strategy:

**If the AI capabilities you depend on get 10x better in six months, does your product become more valuable or less?** Cursor bet that AI would keep getting better but stay inside the editor. When AI got good enough to leave the editor, the bet collapsed.

**If a new tool category emerges that makes your category irrelevant, what survives?** The data survives. The integrations survive. The compliance records survive. The "nice editor theme" does not.

**Can your product's lifecycle outrun your fundraising cycle?** Cursor raised $2.3 billion in November 2025 for a category that was already showing cracks. That capital doesn't disappear, but the strategic assumptions behind it might.

This isn't doom-and-gloom. There's never been a better time to build. But the window between "this idea is novel" and "this idea is legacy" has never been shorter. Plan accordingly.

---

*We're building [Permission Protocol](https://permissionprotocol.com) — authority infrastructure for AI systems. When every six months brings a new generation of tools and agents, the audit trail has to outlast all of them.*
