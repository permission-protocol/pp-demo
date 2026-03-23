We built Permission Protocol because we saw a gap in how people are deploying AI agents.

Most tools today focus on assessment: they scan code, find vulnerabilities, and alert you when something looks wrong. But scanning doesn't stop an agent from executing a dangerous action. It only tells you about it after the fact.

Permission Protocol is an enforcement layer. It sits between your agent and your production environment. If an action doesn't have an explicit, cryptographically signed approval from a human, it cannot happen.

To prove the point, we used Permission Protocol to approve and deploy the very commit that launched this product today. Every line of code in this release was gated by a human-in-the-loop signature.

We're expecting a few common questions:

**1. Why not just use GitHub branch protection?**
Branch protection is great for preventing direct pushes, but it's not designed for the granular, multi-step actions an agent takes (like infrastructure changes or database migrations) that often happen outside of a simple PR merge. PP provides a universal enforcement primitive that works across any service, not just GitHub.

**2. Isn't this just another CI check?**
CI checks verify that code is correct. PP verifies that an action is authorized. A CI check might pass on a perfectly valid script that deletes your production database. PP stops that script because no human signed the specific request to run it.

**3. What if the agent bypasses Permission Protocol?**
PP is designed as a "gate," not a "scanner." If you've correctly configured your environment (e.g., using our GitHub Action or MCP Guard), the credentials required to deploy only exist inside the gated environment. The agent can't "bypass" the gate because it doesn't have the keys to reach production without the gate's signature.

We're just starting out and would love your feedback on the integration flow. You can get set up in under 5 minutes at https://app.permissionprotocol.com.
