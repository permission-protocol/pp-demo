# PP Status — Last Updated: 2026-03-19

## Active — MCP Guard (72h Sprint)
- **v0 spec locked:** `pp-os/mcp-guard/V0-SPEC.md`
- **Day 1 (Mar 20):** Build config parser, decision engine, MCP middleware hook, receipt emitter. Afternoon: demo repo + 90-sec recording + README.
- **Day 2 (Mar 21):** Approval hold path, basic receipt viewer.
- **Day 2-3:** HN post — "We built an MCP guardrail that blocks dangerous agent actions using a simple config file"
- **Product sentence:** "Permission Protocol decides whether AI actions are allowed to happen."
- **Wedge:** Enforcement (block/allow/hold), NOT receipts/audit.

## Active — Governance Framework
- **Repo live:** https://github.com/permission-protocol/governance-framework
- **Content ready:** 3 incident analyses (Agents of Chaos, IBM Refund, Kiro) + target communities doc
- **Stress tested twice**, voice-compliant, referenced, attribution-hedged
- **Publish cadence:** Stagger blog posts 1/week after MCP Guard ships

## Parked (resume after MCP Guard sprint)
- Tinder4PRs demo video recording
- Singapore localization
- Sarah user requirements spec
- Marco requirements (M1-M23)
- Factory stuck items

## Recent Decisions (Mar 19)
- **Enforcement > Receipts**: Wedge is blocking actions, not logging them. Receipts are evidence layer.
- **Moat = execution chokepoint**: Whoever sits in the tool call execution path owns the category.
- **72h window**: Ship working enforcement before someone else does.
- **HN framing**: "Blocks dangerous actions" not "audit log standard."
- **Audience sequence**: Developers → internal adoption → CTO → sell hosted/compliance. Sequential.
- **Naming**: "Authority receipt" in spec. "AI agent guardrails + audit trail" externally.
