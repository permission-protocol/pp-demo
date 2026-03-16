# PRD: idea-060 — Onboarding flow for new users with 0 repos

**Issue:** permission-protocol/app#141
**Priority:** P3
**Repo:** permission-protocol/app
**Size:** M

## Problem
When a new user lands on the PP dashboard with 0 connected repos, they see an empty dashboard with no guidance. There's no clear path from "I signed up" to "I have deploy gates on my repo." This is the #1 drop-off point for new users.

## User Journey (Current)
1. User signs up / logs in for the first time
2. Lands on dashboard → sees empty stats (0 requests, 0 repos)
3. Confused. Clicks around. Maybe finds Repos tab.
4. Doesn't know they need to install the GitHub App first.
5. Leaves.

## User Journey (Expected)
1. User signs up / logs in for the first time
2. Dashboard detects 0 connected repos → shows onboarding flow instead of empty dashboard
3. **Step 1: Install GitHub App** — "Connect your GitHub repos" button → links to GitHub App installation page. After install, callback redirects back.
4. **Step 2: Pick a repo** — Shows list of accessible repos from the installation. User selects one (or all).
5. **Step 3: Add the workflow** — Shows the deploy-gate YAML with a copy button. "Add this to `.github/workflows/deploy-gate.yml` in your repo."
6. **Step 4: First gate** — "Push a PR to see your first deploy gate in action!" with a link to the repo.
7. After first deploy request arrives, onboarding dismisses automatically and shows the real dashboard.

## Requirements

### Must Have
1. **Zero-state detection:** If user has 0 connected repos (no GitHub App installations), show onboarding instead of empty dashboard
2. **Step 1 — Connect GitHub:** CTA button linking to GitHub App install URL. Include brief explanation: "PP needs access to your repos to gate deployments."
3. **Step 2 — Select repos:** After GitHub App callback, show accessible repos. User can enable/disable deploy gates per repo.
4. **Step 3 — Add workflow:** Display the deploy-gate workflow YAML with copy-to-clipboard. Include link to Quickstart page for full docs.
5. **Step 4 — Waiting for first gate:** Show a "waiting" state with a refresh/poll mechanism. When first deploy request arrives, celebrate and transition to real dashboard.
6. **Progress indicator:** Show which step the user is on (1/4, 2/4, etc.)
7. **Skip option:** "I'll set this up later" link that dismisses onboarding (but shows a smaller banner reminder)

### Implementation
- Main component: `src/app/pp/components/onboarding-flow.tsx` (new)
- Dashboard page (`src/app/pp/page.tsx`): conditionally render onboarding vs dashboard based on repo count
- GitHub App install URL: use existing install endpoint or construct from App slug
- Workflow YAML: hardcode the recommended workflow (same as Quickstart page)
- Repo list: fetch from GitHub App installation API (existing code in #41/#42 if built, otherwise use current repo-fetching logic)

### Design
- Full-width card replacing the dashboard content (not a modal or overlay)
- Clean, minimal — think Vercel or Linear onboarding
- Each step is a card with clear heading, brief description, and one primary action
- Progress dots or step indicator at the top
- Celebrate completion: confetti or checkmark animation when first gate fires

### Must NOT Do
- Don't block users from navigating away (they should be able to explore other pages)
- Don't require all steps — partial onboarding is fine (some users will add workflow manually)
- Don't change the dashboard layout for users who have repos
- Don't add new API endpoints unless necessary — use existing data

## Acceptance Criteria
- [ ] New user with 0 repos sees onboarding flow on dashboard
- [ ] GitHub App install CTA works and redirects back after install
- [ ] Workflow YAML is shown with copy button
- [ ] Progress indicator shows current step
- [ ] "Skip" option available at every step
- [ ] Onboarding auto-dismisses after first deploy request
- [ ] Returning users with repos see normal dashboard
