# PRD: GitHub Action Marketplace README Overhaul

**Idea:** idea-013  
**Priority:** P3  
**Complexity:** S (hours)  
**Persona:** Both (Marco + Sarah)  

---

## Summary

The deploy-gate GitHub Action README is the top-of-funnel for every developer who discovers PP. Most GitHub Actions get adopted from the README alone — nobody reads docs. The current README is functional but doesn't sell. Transform it into a 30-second-to-first-gate experience with a hero visual, copy-paste workflow, and clear value proposition.

## Problem

The current state:
- **`receipt-gate/README.md`** — exists but describes the receipt verification action, not the deploy-gate
- **`docs/deploy-gate-github-actions.md`** — good setup guide but buried in docs, not the marketplace README
- **No hero screenshot** — developers can't see what the gate looks like before installing
- **No "30 seconds to first gate"** quickstart — current setup requires understanding receipts, tenant IDs, and multiple secrets
- **Two actions, unclear which to use** — `receipt-gate` vs `verify` confusion
- **No copy-paste complete workflow** — the examples are fragments, not working YAML

A developer landing on the marketplace page should go: "I want this" → copy YAML → push → gated. In under 30 seconds.

## Solution

### New README structure (for the `verify` action — the deploy-gate):

```
1. Hero section: Screenshot of gate blocking + human approving + deploy proceeding
2. One-liner pitch: "No AI agent deploys code without human approval."
3. 30-second quickstart (3 steps: add workflow, set 2 secrets, push)
4. Complete copy-paste workflow YAML
5. What happens: visual flow diagram (text-based)
6. All inputs/outputs table
7. Advanced: environment-specific gating, auto-approve for staging
8. FAQ: "What if I remove this?" "What about existing PRs?"
```

### Key design decisions:
- **Lead with the deploy-gate (`verify`) action**, not receipt-gate. Deploy-gate is the entry point; receipt-gate is advanced.
- **Minimize secrets** — only `PP_BASE_URL` and `PP_API_KEY` required. The action detects repo/PR/SHA from GitHub context automatically.
- **Screenshot shows the actual CI output** — the "Approval Required" message with the approve link. This is what sells it.
- **The complete workflow YAML must actually work** when copy-pasted into any repo. No placeholders except secrets.
- **Text-based flow diagram** because GitHub markdown doesn't support images well in all contexts:
  ```
  AI Agent pushes code → Deploy gate blocks → Human reviews → Approves → Deploy proceeds
       ❌ Blocked            🔍 Review           ✅ Approved      🚀 Deployed
  ```

## User Journey

1. Developer searches "AI agent deploy approval" or finds PP via word-of-mouth
2. Lands on GitHub Action marketplace page → sees hero screenshot + pitch
3. Reads "30-second quickstart" — 3 steps
4. Copies complete workflow YAML into their repo
5. Sets 2 secrets in GitHub (PP_BASE_URL + PP_API_KEY)
6. Pushes a commit → gate fires → they see the approval flow
7. Thinks "wow, this is real" → tells team

## Files to Change

1. **`docs/deploy-gate-github-actions.md`** — This becomes the primary README content. Restructure with hero section, quickstart, complete workflow, and flow diagram. This is the file that should be referenced from the action or linked from marketplace.

2. **`.github/actions/verify/action.yml`** — Update the `description` field to be marketplace-friendly: "Block AI agent deploys until a human approves. Cryptographic proof of authorization."

3. **`templates/github-actions/receipt-gate/README.md`** — Add a note at the top: "Looking for the deploy gate? See [Permission Protocol Verify](link)." This prevents confusion.

## Acceptance Criteria

- [ ] README starts with a pitch line: "No AI agent deploys code without human approval"
- [ ] 30-second quickstart with exactly 3 steps (add workflow, set secrets, push)
- [ ] Complete, copy-paste-ready workflow YAML that works on any repo
- [ ] Text-based flow diagram showing: push → gate → review → approve → deploy
- [ ] All inputs/outputs documented in a clean table
- [ ] action.yml description updated for marketplace
- [ ] receipt-gate README cross-links to verify action
- [ ] No broken links
- [ ] README renders correctly on GitHub (tested by viewing raw)

