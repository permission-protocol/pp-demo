# PRD: idea-059 — Agent Detection card: persist in Settings after dismissal

**Issue:** permission-protocol/app#143
**Priority:** P3
**Repo:** permission-protocol/app
**Size:** S

## Problem
The Agent Detection card on the dashboard can be dismissed, but once dismissed it's gone forever. Users who dismissed it early (before configuring agent detection) have no way to find those settings again.

## User Journey
1. Marco sees Agent Detection card on dashboard after first login
2. Dismisses it (busy, will configure later)
3. Comes back a week later, wants to configure agent detection
4. Card is gone. No way to find the settings.
5. **Expected:** Agent Detection settings live in Settings page, always accessible

## Requirements

### Must Have
1. **Settings page section:** Add "Agent Detection" section to the Settings page (or create Settings page if it doesn't exist)
   - Show the same content as the dismissible card: what agent detection does, configuration options
   - This is the permanent home for agent detection config
2. **Dashboard card update:** When the card is shown on dashboard, add a subtle note: "You can always find this in Settings"
3. **Dismissal behavior:** Dismissing the dashboard card only hides it from the dashboard — Settings section is unaffected

### Implementation
- Check if a Settings page exists at `src/app/pp/settings/` or similar
  - If yes: add Agent Detection section
  - If no: create a basic Settings page with Agent Detection as the first section
- The dashboard card's dismiss state is likely stored in localStorage or a user preference — keep that mechanism, just make it dashboard-only
- Settings section should include:
  - What agent detection does (brief explainer)
  - List of known AI agent patterns (Codex, Claude Code, Dependabot, etc.)
  - Toggle to enable/disable detection
  - Any existing config fields from the original card

### Must NOT Do
- Don't remove the dismissible card from the dashboard — it's still good for onboarding
- Don't change how agent detection actually works (detection logic, API, etc.)
- Don't add a full settings infrastructure if one doesn't exist — keep it simple

## Acceptance Criteria
- [ ] Settings page has Agent Detection section
- [ ] Section shows same info as the dashboard card
- [ ] Dismissing dashboard card doesn't affect Settings
- [ ] Settings page is navigable from the app sidebar/nav
