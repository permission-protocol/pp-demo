# Reddit Posts — Ready to Post

## Post 1: r/AI_Agents

**Title:** How do you handle approvals for AI agent actions that touch production?

**Body:**
We've been running AI coding agents (Codex, Claude Code) that can open PRs and trigger deploys. Works great for velocity — until one of them attempted to deploy a migration that would have dropped a column in production.

The problem: code review catches logic bugs, but it doesn't gate the *deploy itself*. The PR gets approved, CI passes, and the agent's commit ships to prod. No human explicitly authorized "yes, deploy this to production right now."

We built an open-source deploy gate that blocks execution until a human signs off with a cryptographic receipt (Ed25519). It's a GitHub Action — takes about 5 minutes to install. The key design decision: the receipt is verified *locally by your pipeline*, not by checking a database. So even if our service goes down, your existing approvals still work.

Curious how others handle this. Are you:
- Relying on branch protection alone?
- Using environment approvals in GitHub Actions?
- Building custom gates?
- Just... trusting the agent?

GitHub repo (MIT): https://github.com/permission-protocol/deploy-gate
5-minute quickstart: https://permissionprotocol.com/developers/quickstart

---

## Post 2: r/devops

**Title:** We added a human-in-the-loop gate to our CI/CD for AI-generated PRs

**Body:**
AI coding agents are great at writing code. But when they open a PR that triggers a deploy to production, we wanted a harder gate than just "someone clicked Approve on the PR."

What we built: a GitHub Action that creates a deploy request, blocks the pipeline, and waits for a named human to approve the *specific deploy* (not just the code). The approval generates an Ed25519-signed receipt that the pipeline verifies before proceeding.

Why not just use GitHub environment approvals? Two reasons:
1. Environment approvals don't produce a cryptographic receipt you can audit later
2. They don't tie the approval to the specific commit SHA — you can approve once and it applies to future deploys

The whole thing is MIT-licensed and takes about 5 minutes to set up: one YAML file, one secret.

Anyone else gating AI-generated deploys specifically? Curious what patterns people are using.

GitHub: https://github.com/permission-protocol/deploy-gate

---

## Post 3: r/ChatGPTCoding

**Title:** PSA: If you're using Codex/Claude Code to ship PRs, consider gating the deploy

**Body:**
Quick PSA for anyone using AI coding agents in repos that auto-deploy on merge.

These agents are fast. They'll open a PR, CI passes, someone approves the code review, and it ships. The gap: nobody explicitly authorized "deploy this to production." The code review approved the *code*, not the *action*.

We had Claude Code attempt a production-secret deletion by mistake. The code looked fine in the diff — it was removing an "unused" env var that was actually consumed by a different service.

Built an open-source deploy gate that adds a hard stop: the pipeline blocks until a human signs off on the specific deploy, and the approval generates a cryptographic receipt (Ed25519-signed, verifiable offline).

5 min install, GitHub Action, MIT licensed: https://github.com/permission-protocol/deploy-gate

Not trying to sell anything — it's free and open source. Just sharing because this bit us and it'll probably bit someone else.
