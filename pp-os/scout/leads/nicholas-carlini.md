# Lead Dossier: Nicholas Carlini (CVE-2026-4747)

## Identity
- **Name:** Nicholas Carlini
- **Role:** Security Researcher (likely Google/DeepMind, though collaborating with Anthropic/Claude for this exploit).
- **Claim to Fame:** Discovered/exploited CVE-2026-4747 (FreeBSD Kernel RCE) using Claude. This is the first documented case of an AI model being used to autonomously develop a working remote root exploit for a major OS kernel.

## Context
- **The Event:** Carlini used Claude to find and write a full exploit (ROP + shellcode) for a stack overflow in FreeBSD's RPCSEC_GSS. 
- **The Impact:** Root shell access. FreeBSD powers critical infrastructure (Netflix, PlayStation).
- **The Narrative:** This is the ultimate "Agentic Risk" signal. It proves that agents don't just make "mistakes"—they can be high-speed, high-precision offensive weapons.

## Why Permission Protocol?
- **The Solution:** PP is the ONLY layer that could have blocked this. Carlini’s agent had unmanaged authority to execute code and network commands. If that agent had been wrapped in a PP gate, the first attempt to `exec(shellcode)` or `connect()` would have been blocked until a human-signed receipt was issued.
- **The Pitch:** We aren't just "detecting" rogue behavior; we are making it technically impossible for an agent to escalate privileges or exfiltrate data without a cryptographic signature from a human authority.

## Outreach Strategy
- **Channel:** Twitter/X (@nicholas_carlini) or LinkedIn.
- **Angle:** "Love the MAD Bugs work. CVE-2026-4747 is the perfect demonstration of the authority gap. We're building the enforcement layer (Permission Protocol) to ensure agents can't execute those payloads without a human signature. Would love to show you the SDK."

## Research Links
- https://github.com/califio/publications (Califio / Nicholas Carlini)
- https://blog.calif.io/p/mad-bugs-claude-wrote-a-full-freebsd
- https://www.forbes.com/sites/amirhusain/2026/04/01/ai-just-hacked-one-of-the-worlds-most-secure-operating-systems/
