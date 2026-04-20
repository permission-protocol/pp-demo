# HOT SIGNAL Outreach — Malicious Skills Wedge
**Date:** April 20, 2026
**Signal:** Microsoft (APM) and Cisco (Skill Scanner) validation of "Malicious Skills" / supply chain attacks on agents.
**Target:** Engineering leadership at security-conscious AI companies.

---

## LinkedIn Post Draft
```
Microsoft and Cisco just validated what we’ve been tracking for months: "Malicious Skills" are the new supply chain attack for AI agents.

Monitoring what an agent *says* is standard. But monitoring the "skills" (tools/APIs) an agent can *execute* is the new frontier. If an agent loads a malicious skill at runtime, it's already too late for observability.

You need an enforcement primitive.

Permission Protocol gates every execution with a cryptographic authorization receipt. No receipt = the skill doesn't run. This is the only way to move from "detecting rogue agents" to "preventing unauthorized actions."

We just submitted this architecture to NIST. Open-source SDKs live now.

#AIAgentSecurity #CyberSecurity #NIST #PermissionProtocol
```

---

## Direct DM Draft (Target: CISOs/Head of Security)
```
Hi [Name],

Saw the recent Microsoft/Cisco validation of "Malicious Skills" as a critical enterprise agent threat.

Most teams are still trying to solve this with LLM monitoring, but that's architecturally insufficient for runtime execution.

We built Permission Protocol as the enforcement gate. It issues signed authorization receipts (Ed25519) before any agent skill executes. Think of it as the "Signer" decision that sits between the agent and the API.

Would love to share how we're securing the agent supply chain. Worth a quick sync?
```
