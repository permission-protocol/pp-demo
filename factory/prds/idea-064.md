# PRD: idea-064 — Contact Form Submit Confirmation

**Issue:** permission-protocol/site#205
**Priority:** P3 (bug)
**Repo:** permission-protocol/site
**Size:** S

## Problem
The contact form at `/contact` shows a success banner when submitted, but the form stays visible below it. User fills out the form, hits send, sees a small green bar but the form is still there — confusing. No clear "done" state.

## Current State
- `app/contact/ContactPageClient.tsx` has `submitted` state that shows a CheckCircle2 banner
- Form renders regardless of `submitted` state
- Button shows "Sending..." during submission (good)
- Error state exists (good)

## Fix Required
When `submitted === true`:
1. **Hide the form** — replace it entirely with a full success state
2. **Success state should include:**
   - Large check icon (reuse CheckCircle2 from lucide)
   - "Thanks, {name}! We'll be in touch within 24 hours."
   - "What Happens Next" section stays visible below
   - "Submit another" link that resets form
3. **Keep the existing error handling** — no changes needed there

## User Journey
1. User fills out contact form
2. Clicks "Send" → button shows "Sending..."
3. **Success:** Form disappears, replaced by clear confirmation with next steps
4. **Error:** Red error text appears, form stays for retry

## Files to Change
- `app/contact/ContactPageClient.tsx` — conditional render: form vs success state

## What NOT to Change
- API route (`app/api/contact/route.ts`) — works fine
- Form fields or validation
- Styling system / design tokens
