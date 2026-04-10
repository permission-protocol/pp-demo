# HOT SIGNAL: The Claude Code "Vibe Leak" (March 2026)

**Signal Date:** April 9, 2026 (Incident date: March 31, 2026)  
**Priority:** 🚨 P0  
**Source:** SecurityWeek, Wired, Zscaler ThreatLabz  

## Summary
Anthropic accidentally leaked the full source code for **Claude Code** (v2.1.88) by including a debugging JavaScript sourcemap in their public npm package. The 60MB leak includes the agent's memory architecture, internal tool definitions, and unreleased features.

## Why This Matters for Permission Protocol
1. **Infrastructure failure:** The leak wasn't a model failure; it was a deployment pipeline failure. This proves that **trusting the model provider's infrastructure is not enough**.
2. **Malware Injection:** Hackers are now reposting the leak with malware. Any agent using these "cracked" versions is compromised.
3. **The "Secret Patching" Narrative:** The leak confirms agents are designed with complex internal heuristics. If an agent is manipulated or its source is known, attackers can bypass soft-checks.

## Narrative Hook
> "The Claude Code leak proves that even the most secure agent labs can't protect you from a 60MB packaging error. When the agent's source is in the hands of threat actors, your CI/CD isn't a gate—it's an open door. **Permission Protocol is the only immutable lock that doesn't live inside the agent's source map.**"

## Action Items
- [ ] Draft LinkedIn post for Rod regarding "Infrastructure vs. Agent Trust".
- [ ] Update GTM deck with "Claude Code Leak" case study.
- [ ] Research `g0` (Guard0) integration—they already support OpenClaw.
