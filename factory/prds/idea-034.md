# PRD: idea-034 — Visual preview in PP review page

## Summary
Show a live visual preview of the PR's changes embedded in the PP review page. Instead of reading a diff, the approver sees the actual deployed preview and can visually confirm the change looks right. This eliminates the "what does this actually look like?" mental overhead.

## Problem
Reading code diffs is slow and requires mental compilation. For UI changes (which most factory PRs are), the approver needs to see the result, not the code. Currently they'd have to find the Vercel preview link, open it in a new tab, navigate to the affected page, and compare with production. That's 1-2 minutes per PR.

## Solution
Add a `VisualPreview` section to the review page that shows an iframe of the Vercel preview deployment URL. The preview URL is available from GitHub's deployment status API for any PR that triggers a Vercel deployment.

### Why iframe, not screenshot?
- **Interactive** — approver can scroll, click, navigate within the preview
- **Always fresh** — no stale screenshots, shows the live deployment
- **No infrastructure** — no screenshot service needed, just an iframe pointing to the Vercel preview URL
- **Mobile-friendly** — iframe scales to viewport

### Fallback
If no preview deployment is found (non-Vercel repos, or deployment not ready), show a message: "No preview deployment found. Check the PR for deployment links." with a link to the PR.

## User Journey
1. Rod opens PP review page
2. Sees verdict banner: 🟢 ROUTINE
3. Scrolls to Visual Preview section — sees the actual deployed change in an iframe
4. Can interact with the preview (scroll, click) right inside the review page
5. Looks right → approve → done

## Technical Approach

### Getting the preview URL
GitHub's Deployments API provides the preview URL:
```
GET /repos/{owner}/{repo}/deployments?sha={headSha}&environment=Preview
```
Response includes `statuses_url`. The latest status has `environment_url` which is the Vercel preview URL (e.g., `https://pp-app-git-factory-idea-033-permission-protocol.vercel.app`).

**Alternative simpler approach:** Vercel preview URLs follow a predictable pattern:
```
https://{project}-git-{branch}-{org}.vercel.app
```
We can construct this from the deploy request's `ref` field. But this is fragile — better to use the API.

### Implementation
1. Add a new API endpoint: `GET /api/v1/deploy-requests/[requestId]/preview-url`
   - Takes the deploy request's `repo`, `headSha` (or `commitSha`)
   - Calls GitHub Deployments API to find the preview deployment
   - Returns `{ previewUrl: string | null }`
   - Cache the result (preview URL doesn't change for a given SHA)

2. Add `VisualPreview` component to the review page
   - Fetches the preview URL from the new endpoint
   - Shows loading state while fetching
   - If URL found: renders an iframe with the preview URL
   - If not found: shows a fallback message with link to PR
   - Add a "Open in new tab" button above the iframe
   - Add a "Production" / "Preview" toggle to switch between production and preview views

## Files to Change
- `src/app/api/v1/deploy-requests/[requestId]/preview-url/route.ts` — NEW: API endpoint to fetch preview URL from GitHub
- `src/app/pp/deploy-requests/[requestId]/page.tsx` — add VisualPreview component

## Acceptance Criteria
- [ ] New API endpoint returns Vercel preview URL for deploy requests with PR context
- [ ] VisualPreview section appears on the review page below the AI summary
- [ ] Shows an interactive iframe of the preview deployment
- [ ] Shows loading state while fetching preview URL
- [ ] Shows fallback message when no preview URL is available
- [ ] "Open in new tab" link opens the preview in a new window
- [ ] iframe has a reasonable height (500px desktop, 400px mobile) with a resize handle or expand button
- [ ] Works on mobile viewport
- [ ] `tsc --noEmit` passes
- [ ] Existing tests pass

## Edge Cases
- PR has no Vercel deployment (backend-only change) → show "No visual preview available"
- Deployment is still building → show "Preview deploying..." with a retry button
- Cross-origin iframe restrictions → Vercel preview should allow embedding (same org)
- Very slow preview → add a loading spinner inside the iframe area

## Out of Scope
- Before/after comparison (v2 — would need production URL + same page path)
- Screenshot capture and storage
- Non-Vercel deployment providers
- Custom page paths per PR (just show the root URL for now)

## Codex Prompt
Add a visual preview section to the PP deploy request review page. Read FACTORY-PRD.md for full context.

**Step 1: Create the preview URL API endpoint**

Create a new file `src/app/api/v1/deploy-requests/[requestId]/preview-url/route.ts`:
- Use `withTenant` auth wrapper (same pattern as merge-readiness/route.ts)
- Look up the deploy request by `requestId` and `companyId`
- If the deploy request has a `headSha` or `commitSha`, call GitHub's Deployments API:
  ```
  GET https://api.github.com/repos/{owner}/{repo}/deployments?sha={sha}&per_page=5
  ```
- For each deployment, fetch its statuses:
  ```
  GET https://api.github.com/repos/{owner}/{repo}/deployments/{id}/statuses
  ```
- Find the first status with `environment_url` that looks like a Vercel preview (contains 'vercel.app' or the environment is 'Preview')
- Return `{ previewUrl: string | null, status: 'ready' | 'building' | 'not_found' }`
- Use the GitHub App installation token (same as merge-readiness endpoint — use `getAppTokenForRepo()` if available, fallback to `process.env.GITHUB_TOKEN`)
- Add simple in-memory caching (same pattern as merge-readiness cache)

**Step 2: Add VisualPreview component to the review page**

In `src/app/pp/deploy-requests/[requestId]/page.tsx`:
- Create a `VisualPreview` component (in the same file)
- Props: `requestId: string`
- On mount, fetch `/api/v1/deploy-requests/${requestId}/preview-url`
- States:
  - Loading: show a shimmer block (same height as the iframe will be)
  - Ready + previewUrl: show iframe + "Open in new tab" link
  - Building: show "Preview deploying..." with a subtle animation
  - Not found: show "No preview available" with link to PR
- Iframe styling: `w-full rounded-2xl border border-[var(--border)] bg-black` with height 500px (desktop) / 350px (mobile)
- Add an expand/collapse toggle and "Open in new tab" external link icon
- Render the VisualPreview component after the AI Summary section (after `AiSummaryCard`) and before the action buttons

Before finishing, run `npx tsc --noEmit` and fix any type errors.
