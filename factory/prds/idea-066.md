# PRD: idea-066 — Deploy Queue: Pulse Bar + Urgency Sort

**Issue:** permission-protocol/site#194
**Priority:** P2
**Repo:** permission-protocol/site
**Size:** M

## Problem
Deploy queue shows all pending requests equally. Sarah can't quickly see which ones are urgent. Production deploys waiting 2 hours look the same as staging deploys from 5 minutes ago.

## Current State
- `app/review/ReviewDashboard.tsx` (888 lines) — main deploy queue
- Already has `riskBadge()` function for risk tier colors
- Has `waitLabel()` and `averageWait()` — knows how long things have been waiting
- Has `RequestSummary` type with `env`, `risk_tier`, `created_at`
- Two view modes: "list" and "stack"

## Requirements

### 1. Urgency Sort (default)
Sort pending requests by urgency score:
```
urgency = envWeight × riskWeight × ageMinutes
```
- envWeight: production=10, staging=3, development=1
- riskWeight: critical=10, high=5, medium=2, low=1
- ageMinutes: minutes since created_at

Highest urgency first. Add a small "sorted by urgency" label near the queue header. Allow toggling back to "newest first" (created_at desc).

### 2. Pulse Bar
Add a subtle pulse/glow animation to cards above an urgency threshold:
- **Red pulse** on left border: production + (critical|high) + waiting > 15 min
- **Amber pulse** on left border: production + any risk + waiting > 30 min, OR staging + (critical|high) + waiting > 1 hour
- No pulse for everything else

Implementation: Add a `className` with CSS animation on the card's left border. Use `@keyframes pulse-urgent` with the existing danger/warning color tokens.

### 3. Visual Urgency Cues
- Cards with pulse should have slightly elevated z-index / subtle shadow bump
- The wait time label should turn red/amber matching the pulse tier
- Optional: small "⚡ urgent" chip on red-pulsing cards

## User Journey
1. Sarah opens deploy queue
2. Most urgent items are at top (production + high risk + longest wait)
3. Red-pulsing card catches her eye immediately — "production critical, waiting 45 min"
4. She clicks and approves
5. Queue re-sorts, next urgent item rises

## Files to Change
- `app/review/ReviewDashboard.tsx` — sort logic, pulse classes, urgency chip
- May need a small CSS keyframes block (can be inline or in globals.css)

## What NOT to Change
- Card content/layout structure
- API routes
- Stack view (only apply to list view initially)
