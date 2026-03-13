# PRD: Analytics Pipeline — Know Who's Coming and What They Do

**Status:** Draft
**Priority:** High — every day without this is blind flying
**Thread:** #analytics

---

## Problem

We have PostHog on the site and some basic event tracking, but critical gaps mean we can't answer basic questions:

1. **Contact form is broken** — `handleSubmit` sets state to "submitted" but never calls an API. Zero data captured. Every lead that fills this form gets a "thanks!" and we get nothing.
2. **No UTM tracking** — Outreach links, LinkedIn posts, blog shares all land without attribution. Can't tell what's working.
3. **No contact/demo notifications** — Subscribe form pings Discord, but the contact form (our highest-intent surface) doesn't.
4. **No session recordings** — PostHog supports this out of the box, just not enabled.
5. **App pages have no event tracking** — Only blog posts and the landing page have `data-track` attributes. Review dashboard, pricing, how-it-works are dark.

## What Exists Today

| Component | Status |
|-----------|--------|
| PostHog JS snippet | ✅ Loaded in layout.tsx |
| `pp_page_view` / `pp_page_exit` events | ✅ In main.js (landing page only) |
| `pp_section_viewed` scroll tracking | ✅ Landing page sections |
| `pp_demo_view` / `pp_demo_complete` | ✅ Terminal demo |
| Blog CTA `data-track` clicks | ✅ `pp_nav_cta_click`, `pp_blog_deploygate_*` |
| Email subscribe → Discord webhook | ✅ `/api/subscribe` |
| Contact form submission | ❌ **Dead — no API call** |
| Contact form → Discord notification | ❌ Missing |
| Contact form → PostHog event | ❌ Missing |
| UTM parameter capture | ❌ Missing |
| Session recordings | ❌ Not enabled |
| Next.js app page tracking | ❌ Only static pages tracked |

## Implementation Plan (5 Issues, Sequential)

### Issue 1: Fix Contact Form — Wire to API + Discord Alert
**Priority:** CRITICAL — this is losing leads right now

- Create `/api/contact/route.ts`:
  - Validate fields (name, email, company, useCase, environment, message)
  - POST to Discord webhook (new `DISCORD_CONTACT_WEBHOOK` env var) with rich embed
  - Fire PostHog server-side event `pp_contact_submit` with all fields
  - Return success/error
- Update `ContactPageClient.tsx`:
  - Call `/api/contact` on submit instead of just setting state
  - Add loading state and error handling
  - Fire client-side `posthog.capture('pp_contact_form_submit')` on success
- Create Discord webhook for `#rc-alerts` channel

**Acceptance:**
- Fill contact form → see Discord alert in #rc-alerts within 5s
- PostHog shows `pp_contact_form_submit` event with all form fields
- Error states handled (network failure, validation)

### Issue 2: UTM Parameter Capture
**Priority:** High — attribution for all outreach

- Create `lib/utm.ts` utility:
  - On page load, read `utm_source`, `utm_medium`, `utm_campaign`, `utm_content`, `utm_term` from URL
  - Store in `sessionStorage` (persist across page navigations)
  - Expose `getUtmParams()` helper
- Update PostHog initialization in `layout.tsx`:
  - Set UTM params as PostHog person properties via `posthog.register()` on first visit
  - Include UTM in all subsequent events automatically
- Update `/api/contact` and `/api/subscribe`:
  - Accept optional UTM fields from client
  - Include in Discord webhook embeds

**Acceptance:**
- Visit `permissionprotocol.com?utm_source=linkedin&utm_campaign=deploy-gate` → PostHog person shows UTM properties
- Contact form submission includes UTM attribution in Discord embed
- UTM persists across page navigations within same session

### Issue 3: Enable Session Recordings
**Priority:** Medium — see what visitors actually do

- Update PostHog init config in `layout.tsx`:
  ```js
  posthog.init('phc_...', {
    api_host: 'https://us.i.posthog.com',
    person_profiles: 'identified_only',
    session_recording: {
      recordCrossOriginIframes: false,
    },
    capture_pageview: false, // we fire custom pp_page_view
    capture_pageleave: false, // we fire custom pp_page_exit
  })
  ```
  Note: `session_recording` may need to be enabled in PostHog project settings too (check dashboard)
- Add `maskAllInputs: true` for privacy on form fields (except email which we already capture)

**Acceptance:**
- PostHog Recordings tab shows new session replays
- Form inputs are masked in recordings
- No performance degradation (test Lighthouse before/after)

### Issue 4: Next.js App Page Event Tracking
**Priority:** Medium — currently blind on React pages

- Create `components/PostHogPageView.tsx`:
  - Use `usePathname()` + `useSearchParams()` from next/navigation
  - Fire `posthog.capture('$pageview')` on route change
  - Include pathname, referrer, UTM params
- Add to `providers.tsx` or `layout.tsx` as a client component
- Add `data-track` attributes to key CTAs across app pages:
  - Pricing page CTA buttons
  - How-it-works CTA
  - Review dashboard actions (if public-facing)
  - Navigation CTAs

**Acceptance:**
- Navigate between Next.js pages → PostHog shows pageview for each
- CTA clicks on pricing, how-it-works tracked with descriptive event names
- Works with both hard navigations and client-side transitions

### Issue 5: PostHog Funnels + Dashboard Setup
**Priority:** Medium — make sense of all the data

This is PostHog dashboard config, not code:
- Create funnel: Landing Page → Section Scroll → CTA Click → Contact Form View → Contact Submit
- Create funnel: Blog Post → CTA Click → Landing Page → Contact
- Create dashboard: "PP Weekly" with:
  - Unique visitors (daily/weekly)
  - Top pages by views
  - Top referrers
  - Contact form conversion rate
  - UTM campaign performance
  - Session recording count
- Set up weekly email digest to Rod

**Acceptance:**
- Funnels visible in PostHog
- Dashboard shows all key metrics on one screen
- Weekly digest delivers

---

## Out of Scope (Future)
- CRM integration (HubSpot, etc.) — not needed at current volume
- A/B testing — premature
- Custom PostHog reverse proxy (for ad blockers) — nice to have later
- Identify known contacts across sessions — after we have actual contacts

## Notes
- PostHog free tier: 1M events/mo, 5K session recordings/mo — more than enough
- All events should use `pp_` prefix for easy filtering
- Privacy: no PII in events except email (which user explicitly submits)
