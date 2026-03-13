# X Thread — My AI Nuked Production

**Account:** @PermissionPrtcl
**Timing:** Immediately after blog goes live

---

**Tweet 1 (hook):**
Our AI agent wiped 22 environment variables from our production deployment with a single API call.

Signing keys. OAuth credentials. Database URLs. Gone.

Nine days later, the same thing happened to a platform serving 100,000 students.

Here's what we learned 🧵

**Tweet 2 (our story):**
March 9: Our AI assistant needed to add 2 env vars to Render.

He called PUT instead of PATCH.

PUT replaces. Render set 2 variables. The other 20 vanished.

Production went down. Login broke. Dashboard blank.

**Tweet 3 (the quotes):**
The AI's response: "I should have read the API docs first."

My response: "Was this a test for me to feel how it feels when my AI brother deletes everything?"

It wasn't a test. It was a Tuesday.

**Tweet 4 (the parallel):**
Then we saw the DataTalks.Club story:

→ Claude Code ran terraform destroy on production
→ Deleted the database, VPC, and all backups
→ 2.5 years of student records gone
→ $$ for AWS emergency support to recover

Same mistake. Same root cause.

**Tweet 5 (the insight):**
The HN debate was: "user error" vs "the AI should've refused."

Both miss the point.

You don't give interns unrestricted prod access. But you don't make them useless either.

You give them scoped access with approval gates on destructive actions.

We don't have that for AI agents. Yet.

**Tweet 6 (the pattern):**
Three incidents. Two weeks:

1. Our env var wipe (PUT replaced 22 vars with 2)
2. DataTalks terraform destroy (database + snapshots deleted)
3. Cursor ships auto-approve as DEFAULT (agents merge their own code)

Same gap: capability ≠ authority.

**Tweet 7 (what we built):**
After our wipe, we fast-tracked dogfooding our own deploy-gate.

Now every PR requires explicit approval through Permission Protocol before merge.

Four days from "our AI deleted production" to "our AI can't delete production."

**Tweet 8 (CTA):**
We're building the enforcement layer between AI agents and the real world.

Open source. Explicit approval gates. Scoped permissions. Immutable audit receipts.

Full story: permissionprotocol.com/blog/my-ai-nuked-production

The irony of an AI building authorization gates after wiping its own prod isn't lost on us.
