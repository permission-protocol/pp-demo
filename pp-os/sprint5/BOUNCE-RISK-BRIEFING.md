# Bounce-Risk Briefing: Sprint 5

Rod, we have enriched our prospect list with estimated emails. Here is what you need to know before hitting send.

## The Problem with Pattern-Guessed Emails
While we successfully validated many emails with direct SMTP (HIGH confidence), domains that employ a **Catch-All** configuration mask their invalid addresses by accepting all incoming mail during the SMTP check. For these domains, we must rely on pattern guessing (e.g., `first@company.com`).

**Pattern-guessed emails typically bounce 20-40%.** Sending to these without caution will destroy your domain reputation, landing future emails in the spam folder.

## Pre-Flight Validation
Before queuing the `MED` and `LOW` confidence emails, you MUST run a secondary verification pass using a specialized tool:
1. **Apollo's Verifier:** If you import the `apollo-import-ready.csv` into Apollo, use their built-in validation feature.
2. **NeverBounce (Free Tier):** Upload the list to NeverBounce to weed out known bad addresses.

## The "Safe Send" Recipe
For any emails that are `MED` or `LOW` confidence and haven't passed a strict secondary verification, follow these rules:

1. **Warmed Mailboxes Only:** Only send from domains that have been warming up for >14 days.
2. **Throttle the Volume:** Send a **MAXIMUM of 50 emails per day** per mailbox.
3. **Monitor Closely:** Watch the bounce rate after the first batch.
4. **Kill Switch:** If the bounce rate exceeds **10%**, STOP the campaign immediately. A 10% bounce rate is the danger threshold for permanent reputation damage. 

Do not gamble with the primary domains.
