# HOT SIGNAL: McKinsey AI Agent "Lilli" Breached via Action Layer Integration
**Date:** 2026-03-14
**Source:** [Security Boulevard](https://securityboulevard.com/2026/03/an-ai-agent-didnt-hack-mckinsey-its-exposed-apis-did/), [India Today](https://www.indiatoday.in/technology/news/story/ai-agents-now-hacking-other-ai-mckinsey-system-breached-in-2-hours-2881341-2026-03-13)

### Incident Summary
McKinsey's internal AI agent "Lilli" was breached in under 2 hours by a researcher using another AI agent. The breach didn't target the model layer, but the **action layer**: exposed APIs and database queries that the agent could manipulate.

### Why it matters for Permission Protocol (PP)
- **Direct Wedge:** This is a high-profile validation of the "Action Layer" risk. 
- **The Core Problem:** As Security Boulevard noted: *"too many organizations are still thinking about AI security at the model layer, while the real enterprise risk sits in the action layer: the APIs, MCP servers, internal services, and shadow integrations that AI agents can reach, invoke, and manipulate."*
- **PP Solution:** This is exactly what PP's gatekeeper/enforcement layer solves by intercepting and authorizing agent actions before they hit the API.

### Action Item
- Mention this incident in the next PP demo as a real-world example of why model-only security fails.
- Target security engineers/SREs concerned about "Agentic AI security" on Twitter/LinkedIn.
