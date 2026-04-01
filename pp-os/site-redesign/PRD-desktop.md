## Permission Protocol Homepage Redesign Product Requirements Document (PRD)

**Project Title:** Permission Protocol Homepage Redesign
**Version:** 1.0
**Date:** October 26, 2023
**Author:** [Your Name/Role]

---

### 1. Executive Summary

This document outlines the requirements for a comprehensive redesign of the Permission Protocol homepage. The primary goal is to significantly improve the start of real-product onboarding (GitHub/install, "Protect 1 repo free" clicks) by optimizing for understanding, trust, and low-friction next steps. The redesign addresses the current problem where the page prioritizes visual mood over clear product explanation, setup speed, and proof. The new structure will answer critical user questions in a logical order, surface key information above the fold, and maintain a dark, technical, premium visual aesthetic.

---

### 2. Project Goals

The redesign aims to maximize:

**Primary KPIs (Start of Real-Product Onboarding):**
*   GitHub/install click-through rate
*   “Protect 1 repo free” click-through rate

**Secondary KPIs (Intent and Education):**
*   Demo starts
*   Demo completions
*   Quickstart clicks
*   Live receipt clicks
*   Pricing clicks
*   Request-access clicks

**Overall Objective:** Optimize for understanding, trust, and low-friction next steps, not solely visual mood.

---

### 3. Problem Statement & Core Strategy

**Current Problem:** The existing homepage is visually strong but fails to explain the product category, setup speed, and proof points effectively in the initial view. It introduces scary scenarios before basic product legibility.

**Core Strategy:** The new homepage must answer the following questions in this exact order to build understanding and trust efficiently:
1.  What is this?
2.  What risky actions does it control?
3.  How does it work?
4.  Why should I trust it?
5.  How fast can I try it?
6.  What does it cost?
7.  What should I do next?

The redesign must make the product "legible" within the first screen.

---

### 4. Target Audience

The primary target audience consists of developers, technical decision-makers, and teams managing AI and automation systems who need to implement robust approval and audit mechanisms for irreversible actions.

---

### 5. Product Positioning & Messaging

**Positioning Statement:** Permission Protocol is the approval and receipt layer for irreversible AI and automation actions.

**Plain-English Framing:** It blocks risky actions until a human or policy decision authorizes the exact request, then returns a signed receipt that systems can verify before execution.

This messaging must be consistent across the homepage, how-it-works page, quickstart, and pricing.

---

### 6. Scope: What to Keep & What to Change

**Keep:**
*   Dark, premium visual language
*   Live demo as the main top-of-funnel CTA
*   Receipt visual / signed-proof concept
*   Use cases for deploys, sensitive data, money movement, and high-risk tool calls
*   GitHub-first motion

**Change:**
*   Replace vague first-screen messaging with explicit product/category clarity.
*   Bring setup speed, free entry point, and proof points above the fold.
*   Remove tiny, low-contrast helper copy under CTAs.
*   Merge overlapping “In 15 seconds” and “How it works” concepts into a tighter flow.
*   Add pricing snapshot and objection handling before the final CTA.
*   Add a sticky mobile CTA.

---

### 7. Proposed Homepage Structure & Content

**Required Section Order:**
1.  Sticky Nav
2.  Hero with live visual
3.  Proof bar
4.  3-step approval flow
5.  Signed proof / comparison section
6.  Quickstart / implementation section
7.  Use cases
8.  Pricing snapshot
9.  FAQ / objections
10. Final CTA
11. Footer

**Visibility Requirement:** By 50% scroll, the visitor should have already seen:
*   What the product is
*   How it works
*   What proof it creates
*   How fast it is to try
*   How much it costs

---

#### 7.1. Section 1 — Sticky Nav

*   **Desktop Nav Links:** How it works, Quickstart, Pricing, GitHub
*   **Right-side CTA:** Primary button: "Try live demo"
*   **Rules:**
    *   Keep nav sticky.
    *   Use light blur/background on scroll.
    *   Do not feature “Contact” in the main nav.
    *   “Log in” can stay, but de-emphasized.

