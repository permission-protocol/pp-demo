# Xdares - Project Notes

**URL:** https://xdares.com  
**Repo:** git@github.com:Roca-Ventures/Xdares.git (cloned to ~/Xdares)  
**Tagline:** "The best place on the web for dares — to send dares, and for creators to earn money doing dares."

## Architecture

### Frontend (app/)
- **Stack:** React 18 + Vite + Tailwind CSS 4 + Framer Motion
- **Scale:** 150 components, 81 hooks, 62 pages
- **State:** Firebase SDK direct + custom hooks

### Backend (api/functions/)
- **Runtime:** Firebase Cloud Functions Gen2
- **Database:** Firestore
- **Payments:** Stripe Connect (escrow + payouts)
- **Storage:** Firebase Storage (video HLS processing)
- **AI:** Genkit with Google AI (Gemini)

### Shared (shared/)
- Unified dare model (v1/v2 compatible)
- State machine with transitions
- Outbox pattern for events
- Type definitions

## Dare State Machine

States: initiated → accepted/declined → proofSubmitted → revisionRequested → proofAccepted/proofRejected → escalated → expired/cancelled

Key files:
- `shared/dareTransitions.ts` - Canonical state transitions
- `shared/models/dare-unified.ts` - Unified schema
- `api/functions/src/dareStateMachine.ts` - Backend implementation

## Environments

- **Dev:** `firebase use dev`
- **Prod:** `firebase use prod`
- Deploy: `npm run build:dev` or `npm run build:prod`

## Key Docs

- `docs/XDARES_POSITIONING_BIBLE.md` - Positioning strategy
- `docs/DARE_STATE_MACHINE_CONTRACTS.md` - State machine contracts
- `docs/operational-runbooks/` - Ops guides

## Current State (from ChatGPT analysis)

**Working:**
- Full dare lifecycle
- Stripe Connect escrow + payouts
- Video proof with HLS
- Feed, reactions, social features
- SEO foundations

**Gaps:**
- No self-sustaining creator/participant cycle
- Activation friction
- Viral loop weak
- Waitlist is just lead capture

## Priorities

Rod's Hook Model focus:
1. **Triggers** - Notifications, referrals, daily prompts
2. **Actions** - Streamlined dare creation, video UX
3. **Rewards** - Social feedback, points, badges
4. **Investment** - Payouts, follows, profiles

## AI Integration Roadmap

1. AI Dare Suggestions
2. Performance Referee
3. Personalized Feed
4. Challenge Coach
5. Creator Concierge
6. Fan Companion Chatbot
7. Safety Moderation

---

*Updated: 2026-02-02*
