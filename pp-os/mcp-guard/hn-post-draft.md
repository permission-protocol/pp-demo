# HN Post Draft — MCP Guard

## Title

**Show HN: Block dangerous AI agent tool calls with a YAML config**

---

## URL

https://github.com/permission-protocol/mcp-guard

---

## Body

We've been building with MCP-based agents and realized there's no built-in way to control what they're allowed to do. An agent with access to `delete_user_data` will happily call it if the model decides to.

So we built a small proxy that sits between the MCP client and server and decides whether tool calls are allowed.

You can try it in 60 seconds (no setup required):
```
npx @permission-protocol/mcp-guard demo
```

You write rules like:

```
rules:
  - tool: delete_user_data
    action: block

  - tool: deploy_production
    action: require_approval
```

Then run:

```
mcp-guard --config pp.config.yaml -- node my-mcp-server.js
```

The guard intercepts `tools/call`, checks the rules, and either:

- **allows** the call (forwards to server)
- **blocks** it (returns error to agent)
- **holds** it for human approval

Every decision emits a structured receipt with a SHA-256 hash of the request payload — so you can prove what was attempted and what happened.

There's also an `observe` mode that logs what *would* be blocked without actually blocking, so you can audit before enforcing.

~800 lines of TypeScript, zero config beyond the YAML file, works with any MCP server over stdio (Claude Desktop, Cursor, etc).

Still v0. Curious how others are thinking about authorization and control in MCP systems.

---

## Posting Strategy

- **When:** Tuesday 8-9 AM EST (Mar 25) or Wednesday if approval page needs polish
- **Account:** cgoldber82
- **First comment:** Post immediately with architecture diagram + link to governance framework repo + "here's what we're building next" (approval UI, receipt viewer)
- **Engage:** Answer every comment in first 2 hours

## Anticipated Q&A

**"How is this different from mcp-guardian / other guard tools?"**
Those do approve/deny at the connection level. We do per-tool-call enforcement with structured audit receipts. The receipt trail is the differentiator — every decision is an immutable record with a cryptographic hash. We also have observe mode for dry-run auditing.

**"Why not just use the MCP server's built-in auth?"**
MCP handles transport auth (who connects), not action auth (what they can do once connected). MCP Guard fills that gap.

**"This is just a firewall for LLM tool calls."**
Exactly. Firewalls work.

**"750 lines? I could write this in a weekend."**
You could. We'd love a PR. The value isn't complexity — it's that it exists as a package you can install today, with a receipt schema that maps to governance standards.

**"Performance overhead?"**
String matching on tool names. Single-digit milliseconds. The LLM is always the bottleneck.

**"Works with Claude Desktop / Cursor?"**
If it uses MCP over stdio, yes. One line change in your MCP config.
