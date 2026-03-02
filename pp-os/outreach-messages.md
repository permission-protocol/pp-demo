# Deploy Gate – Outreach Messages

*Created: 2026-03-02*
*Purpose: Design partner recruitment for Permission Protocol's Deploy Gate*
*Goal: First design partner signed by March 21, 2026*

---

## Message 1 — Greptile

**Target Company:** Greptile (greptile.com)
**Contact Role:** Co-founder / CEO (Daksh Gupta)
**Format:** Twitter/LinkedIn DM

---

Hey Daksh — saw Greptile's been growing fast. You're in an interesting spot: AI is reviewing and suggesting code, but there's no layer that proves *who authorized* that code going to prod.

You probably saw the OpenClaw fallout — 42K exposed instances, agents shipping code without any auth trail. That's the exact gap we're filling.

Built a tool called Deploy Gate — it's a GitHub Action that blocks merges without a cryptographic receipt of authorization. 2-minute install. No new workflow, just a required status check.

Would you want to try it on one Greptile repo? Partly for your own use, partly because your customers probably need this on top of what you're already giving them.

---

**Rationale:** Greptile's customers trust AI to review code but have no governance layer for what gets merged. Greptile is both a design partner candidate and a potential referral channel to their entire customer base. Founder-to-founder DM keeps it casual and direct.

---

## Message 2 — StepSecurity

**Target Company:** StepSecurity (stepsecurity.io)
**Contact Role:** Co-founder / CTO
**Format:** Email

---

**Subject:** Deploy Gate + Harden-Runner — natural fit?

Hey —

You're already in the GitHub Actions security lane hardening CI pipelines. We just shipped Deploy Gate — a required status check that blocks merges without a signed authorization receipt from Permission Protocol.

You harden the runner. We certify the action was explicitly approved. Together that's: secure execution + provable authorization.

Given the OpenClaw situation (6 CVEs in Feb, agents deploying code with zero auth trail), I think companies are about to want both layers — and right now nobody's offering them together.

Worth a 20-minute call to see if there's a natural integration? Or if you want to kick the tires first, Deploy Gate is a 2-minute install on any repo.

— Rod

---

**Rationale:** StepSecurity is already embedded in GitHub Actions security workflows. They harden the runner; Deploy Gate certifies the authorization. This is the clearest integration story in the ecosystem, and a partnership gives both tools more surface area. Engineer/founder tone, shared technical context.

---

## Message 3 — CodeRabbit

**Target Company:** CodeRabbit (coderabbit.ai)
**Contact Role:** Head of Engineering / CTO
**Format:** LinkedIn DM

---

Hey — quick thought from one AI-in-the-loop team to another.

CodeRabbit reviews the code. But once the AI suggests an approval, what stops that from becoming a merge without any human explicitly in the chain?

The OpenClaw crisis made this concrete: 42K exposed instances, agents with full repo access, no audit trail on what they deployed or who signed off. Cisco called it "an absolute nightmare." The Register called it "an identity problem at scale."

We built Deploy Gate for exactly this gap — cryptographic proof that a human (or authorized system) approved each deploy. GitHub required status check, 2-min install.

I'd love to get your team's read on it. Would you try it on one repo? Happy to set it up with you.

---

**Rationale:** CodeRabbit sits directly in the PR/review flow, making them acutely aware of the "AI approved → auto-merged" risk. Their engineering team will immediately understand the gap. Referencing the OpenClaw crisis grounds the ask in a real, timely incident rather than a hypothetical.

---

## Message 4 — Vercel / AI-Native Deployment Team

**Target Company:** Vercel
**Contact Role:** Staff Engineer, Platform Security
**Format:** Email

---

**Subject:** Who authorized your last 50 AI-assisted deploys?

Hey —

Not a gotcha question — I genuinely don't know if anyone has a clean answer to this yet.

Post-OpenClaw (42K exposed agents, zero authorization receipts on what they deployed), I've been thinking about the specific gap: AI assists or initiates the code change, CI/CD runs it, but there's no cryptographic proof that a human explicitly authorized that specific deploy.

Logs aren't enough. Logs say what happened. Receipts prove what was approved.

We built Deploy Gate — a GitHub Action that requires a signed authorization receipt before any merge. Immutable, timestamped, cryptographic. Not a policy doc. Evidence.

Given Vercel's position in the deployment stack, I think you'd have real opinions on whether this is the right model. Would you be willing to run it on one internal repo and poke holes in it?

— Rod

---

**Rationale:** Vercel is at the center of modern deployment workflows and has both the scale and the technical credibility to be a high-signal design partner. A staff-level security engineer is the right persona — skeptical enough to be useful, technical enough to evaluate the model. The "poke holes in it" framing invites honest feedback rather than a sales conversation.

---

## Message 5 — Astrix Security

**Target Company:** Astrix Security (astrix.security)
**Contact Role:** Co-founder / Head of Product
**Format:** Email

---

**Subject:** You detect it. We authorize it. Full coverage?

Hey —

Astrix's write-up on the OpenClaw crisis was sharp — "42K exposed instances, AI agents acting without governance" is exactly the framing that matters. You're detecting that agent activity. We're building the layer that proves it was authorized before it happened.

Different surfaces, same thesis: agents can't be trusted without an external control layer.

Deploy Gate is our wedge — a required GitHub Actions status check that blocks deploys without a signed receipt from Permission Protocol. No receipt, no merge. Cryptographic, immutable.

I'd love to explore whether there's an integration story here. Detection + authorization together is a much stronger pitch than either alone.

Or if you just want to run Deploy Gate on an Astrix repo first, it's a 2-minute install. Happy to do it live on a call.

— Rod

---

**Rationale:** Astrix published one of the most-cited analyses of the OpenClaw crisis, making them a credible technical peer. They detect agent activity; PP authorizes it — the framing is complementary, not competitive. This opens both a design partner relationship and a potential go-to-market partnership. Using their own research as the hook establishes credibility immediately.

---

## Usage Notes

- **Send order:** Start with StepSecurity (clearest integration story) and Greptile (founder-accessible).
- **Follow-up:** If no response in 5 days, reply to same thread with a relevant incident or NIST update as a reason to re-engage.
- **Tracking:** Log sends + responses in `pp-os/crm.md` (create if needed).
- **Personalize before sending:** Check each contact's recent tweets/posts for a timely hook to open with.
