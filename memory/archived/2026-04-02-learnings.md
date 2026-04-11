# Learning: 2026-04-02

## Context
Week 4, Day 4. 2 days to sprint deadline. Final SEO sprint, Mobile Overflow fixes, and Design Token Unification.

## The Lessons

### 1. The SEO "Last Mile" is Technical
**Problem:** Publishing blog posts is only half the battle. Dead URLs in the sitemap and a stale `robots.txt` were working against the new content.
**Pattern:** Content velocity must be matched by crawler readiness.
**Fix:** Explicit sitemap hygiene (PR #262) and canonical URL enforcement.

### 2. Standardize Tokens Early
**Problem:** The marketing site and the dashboard app had subtle color and spacing drifts (e.g. emerald-400 vs emerald-500) that made the transition feel disjointed.
**Pattern:** Visual trust is built on consistency.
**Fix:** Unified app design tokens with the Sovereign Logic palette in PR #287.

### 3. Aging Blockers are Invisible
**Problem:** Several blockers (X API, Paperclip) have been on `STATUS.md` for days without any indication of how long they've been stalling progress.
**Pattern:** If a blocker isn't measured, it isn't prioritized.
**Fix:** Added "(X days)" aging to all active and blocked ideas in `STATUS.md`.

## Top 3 Improvements
1. **Blocker Aging Escalation**: Implemented "aging" tags in `STATUS.md`.
2. **Design-to-Code Parity**: Enforce Sovereign Logic CSS variables across both repos.
3. **Gateway Channel Monitoring**: Identified a major failure pattern in cron messaging channels (Discord/Telegram).

## Patterns to Adopt
- **Search Console Indexing**: Pushing new posts for manual indexing immediately.
- **Mobile Regression Checks**: iPhone SE is the "floor" for our UI density.

## Patterns to Avoid
- **Ghost Blockers**: Letting an item sit on STATUS.md for >48h without a fresh "tried" note.
- **Hardcoded Hex Codes**: Using raw colors instead of the unified token system.
