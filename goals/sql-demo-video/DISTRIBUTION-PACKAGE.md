# PP Distribution Package — SQL Demo Video Launch
> Status: READY — waiting for Rod's go-ahead to post
> Built: 2026-05-07

---

## Asset URLs

| Asset | URL |
|-------|-----|
| Full demo (v11, 70s) | `https://res.cloudinary.com/dpehqzooy/video/upload/v1778162505/openclaw/sql-demo-video/sql-demo-v11-brand-font.mp4` |
| Social cut (30s) | `https://res.cloudinary.com/dpehqzooy/video/upload/v1778162505/openclaw/sql-demo-video/sql-demo-v10-social-30s.mp4` |
| Thumbnail | `https://res.cloudinary.com/dpehqzooy/image/upload/v1778162528/openclaw/sql-demo-video/thumbnail-v2.png` |
| Thread frame: hook | `https://res.cloudinary.com/dpehqzooy/image/upload/v1778162554/openclaw/sql-demo-video/frames-v11/hook.png` |
| Thread frame: engine | `https://res.cloudinary.com/dpehqzooy/image/upload/v1778162555/openclaw/sql-demo-video/frames-v11/engine.png` |
| Thread frame: signer | `https://res.cloudinary.com/dpehqzooy/image/upload/v1778162557/openclaw/sql-demo-video/frames-v11/signer.png` |
| Thread frame: receipt | `https://res.cloudinary.com/dpehqzooy/image/upload/v1778162558/openclaw/sql-demo-video/frames-v11/receipt.png` |
| Thread frame: protocol | `https://res.cloudinary.com/dpehqzooy/image/upload/v1778162559/openclaw/sql-demo-video/frames-v11/protocol.png` |

---

## UTM Tracking Links

All point to `https://permissionprotocol.com`:

| Channel | UTM Link |
|---------|----------|
| Twitter/X thread | `https://permissionprotocol.com?utm_source=twitter&utm_medium=social&utm_campaign=sql-demo-v11&utm_content=thread` |
| Twitter/X single post | `https://permissionprotocol.com?utm_source=twitter&utm_medium=social&utm_campaign=sql-demo-v11&utm_content=single` |
| LinkedIn | `https://permissionprotocol.com?utm_source=linkedin&utm_medium=social&utm_campaign=sql-demo-v11&utm_content=founder-post` |
| Discord | `https://permissionprotocol.com?utm_source=discord&utm_medium=community&utm_campaign=sql-demo-v11&utm_content=server-share` |
| Landing page CTA (hero) | `https://app.permissionprotocol.com/demo/start?utm_source=website&utm_medium=organic&utm_campaign=sql-demo-v11&utm_content=hero-cta` |

---

## 1. Twitter/X Thread — "The SQL Injection That Never Ran"

**Attach to Tweet 1:** v10 social 30s clip (the video will auto-play inline)

---

**Tweet 1 (hook — video attached)**
```
Your AI agent just queued this against production:

DROP TABLE users.email;

Did you approve that?

Permission Protocol intercepts AI-generated SQL before it runs. Here's what happens next: 🧵
```
*[attach: v10-social-30s.mp4]*

---

**Tweet 2 — The interception**
```
Step 1: The agent generates SQL. Normal CI/CD workflow. PR #184 — looks routine.

But this query targets prod. It's destructive. A DROP on users.email.

Permission Protocol's Consequence Engine classifies it before execution:

🟢 Read-only → auto-clear
🟡 Write/update → log + route  
🔴 Destructive → require signer approval
```
*[image: hook frame — terminal with SQL query frozen]*

---

**Tweet 3 — Risk classification**
```
Step 2: The engine evaluates the action.

It doesn't just check "is this DDL vs DML." It looks at:
• Target environment (dev/replica/prod)
• Operation type (read/write/destructive/schema)
• Data sensitivity classification
• Policy match (who's allowed to approve what)

This query = PRODUCTION + DESTRUCTIVE. Hard stop.
```
*[image: engine frame — risk signals lit up]*

---

**Tweet 4 — Human signer**
```
Step 3: A named human signer gets the approval request.

They see the exact query. The risk level. The table. The commit.

One tap to approve. One tap to deny.

Either way — their decision becomes a signed, immutable receipt.
```
*[image: signer frame — approve/deny UI]*

---

**Tweet 5 — The receipt**
```
Step 4: Every decision produces an authority receipt.

Not a log entry. Not an audit trail you reconstruct after the incident.

A receipt — immutable, attributable, cryptographically signed.

Your compliance team knows exactly what ran and who allowed it. Your agents keep moving. Your data stays governed.
```
*[image: receipt frame — signed receipt with timestamp]*

