# ProductHunt Launch Copy

---

## Tagline (60 chars max)

```
Signed authorization receipts for AI agent actions
```

Alt:
```
No receipt = no merge. The auth layer AI agents were missing.
```

---

## Description (260 chars)

```
AI agents can deploy code, move money, and delete data — but nothing proves who 
authorized those actions. Permission Protocol issues cryptographic receipts before 
each consequential AI action. No receipt = no merge. Works with LangChain, CrewAI, 
Claude Code, OpenAI Agents, and MCP.
```

---

## Long description

**The problem**

AI agents are now capable enough to open pull requests, trigger CI, merge to main, and deploy to production. The authorization gap: nothing external proves a human authorized those specific actions. "Human in the loop" is an architecture claim. An authority receipt is evidence.

**What Permission Protocol does**

It sits between the agent's decision and the infrastructure that executes it. Before a consequential action runs — deploy, merge, database mutation, API call — the agent must present a signed authority receipt. No receipt = action blocked. The receipt names who authorized it, what they approved, under which policy, and when. It's independently verifiable.

**The primitive**

```python
from permission_protocol import require_approval

@require_approval(action="deploy", resource="billing-service:production")
def deploy():
    run_deploy()

# Agent calls deploy()
# → Paused — approval required
# → Approval link sent to sre.lead@company.com
# → Human reviews exact action, approves
# → Receipt issued: pp_r_8f91c2
# → Deployment executes with cryptographic proof
```

**Integrations**

LangChain · OpenAI Agents SDK · CrewAI · Claude Code · Model Context Protocol (MCP) · GitHub Actions

**Why external enforcement matters**

An agent told not to deploy without permission can still deploy without permission — if the constraint lives in a system prompt. We learned this firsthand. The enforcement must be outside the agent, in systems the agent cannot modify or reinterpret. That's what Permission Protocol provides.

Read the incident: permissionprotocol.com/blog/claude-code-production-deploy
Read the spec: permissionprotocol.com/spec

---

## Maker comment (post immediately after launch)

```
Hey PH 👋 Rod here, founder of Permission Protocol.

We built this after Claude Code deployed to our production without explicit authorization. 
The agent was told not to. A developer said "looks good" and Claude Code interpreted 
that as a merge signal. Nothing broke — but we only found out because someone happened 
to check the deploy log.

The fix wasn't a better system prompt. It was an external gate: a GitHub required 
status check that blocks merge until a human issues a signed receipt. The agent can't 
reinterpret its way around a branch protection rule.

That pattern — signed receipt, external enforcement, fail-closed — is what we've 
generalized into Permission Protocol.

Happy to answer questions about the architecture, the failure modes we've found with 
different agent frameworks, or why we think "authority" is the missing layer in the 
AI infrastructure stack (after identity, encryption, payments, and observability).

Full incident writeup: permissionprotocol.com/blog/claude-code-production-deploy
```

---

## Assets needed

- [ ] Demo GIF: agent trying to deploy → gate blocks → approval flow → receipt issued
- [ ] Screenshot: receipt card (use /r/demo)
- [ ] Screenshot: approval interface
- [ ] 240x240 logo

## Timing

- Launch Tuesday–Thursday
- Avoid Mondays (crowded) and Fridays (low traffic)
- Aim for 12:01am PT (maximum day visibility)
- Have 10 genuine supporters ready to upvote + comment in first hour
