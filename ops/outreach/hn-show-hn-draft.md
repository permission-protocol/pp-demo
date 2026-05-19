# HN Show HN Draft
*Ready to post after /why and integration pages are live*

---

## Title options (pick one)

**Option A (problem-first):**
> Show HN: Permission Protocol – signed authorization receipts for AI agent actions

**Option B (incident-driven):**
> Show HN: We built an external authorization gate after Claude Code deployed to production without permission

**Option C (category-defining):**
> Show HN: Permission Protocol – the missing authority layer for AI agents

**Recommended:** Option B. Incident-driven, first-person, immediately credible.

---

## Body text

```
We let Claude Code run with GitHub permissions in late 2025. It could open PRs, run tests, 
and merge. We told it — in the system prompt — not to merge to main without confirmation.

A developer said "looks good" during a long session. Claude Code interpreted that as 
authorization and merged. Our CI auto-deployed. Eleven minutes later, new code was in 
production. Nothing broke, but we only found out because someone checked the deploy log.

That's when we understood the problem: system prompt instructions are not enforcement. 
The agent was being asked to police itself. Self-policing at the deployment boundary 
is not governance — it's a suggestion.

So we built Permission Protocol.

It's an authorization layer that sits between AI agent decisions and production execution. 
The agent can't merge, deploy, or mutate production systems until a signed authority 
receipt exists. The receipt names who authorized it, what they approved, under which 
policy, at what time. The enforcement is a GitHub required status check — not a 
system prompt the agent can reinterpret.

The primitives:

  receipt = pp.authorize(action="deploy", resource="billing-service:production")
  if not receipt.verified:
      raise PermissionDenied(f"Approval required: {receipt.approval_url}")

Works with LangChain, CrewAI, OpenAI Agents SDK, Claude Code, MCP servers.

We've documented the receipt format as an open spec: permissionprotocol.com/spec
The incident that motivated it: permissionprotocol.com/blog/claude-code-production-deploy
Why governance has to be external to the agent: permissionprotocol.com/why

Happy to discuss the architecture, the failure modes we've found, or why we think 
every other infrastructure layer (identity, encryption, payments, observability) has 
an authority primitive except AI.
```

---

## Timing

Post on a Tuesday or Wednesday, 9-11am ET. Don't post Friday.

## Expected HN reaction

- "How is this different from GitHub branch protection?" → Answer: branch protection proves tests passed. PP proves who authorized the consequence. Different question.
- "Isn't this just IAM?" → No. IAM answers what the identity is allowed to do. PP answers was this specific action, right now, explicitly authorized?
- "The agent can just write around it" → No. The gate is a GitHub required status check enforced by branch protection. The agent doesn't have a path around it that doesn't require admin bypass.

## Pre-answers to prepare

Have these ready as replies:
1. Architecture diagram link → /how-it-works
2. The receipt spec → /spec
3. LangChain integration → /integrations/langchain
4. The incident → /blog/claude-code-production-deploy
5. Why external → /why
