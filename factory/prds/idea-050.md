# PRD: idea-050 — Dashboard Zero-State Improvement

**Issue:** permission-protocol/app#125  
**Priority:** P2  
**Repo:** permission-protocol/app

## Problem
"Shipped Today: 0 — 0 approved · 0 denied" adds visual noise when nothing happened.

## Requirements
- When Shipped Today is 0: show "Last shipped: X ago" with relative time of most recent approved/denied request
- If no requests ever: show "No deploys yet — connect a repo to get started" with link to repos page
- Keep the card visible (don't hide it) but make zero-state informative rather than blank

## Must NOT Do
- Don't change other dashboard cards
- Don't modify the stats API
