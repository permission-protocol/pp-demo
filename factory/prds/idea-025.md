# PRD: idea-025 — Post-Install AI Agent Config Guide

## Summary
After installing the GitHub App, the dashboard shows repos but doesn't guide users on configuring AI agent detection. Add an onboarding card that appears when a repo has the deploy-gate workflow but no AI agent configuration, guiding Marco through adding bot IDs or commit patterns.

## Problem
Marco installs the GitHub App and connects a repo. The deploy-gate workflow is running, but it gates ALL PRs equally — it doesn't distinguish human PRs from AI agent PRs (Codex, Claude Code, Dependabot). Without agent-specific config, Marco can't set different policies for AI vs human deploys, which is the entire value proposition.

## Solution
Add an `AiAgentConfigCard` component to the dashboard (`src/app/pp/page.tsx`) that:
1. Checks if any connected repo is missing AI agent config in its workflow
2. Shows a dismissible onboarding card with common AI agent bot IDs
3. Provides a copy-paste YAML snippet to add to the workflow
4. Links to docs for advanced configuration

## User Journey
1. Marco installs GitHub App → connects a repo
2. Dashboard shows the repo with "Setup checklist still needs attention"
3. New `AiAgentConfigCard` appears below the repo list
4. Card shows: "Detect AI agents automatically" with common bot patterns
5. Marco copies the YAML snippet → adds to workflow → card auto-dismisses on next reload

## Personas
- **Marco (EM)**: Wants quick setup, copy-paste ready

## Files to Change
- `src/app/pp/page.tsx` — add AiAgentConfigCard component, render after the repos section (~line 759)
- The card is a self-contained client component within page.tsx (no new files needed for this size)

## Acceptance Criteria
- [ ] Dashboard shows AI agent config card when repos are connected but no agent-specific config detected
- [ ] Card displays common AI agent bot IDs (github-actions[bot], dependabot[bot], codex, etc.)
- [ ] Copy-paste YAML snippet is provided and copies to clipboard on click
- [ ] Card is dismissible (stores dismissal in localStorage)
- [ ] Card doesn't show if no repos are connected (different onboarding flow)
- [ ] Existing tests pass
- [ ] `tsc --noEmit` passes

## Edge Cases
- User has already configured agent detection — card should not show
- User dismisses card — stays dismissed across sessions (localStorage)
- No repos connected — don't show this card (show the "connect repos" flow instead)

## Out of Scope
- Actually parsing the workflow YAML to verify configuration
- Auto-modifying the workflow file
- Per-repo configuration UI

## Codex Prompt
Add an AI agent configuration onboarding card to the PP dashboard.

In `src/app/pp/page.tsx`:

1. Add an `AiAgentConfigCard` component (define it in the same file, before the main component). It should:
   - Accept `repos: GitHubAppRepoSummary[]` prop
   - Return `null` if repos is empty or if `localStorage.getItem('pp-ai-config-dismissed')` is truthy
   - Render a card with:
     - Header: "🤖 Detect AI Agent Deployments"
     - Body: "Permission Protocol can automatically detect PRs from AI coding agents and apply stricter review policies."
     - A list of common agent identifiers: `github-actions[bot]`, `dependabot[bot]`, `renovate[bot]`, `codex`, `claude-code`
     - A code block with a YAML snippet showing how to add `ai-actors` input to the deploy-gate workflow
     - A "Copy snippet" button that copies the YAML to clipboard
     - A dismiss "×" button that sets localStorage and hides the card
   - Use existing UI components: `Card`, `CardContent`, `CardHeader`, `CardTitle` from `../../components/ui/card`
   - Use existing icon: `Sparkles` from lucide-react (already imported)
   - Style: border-sky-400/25, matching the existing dashboard card aesthetic

2. Render `<AiAgentConfigCard repos={connectedRepos} />` after the repos list section (around line 770), inside the same grid layout.

Follow the existing code patterns in page.tsx (it's a large client component with inline state management). Do NOT create new files.

Before finishing, run `npx tsc --noEmit` and fix any type errors.
