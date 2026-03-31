# Separate Demo Mode — Refined Spec (2A)

## Status Quo

The current demo lives at `/demo/deploy-requests/[requestId]` — it's a stripped-down version of the real review page. It still:
- Requires a live DB-backed deploy request (fetched via API)
- Wraps in the full AppShell (sidebar, header, dashboard chrome)
- Has a production confirmation checkbox + generic "Approve for production" button
- Shows a receipt card after approval, but no emotional pivot or CTA to install
- Doesn't work as a standalone entry point (you need a valid `requestId`)

**This rewrite creates a fully static, self-contained `/demo` route that works without a database, without auth, and without any product chrome.**

---

## What Changed from Rod's Spec

### Kept as-is
- Route structure, demo layout, fixture data model, session model, screen copy, non-goals, safety requirements, build order

### Improved

1. **AppShell bypass** — The root `layout.tsx` wraps everything in `<AppShell>` (sidebar + header). Current bypass only checks `/auth/`. The fix: update `AppShell` to also skip `/demo` paths, **and** add a dedicated `src/app/demo/layout.tsx` that provides the minimal demo chrome. This is a 2-line change + new layout file.

2. **No server-side session needed for the happy path** — Rod's spec calls for a server-side cookie session with TTL. That adds API surface, cookie management, and an expiry edge case. **Simpler:** Use client-side `sessionStorage` for demo state. The fixture is static. The "approve" action is local (no POST needed). The only server call is the deep-link CTA at the end. If we want tracking, a lightweight `POST /api/demo/track` can fire-and-forget on approve/CTA-click without blocking the UX.

3. **Fixture is 100% static, rendered at build time (SSG)** — No `useEffect` fetch. No loading spinner. No client-side state machine for data loading. The page renders instantly. The only client interaction is the approve click (state transition) and the CTA click (navigation). This guarantees LCP < 1s, not 1.5s.

4. **Mobile-first copy refinement** — Rod's screen 1 copy is great but slightly long for mobile above-the-fold. Collapsed the pill structure to one line (`LIVE DEMO • SIMULATED PRODUCTION DEPLOY`) to save vertical space. Moved the "Demo only" footer note into a subtle inline element so the CTA is higher on small screens.

5. **Rejection screen is worth building** — Rod marked it optional, but it's 20 minutes of work and completes the mental model: "approve = ship, reject = block." It makes the demo feel like a real decision, not a one-path funnel. Recommend including it.

6. **Deep-link CTA passes UTM params** — `?utm_source=demo&utm_medium=app&utm_campaign=demo_approval` on the GitHub App install link, so we can track demo→install conversion in PostHog.

7. **Added a `/demo` index redirect** — `/demo` itself should show the blocked deploy screen directly (no intermediate page). This means `src/app/demo/page.tsx` IS the blocked deploy screen, not a landing page.

---

## Route Structure (Final)

```
src/app/demo/
├── layout.tsx          # Minimal demo layout (no AppShell)
├── page.tsx            # Screen 1: Blocked deploy (static fixture)
├── approved/
│   └── page.tsx        # Screen 2: Post-approval realization
└── rejected/
    └── page.tsx        # Screen 3: Deploy blocked state

src/app/api/demo/
└── track/
    └── route.ts        # Lightweight event tracking (fire-and-forget)

src/lib/demo/
├── fixture.ts          # Static demo data
└── constants.ts        # Demo route constants, CTA URLs
```

### Files to modify
- `src/components/layout/app-shell.tsx` — Add `/demo` to bare-render paths
- Remove or keep old `/demo/deploy-requests/[requestId]/*` routes (recommend: keep for now, they serve live demo PRs from pp-demo repo)

---

## Demo Data Fixture

```typescript
// src/lib/demo/fixture.ts
export const DEMO_REQUEST = {
  id: 'demo-pr-35',
  repo: 'acme-corp/payments-api',  // Use a realistic-sounding repo, not our own
  prNumber: 35,
  title: 'DEPLOY TO PRODUCTION — Delete user data migration',
  branch: 'feat/purge-inactive-users',
  environment: 'production',
  risk: 'high' as const,
  commitSha: 'a1b2c3d',
  author: 'dependabot[bot]',  // Extra tension: a bot authored this
  summary: [
    'Drops inactive_users table (irreversible)',
    'Deletes 12,847 user records',
    'Runs in production — no staging gate',
  ],
  changedFiles: [
    'migrations/20260329_purge_users.sql',
    'src/jobs/cleanup.ts',
    'config/retention-policy.yaml',
  ],
} as const;
```

