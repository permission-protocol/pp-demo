# Spec: Fix Post-Approval Banner States

## Problem
After approval + successful rerun, the banner shows "⟳ Attempting to merge PR..." even though:
1. The user hasn't clicked Merge yet
2. No merge attempt has been made
3. The system is just waiting for the user to click "Merge & Deploy"

This is confusing and inaccurate — it implies an active merge operation that doesn't exist.

## Current Behavior
After approval → rerun succeeds → banner shows:
```
⟳ Attempting to merge PR...
```
With the "Merge & Deploy" button active below it.

## Expected Behavior
The banner should reflect the actual state of the pipeline:

### State Machine for Post-Approval Banner:
1. **Just approved, rerun not started yet:**
   ```
   ⏳ Setting up checks...
   ```

2. **Rerun triggered, checks running:**
   ```
   ⏳ Re-running checks after approval...
   ```
   (with animated spinner — ties to spec #1)

3. **Checks passed, waiting for user to merge:**
   ```
   ✅ All checks passed — ready to merge
   ```
   Banner should turn **green/success** color. "Merge & Deploy" button prominent.

4. **User clicked Merge, merge in progress:**
   ```
   ⟳ Merging PR...
   ```
   (THIS is when "attempting to merge" is appropriate)

5. **Merge complete:**
   ```
   ✅ PR merged successfully
   ```

## Key Rule
"Attempting to merge" should ONLY appear after the user clicks the Merge button, not before.

## Implementation Notes
- The banner state should derive from `mergeStatus` and `githubRerunStatus` fields on the deploy request
- Current code likely checks `mergeStatus === 'pending_merge'` and shows the merge banner too early
- `pending_merge` means "approved and rerun queued" — it does NOT mean "merge in progress"
- Need a new status or a combined check: only show merge banner when an actual merge API call has been initiated

## Suggested Status Mapping:
| `mergeStatus` | `githubRerunStatus` | Checks | Banner |
|---|---|---|---|
| `pending_merge` | `pending` | — | "Setting up checks..." |
| `pending_merge` | `in_progress` | running | "Re-running checks..." |
| `pending_merge` | `success` | passed | "✅ Ready to merge" |
| `merging` | — | — | "⟳ Merging PR..." |
| `merged` | — | — | "✅ PR merged" |
| `merge_failed` | — | — | "❌ Merge failed" |

May need to add a `merging` status to distinguish "waiting for user to merge" from "merge API call in flight".

## Files Likely Changed
- The deploy request detail page component (banner rendering logic)
- Possibly `deploy-gate-post-approval.ts` if `mergeStatus` values need updating

## Priority
High — this is the first thing users see after approval. Wrong state = lost trust.
