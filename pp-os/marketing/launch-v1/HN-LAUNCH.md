# Hacker News Launch Strategy

**Title:** Show HN: We built a system where AI agents can't deploy without a human signer

**First Comment:**
Hey HN,

We've been watching the rise of autonomous agents (and the recent Vett.sh/Replit incidents), and realized the industry is solving the wrong problem. Everyone is building better AI *tooling* or trying to solve *alignment*.

We think the actual missing primitive is **authority**. 

Agents can't hold accountability. When an agent drops a database or pushes a bad deploy, who actually authorized it? Right now, API keys are just handed to agents, meaning the agent *is* the authority.

We built Permission Protocol to fix this. It's an authority layer for AI agents that acts as the "Signer of Record".

**How it works (The Atomic Loop):**
1. **Agent Proposes:** An agent wants to run `deploy_code` (or `delete_user`).
2. **Policy Evaluates:** A simple YAML file says `deploy_code` to `prod` requires 2 human signatures.
3. **Humans Sign:** Authorized users click "Sign & Authorize" in our UI. The backend mints an Ed25519 cryptographic token bound to the *exact arguments* the agent proposed.
4. **Guard Verifies:** Our MCP Guard (a stdio proxy) intercepts the tool call. If the token is missing, expired, tampered with, or the arguments deviate by a single character, it hard-fails.
5. **Execution & Receipt:** If verified, the action executes (e.g., triggers a GitHub Workflow) and an immutable receipt is written to an audit log.

**Why not IAM or API Gateways?**
IAM controls *what* a key can access. Gateways rate-limit *how often*. Neither captures *human intent* at the exact moment of execution. PP ensures no high-risk consequence happens without cryptographic proof of human authorization.

We put together a 60-second demo showing an agent getting blocked from deploying, two humans signing the payload, the GitHub Action triggering, and the resulting audit receipt.

Repo: [link]
Demo: [link]

Would love to hear how you're currently handling (or avoiding) giving your agents write access to production.