**Changes from Rod's spec:**
- Repo is `acme-corp/payments-api` instead of `pp-demo` — feels like a real org, not our test repo
- Author is `dependabot[bot]` — adds "who approved this bot PR?" tension
- Summary items are more specific and scarier (table drop, record count, no staging)
- Added `changedFiles` for the visual diff preview card
- Added `branch` for realism

---

## Screen 1: Blocked Deploy (`/demo`)

### Layout
- **No sidebar, no header, no footer** — just the demo layout
- Dark background (`#0a0a0a`), centered card, max-width ~640px
- Mobile: full-width with padding

### Content (top to bottom)

1. **Demo pill bar** (fixed top, subtle)
   ```
   [PP Logo] LIVE DEMO • SIMULATED PRODUCTION DEPLOY
   ```

2. **Risk badges** (inline, left-aligned)
   ```
   [🔴 HIGH RISK]  [⚡ PRODUCTION]  [🤖 BOT-AUTHORED]
   ```

3. **Title** (large, white, bold)
   ```
   Delete user data migration
   ```

4. **Subtitle** (muted)
   ```
   PR #35 → production • awaiting human signer
   ```

5. **Summary card** (bordered, visible — NOT an accordion)
   ```
   ⚠️ What this deploy does:
   • Drops inactive_users table (irreversible)
   • Deletes 12,847 user records  
   • Runs in production — no staging gate
   
   Changed files:
   migrations/20260329_purge_users.sql
   src/jobs/cleanup.ts
   config/retention-policy.yaml
   ```

6. **Warning block** (amber background)
   ```
   You are approving a production deploy.
   The approver becomes the signer of record.
   ```

7. **Primary CTA** (large, full-width on mobile, amber/red)
   ```
   [Approve & Sign]
   ```

8. **Secondary** (small text link below CTA)
   ```
   Reject deploy
   ```

9. **Footer note** (very subtle, inline)
   ```
   Demo only — no real systems affected
   ```

### Behavior
- Click "Approve & Sign" → client-side navigate to `/demo/approved`
- Click "Reject deploy" → client-side navigate to `/demo/rejected`
- Fire `POST /api/demo/track` with `{ event: 'demo_approve' | 'demo_reject', timestamp }` (non-blocking)

---

## Screen 2: Approved (`/demo/approved`)

### Content

1. **Demo pill bar** (same as screen 1)

2. **Success icon** (large green check, animated entrance)

3. **Headline** (large, white)
   ```
   Approved. This deploy would now ship to production.
   ```

4. **Realization block** (bordered card, key moment)
   ```
   Without Permission Protocol, this deploy would have gone 
   straight to production.
   
   • A bot-authored PR that drops a user table
   • No human reviewed the risk
   • No signed record of who approved it
   
   Every team ships a bad deploy eventually.
   The question is whether anyone signed off on it.
   ```

5. **Signed receipt preview** (dark card, mono font — this IS the product)
   ```
   ─── AUTHORITY RECEIPT ───
   
   Action:     Deploy to production
   Signer:     You (demo)
   Decision:   APPROVED
   Signed at:  [current timestamp]
   Receipt ID: pp_rcpt_demo_[random]
   Algorithm:  Ed25519
   
   This receipt is cryptographically signed and immutable.
   In production, it becomes your audit trail.
   ```

6. **Action bridge**
   ```
   Protect your production repos the same way.
   ```

7. **Primary CTA** (green, prominent)
   ```
   [Select a production repo →]
   ```
   Links to: `https://github.com/apps/permission-protocol/installations/select_target?utm_source=demo&utm_medium=app&utm_campaign=demo_approval`

8. **Secondary** (small text)
   ```
   Takes ~30 seconds. No code changes.
   ```

9. **Tertiary link**
   ```
   Run demo again
   ```

---

## Screen 3: Rejected (`/demo/rejected`)

### Content

1. **Demo pill bar**
2. **Shield icon** (blue/white)
3. **Headline**: `Deploy blocked.`
4. **Body**: `This is what governance looks like. No signer approved production — the deploy stays gated.`
5. **Same CTA bridge** as approved screen
6. **"Run demo again" link**

---

## Technical Notes

