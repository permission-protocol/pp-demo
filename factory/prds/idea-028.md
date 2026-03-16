# Bugfix: idea-028 — PAT permission error on pre-merge checklist

## Symptom
The PP review page shows a red error "Resource not accessible by personal access token" in the pre-merge checklist. The `GITHUB_TOKEN` env var used by the merge-readiness API doesn't have sufficient permissions for the target repo.

## Affected Files
- `src/app/api/v1/deploy-requests/[requestId]/merge-readiness/route.ts` — main file, uses `process.env.GITHUB_TOKEN` directly
- `src/app/pp/deploy-requests/[requestId]/review-page-helpers.tsx` — displays the error to users

## Root Cause Analysis
The `merge-readiness/route.ts` endpoint uses a single global `GITHUB_TOKEN` to call GitHub's API for ANY repo. This works for repos the token has access to, but fails with 403 "Resource not accessible by personal access token" for repos outside the token's scope.

The real fix: use the **GitHub App installation token** instead of a static PAT. The app is already installed on target repos (that's how the deploy gate works). The installation token has the right permissions for that specific repo.

## Fix Approach
1. In `merge-readiness/route.ts`, replace `process.env.GITHUB_TOKEN` with the GitHub App installation token for the target repo
2. Look at how other API routes get the installation token — likely via `@/lib/github/get-installation-token` or similar
3. Find the `installationId` from the deploy request's repo (it's stored when the GitHub App is installed)
4. Use the installation token for all GitHub API calls in this endpoint
5. Keep `GITHUB_TOKEN` as a fallback if no installation token is available (graceful degradation)
6. Surface a clearer error message when the token doesn't have access: "GitHub App not installed on this repo" instead of the raw GitHub error

## Acceptance Criteria
- [ ] merge-readiness endpoint uses GitHub App installation token instead of static PAT
- [ ] Pre-merge checklist works for repos where the GitHub App is installed
- [ ] Error message is user-friendly when GitHub App is not installed on the repo
- [ ] Existing tests still pass
- [ ] `tsc --noEmit` passes on changed files

## Files to Change
- `src/app/api/v1/deploy-requests/[requestId]/merge-readiness/route.ts` — replace token source
- Possibly `src/lib/github/` — check for existing installation token helpers

## Test Plan
1. Run `npx tsc --noEmit` — should pass
2. Run existing tests — should pass
3. The actual fix verification requires a deployed instance with the GitHub App installed

## Codex Prompt
You are fixing a bug in the merge-readiness API endpoint. Read FACTORY-PRD.md for full context.

The file `src/app/api/v1/deploy-requests/[requestId]/merge-readiness/route.ts` currently uses `process.env.GITHUB_TOKEN` (a static PAT) to call GitHub APIs. This fails with 403 on repos the PAT doesn't have access to.

Fix: Replace the static PAT with the GitHub App installation token for the target repo. Look at other API routes in `src/app/api/v1/` to see how they obtain installation tokens — likely via a helper in `src/lib/github/`. The deploy request record has the repo name, which can be used to look up the installation.

Keep `process.env.GITHUB_TOKEN` as a fallback if no installation token is found.

Add a clear error message: "GitHub App is not installed on [repo]. Install it at [install URL]" instead of surfacing raw GitHub API errors.

Before finishing, run `npx tsc --noEmit` and fix any type errors.
