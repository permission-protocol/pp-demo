# PRD: idea-069 — Design Partner Onboarding Checklist

**Issue:** permission-protocol/site#14
**Priority:** P2
**Repo:** permission-protocol/site
**Size:** M

## Problem
New design partners sign up but have no guided path to get fully set up. They land on the dashboard with nothing configured and have to figure it out themselves.

## Current State
- Dashboard at `/review` (ReviewDashboard.tsx) shows deploy requests
- Quickstart at `/developers/quickstart` has SDK setup steps
- No onboarding wizard or checklist component

## Requirements

### Onboarding Checklist Widget
A persistent checklist widget that appears on the dashboard for users who haven't completed setup:

**Steps:**
1. ✅ Create account (auto-completed on signup)
2. Install GitHub App → link to GitHub App install URL
3. Connect first repository → shows after GitHub App installed, link to repo settings
4. Configure first policy → link to policy editor or docs
5. Trigger first deploy gate → instructions to open a PR on connected repo
6. Review first request → will auto-complete when they approve/deny their first request

### UX
- Shows as a card/banner at top of dashboard (above deploy queue)
- Progress bar: "2 of 6 steps complete"
- Each step: checkbox + title + brief description + action button/link
- Completed steps show green check, in-progress step is highlighted
- Can be collapsed/minimized but not permanently dismissed until all steps done
- After all 6 complete: celebration state → "You're all set! 🎉" → auto-hides after 5 sec

### State Tracking
- Track completion client-side via localStorage (key: `pp-onboarding-progress`)
- Check actual state on load: if GitHub App is installed (repos exist in API response), auto-mark step 2 done
- If deploy requests exist, auto-mark steps 5+6 done
- This prevents stale checklist showing for users who set up via other paths

## User Journey
1. Marco creates account → lands on dashboard
2. Sees onboarding checklist: "Get started with Permission Protocol" (2/6 done)
3. Clicks "Install GitHub App" → redirected to GitHub → installs → back to dashboard
4. Checklist updates: 3/6 done, next step highlighted
5. Follows remaining steps → all done → 🎉 → checklist hides

## Files to Change
- New: `src/components/OnboardingChecklist.tsx`
- `app/review/ReviewDashboard.tsx` — render checklist above queue when incomplete
- May need to check `/api/reviews` response for "has any requests" signal

## What NOT to Change
- Dashboard layout below the checklist
- Auth flow
- API routes
