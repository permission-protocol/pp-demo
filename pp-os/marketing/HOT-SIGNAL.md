# HOT SIGNAL: The "Unsigned Binary" Supply Chain Attack (AI Agent Skills)

**Signal Source:** [Vett.sh (Show HN)](https://vett.sh) — Published Mar 13, 2026
**Urgency:** HIGH
**Targeting:** AI Coding Agent Security / CI/CD Governance

## The Threat
Vett.sh has identified and scanned over 5,000 "agent skills" (SKILL.md files) used by Cursor, Claude Code, Windsurf, and Codex. Their core thesis: **SKILL.md is an unsigned binary.** 

Agents pull these instructions at HEAD from GitHub. Vett.sh demonstrated that a malicious skill can:
- Exfiltrate `.env` files, shell history, and git configs.
- Modify `config.toml` to bypass network sandboxing.
- Use LLM-generated "plausible reasons" to trick users into confirming dangerous actions.

## Market Stats
- **59 Critical Risks found:** Base64 droppers calling C2 servers, disguised as benign tools.
- **335 High Risks:** Arbitrary shell execution, piped installers.
- **Supply Chain Vulnerability:** Popular skills (e.g., "React Native Best Practices" with 5k+ installs) piping to unowned/expired domains.

## Relevance to Permission Protocol
This validates the **"Assessment Identifies, Governance Prevents"** positioning. 
1. **Vett.sh is on the Assessment side:** They scan and sign skills.
2. **Permission Protocol is the Governance side:** We are the layer that prevents the *execution* of the malicious payload (e.g., the unauthorized outbound request or shell command) regardless of whether the skill was "signed."

## Strategic Opportunity
- **"Signed ≠ Safe":** A signed skill can still be compromised or perform "authorized" but risky actions (e.g., a devops agent deleting a production DB). PP's enforcement layer is the only way to catch "behavioral" risks that static scanners miss.
- **GTM Pivot:** Focus on the "Supply Chain" angle. Every time a team adds a new SKILL.md or MCP server, they are adding an unvetted human-readable binary to their production environment. PP is the firewall for those binaries.

## Infrastructure Clashes
- **Cursor/Codex Interop Bug:** Recent forum posts (Mar 17) show Cursor accidentally pulling and injecting Codex-specific skills into its system prompt, leading to crashes or conflicting instructions. This highlights the "instruction drift" occurring as teams layer multiple agent tools.
