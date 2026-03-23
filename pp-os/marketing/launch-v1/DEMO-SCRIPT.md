# 60-Second Demo Script

**Goal**: "I understand this in 30 seconds and I need it."
**Flow**: Fast, undeniable, no narration needed. Split screen or fast cuts between Terminal and Browser.

### 0:00 - The Block (Terminal)
- `claude` (or `cursor`/`agent`) is running. 
- Prompt: "Deploy the latest commit to production."
- **Terminal output**:
  ```
  [Agent] Calling tool: deploy_code { env: 'prod', commit: 'abc1234' }
  🛡️ [MCP Guard] Intercepting high-risk action: deploy_code
  ❌ [MCP Guard] DENY: Missing _authorization block.
  [Agent] I cannot deploy. I need human authorization.
  ```

### 0:10 - The Authority (Browser - PP UI)
- Open the Permission Protocol dashboard.
- A pending deploy request sits in the queue: `Deploy to prod: abc1234`.
- **UI shows**: 
  - Risk Level: HIGH (from `pp.config.yaml`)
  - Required Approvals: 2 (Multi-sig)
  - The exact JSON arguments the agent tried to use.
- **Action**: Rod clicks `[Sign & Authorize]`.
- **UI updates**: "1/2 signatures collected."
- **Action**: Alice clicks `[Sign & Authorize]`.
- **UI updates**: "Token minted."

### 0:30 - The Execution (Terminal)
- **Terminal output**:
  ```
  [Agent] Retrying with authorization token...
  🛡️ [MCP Guard] Intercepting high-risk action: deploy_code
  ✅ [MCP Guard] ALLOW: Authorization verified for deploy_code (Signers: rod, alice).
  🚀 [Executor] Triggering GitHub Workflow: permission-protocol/demo-repository/proof-html.yml on branch main
  ✅ [Executor] GitHub Workflow successfully dispatched.
  ```

### 0:45 - The Reality (Browser - GitHub & Audit Log)
- **Fast cut to GitHub Actions UI**: The `proof-html` workflow is running right now. (Undeniable real-world consequence).
- **Fast cut to PP Audit Log UI**:
  - Row appears: `deploy_code` | Verified ✅
  - Expand row:
    - **Exact Arguments**: `{ env: 'prod', commit: 'abc1234' }`
    - **Signer Identity**: `@rod, @alice`
    - **Execution Result**: `success: workflow proof-html.yml dispatched...`

**End (0:60)**
- "Permission Protocol: The Signer of Record for AI Actions."
- Link to repo.
