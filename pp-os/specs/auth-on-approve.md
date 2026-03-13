# Spec: Auth on Approve

**Status:** Building NOW
**Date:** 2026-03-12
**Priority:** #1 — blocks demo

---

## Problem

The review page at `permissionprotocol.com/review/[id]` lets anyone with the URL approve a deploy request. No identity verification. This breaks the authority thesis — the receipt should prove WHO approved, not just that someone clicked a button.

## Solution

Require GitHub OAuth login before the approve action fires. The link opens the page (anyone can view), but only authenticated users can approve.

## Changes Required

### 1. Review page client (`app/review/[id]/ReviewPageClient.tsx`)
- Check session state on load
- **Viewing:** No auth required — anyone can see the request details, AI summary, risk score
- **Approving/Rejecting:** Auth required
- If not logged in and they click approve → redirect to GitHub OAuth with `callbackUrl` back to the review page
- Show logged-in user's GitHub avatar + username near approve button ("Approving as @rodcarvalho")

### 2. Approve API route (`app/api/review/[id]/approve/route.ts`)
- Add `getServerSession(authOptions)` check at top
- If no session → return 401
- Extract `session.user.name` (GitHub username) from session
- Pass `approved_by: session.user.name` (not hardcoded "reviewer")
- Include GitHub username in the receipt metadata

### 3. Reject API route (`app/api/review/[id]/reject/route.ts`)
- Same auth check as approve
- Record rejector identity

### 4. PR comment update
- Change approval comment to include signer identity:
  `✅ **Permission Protocol** — Approved by @alice`

### 5. Receipt display
- Receipt/review page should show the authenticated signer, not "reviewer"

## What Does NOT Change
- The review page itself remains publicly viewable (no auth to see it)
- The deploy-gate GitHub Action — no changes needed
- The PP backend API — it already accepts `approved_by` field
- Auto-rerun logic — unchanged

## Auth Flow
```
User clicks approval link
→ Review page loads (public, no auth)
→ User reads AI summary, risk score, diff
→ User clicks "Hold to approve"
→ If not logged in: redirect to /login?callbackUrl=/review/[id]
→ GitHub OAuth → redirect back to review page
→ Now authenticated → hold to approve works
→ Receipt records: "Approved by github.com/alice"
```

## Testing
1. Open review page in incognito → can view, cannot approve
2. Click approve → redirected to GitHub login
3. Login → returned to review page → approve works
4. Check receipt shows correct GitHub username
5. Check PR comment shows "@username"
