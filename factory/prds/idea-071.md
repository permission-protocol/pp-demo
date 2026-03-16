# PRD: idea-071 — Mobile Approval Phase 3: Push Notifications + PWA

**Issue:** permission-protocol/site#173
**Priority:** P2
**Repo:** permission-protocol/site
**Size:** L

## Problem
Sarah gets deploy requests but has no push notification to alert her. She has to actively check the dashboard. On mobile, there's no "install as app" capability.

## Current State
- Site is a Next.js app on Vercel
- No service worker, no manifest.json for PWA
- No push notification infrastructure
- Mobile-responsive design already exists

## Requirements

### 1. PWA Manifest + Install
- Add `manifest.json` with PP branding (name, icons, theme color)
- Icons: use PP logo at 192x192 and 512x512 (generate from existing assets or use placeholder)
- `display: "standalone"`, `start_url: "/review"`, `theme_color` matching PP brand
- Add `<link rel="manifest">` to layout
- iOS: add `apple-touch-icon` and `apple-mobile-web-app-capable` meta tags
- Show "Install App" prompt on mobile if not already installed (use `beforeinstallprompt` event on Android, manual instruction for iOS)

### 2. Service Worker (Offline + Push)
- Register service worker via `next.config.js` or inline script in layout
- **Cache strategy:** Network-first for API calls, cache-first for static assets
- **Offline page:** Simple "You're offline. Pending requests will load when you reconnect." page
- Push notification subscription: use the Web Push API
  - On first visit to dashboard, ask permission: "Get notified when deploy requests need your approval?"
  - Store subscription endpoint (for now, localStorage — real backend integration is Phase 4)

### 3. Push Notification Display
- **For now (MVP):** Use the Notification API to show local notifications when new requests arrive
  - Poll `/api/reviews` every 60 seconds when page is in background (via service worker)
  - If new pending request appears that wasn't in last poll → show notification
  - Notification click → opens the review page for that request
- **Title:** "Deploy request needs approval"
- **Body:** "{repo} — {pr_title} ({risk_tier})"
- **Icon:** PP logo

### 4. Offline Indicator
- When `navigator.onLine === false`, show a small amber bar at top: "You're offline"
- Auto-dismiss when back online
- During offline: queue any approve/deny actions and replay when online (stretch goal — can defer)

## User Journey
1. Sarah visits PP on her phone → "Add to Home Screen" prompt appears
2. Installs → PP icon on home screen
3. Opens app → prompted for notification permission → allows
4. Later: new deploy request arrives → phone buzzes with "Deploy request needs approval"
5. Taps notification → opens directly to the review page
6. On subway (offline) → sees "You're offline" bar, cached dashboard still visible

## Files to Create/Change
- New: `public/manifest.json`
- New: `public/sw.js` (service worker)
- New: `public/icons/` (PWA icons)
- New: `src/components/OfflineIndicator.tsx`
- New: `src/components/InstallPrompt.tsx`
- `app/layout.tsx` — add manifest link, apple meta tags, SW registration, offline indicator
- `app/review/ReviewDashboard.tsx` — notification permission prompt

## Technical Notes
- Next.js on Vercel supports service workers in `/public`
- Web Push API works on Android Chrome + iOS 16.4+ Safari
- Keep the service worker simple — no workbox needed for MVP
- Notification polling is a stopgap; real-time would be WebSocket/SSE (future)

## What NOT to Change
- Desktop experience (all PWA additions are progressive)
- API routes
- Auth flow
