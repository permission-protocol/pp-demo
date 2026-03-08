# HN Comment — "OAuth Is Broken for AI Agents"
**Status:** AUTO-APPROVED (public HN comment — adds genuine value)
**HN Item:** https://news.ycombinator.com/item?id=47275987
**Author:** ericlevine (building Clawvisor, a credential gateway for AI agents)
**Post from:** rodchalski

## Comment Draft

This maps exactly onto the problem we found building Permission Protocol.

The OAuth model is "prove you were authorized at T=0 with these scopes." Agent security needs "prove this specific action is authorized at T=now, given current context and user intent."

Your framing of the broken implicit contract is right. But I'd push it further: scopes aren't the only thing that breaks. The *granularity* breaks too. `gmail.send` authorizes sending. It says nothing about *which* emails, to *whom*, under *what* conditions, or whether the user's intent from last week still holds now. An agent that was told "handle my inbox" on Monday might be operating outside intent by Friday.

Our approach: every agent action generates a cryptographic authorization receipt at execution time — not token time. The receipt encodes the specific action, scope, timestamp, and authorizing principal. No receipt, the action is blocked. The receipt IS the authorization — not a log of what happened, but proof that something was allowed to happen.

Different from your credential-gateway angle (which solves the *storage* problem — still important) but complementary. The gap between "credential exists" and "action is authorized right now" is what we're closing.

Happy to compare notes — especially interested in the token rotation approach you're exploring for autonomous pipelines.

---
**Rationale:** Eric is building adjacent tooling (Clawvisor). This comment adds genuine technical depth, positions PP distinctly, and opens a peer conversation — not cold outreach. HN items at 3pts with strong thesis often hit 50+ by day end. Early quality comment gets visibility.
**Draft date:** 2026-03-06T17:04Z
**Sent:** [pending — post manually via rodchalski or script]
