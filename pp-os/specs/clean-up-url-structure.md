# Spec: Clean Up URL Structure

## Problem
The URL `app.permissionprotocol.com/pp/c/permission-protocol/deploy-requests/...` shows "permission-protocol" twice — once as the product path (`/pp`) and once as the company slug (`/permission-protocol`). This looks broken/redundant to users and is bad for screenshots/demos.

## Current Structure
```
/pp/c/{company-slug}/deploy-requests/{id}
```
Example: `/pp/c/permission-protocol/deploy-requests/5d09a195-...`

## Proposed Options

### Option A: Drop the `/pp` prefix (Recommended)
```
/c/{company-slug}/deploy-requests/{id}
```
- The app is already scoped to Deploy Gate — `/pp` is redundant
- Cleaner: `/c/permission-protocol/deploy-requests/...`
- If other products are added later, use `/dg/` (deploy-gate) not `/pp/`

### Option B: Drop `/c/` and use company as top-level
```
/pp/{company-slug}/deploy-requests/{id}
```
- `/pp/permission-protocol/deploy-requests/...`
- Still has the double "permission-protocol" feel but shorter

### Option C: Short company aliases
- Allow companies to set a short alias (e.g., "pp" for Permission Protocol)
- URL becomes `/c/pp/deploy-requests/...`
- Requires DB migration + slug management

## Recommendation
**Option A** — drop `/pp` prefix. It's the simplest change and the biggest visual win. The entire app is Deploy Gate right now, so the prefix adds no value.

## Implementation Notes
- This is a routing change in Next.js — move files from `src/app/pp/` up one level or to `/dg/`
- Add redirects from old `/pp/...` paths to new paths (backward compat)
- Update all internal links and `href` references
- Update the sidebar navigation links

## Files Likely Changed
- `src/app/pp/` → `src/app/c/` (rename route group)
- All components with hardcoded `/pp/` links
- Sidebar/navigation components
- Any middleware that checks path prefixes

## Priority
Medium — cosmetic but affects every screenshot, demo, and shared URL.