#### 7.2. Section 2 — Hero

*   **Layout:**
    *   **Desktop:** 2-column layout, 5/7 or 6/6 split (Left = copy + CTAs; Right = animated product visual).
    *   **Mobile:** Stacked, copy first, visual second. The first mobile viewport must show headline, subhead, both CTAs, and at least 3 proof chips.
*   **Hero Copy:**
    *   **Eyebrow:** Signer of Record for AI Systems
    *   **Headline:** Stop AI agents from taking irreversible actions without human approval.
    *   **Subhead:** Permission Protocol blocks deploys, data access, payouts, and destructive tool calls until a signer approves the exact request and your system verifies a cryptographic receipt.
*   **CTAs:**
    *   **Primary CTA:** Try the live demo
    *   **Secondary CTA:** Protect 1 repo free
    *   **Tertiary Text Link:** Read the 5-minute quickstart
*   **Proof Chips (under CTA row):** 15-second demo · First receipt in 5 minutes · Free Developer plan · GitHub integration · Ed25519 receipts · &lt;200ms latency · MIT enforcement layer
*   **Small Helper Line (below proof chips):** Start with 1 repo. Scale to every agent.
*   **Hero Visual Spec:**
    *   Single composite visual demonstrating the whole value prop without needing scroll.
    *   **Frame 1: Blocked Action** (label: BLOCKED, action: deploy -> billing-service, agent: deploy-bot, policy: production-deploy)
    *   **Frame 2: Approval Decision** (named signer, approve/reject controls, exact request visible)
    *   **Frame 3: Verified Receipt** (receipt verified, signer shown, timestamp, policy, issuer)
    *   **Animation:** Slow loop (6–8 seconds), pause on hover desktop, static fallback for reduced motion.
*   **Hero Rules:**
    *   The current dramatic number-led headline can remain only as an A/B variant, not the default.
    *   Default hero must prioritize clarity over intrigue.
    *   Secondary CTA should not say “Install on GitHub.”

#### 7.3. Section 3 — Proof Bar

*   Immediately under hero, horizontal trust/proof strip. Heading not needed.
*   **Items:** Free Developer plan, Production from $300/org/month, GitHub integration, Ed25519 signatures, &lt;200ms median gate latency, MIT-licensed enforcement layer
*   **Behavior:** Desktop: inline chips; Mobile: horizontally scrollable chips. Each chip can optionally link to pricing, quickstart, or docs.
*   **Purpose:** To kill skepticism fast.

#### 7.4. Section 4 — Approval Flow

*   Replace current separate “In 15 seconds” and “How it works” sections.
*   **Section Heading:** See the approval flow in 15 seconds.
*   **Subhead:** Execution stays closed until the request is approved and the receipt is verified.
*   **3 Cards:**
    1.  **Title:** Blocked before execution. **Body:** Policy intercepts deploys, mutations, and destructive tool calls before they run.
    2.  **Title:** Human approves the exact request. **Body:** The approver sees the actor, action, target, and policy before deciding.
    3.  **Title:** Receipt verified by the pipeline. **Body:** The action executes only after a valid signed receipt is verified.
*   **Section CTA:** See a live receipt

#### 7.5. Section 5 — Signed Proof Section

*   Keep the current receipt section, upgrade message.
*   **Section Heading:** Signed proof, not logs.
*   **Subhead:** Logs tell you what happened. Receipts prove who authorized the exact action, when, and under which policy.
*   **Layout:** Desktop: comparison content left, receipt card right; Mobile: copy first, receipt card second.
*   **Comparison Content (3 tiles):**
    1.  **Label:** Slack / PR approval. **Text:** Human intent, but not machine-verifiable proof tied to execution.
    2.  **Label:** Audit logs. **Text:** Useful after the fact, but not an execution gate.
    3.  **Label:** Permission Protocol receipt. **Text:** Signed, portable, verifiable proof that the action was authorized before it ran.
*   **Receipt Card:** Refined version of current receipt visual. Preserve: action, approved by, policy, timestamp, verified signature, issuer.
*   **CTA below card:** View live receipt

