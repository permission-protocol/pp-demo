# Content: Clinejection — 4,000 Machines, One GitHub Issue Title
**Platform:** twitter
**Type:** incident_reaction
**Signal:** https://simonwillison.net/2026/Mar/6/clinejection/
**Priority:** hot
**Timeliness:** Publish immediately — secondary coverage wave hitting now

## Content

**Tweet 1/4**
A GitHub issue title. 4,000 developer machines.

That's the Clinejection attack. A malicious string of text, read by an AI triage bot, interpreted as an instruction, and executed — straight into the npm release pipeline.

---

**Tweet 2/4**
The bot had legitimate access to GitHub and the release pipeline. It was doing its job.

The problem isn't the access. It's that nothing stood between "the agent read something" and "the agent did something."

---

**Tweet 3/4**
Agents self-authorize by default. They read an issue. They infer intent. They act.

No gate. No signed receipt. No human checkpoint. Just: read → decide → execute.

---

**Tweet 4/4**
PP puts a hard boundary at the action point. The agent reads. The gate decides.

A signed receipt is required before the pipeline runs. A poisoned issue title is just text if the agent can't self-authorize the next step.

permissionprotocol.com/deploy-gate

## Image
**Prompt:** A glowing teal pipeline diagram on void black, interrupted mid-flow by a clean geometric gate element. A red injection arrow enters before the gate and is blocked. Minimal, geometric, abstract. No text, no people. 16:9.
**Path:** /tmp/marketing-clinejection-twitter.png

## Approval
- [ ] Human-gated (blog, LinkedIn)
- [x] Auto-approved (Twitter thread ≤ 4 tweets, incident reaction)

Status: pending-review
Created: 2026-03-06T08:06:00-07:00
