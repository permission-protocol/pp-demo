Okay, here is a Project PRD (Product Requirements Document) brief for the Permission Protocol Homepage Redesign, based on the detailed specifications you provided.

---

## Project PRD Brief: Permission Protocol Homepage Redesign

**1. Project Title:** Permission Protocol Homepage Redesign for Enhanced Onboarding & Trust

**2. Executive Summary:**
This project outlines the redesign of the Permission Protocol homepage with the primary goal of maximizing user onboarding (GitHub/install & "Protect 1 repo free" clicks) and significantly improving user understanding, trust, and education. The current homepage is visually strong but fails to clearly explain the product, its speed, and proof points early enough. The redesign will implement a structured information flow, bring critical information above the fold, introduce a clear pricing snapshot, and refine the visual language to prioritize clarity and conversion without sacrificing the premium, technical aesthetic.

**3. Goals & Key Performance Indicators (KPIs):**

*   **Primary Goal:** Maximize the start of real-product onboarding.
    *   **Primary KPIs:**
        *   GitHub/install click rate
        *   "Protect 1 repo free" click rate
*   **Secondary Goal:** Improve user intent and education.
    *   **Secondary KPIs:**
        *   Demo starts
        *   Demo completions
        *   Quickstart clicks
        *   Live receipt clicks
        *   Pricing clicks
        *   Request-access clicks
*   **Non-Goal:** Optimize for visual mood alone. Focus on understanding, trust, and low-friction next steps.

**4. Problem Statement:**
The current Permission Protocol homepage, while visually appealing, struggles to communicate the core product value proposition, setup speed, and proof points effectively in the initial user experience. It leads with scary scenarios before establishing product category, setup speed, and proof, hindering quick understanding and trust building. Secondary copy under CTAs is low-contrast and unhelpful, and key information like pricing and quickstart benefits are buried on other pages.

**5. Core Strategy:**
The new homepage must answer the following questions in this exact order:
1.  **What is this?** (Product category & core function)
2.  **What risky actions does it control?** (Use cases & value)
3.  **How does it work?** (Mechanism & process)
4.  **Why should I trust it?** (Proof & technical credibility)
5.  **How fast can I try it?** (Ease of entry & quickstart)
6.  **What does it cost?** (Transparency & plan options)
7.  **What should I do next?** (Clear calls to action)

**6. Positioning Statement & Framing:**
*   **Positioning Statement:** Permission Protocol is the approval and receipt layer for irreversible AI and automation actions.
*   **Plain-English Framing:** It blocks risky actions until a human or policy decision authorizes the exact request, then returns a signed receipt that systems can verify before execution.

**7. What to Keep vs. What to Change:**

*   **Keep:**
    *   Dark, premium visual language
    *   Live demo as the main top-of-funnel CTA
    *   Receipt visual / signed-proof concept
    *   Use cases for deploys, sensitive data, money movement, and high-risk tool calls
    *   GitHub-first motion
*   **Change:**
    *   Replace vague first-screen messaging with explicit product/category clarity.
    *   Bring setup speed, free entry point, and proof points above the fold.
    *   Remove tiny, low-contrast helper copy under CTAs.
    *   Merge overlapping "In 15 seconds" and "How it works" concepts into a tighter flow.
    *   Add pricing snapshot and objection handling before the final CTA.
    *   Add a sticky mobile CTA.

**8. New Homepage Structure (Section Order):**

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

*(By 50% scroll, the visitor should have seen: what the product is, how it works, what proof it creates, how fast it is to try, how much it costs.)*

**9. Key Content Specifications (Per Section):**

*   **Sticky Nav:** Desktop links: How it works, Quickstart, Pricing, GitHub. Primary CTA: "Try live demo". Sticky on scroll, light blur.
*   **Hero:**
    *   **Layout:** Desktop 2-column (copy + CTAs left, animated visual right). Mobile stacked (copy first).
    *   **Mobile First Viewport:** Headline, subhead, both CTAs, at least 3 proof chips.
    *   **Copy:** Eyebrow "Signer of Record for AI Systems", Headline "Stop AI agents from taking irreversible actions without human approval.", Subhead explains blocking deploys, data access, payouts, etc.
    *   **CTAs:** Primary "Try the live demo", Secondary "Protect 1 repo free", Tertiary text link "Read the 5-minute quickstart".
    *   **Proof Chips:** 15-second demo, First receipt in 5 minutes, Free Developer plan, GitHub integration, Ed25519 receipts, <200ms latency, MIT enforcement layer.
    *   **Visual:** Single animated composite visual (6-8s loop) demonstrating Blocked action -> Approval decision -> Verified receipt.
