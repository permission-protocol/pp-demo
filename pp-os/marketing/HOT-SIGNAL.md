# HOT SIGNAL: AI Agent Security & Governance Surface Exploding

**Date:** 2026-03-22

## Summary
The "supply chain" for AI coding agents (Claude Code, Codex, Cursor) is being actively weaponized. Security researchers have demonstrated successful data exfiltration via malicious `SKILL.md` files, and new "control layer" startups are emerging to address the lack of governance in agent-led deployments.

## Key Signals
- **[CRITICAL] Malicious Skills Exfiltration:** `Vett.sh` demonstrated that unsigned `SKILL.md` files can be used to exfiltrate env vars and shell history from **Claude Code** and **Codex**. They found ~60 critical risk skills in the wild acting as C2 droppers.
- **[COMPETITIVE/PARTNER] G0 Control Layer:** A new tool (`g0`) launched specifically to provide a "control layer" for agent governance, including explicit support for **OpenClaw** hardening and deployment audits.
- **[MARKET] 300k Business Customers for Claude Code:** Fortune reports Claude Code has reached a $2.5B run rate. The sheer volume of enterprise adoption makes the "unauthorized deploy/merge" problem a massive surface area for Permission Protocol.
- **[TOOLING] APM (Microsoft/GitHub):** Microsoft is moving into the "Agent Package Manager" space to standardize agent configs across tools, highlighting the need for a stable "identity" and "dependency" layer for agents.

## Strategic Takeaway
The narrative is shifting from "how do we code with agents" to "how do we secure and govern the agents that are already coding." This is the perfect entry point for Permission Protocol's enforcement primitives.
