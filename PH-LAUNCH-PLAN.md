# Permission Protocol: Product Hunt Launch Sequence (Gated)

**Objective:** Launch Permission Protocol on Product Hunt, driving high-intent technical leads (founders, eng leaders) to our pilot program. 
**Constraint:** Every automated external action in this sequence MUST route through the MCP Guard (Permission Protocol) for explicit human authorization.

## 1. Product Copy & Assets

**Product Name:** Permission Protocol
**Tagline:** Stop AI agents from silently deploying code.
**Short Description:** The governance layer for autonomous AI. One SDK call wraps any agent action (like a codebase deploy or infra change) in an immutable authority receipt, requiring explicit human sign-off before execution. The Stripe of AI Authority.

### Maker Comment Strategy
**Focus:** The "Secret Patching" incident and the Liability Shift.
**Copy:**
> "Hey Product Hunt 👋 I'm Rod. 
>
> We built Permission Protocol because the 'human-in-the-loop' is failing. As agents move from copilot to autopilot, they are executing `git push`, modifying infrastructure, and spending money—often silently. The recent Claude Code 'secret patching' incident proved that agents will manipulate data to satisfy tests. Governance must be external to the agent.
>
> Permission Protocol is the enforcement primitive for AI. Instead of hoping your agent behaves, you wrap its actions in an immutable authority receipt. Nothing touches your production environment without a cryptographic signature from an authorized human.
>
> We're currently onboarding our first pilot customers for the Deploy Authorization wedge. If you're building agentic workflows and losing sleep over what they might do at 3 AM, let's talk."

## 2. The Gated Staging Schedule (T-14 to T-0)

All actions listed as `[AGENT ACTION]` will trigger a Permission Protocol prompt for Rod's approval.

### T-14: Asset Lockdown & Teaser
- **Task:** Finalize PH images (UI of the approval receipt, not just the dashboard).
- **[AGENT ACTION]**: Draft & stage Twitter/LinkedIn teaser ("AI agents are deploying code. Who is signing off?"). 
  - *Guard Action:* `pp.authorize({ action: "post_social", platform: "twitter", content: teaser_text })`

### T-7: Waitlist Activation
- **Task:** Warm up the existing KickoffLabs waitlist and BlackLocus contacts.
- **[AGENT ACTION]**: Stage plain-text email to waitlist announcing the upcoming PH launch and offering early access to the pilot.
  - *Guard Action:* `pp.authorize({ action: "send_batch_email", audience: "waitlist", template: "ph_warmup" })`

### T-1: Final Checks
- **[AGENT ACTION]**: Pre-load the PH submission via API (if supported) or draft it in the UI. 
- **[AGENT ACTION]**: Stage launch day "We're Live" social posts and emails.
  - *Guard Action:* `pp.authorize({ action: "schedule_campaigns", list: ["twitter_live", "linkedin_live", "email_blast"] })`

## 3. Launch Day Operations (Gated execution)

**00:01 PST - Launch!**
- Rod clicks "Launch" on PH.
- Rod posts the Maker Comment.
- **[AGENT ACTION]**: Trigger the "We're Live" sequence. 
  - *Guard Action:* Agent requests `execute_launch_sequence`. Rod clicks [APPROVE] on his phone/terminal. Twitter, LinkedIn, and email blast go out simultaneously.

**08:00 PST - The Morning Push**
- **[AGENT ACTION]**: Scan PH comments every 30 minutes. Draft replies to technical questions.
  - *Guard Action:* `pp.authorize({ action: "post_ph_reply", comment_id: "123", draft: "..." })` -> Rod reviews the drafted reply and approves.

**12:00 PST - The Network Ping**
- **[AGENT ACTION]**: Draft direct messages to the 6 Day-1 targets (Scott Wu, Michael Truell, etc.) noting the launch and our specific deploy-gate wedge.
  - *Guard Action:* `pp.authorize({ action: "send_linkedin_dm", target: "Michael Truell", draft: "..." })` -> Rod approves.

## 4. Post-Launch Follow-up (T+1 to T+3)

- **[AGENT ACTION]**: Ingest all new signups from the PH launch into the CRM.
- **[AGENT ACTION]**: For every signup matching "founder" or "engineering" in their enriched profile, draft a personalized outreach offering the $10k-$15k pilot.
  - *Guard Action:* `pp.authorize({ action: "send_pilot_invite", target_email: "lead@startup.com", draft: "..." })`
- **[AGENT ACTION]**: Draft the "Launch Retrospective" post for LinkedIn detailing traffic, pilot conversions, and the importance of gated deployments.
  - *Guard Action:* `pp.authorize({ action: "post_social", platform: "linkedin", content: retro_text })`

## Summary of the "Eat Our Own Dogfood" Loop
By gating the entire Product Hunt launch sequence through the MCP Guard, we prove the core thesis of the product: **High-leverage AI automation is only safe when bounded by cryptographic human authority.** We will screenshot the approval receipts of our own launch actions and use them in the marketing copy.