## Edge Cases

1. **Developer uses both actions** — README should clarify: verify creates requests + checks approvals; receipt-gate is for custom receipt verification. Most users only need verify.
2. **Self-hosted PP** — Quickstart defaults to hosted (`https://app.permissionprotocol.com`), with a note about self-hosted base URLs.
3. **Existing CI workflows** — FAQ section: "Can I add this to my existing workflow?" Yes — it's one step, add it before your deploy step.

## Out of Scope

- Actual screenshot image creation (needs a live gate to screenshot — separate task)
- Video embed
- Marketplace listing optimization (icon, branding colors — already set in action.yml)
- Receipt-gate README rewrite (just cross-link for now)

## Codex Prompt

```
Rewrite the deploy-gate GitHub Action README for the marketplace.

CONTEXT:
- The deploy-gate action is at .github/actions/verify/action.yml
- Current docs are at docs/deploy-gate-github-actions.md
- The receipt-gate (a different action) has its own README at templates/github-actions/receipt-gate/README.md
- The verify action requires 2 secrets: PP_BASE_URL and PP_API_KEY
- Everything else (repo, PR number, commit SHA, environment) is auto-detected from GitHub context

CHANGES:

1. Rewrite docs/deploy-gate-github-actions.md with this structure:
   
   # Permission Protocol Deploy Gate
   
   > No AI agent deploys code without human approval.
   
   [Text description of what the screenshot would show: gate blocking, approval page, deploy proceeding]
   
   ## 30-Second Setup
   
   ### 1. Add the workflow
   Create `.github/workflows/deploy-gate.yml`:
   [Complete, working YAML - uses permission-protocol/verify@v1, triggers on pull_request to main, uses PP_BASE_URL and PP_API_KEY secrets, sets environment: production]
   
   ### 2. Set secrets
   Go to Settings → Secrets → Actions and add:
   - `PP_BASE_URL`: `https://app.permissionprotocol.com` (or your self-hosted URL)
   - `PP_API_KEY`: Get one at https://app.permissionprotocol.com/settings/api-keys
   
   ### 3. Push a commit
   That's it. The next PR will be gated.
   
   ## What Happens
   
   ```
   AI pushes code → Gate blocks PR → Human reviews → Approves → PR merges
        ❌               🔍              ✅            🚀
   ```
   
   1. An AI agent (Codex, Claude Code, Cursor) opens a PR
   2. The deploy gate creates an approval request
   3. A human reviews the changes and approves (or denies)
   4. The gate passes, PR can merge
   5. A cryptographic receipt proves who authorized it
   
   ## Inputs
   [Table of all inputs from action.yml with descriptions]
   
   ## Outputs
   [Table of all outputs]
   
   ## Advanced
   - Environment-specific gating
   - Auto-approve for staging
   - Required status checks setup
   
   ## FAQ
   - "What if I remove this action?" → Requires modifying CI. Intentionally sticky.
   - "Does this work with existing workflows?" → Yes, add it as one step.
   - "What about non-AI deploys?" → Works for all deploys. AI agents just make it essential.

2. In .github/actions/verify/action.yml, update the description field to:
   "Block AI agent deploys until a human approves. Cryptographic receipt proves authorization."

3. In templates/github-actions/receipt-gate/README.md, add after the title:
   > **Looking for the deploy gate?** Most users want the [Permission Protocol Verify action](../../.github/actions/verify) which creates approval requests automatically.

CONSTRAINTS:
- The workflow YAML must be complete and working — no placeholders except secrets
- Use permission-protocol/verify@v1 as the action reference
- Keep the README under 300 lines
- No images (text-based diagrams only)
- All links must be valid GitHub paths or permissionprotocol.com URLs
```

---

*PRD written by Charles · Create Factory · 2026-03-13*