*   **Proof Bar:** Horizontal trust strip directly under hero: Free Developer plan, Production from $300/org/month, GitHub integration, Ed25519 signatures, <200ms median gate latency, MIT-licensed enforcement layer.
*   **Approval Flow:** Heading "See the approval flow in 15 seconds." Subhead: "Execution stays closed until the request is approved and the receipt is verified." Three cards: Blocked, Human approves, Receipt verified. CTA: "See a live receipt".
*   **Signed Proof Section:** Heading "Signed proof, not logs." Subhead contrasts logs with verifiable receipts. Comparison content (Slack/PR approval, Audit logs, Permission Protocol receipt) with refined receipt card visual. CTA: "View live receipt".
*   **Quickstart / Implementation:** Heading "Add authority in 5 minutes." Subhead: "Wrap the action. Wait for approval. Verify the receipt." Split layout with 3-step stack and dashboard mockup. CTAs: "Read the quickstart", "Get a free API key".
*   **Use Cases:** Heading "Built for high-impact actions." Subhead: "One primitive. Multiple policies." Four cards: Production deploys, Sensitive data access, Money movement, High-risk tool calls.
*   **Pricing Snapshot:** Heading "Start free. Enforce when ready." Subhead explains the common start. Two cards: "Developer" (Free) with benefits and "Protect 1 repo free" CTA; "Production" ($300/month/organization) with benefits and "Request access" CTA. Enterprise line link. Proof chips below pricing cards.
*   **FAQ / Objections:** Heading "Common questions." Six specific FAQs addressing setup speed, proof, latency, free plan, starting small, and open-source status.
*   **Final CTA:** Headline "Try the approval flow now. Then protect a real repo." Subhead: "Start with one repo. Scale to every agent." Primary CTA: "Try the live demo", Secondary: "Protect 1 repo free", Tertiary link: "Need org-wide enforcement? Request access".

**10. Visual Design Requirements:**

*   **General:** Keep current dark, technical, premium feel. Aqua/teal as action color, red for risk/blocked. Rounded cards, clean spacing. Increased contrast on secondary copy.
*   **Typography:** Crisp headlines. Avoid overly light gray body copy. Mobile body text min 16px, secondary labels min 14px. Desktop line length max ~70 chars.
*   **Spacing:** Desktop section padding 88–112px, Mobile 48–64px. Reduce dead vertical air and hero-to-next-section gap.
*   **Buttons:** Primary 52px (desktop)/48px (mobile) height. Secondary must be visually important. Clear hover/pressed/focus states.
*   **Cards:** 16px radius, subtle borders/highlights. Receipt card: "verifiable system object" feel.
*   **Motion:** Light motion only. No autoplay gimmicks. Respect reduced-motion. Hero animation to teach.

**11. Mobile-Specific Requirements:**

*   **First Viewport:** Must show headline, subhead, primary CTA, secondary CTA, and proof chips.
*   **Sticky CTA:** After scrolling past hero, implement a sticky bottom CTA with "Try demo" and "Start free" buttons.
*   **Layout:** Proof chips horizontally scrollable. No paragraph longer than 3 lines where avoidable. Stacked cards.
*   **Content:** Pricing must be visible before the footer.

**12. Content Rules (Do's & Don'ts):**

*   **Do:** Use concrete verbs (block, approve, verify, enforce, sign) and nouns (deploy, payout, customer data, receipt, policy, signer). Explain mechanism before inferring. Surface setup speed and pricing early.
*   **Do Not:** Lead with abstract/security-theory language. Use implementation copy ("Install on GitHub") as value message. Make users scroll multiple screens for product understanding. Bury pricing/quickstart benefits.

**13. Tracking Requirements:**

*   **Events:** `hero_demo_click`, `hero_start_free_click`, `hero_quickstart_click`, `proofbar_pricing_click`, `live_receipt_click`, `quickstart_click`, `pricing_start_free_click`, `pricing_request_access_click`, `faq_expand`, `final_demo_click`, `final_start_free_click`.
*   **Additional Tracking:** 25%/50%/75% scroll depth, demo start/completion, post-demo install click, homepage-to-pricing click, homepage-to-quickstart click.
*   **Optimization Target:** Install/start-free rate (primary), not raw CTR.

**14. Acceptance Criteria:**

*   A first-time visitor can explain what the product does in under 5 seconds.
*   The first viewport shows both a conversion path and proof.
*   The page clearly surfaces quickstart speed, pricing entry point, technical proof, and core use cases.
*   By halfway down the page, the visitor has seen both how the product works and why the proof is different from logs.
*   Mobile has a sticky CTA.
*   Secondary text is readable; no tiny gray helper copy.
*   Pricing is visible before the footer.
*   Every section has one clear next step.

---