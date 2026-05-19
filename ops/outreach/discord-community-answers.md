# Discord Community Answer Templates
*For LangChain, CrewAI, AutoGen, OpenAI Discord servers*
*Rule: Only answer when someone asks a genuine question. Never pitch cold.*

---

## Trigger questions to watch for

- "How do I add human approval before my agent takes an action?"
- "Is there a way to require review before LangChain tool calls?"
- "How do I pause agent execution and wait for human input?"
- "What's the best way to add HITL to CrewAI?"
- "How do I prevent my agent from deploying to production on its own?"
- "Is there an audit trail for what my agent did?"
- "How do I make my LangChain agent ask for approval?"

---

## LangChain Discord — answer template

```
A few options depending on what you need:

If you just want to pause: LangGraph's interrupt() node lets you break out of the graph 
and wait for external input before resuming.

If you want a verifiable record of who approved what: we built Permission Protocol 
for this. It's a decorator that wraps any tool call, fires an approval request to a 
configured reviewer, and issues a signed receipt before the tool executes. 

@require_approval(action="deploy", resource="billing-service:production")
def deploy_tool(service: str) -> str:
    return run_deploy(service)

The receipt records exactly who approved, which policy, when — independently verifiable. 
Integration guide: permissionprotocol.com/integrations/langchain
```

---

## CrewAI Discord — answer template

```
For a simple pause, CrewAI's human_input=True on a task works but doesn't give 
you a record of what was approved.

For a verifiable approval trail (useful if you're deploying to production or 
touching sensitive data), we use Permission Protocol — a decorator on BaseTool._run 
that fires an approval gate and issues a signed receipt before execution:

class DeployTool(BaseTool):
    @require_approval(action="deploy", resource="billing-api:production")
    def _run(self, service: str) -> str:
        return deploy(service)

The receipt names the approver, the exact action, the policy, and the timestamp. 
Full integration: permissionprotocol.com/integrations/crewai
```

---

## MCP / Claude Code Discord — answer template

```
MCP's trust model is binary — once you trust a server, the agent can call any 
tool. To gate specific tools:

from permission_protocol import authorize

async def my_tool_handler(service: str):
    receipt = await authorize(action="deploy", resource=f"{service}:production")
    if not receipt.verified:
        raise Exception(f"Authorization required: {receipt.approval_url}")
    return await deploy(service)

The gate fires before the tool body executes. If you're using Claude Code 
specifically, the GitHub App + required status check approach blocks merge 
entirely until a receipt exists:
permissionprotocol.com/integrations/claude-code
permissionprotocol.com/integrations/mcp
```

---

## AutoGen Discord — answer template

```
AutoGen doesn't have built-in tool-level approval gating. Two options:

1. Human proxy agent with human_input_mode="ALWAYS" — pauses but no audit trail
2. Permission Protocol — wraps any function tool in an external gate that issues 
   a signed receipt before execution. The agent pauses until a human approves 
   via a link, then the tool proceeds.

Works with any callable you register as a tool. The receipt is independently 
verifiable (Ed25519 signed) so you get an actual audit record, not just a log.
permissionprotocol.com/integrations/openai-agents (similar pattern for AutoGen)
```

---

## Rules for posting

1. **Only reply when the question is genuine and your answer adds value** — don't force it
2. **Answer the actual question first**, then mention PP if it's genuinely relevant
3. **One link max** — the most relevant integration guide
4. **No "we built X" cold pitching** — only in response to a direct question
5. **If the built-in solution is good enough for their use case, say so**
6. Check threads weekly, not daily — quality over quantity
