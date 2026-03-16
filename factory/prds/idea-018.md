# PRD: Deploy-Gate Onboarding Wizard — 3 Clicks to First Gate

**Idea:** idea-018  
**Priority:** P4  
**Complexity:** M (half-day)  
**Persona:** Marco  

---

## Summary

New users hit a wall between "this sounds cool" and "it works on my repo." The infrastructure for automated setup exists (`/api/v1/github-app/setup-repo` creates workflows, sets secrets, configures rulesets) but there's no focused deploy-gate onboarding flow. Build a streamlined 3-step wizard specifically for deploy-gate setup, separate from the general PP setup wizard.

## Problem

Current state:
- **General setup wizard** (`/pp/setup`) — 4 steps covering policy packs, connectors (WordPress + GitHub), and verification. Too broad for someone who just wants deploy-gate.
- **GitHub connection wizard** (`/wizards/github-connection`) — focuses on PAT-based GitHub connection, not GitHub App installation.
- **`setup-repo` API** — fully automated: creates workflow YAML, sets `PP_API_KEY` secret, configures required status check ruleset. But no UI calls it.
- **GitHub App install flow** (`/api/github-app/install` → callback) — works but is buried.

Marco finds PP, wants deploy-gate on his repo. He has to: sign up → navigate general setup → figure out which connector → install GitHub App → manually add workflow YAML → set secrets → configure branch protection. That's 10+ steps across PP dashboard and GitHub settings.

The `setup-repo` API can do steps 4-7 automatically. We just need a UI that calls it.

## Solution

New route: `/pp/deploy-gate/setup` — a focused 3-step wizard:

### Step 1: Install GitHub App
- Show "Install Permission Protocol on GitHub" button
- Links to `/api/github-app/install` (existing) which redirects to GitHub
- After GitHub App install, callback redirects back to Step 2
- If already installed, auto-skip to Step 2

### Step 2: Select Repository
- Fetch repos where GitHub App is installed via `/api/v1/github-app/repos` (existing)
- Show repo list with checkboxes
- "Set up deploy gate" button

### Step 3: Automatic Setup (calls `setup-repo` API)
- Creates `.github/workflows/pp-gate.yml` via GitHub API
- Sets `PP_API_KEY` as repo secret
- Configures required status check ruleset
- Shows progress: ✅ Workflow created → ✅ Secret set → ✅ Status check required
- "Done — push a PR to test it" with link to the repo

### Key design decisions:
- **Separate from general setup** — `/pp/deploy-gate/setup` is a focused landing page, not buried in the general wizard
- **Leverages existing APIs** — `setup-repo` does all the heavy lifting. This is a UI wrapper.
- **Skip-if-done** — each step detects prior completion and auto-advances
- **No policy pack selection** — uses a sensible default for deploy-gate (auto-approve staging, require approval for production)
- **API key auto-created** — the `setup-repo` endpoint already generates a scoped API key if needed

## User Journey

1. Marco signs up for PP (or is already signed in)
2. Lands on `/pp/deploy-gate/setup` (linked from README, marketing, dashboard)
3. **Step 1:** Clicks "Install on GitHub" → redirected to GitHub → approves → redirected back
4. **Step 2:** Sees his repos → selects one → clicks "Set up"
5. **Step 3:** Watches 3 green checkmarks appear (workflow, secret, ruleset) → clicks "Done"
6. Opens a PR on his repo → deploy gate fires → sees approval flow
7. Total time: under 60 seconds

## Files to Change

### New:
1. **`src/app/pp/deploy-gate/setup/page.tsx`** — The 3-step wizard component. Client component using React state for step management.

### Modify:
2. **`src/app/api/v1/github-app/setup-repo/route.ts`** — May need minor adjustments:
   - Return step-by-step progress (which sub-steps succeeded/failed) instead of all-or-nothing
   - Accept optional `environment` parameter (default: "production")

### No changes needed:
- `/api/github-app/install` + `/api/github-app/callback` — already work
- `/api/v1/github-app/repos` — already returns installed repos
- Prisma schema — no new models
- General setup wizard — leave untouched

## Acceptance Criteria

