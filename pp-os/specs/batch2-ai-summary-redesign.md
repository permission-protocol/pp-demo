# Spec: AI Summary — Scannable Format + Remove Gradient

## Problem
The AI Summary is a dense paragraph on a dark gradient background. Hard to scan, hard to extract the key info. The gradient adds visual noise for no reason.

## Current
- Dark green gradient background
- Single paragraph of prose
- Buried lead: "rollout risk is extremely low" is mid-sentence
- No visual hierarchy

## Fix

### 1. Remove the gradient background
- Plain card background matching the rest of the page (dark card, no gradient)
- Subtle left border accent (teal or neutral) is fine, but no gradient fill

### 2. Structured summary format
Replace the paragraph with a scannable layout. The AI summary API response should be restructured (or the frontend should parse it) into:

```
AI Summary

What: Adds a centralized `log` utility for JSON-formatted output
Risk: Low — non-breaking addition, doesn't replace existing calls  
Action: ✅ Safe to merge

Details (collapsed by default):
  Improves observability and log parsing for ops teams.
  Establishes foundation for structured logging.
```

### Key fields to extract:
- **What** — one-line description of the change (what does it DO)
- **Risk** — Low/Medium/High + one-line reason
- **Action** — Clear recommendation: "Safe to merge" / "Review needed" / "Block"
- **Details** — expanded explanation (collapsible)

### 3. Visual hierarchy
- "What" in normal weight, "Risk" with color-coded badge (green/yellow/red), "Action" bold
- Details in a collapsible `<details>` element or smaller muted text
- The three key fields should be readable in <3 seconds

## Implementation Notes
- If the AI summary is currently generated as a single paragraph, the generation prompt needs updating to return structured JSON: `{ what, risk, riskLevel, action, details }`
- If changing the AI prompt is too much for this pass, the frontend can use a simple heuristic to extract risk level and split the paragraph at key phrases
- The summary component should accept both old-format (paragraph) and new-format (structured) gracefully

## Files Likely Changed
- AI Summary component on the deploy request detail page
- Possibly the AI summary generation prompt/service (if restructuring output)
- CSS/Tailwind for the card background

## Priority
High — this is the centerpiece of the review page. First thing Marco reads.