#### 7.6. Section 6 — Quickstart / Implementation Section

*   Pull quickstart promise onto the homepage.
*   **Section Heading:** Add authority in 5 minutes.
*   **Subhead:** Wrap the action. Wait for approval. Verify the receipt.
*   **Layout:** Desktop: split layout (Left = step stack + code-style visual; Right = dashboard approval mockup).
*   **Step Stack (3 steps):**
    1.  Add `@require_approval` or `authorize()` around a risky action.
    2.  Permission Protocol creates the approval request and waits for a decision.
    3.  Verify the receipt before execution continues.
*   **CTAs:**
    *   **Primary CTA:** Read the quickstart
    *   **Secondary Text Link:** Get a free API key

#### 7.7. Section 7 — Use Cases

*   Make use-case section more concrete.
*   **Section Heading:** Built for high-impact actions.
*   **Subhead:** One primitive. Multiple policies.
*   **4 Cards:**
    1.  **Title:** Production deploys. **Body:** Require approval before code reaches protected branches.
    2.  **Title:** Sensitive data access. **Body:** Gate access to customer data and destructive queries until approved.
    3.  **Title:** Money movement. **Body:** Require sign-off before payouts, transfers, or refunds.
    4.  **Title:** High-risk tool calls. **Body:** Block destructive API calls and privileged automation.

#### 7.8. Section 8 — Pricing Snapshot

*   Homepage should surface pricing model.
*   **Section Heading:** Start free. Enforce when ready.
*   **Subhead:** Every plan starts the same way: add the guard, create the approval request, verify the receipt.
*   **Pricing Card 1 (Developer):**
    *   **Plan name:** Developer
    *   **Price:** Free
    *   **Use label:** For experimentation
    *   **Bullets:** Unlimited deploy gates, AI risk analysis, Receipt proof pages, GitHub integration
    *   **CTA:** Protect 1 repo free
*   **Pricing Card 2 (Production):**
    *   **Plan name:** Production
    *   **Price:** $300 / month / organization
    *   **Use label:** Full enforcement for teams
    *   **Bullets:** Production branch enforcement, Team approval workflows, Audit log and compliance export, Priority support, Custom policies
    *   **CTA:** Request access
*   **Enterprise Line:** Text link below cards: Need self-hosting, SSO, or multi-org federation? Talk to sales.
*   **Proof Chips (below pricing cards):** Ed25519 signatures · &lt;200ms median gate latency · MIT-licensed enforcement layer

#### 7.9. Section 9 — FAQ / Objections

*   This section is required to address basic objections.
*   **Section Heading:** Common questions
*   **6 FAQs (Q&A format):**
    1.  **Q:** How quickly can I try this? **A:** The live demo takes about 15 seconds, and the first authority receipt can be created in about 5 minutes.
    2.  **Q:** What proves the approval actually happened? **A:** Approved actions receive a cryptographically signed receipt. The pricing page specifies Ed25519 as the signature algorithm.
    3.  **Q:** Will this slow down pipelines? **A:** Pricing states median gate latency is under 200ms.
    4.  **Q:** Can I start without enforcing production branches? **A:** Yes. The free Developer plan is for experimentation, while production branch enforcement is part of the Production plan.
    5.  **Q:** Can I start small? **A:** Yes. Start with one repo, then scale to every agent.
    6.  **Q:** Is the enforcement layer open source? **A:** Pricing states the enforcement layer is MIT-licensed.

#### 7.10. Section 10 — Final CTA

*   Simple and decisive.
*   **Headline:** Try the approval flow now. Then protect a real repo.
*   **Subhead:** Start with one repo. Scale to every agent.
*   **Primary CTA:** Try the live demo
*   **Secondary CTA:** Protect 1 repo free
*   **Tertiary Link:** Need org-wide enforcement? Request access

#### 7.11. Footer

*   Standard links (e.g., Quickstart, Pricing, Contact, GitHub, Legal) and copyright information.

---

### 8. Design & Visual Requirements

