# PRD: Polish V3 — Typography Alignment

## Summary
Apply DESIGN.md typography hierarchy across the entire app. Space Grotesk for headlines, Inter for body, JetBrains Mono (font-mono) for metadata labels, timestamps, and IDs.

## Problem
The `font-headline` (Space Grotesk) Tailwind utility is defined in `tailwind.config.ts` but used **zero times** in the app. Every headline renders in Inter, breaking the "Editorial Brutalism" design language. Section labels and timestamps also don't use the monospace utility.

## Scope

### Headlines → `font-headline` (Space Grotesk)
Apply `font-headline` to these elements:
1. **`CardTitle` component** (`src/components/ui/card.tsx`) — add `font-headline` to the `h3` className
2. **Page-level headings** in these files (any `h1`, `h2`, or large `text-xl`/`text-2xl`/`text-3xl` that serves as a page title):
   - `src/app/pp/page.tsx` — "Get your deploy gate running" (h1), stat card titles, section titles ("Approval Queue", "Recent Activity", "Connected Repositories")
   - `src/app/pp/deploy-requests/[requestId]/page.tsx` — page heading, section headers
   - `src/app/pp/deploy-requests/page.tsx` — page heading
   - `src/app/pp/api-keys/page.tsx` — page heading
   - `src/app/pp/deploy-providers/page.tsx` — page heading
   - `src/app/pp/repos/page.tsx` — page heading
   - `src/app/pp/settings/page.tsx` — page heading
   - `src/app/activity/page.tsx` — page heading
   - `src/app/audit/page.tsx` — page heading
   - `src/app/account/page.tsx` — page heading
   - `src/app/companies/page.tsx` — page heading
   - `src/components/ui/empty-state.tsx` — the `h3` title
   - `src/app/auth/signin/page.tsx` — sign-in heading
   - `src/app/install/complete/` — success heading

### Section Labels → `font-mono` (JetBrains Mono)
Apply `font-mono` to uppercase section labels:
1. **Sidebar section labels** (`src/components/layout/sidebar.tsx`) — "DEPLOY GATE" and "ADMIN" labels (the `<p>` elements with `uppercase tracking-wider`)
2. **Stat card labels** in `src/app/pp/page.tsx` — small uppercase labels above numbers
3. **Timestamp displays** — any relative time display (e.g. "3m ago", "2h ago") should use `font-mono`
4. **ID/SHA displays** — commit SHAs, request IDs, API key prefixes

### Do NOT Change
- Body text (stays Inter)
- Button text (stays Inter)
- Navigation items (stays Inter)
- Demo pages (already correct)
- Marketing pages (separate design)

## User Journey
1. User opens dashboard → sees Space Grotesk headlines contrasting with Inter body text
2. User scans sidebar → section labels in monospace feel "terminal-chic"
3. User views deploy request → timestamps and SHAs in monospace, headings in Space Grotesk

## Implementation Notes
- `font-headline` is already defined in `tailwind.config.ts` mapping to `'Space Grotesk', sans-serif`
- `font-mono` is already defined mapping to `'JetBrains Mono', monospace`
- Google Fonts import in `globals.css` already includes Space Grotesk and JetBrains Mono
- This is purely additive className changes — no structural changes

## Verification
- `grep -rn "font-headline" src/ | wc -l` should return 15+ (currently 0)
- `next build` passes
- No layout shifts or text overflow from font change (Space Grotesk is slightly wider than Inter)

## Customer Test
"Does the app feel like a premium developer tool or a generic SaaS dashboard?" — Space Grotesk headlines are the fastest path to "premium."
