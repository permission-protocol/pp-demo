# Xdares Deep Dive - Architecture & Codebase Analysis

**Date:** 2026-02-02  
**Repo:** ~/Xdares

## Executive Summary

Xdares is a production-grade 18+ dare-based creator platform with sophisticated infrastructure. It's not a toy - it's a real marketplace with escrow, video processing, and proper state management.

## Tech Stack

### Frontend
- **Framework:** React 18 + TypeScript
- **Build:** Vite
- **Styling:** Tailwind CSS 4 + Framer Motion
- **State:** Firebase SDK direct + 81 custom hooks
- **Scale:** 150 components, 62 pages

### Backend
- **Runtime:** Firebase Cloud Functions Gen2
- **Database:** Firestore (70+ collections)
- **Payments:** Stripe Connect (escrow, payouts, subscriptions)
- **Storage:** Firebase Storage + HLS video processing
- **AI:** Genkit with Google AI (Gemini)
- **Notifications:** FCM + Email (Postmark) + SMS (Twilio)

## Core Data Model

### Primary Collections
- `users` - User profiles, preferences, presence
- `dares` - Dare documents with unified v1/v2 schema
- `wallets` - User wallets (depositBalance, escrowBalance, winningBalance)
- `feedz` - Social feed posts
- `chat_sessions_v2` - Chat threads
- `subscriptions` - Creator subscriptions
- `waitlist_leads` - KickoffLabs integration

### Wallet Structure
```
wallets/{userId}
  - depositBalance: credits added via Stripe
  - escrowBalance: credits locked for active dares
  - winningBalance: earnings from completed dares
  - balance: total available (deposit + winning)
```

## Dare State Machine

### States
```
initiated → accepted/declined → proofSubmitted → 
revisionRequested → proofAccepted/proofRejected → 
escalated → expired/cancelled
```

### Key Files
- `shared/dareTransitions.ts` - Canonical transitions, roles, validators
- `shared/models/dare-unified.ts` - Unified schema (v1/v2 compatible)
- `api/functions/src/dareStateMachine.ts` - Server-side mutation engine

### Features
- Monotonic revision counter for optimistic locking
- Idempotent transitions via UUIDv7 transitionId
- Actor role validation (sender/receiver/system/admin)
- Automatic deadline calculation
- Outbox pattern for side effects

## Payment Flow

### Deposit → Escrow → Payout
1. User deposits via Stripe Checkout → `depositBalance`
2. User creates dare → funds move to `escrowBalance`
3. Dare completed → funds release to recipient's `winningBalance`
4. Creator requests payout → Stripe Connect transfer

### Key Files
- `api/functions/src/stripe.ts` - Stripe integration
- `api/functions/src/services/escrow.service.ts` - Escrow operations
- `api/functions/src/admin/paymentsAdmin.ts` - Reconciliation

### Safety Features
- Idempotency guards via `unique` collection
- Audit logging for all balance changes
- Reconciliation scheduler
- Held payouts for manual review

## Video Processing

### Flow
1. User records in-app → raw video uploaded to Storage
2. `onObjectFinalized` trigger starts processing
3. FFmpeg adds overlays, captions, filters
4. HLS transcoding for streaming
5. Thumbnail generation
6. Update dare/feedz documents

### Key Files
- `api/functions/src/dareProofProcessor.ts` - Main processor
- `api/functions/src/storage/validateRecording.ts` - Upload validation

## Notification System

### Channels
- **Push:** FCM (web/mobile) + OneSignal
- **Email:** Postmark transactional
- **SMS:** Twilio
- **In-App:** Firestore-backed

### Features
- Per-channel preferences
- Quiet hours (timezone-aware)
- Rate limiting (hourly/daily caps)
- Collapse keys for batching
- Mute targets (dare/user/thread)

## Waitlist System

### KickoffLabs Integration
- Webhook creates `waitlist_leads` documents
- Two-tier points: `waitlist_points` (access) + `legend_points` (prize)
- Referral tracking via `referrer_id`
- Instant access at threshold (4 points)
- Invite codes generated per-lead

## Events/Outbox Pattern

### Structure
```typescript
interface OutboxEvent {
  id: string;
  dareId: string;
  transitionId: string;
  type: OutboxEventType;
  status: 'pending' | 'processing' | 'done' | 'dead';
  attempts: number;
}
```

### Flow
1. State machine writes dare + outbox event atomically
2. `outboxPump` processes pending events
3. Consumers handle side effects (notifications, analytics)
4. SLO monitor alerts on stale events

## Admin System

### Features
- Feature flags per environment
- Emergency rollback
- Batch migrations
- Payment reconciliation
- Index health monitoring
- User diagnostics

### Key Endpoints
- `getOpsOverview` - Operational dashboard
- `getGrowthOverview` - Growth metrics
- `statusHeartbeat` - Health check
- `auditPaymentSystems` - Payment audit

## Positioning (from POSITIONING_BIBLE.md)

### Core Message
> "Social media is boring because everyone's faking it. Xdares is where people actually do something – and get paid for it."

### Tagline
> "Prove it. Get paid."

### Audience
- **Creators:** "Turn your boldness into income"
- **Fans:** "Pay to see it done – exactly how you asked"

## Identified Gaps (from Rod's analysis)

1. **No self-sustaining cycle** - Creators need participants, participants need creators
2. **Activation friction** - Onboarding, proof submission UX
3. **Weak viral loop** - Waitlist is lead capture, not flywheel
4. **Feedback loop** - Doesn't compel repeat use yet

## Code Quality Observations

### Strengths
- Well-architected state machine with proper validation
- Comprehensive error handling and logging
- Idempotency throughout payment flows
- Good separation of concerns (services, consumers, triggers)
- Extensive documentation in `/docs`

### Opportunities
- Some deprecated code still present (v1 references)
- Multiple notification providers (FCM + OneSignal) could be consolidated
- Large files could be split (dareProofProcessor.ts is 1000+ lines)

---

*This document captures my initial deep dive. Will update as I learn more.*
