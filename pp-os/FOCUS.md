# PP FOCUS — Corrected March 16 → April 4, 2026

## What Happened (Days 1-8)
We drifted. Built a review application (dashboards, mobile UX, filter pills, approval presets) instead of the primitive. Productive but wrong layer. Sunk cost accepted. Moving on.

## The Mission (Unchanged)
**No AI agent deploys code without Permission Protocol.**

## The Strategy (Corrected)
**PP = primitive. Like Stripe.** One integration wraps an agent action in an authority receipt. The developer's existing workflow doesn't change. The app is an enterprise upgrade later — not the product now.

## The Filter (Tightened)
Before doing ANYTHING, ask: **Does this make the primitive work for a real user on their repo?**
- YES → do it
- NO → don't touch it
- "But the app needs..." → NO

## What's IN (Days 9-28)
### Week 1: Make It Real (Mar 17-21)
- [ ] deploy-gate Action works silently on a stranger's repo (install → first gated PR in 5 min)
- [ ] Notification flow: gate fires → human gets pinged (Slack/email/CLI) → approves without opening a dashboard
- [ ] AI summary good enough that human doesn't need to read the diff
- [ ] `pp.gate()` SDK call documented and working
- [ ] Onboarding: GitHub App install → done. No manual secrets, no config files.

### Week 2: Ship It (Mar 22-28)
- [ ] 60-second demo video: agent PR → gate → approve from phone → receipt → merged
- [ ] 1 real external user running it on their repo
- [ ] Show HN post
- [ ] "Why this exists" content tied to Clinejection / agent safety narrative

### Week 3: Prove It (Mar 29-Apr 4)
- [ ] 5 external users with deploy-gate installed
- [ ] 1 user has completed the full loop (agent → gate → approve → deploy)
- [ ] Iterate based on real feedback
- [ ] Decision: double down or pivot

## What's OUT (Frozen)
- App dashboard work (any UX, mobile, polish)
- New app features not on the list above
- Marco/Sarah persona specs (informational, not buildable right now)
- NIST submissions
- Scout pipeline
- Xdares work
- Newsletter
- Mobile-first approval phases 3-4

## Board Cleanup
These items should move to Backlog/frozen:
- "Deploy Request Page Mobile UX Revamp" → Backlog
- "Blog post" → Backlog (unless it's the Clinejection piece)
- "Dead man's switch" → Backlog
- "NIST RFI" → Backlog (missed deadline anyway)
- "Mobile-First Phase 3 & 4" → Backlog

These items are the sprint:
- "Create 60-second demo video/GIF" → Ready
- "Create design partner quick-start guide" → Ready
- "Draft and send 5 personalized outreach messages" → Ready (unblock it)

## Charles's Job
Same as before but meaner about it. If work isn't on this list, stop it. Flag drift within 1 message, not 8 days.

## Success = One Real User
Everything else is vanity. One person who isn't us, running deploy-gate on their repo, approving an agent PR, getting a receipt. That's the only metric that matters by April 4.