### AppShell bypass
```typescript
// src/components/layout/app-shell.tsx
const isBarePage = pathname?.startsWith('/auth/') || pathname?.startsWith('/demo');
```

### Demo layout
```typescript
// src/app/demo/layout.tsx
export default function DemoLayout({ children }) {
  return (
    <div className="min-h-screen bg-[#0a0a0a] text-white">
      {/* Minimal header */}
      <header className="fixed top-0 z-50 w-full border-b border-white/5 bg-[#0a0a0a]/80 backdrop-blur px-4 py-2">
        <div className="mx-auto flex max-w-2xl items-center gap-2">
          <Shield className="h-5 w-5 text-emerald-400" />
          <span className="text-sm font-medium">Permission Protocol</span>
          <span className="rounded-full bg-amber-500/20 px-2 py-0.5 text-[10px] font-medium tracking-wide text-amber-300">
            LIVE DEMO
          </span>
          <span className="text-[10px] text-white/30">•</span>
          <span className="text-[10px] text-white/40 tracking-wide">
            SIMULATED PRODUCTION DEPLOY
          </span>
        </div>
      </header>
      <main className="pt-12">{children}</main>
    </div>
  );
}
```

### Tracking endpoint (lightweight)
```typescript
// src/app/api/demo/track/route.ts
export async function POST(req: NextRequest) {
  const { event, meta } = await req.json().catch(() => ({}));
  // Fire to PostHog or log — non-blocking
  // Could also increment a simple counter in the DB
  return NextResponse.json({ ok: true });
}
```

### No DB dependency
The entire `/demo` flow renders from the static fixture. No Prisma calls. No deploy request lookup. This means:
- Works even if the DB is down
- No race conditions with demo PR creation
- Instant load (SSG-eligible)
- The existing `/demo/deploy-requests/[requestId]` routes continue working for live demo PRs

---

## Acceptance Criteria (same as Rod's, with additions)

- [ ] Fresh incognito desktop: `/demo` loads blocked deploy immediately
- [ ] Fresh mobile Safari: "Approve & Sign" visible without scroll  
- [ ] User reaches approved screen in one tap
- [ ] No auth/install/setup before approved screen
- [ ] Approved screen CTA opens GitHub repo selector
- [ ] No dashboard chrome anywhere in demo path
- [ ] Rejected screen works and has CTA to install
- [ ] Page is SSG (no loading spinners, no fetch waterfalls)
- [ ] LCP < 1s on 4G mobile
- [ ] Tracking events fire on approve/reject/CTA click
- [ ] Existing `/demo/deploy-requests/[requestId]` routes still work

---

## Build Order

1. **AppShell bypass** — 2-line change in `app-shell.tsx`
2. **Demo layout** — `src/app/demo/layout.tsx`  
3. **Fixture + constants** — `src/lib/demo/fixture.ts`, `constants.ts`
4. **Blocked deploy screen** — `src/app/demo/page.tsx`
5. **Approved screen** — `src/app/demo/approved/page.tsx`
6. **Rejected screen** — `src/app/demo/rejected/page.tsx`
7. **Tracking endpoint** — `src/app/api/demo/track/route.ts`
8. **Mobile QA** — incognito + Safari viewport test
9. **Cold-user test** — 3/5 can explain the product after one pass

---

## Codex Execution Plan

### Phase 1: Single Codex agent

**Prompt:**
Build a self-contained demo mode at `/demo` per the spec. Key constraints:
- Bypass AppShell for `/demo` paths (update `src/components/layout/app-shell.tsx`)
- Create dedicated demo layout at `src/app/demo/layout.tsx` — minimal, no product chrome
- Static fixture at `src/lib/demo/fixture.ts` — no DB calls
- Three screens: `/demo` (blocked deploy), `/demo/approved`, `/demo/rejected`
- Client-side navigation between screens (no server round-trips for state)
- All copy/content per the spec
- Mobile-first: CTA above fold on 375px viewport
- Dark theme (#0a0a0a background)
- Do NOT modify or remove existing `/demo/deploy-requests/` routes

**Working directory:** Fresh clone of `permission-protocol/app` at `/tmp/pp-demo-mode`

### Phase 2: Visual QA
- Screenshot `/demo` at desktop (1280px) and mobile (375px) viewports
- Screenshot `/demo/approved` at both viewports
- Verify no sidebar/header chrome bleeds through
- Verify CTA placement on mobile

### Phase 3: Cold-user review
- Show screenshots to Rod for gut-check before merge
