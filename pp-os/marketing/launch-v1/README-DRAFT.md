# Permission Protocol: Signer of Record for AI Actions

**No AI action executes without an explicit signer.**

Permission Protocol is the authority layer for autonomous AI agents. It ensures that critical actions—like deploying code or deleting data—cannot be executed by an AI without cryptographic proof of human authorization.

![60-second demo GIF placeholder](./demo.gif)

## Why?

API keys give agents unconstrained authority. If an agent goes rogue (or is manipulated), the API key executes its command blindly.

**The missing primitive is authority, not alignment.** 
Agents can't be held accountable. Humans must be the "Signer of Record."

### Why not IAM or API Gateways?
- **IAM** controls *what* a key can access. It doesn't capture human intent at execution time.
- **API Gateways** rate-limit or log *how often* endpoints are hit.
- **Permission Protocol** intercepts the exact arguments an agent intends to execute and mathematically binds them to a human's signature. If the agent changes an argument by a single character, the cryptographic token is invalid, and the execution is blocked.

## The Atomic Loop

1. **Agent Proposes:** An agent attempts to call a protected tool (e.g., `deploy_code(env="prod", commit="abc")`).
2. **MCP Guard Blocks:** The tool call is intercepted by our stdio proxy. Without a valid token, it fails closed.
3. **Policy Evaluates:** A simple YAML file defines the rules (e.g., `prod` deploys require 2 signatures from `admin` roles).
4. **Humans Sign:** Authorized users review the exact arguments in the Permission Protocol UI and click **Sign & Authorize**.
5. **Token Minted:** The backend mints an Ed25519 cryptographic token bound to those exact arguments, valid for a short TTL.
6. **Guard Verifies & Executes:** The agent retries with the token. MCP Guard cryptographically verifies the signatures, the arguments, the policy, and the nonce (replay protection).
7. **Immutable Receipt:** If verified, the action executes (e.g., triggering a GitHub Workflow) and a verifiable receipt is persisted to the audit log.

## Quick Start (Demo)
[... technical instructions for running the demo repo locally ...]
