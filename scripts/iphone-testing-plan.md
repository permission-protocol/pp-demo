# iPhone Testing Plan — Making Mirroring Actually Useful

## Current State
- iPhone SE connected via iPhone Mirroring (wireless)
- Screenshots: ✅ Perfect via `peekaboo image`
- Mouse/touch: ❌ All programmatic clicks blocked by iPhone Mirroring
- Keyboard: ⚠️ `press space` works, `type` broken, `tab` needs Full Keyboard Access
- Scroll: ⚠️ `press space` for page-down works in Safari

## The Problem
iPhone Mirroring filters programmatic mouse events (CGEvents, AppleScript clicks, cliclick).
Only real hardware mouse input from the trackpad passes through. This is likely a security
measure by Apple to prevent remote control of iPhones by malware.

## The Plan

### Phase 1: Keyboard-Only Navigation (Rod does 2 min of iPhone setup)

**Rod's part (one-time, on the iPhone):**
1. Settings → Accessibility → Keyboards → Full Keyboard Access → ON
2. Settings → Accessibility → Motion → Reduce Motion → ON  
3. Settings → Safari → Tab Bar → Single Tab (top bar)

**What this unlocks:**
- Tab/Shift+Tab to move focus between all UI elements
- Enter/Return to tap the focused element
- Arrow keys to navigate within lists/menus
- Space to scroll (already works)
- Full Keyboard Access shows a blue focus ring so I know where I am

**Charles can then:**
- Navigate Safari entirely via keyboard (Tab to URL bar, type URL, Enter)
- Tab through page elements, press Enter to click buttons
- Arrow keys to scroll through lists
- Screenshot at any point for visual QA

### Phase 2: Smart QA Script (`iphone-qa.sh`)

Build a wrapper script:
```bash
# Navigate to a URL
iphone-qa navigate "https://permissionprotocol.com"
# → focuses URL bar via keyboard, types URL char-by-char with press, hits enter

# Scroll down N pages  
iphone-qa scroll 3
# → sends 3 space key presses

# Screenshot and analyze
iphone-qa screenshot "hero section"
# → captures, copies to workspace, runs image analysis

# Full page audit
iphone-qa audit "https://permissionprotocol.com"
# → navigates, screenshots every page-down, generates full report
```

**Key technique for typing:** Use `peekaboo press` for each character individually
instead of `peekaboo type`. We know `press space` works, so `press a`, `press b`, etc.
should work too. Need to test this.

### Phase 3: Automated Mobile QA Pipeline

Once keyboard nav works reliably:
1. Cron job: Daily mobile screenshot audit of PP + Xdares
2. Compare screenshots day-over-day for visual regressions
3. Run after every deploy to catch mobile breakage
4. Post results to #daily-log

## What We'll Test
- permissionprotocol.com — full page mobile review
- app.permissionprotocol.com — approval flow on mobile
- xdares.com — all pages
- blog.xdares.com — article readability

## Success Criteria
- Charles can navigate to any URL without Rod's help
- Charles can scroll through entire pages
- Charles can tap buttons via keyboard Tab+Enter
- Full mobile QA takes < 5 minutes per site