**General Direction:**
*   Keep the current dark, technical, premium feel.
*   Use aqua/teal as the action color.
*   Use red only for risk, blocked state, or destructive emphasis.
*   Keep rounded cards and clean spacing.
*   Increase contrast on secondary copy.

**Typography:**
*   Headline style should feel crisp, not ornamental.
*   Avoid overly light gray body copy.
*   Mobile body text minimum: 16px.
*   Secondary labels minimum: 14px.
*   Line length desktop: max ~70 characters for body copy.

**Spacing:**
*   Desktop section padding: 88–112px top/bottom.
*   Mobile section padding: 48–64px top/bottom.
*   Remove dead vertical air between sections.
*   Reduce hero-to-next-section gap.

**Buttons:**
*   Primary button height: 52px desktop / 48px mobile.
*   Secondary button must visually read as important, not ghosted into irrelevance.
*   All buttons must have clear hover/pressed/focus states.

**Cards:**
*   Radius: 16px.
*   Borders: subtle, high-contrast enough to define grouping.
*   Use thin highlights, not heavy glows.
*   Receipt card should look more “verifiable system object” than “marketing card.”

**Motion:**
*   Light motion only.
*   No autoplay gimmicks.
*   Respect reduced-motion setting.
*   Hero animation should teach, not decorate.

---

### 9. Mobile-Specific Requirements

**Mobile Rules:**
*   **First viewport must show:** headline, subhead, primary CTA, secondary CTA, proof chips.
*   Use sticky bottom CTA after the user scrolls past hero.
    *   **Sticky CTA buttons:** Try demo, Start free.
*   Keep proof chips horizontally scrollable.
*   No paragraph longer than 3 lines on mobile where avoidable.
*   Use stacked cards, not cramped side-by-side layouts.
*   Do not bury pricing below the final CTA.

---

### 10. Content Rules

**Do:**
*   Use concrete verbs: block, approve, verify, enforce, sign.
*   Use concrete nouns: deploy, payout, customer data, receipt, policy, signer.
*   Explain the mechanism before making the user infer it.
*   Surface setup speed and pricing before the user has to go hunting.

**Do Not:**
*   Lead with abstract/security-theory language.
*   Use implementation copy like “Install on GitHub” as the main value message.
*   Make the user scroll multiple screens before understanding how the product works.
*   Bury pricing and quickstart benefits on other pages.

---

### 11. Tracking & Analytics Requirements

**Required Events (for GA4/Amplitude):**
*   `hero_demo_click`
*   `hero_start_free_click`
*   `hero_quickstart_click`
*   `proofbar_pricing_click`
*   `live_receipt_click`
*   `quickstart_click`
*   `pricing_start_free_click`
*   `pricing_request_access_click`
*   `faq_expand` (for each FAQ item)
*   `final_demo_click`
*   `final_start_free_click`

**Additional Tracking:**
*   Scroll depth: 25%, 50%, 75%
*   `demo_start`
*   `demo_completion`
*   `post_demo_install_click`
*   `homepage_to_pricing_click`
*   `homepage_to_quickstart_click`

**Primary Optimization Target:** Install/start-free rate, not raw CTR.

---

### 12. Acceptance Criteria

The redesign is not done unless all of the below are true:
*   A first-time visitor can explain what the product does in under 5 seconds.
*   The first viewport shows both a conversion path and proof.
*   The page surfaces: quickstart speed, pricing entry point, technical proof, core use cases.
*   By halfway down the page, the visitor has seen both: how the product works AND why the proof is different from logs.
*   Mobile has a sticky CTA.
*   Secondary text is readable; no tiny gray helper copy.
*   Pricing is visible before the footer.
*   Every section has one clear next step.

---

### 13. Open Questions / Dependencies

*   **A/B Testing:** Confirmation on the specific A/B testing plan for the "dramatic number-led headline" vs. the default clarity-focused headline.
*   **Visual Assets:** Dependency on design team for creation of the animated hero visual and refined receipt visual.
*   **Content Finalization:** Review and approval of all copy to ensure tone and accuracy.
*   **Technical Implementation:** Clear scope and timeline for front-end development, backend integration for demo/quickstart flows, and analytics tagging.