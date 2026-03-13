# HN Comment — On the DataTalks terraform destroy thread

**Thread:** https://news.ycombinator.com/item?id=47278720
**Account:** rodchalski
**Timing:** After blog is live

---

We had the same thing happen to us nine days before this incident.

Our AI assistant needed to add two environment variables to our Render deployment. It called PUT instead of PATCH. PUT replaces the entire resource. Twenty-two env vars — signing keys, OAuth credentials, database URLs — replaced with two.

The "user error vs tool failure" debate here is describing the same gap from two angles. The real problem is simpler: we give AI agents API keys, and everything that key can do is implicitly authorized. There's no layer that says "you can call this API, but destructive operations on production need a human to sign off."

We're building that layer (https://permissionprotocol.com). After the wipe, we fast-tracked dogfooding it on our own repos. Every PR now requires explicit approval through our system before merge. Four days from incident to enforcement.

Wrote up the full story with the uncomfortable parallels between our incident, this one, and Cursor shipping auto-approve as a default: https://permissionprotocol.com/blog/my-ai-nuked-production
