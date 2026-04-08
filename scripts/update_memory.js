const fs = require('fs');

const memoryPath = '/Users/moltbot/.openclaw/workspace/MEMORY.md';
const dailyPath = '/Users/moltbot/.openclaw/workspace/memory/2026-04-08.md';

const memContent = `
### GitHub App Installation Race Conditions
When receiving a GitHub App installation callback, querying \`GET /installation/repositories\` immediately can return an empty array due to GitHub's internal propagation delay. Always implement an exponential backoff (e.g., 1s, 2s, 4s) retry loop when the repo list is empty.

### Idempotent State Machines
When building state machines for onboarding (like ActivationAttempts), locked steps must be idempotent and resumable so users can recover from early failures without getting permanently stuck.
`;

fs.appendFileSync(memoryPath, memContent);

const dailyContent = `## Thread Archived: Onboarding Flow QA
- **Outcome:** Overhauled the Permission Protocol onboarding flow into a deterministic, server-orchestrated "Hello World" loop.
- **Key Decisions:** 
  - Activation = blocked action -> signer decision -> receipt. 
  - State machine steps must be idempotent/resumable. 
  - GitHub App installation callbacks need exponential backoff.
`;

fs.mkdirSync('/Users/moltbot/.openclaw/workspace/memory', { recursive: true });
fs.appendFileSync(dailyPath, dailyContent);
