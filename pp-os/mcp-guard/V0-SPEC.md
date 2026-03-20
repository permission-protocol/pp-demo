# MCP Guard — v0 Spec

**Product sentence:** Permission Protocol decides whether AI actions are allowed to happen.

If anything tomorrow does not strengthen that sentence, cut it.

---

## What ships in v0

A middleware that intercepts MCP `tools/call` requests, evaluates them against a YAML config, and allows/blocks/holds them. Emits a receipt for every decision.

### Three actions only

- `allow` — tool call proceeds
- `block` — tool call is rejected, agent receives error
- `require_approval` — tool call is held (v0: blocks with "approval required" message; approval web page is v0.1)

### Config: `pp.config.yaml`

```yaml
rules:
  - id: block-delete-user-data
    tool: delete_user_data
    action: block

  - id: require-approval-prod-deploy
    tool: deploy_production
    action: require_approval

  - id: allow-company-email
    tool: send_email
    action: allow
```

Exact-match on tool name. No regex. No conditionals. No argument inspection. No role hierarchies.

Default behavior for tools not in config: `allow` (configurable via `default_action: allow | block`).

### Receipt: JSON, one per decision

```json
{
  "receipt_id": "uuid",
  "timestamp": "iso8601",
  "agent_id": "string",
  "tool_name": "string",
  "decision": "allowed | blocked | held_for_approval",
  "reason": "string",
  "rule_id": "string",
  "request_payload_hash": "sha256"
}
```

That's it. No compliance mapping. No OWASP fields. No extensibility hooks. Those are v0.2+.

Receipt output: stdout + append to `pp-receipts.jsonl` file. No database. No API.

---

## What does NOT ship in v0

- Regex or glob policies
- Role hierarchies
- OWASP/NIST mapping in-product
- Dashboard
- Multi-tenant anything
- Conditional logic on tool arguments (e.g., `allowed_domains`)
- Approval web page (v0 blocks with message; page is v0.1)
- Receipt viewer (v0.1)
- npm publish (ship as GitHub repo first, publish after demo)

---

## Success test

A developer can do this:

1. `npm install @permissionprotocol/mcp-guard`
2. Create `pp.config.yaml` with 3 rules
3. Wrap their MCP server with the middleware
4. See in their terminal:
   - `delete_user_data` → **blocked**
   - `deploy_production` → **held for approval**
   - `send_email` → **allowed**
   - Receipt JSON written for each

That's it. If this works, v0 is done.

---

## Implementation components

| Component | What it does |
|---|---|
| Config parser | Reads `pp.config.yaml`, validates, returns rule list |
| Decision engine | Takes tool name + rules → returns allow/block/hold |
| MCP middleware hook | Intercepts `tools/call` JSON-RPC, runs decision engine, passes through or rejects |
| Receipt emitter | Generates receipt JSON, writes to stdout + file |

---

## Tomorrow's schedule

**Morning:**
- Config parser
- Decision engine
- MCP middleware hook
- Receipt emitter

**Afternoon:**
- Demo repo (3 example tools, config, run it)
- 90-second terminal recording
- README: "works in 10 minutes"

**Day after:**
- Approval hold path (simple web page)
- Basic receipt viewer
- HN post: "We built an MCP guardrail that blocks dangerous agent actions using a simple config file"

---

## HN framing

NOT: "We need a standard for AI agent audit logs"
YES: "We built an MCP guardrail that blocks dangerous agent actions using a simple config file"

"Standard" sounds committee-first. "Blocks dangerous actions" sounds useful.

The governance framework repo and receipt spec get mentioned *inside* the post. They're not the headline.