- [ ] `/pp/deploy-gate/setup` loads a 3-step wizard
- [ ] Step 1: "Install on GitHub" button redirects to GitHub App install
- [ ] Step 1: auto-skips if GitHub App already installed on at least one repo
- [ ] Step 2: shows repos where App is installed with select UI
- [ ] Step 3: calls `setup-repo` API and shows progress for each sub-step
- [ ] After completion, shows "Push a PR to test it" with repo link
- [ ] Each step handles errors gracefully (API failures, missing permissions)
- [ ] Works on mobile (responsive)
- [ ] Page is linkable from README and marketing site

## Edge Cases

1. **GitHub App already installed** — Step 1 auto-skips, show "✅ Already installed" briefly then advance
2. **No repos found** — After App install, if repos list is empty, show "Select repositories on GitHub" link to the App's configuration page
3. **`setup-repo` partial failure** — Show which steps succeeded/failed. "Workflow created ✅ Secret failed ❌ — Set it manually: [link]"
4. **User not signed in** — Redirect to sign-in with `callbackUrl=/pp/deploy-gate/setup`
5. **User has no company** — Show "Create your organization first" with link to general setup
6. **Repo already has deploy-gate** — Detect existing `pp-gate.yml` in Step 3, show "Already set up ✅"

## Out of Scope

- Modifying the general setup wizard
- Multi-repo batch setup (select multiple repos at once — future)
- Custom workflow templates (use the default from `setup-repo`)
- Slack/email notifications for setup completion

## Codex Prompt

```
Build a focused deploy-gate onboarding wizard at /pp/deploy-gate/setup.

CONTEXT:
- Existing setup-repo API at src/app/api/v1/github-app/setup-repo/route.ts handles all automation: creates workflow YAML, sets PP_API_KEY secret, configures status check ruleset.
- GitHub App install flow exists: /api/github-app/install redirects to GitHub, /api/github-app/callback handles the return.
- Repos API at /api/v1/github-app/repos returns repos where the App is installed.
- Existing general setup wizard at src/app/pp/setup/page.tsx (DON'T MODIFY — reference for component patterns only).
- UI components: Card, CardContent, CardHeader, CardTitle from components/ui/card; Button from components/ui/button; lucide-react icons.

CHANGES:

1. Create src/app/pp/deploy-gate/setup/page.tsx as a 'use client' component:
   - 3-step wizard: Install App → Select Repo → Automatic Setup
   - Use useState for currentStep (1, 2, 3) and step data
   
   Step 1 (Install):
   - On mount, check if GitHub App is installed by fetching /api/v1/github-app/repos
   - If repos exist → auto-advance to Step 2
   - If no repos → show "Install Permission Protocol on GitHub" Button that links to /api/github-app/install
   - After install callback, page reloads → detects repos → advances
   
   Step 2 (Select Repo):
   - Fetch /api/v1/github-app/repos, display as selectable cards
   - Each card shows: repo name, owner, visibility (public/private)
   - Single-select (radio), "Set up deploy gate →" Button
   
   Step 3 (Setup):
   - POST to /api/v1/github-app/setup-repo with { repo: "owner/name" }
   - Show animated progress: Workflow → Secret → Ruleset, each with spinner → ✅/❌
   - On success: show "Push a PR to test it 🚀" with link to the repo
   - On partial failure: show which steps succeeded, manual fix instructions for failures

   Style: match the existing setup wizard aesthetic (dark theme, card-based, lucide icons)
   Follow the component patterns from src/app/pp/setup/page.tsx

2. In src/app/api/v1/github-app/setup-repo/route.ts:
   - Add a `steps` array to the response: [{step: "workflow", status: "success"}, {step: "secret", status: "success"}, {step: "ruleset", status: "failed", error: "..."}]
   - This allows the UI to show per-step progress
   - Keep the existing all-or-nothing success boolean for backwards compatibility

CONSTRAINTS:
- Do NOT modify the general setup wizard (src/app/pp/setup/page.tsx)
- Do NOT modify the Prisma schema
- Use existing UI components from components/ui/
- Use existing auth patterns (getServerSession or client-side session check)
- Mobile-responsive layout
- Handle loading, error, and empty states
```

---

*PRD written by Charles · Create Factory · 2026-03-13*