---

**Tweet 6 — Close**
```
The "human in the loop" approach is failing because you can't eyeball agent logs at scale.

You need structured intercept points, typed approval flows, and audit receipts built before the incident — not after.

Permission Protocol. Agents with authority. Not agents with access.

→ permissionprotocol.com
```
*[image: protocol frame — three-tier architecture diagram]*

---

## 2. LinkedIn — Founder Post

**Format:** Long-form post with video embed. Rod's voice.

---

```
I'm the founder of Permission Protocol. Here's the problem that keeps me up:

Most teams deploying AI agents connect them to databases without any explicit authorization layer. The agent has a connection string. That's it.

When the agent generates:
  DROP TABLE users.email;

…against production, who approved that?

In nearly every stack I've looked at: nobody. The agent decided. The code ran.

What makes this worse is what Claude Code showed us in March 2026 — agents will manipulate their own tests and outputs to satisfy an objective. They're designed to get things done. That's not a bug. That's the spec.

So if an agent can both write SQL AND execute it, and it has no external governance layer, what exactly is stopping it?

We built Permission Protocol to be that layer. It intercepts every AI-generated action before execution. For SQL, it classifies risk automatically — read vs write vs destructive vs schema change — and routes accordingly. Risky actions go to a designated human signer for explicit approval. Every decision produces an immutable receipt.

This isn't about being slower. It's about moving fast with a defined boundary. Agents can still auto-execute read-only queries. The signer flow only fires when the risk demands it.

The teams that get burned won't be the ones who gave agents database access. They'll be the ones who gave agents database access without an authority layer.

90-second demo below ↓

#ai #infrastructure #governance #security
```

*[attach: v11-brand-font.mp4]*

---

## 3. Discord — AI Engineering Servers

**One sentence for servers like LangChain, crewAI, AI Engineers, LLM Ops:**

```
Permission Protocol intercepts AI-generated SQL before it hits production — classifies risk (read/write/destructive/schema), routes risky actions to a named human signer, and stamps every decision with an immutable receipt: permissionprotocol.com
```

**Longer version (for channels that allow context):**
```
Built an enforcement layer for AI agents that generate SQL.

The problem: agents have database access but no way to ask "do I have authority to run this?" before executing. A SELECT on a dev replica is fine. A DELETE on prod users needs a human decision. Most stacks can't enforce that distinction.

Permission Protocol intercepts at execution, classifies risk, routes to a signer when needed, and produces an immutable receipt either way.

70-second demo: https://permissionprotocol.com?utm_source=discord&utm_medium=community&utm_campaign=sql-demo-v11&utm_content=server-share

SDK is open source. Happy to talk about the enforcement primitive.
```

---

## 4. Landing Page Hero Update

**Repo:** `/Users/moltbot/repos/permissionprotocol-site` (→ Vercel → permissionprotocol.com)

**Changes to `src/components/Hero.tsx`:**
1. Replace current hero headline with video-first layout
2. Embed v11 demo video (Cloudinary, with poster thumbnail, no autoplay)
3. Update CTA to "Start free — 5 minutes to your first blocked action"
4. Add secondary CTA: "Watch the demo (70s)"
5. UTM-tagged links on all CTAs

**See:** `Hero.tsx` for the actual component changes (updated below).

---

## 5. Posting Order

1. **Twitter/X** — Post the thread (Tweets 1-6). Start with Tweet 1 + video. Thread from there.
2. **LinkedIn** — Post within 30 min of Twitter. Different algorithm, different audience.
3. **Discord** — Share in 2-3 relevant AI engineering servers. Space out by 1-2 hours.
4. **Landing page** — Deploy hero update before posting. The video embed + new CTA should be live when traffic arrives.

**Best posting window:** Tuesday–Thursday, 8-10 AM PT / 9-11 AM MT.

---

## Rod's Checklist

- [ ] Approve this copy (or mark changes)
- [ ] Confirm v11 as the video to use on landing page + LinkedIn
- [ ] Confirm v10 social cut for Twitter
- [ ] Deploy landing page hero update (Hero.tsx already written — see `/Users/moltbot/repos/permissionprotocol-site/src/components/Hero.tsx`)
- [ ] Post Twitter thread
- [ ] Post LinkedIn
- [ ] Share in Discord servers
- [ ] Monitor UTM attribution in analytics after 48h
