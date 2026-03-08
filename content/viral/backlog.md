# Viral Content Backlog

## Pipeline
```
Rod drops idea in #rc-viral-media
    ↓
Charles evaluates (2 min): viral potential, PP angle, timeliness
    ↓
Draft article + platform-specific titles + image (15 min)
    ↓
Rod reviews in-channel
    ↓
Publish: Blog → X → (wait) → Reddit → HN (safest last)
    ↓
Scout monitors engagement across all platforms
```

## Platform title strategy (ALWAYS do this)
Every piece gets 4 titles:
- **Blog (canonical):** Balanced, substantive — becomes the OG meta title
- **X hook:** Provocative, punchy, emoji ok — what X rewards
- **HN title:** Factual, curiosity-driven — "How X did Y" format, NO declarations ("X is dead"), NO superlatives
- **LinkedIn:** Founder lesson — "What I learned from watching..."

## Platform launch order
1. **Blog** first (canonical URL, needs to exist before everything else)
2. **X thread** (fast, tolerant of hot takes)
3. **Reddit** (24h later if we have karma, else Rod manual post)
4. **HN** (last — most aggressive moderation, highest risk of flagging)
5. **LinkedIn** (next morning — different audience, different peak time)

Never submit to HN from a low-karma account with a hot-take title. Build karma first.

## Account warmup status
- **@PermissionPrtcl (X):** Active, 3 followers, needs growth
- **rodchalski (HN):** New, low karma — needs comment warmup before submissions
- **PermissionProtocol (Reddit):** 0 karma, warmup via Scout daily digest
- **Rod LinkedIn:** Established, manual posting

## Key rules
- News-reactive pieces: ship X thread AND blog simultaneously (no dead-end threads)
- Different platforms have different immune systems — what works on X gets killed on HN
- Engage replies in first 2-4 hours (that's where the viral loop happens)
- Don't force engagement on dead posts — move on
- 18 points before HN death = content worked, packaging failed. Reframe and resubmit.

## Scripts
- `scripts/gen-image.sh "prompt" output.png` — brand image generation
- `scripts/post-x-thread.sh thread.json [image.png]` — fire X thread
- `scripts/publish-blog.sh slug title desc image.png content.html` — full blog publish pipeline

---

## Live campaigns

### Campaign #1: Cursor Is Dead (2026-03-06)
- **Type:** Evergreen analysis
- **Blog:** https://permissionprotocol.com/blog/cursor-is-dead.html
- **X Thread:** https://x.com/PermissionPrtcl/status/2029957726001058155
- **HN:** https://news.ycombinator.com/item?id=47277134
- **Image:** content/viral/cursor-dead-v2.png (gravestone)
- **Status:** Live, Scout monitoring active
- **Pending:** LinkedIn (Rod personal, tomorrow AM)

### Campaign #2: Who Authorized This Drone Strike? (2026-03-06)
- **Type:** News-reactive (Anthropic/Pentagon)
- **X Thread:** https://x.com/PermissionPrtcl/status/2029969527270953045
- **Image:** content/viral/pentagon-authorize.png (empty chair)
- **Status:** Live, Scout monitoring active
- **Pending:** Blog post, HN submission

---

## Ideas queue (ranked by potential)

| Priority | Idea | Type | Timeliness | PP angle |
|----------|------|------|------------|----------|
| HIGH | Pentagon blog post (deeper analysis of authorization architecture) | News-reactive | This week | Direct |
| MED | "Your AI CEO doesn't have a signing key" — the autonomous company problem | Evergreen | Anytime | Core thesis |
| MED | "The deploy receipt is the new unit test" — why CI/CD needs cryptographic proof | Evergreen | Anytime | Product |
| LOW | "Every AI framework forgot authorization" — LangChain, CrewAI, AutoGen audit | Evergreen | Anytime | Technical |
| LOW | "The $1 trillion audit gap" — who approved what in enterprise AI | Evergreen | Anytime | Enterprise |

---

## Lessons learned

### 2026-03-06 — First viral day
- Image gen: use `scripts/gen-image.sh` (gemini-3.1-flash-image-preview). First attempt hit wrong model endpoint 3x — script now tested and cached.
- Reddit: PermissionProtocol account needs warmup (daily digest via Scout). New accounts get auto-blocked from major subs.
- Reddit auto-posting blocked (403) — manual only. Don't waste time scripting Reddit login.
- News-reactive pieces: ship X thread AND blog simultaneously. Campaign #2 had no blog — thread is a dead end if it pops.
- Blog publish: use `scripts/publish-blog.sh` to skip template reverse-engineering.
- HN: "X is dead" titles get flagged immediately. Factual curiosity titles survive. 18 points before death = content works, packaging doesn't.
- HN from low-karma accounts = high flag risk. Warm up with comments first.
- OG image caching: Vercel needs 2-3 min after deploy before social cards work. Wait before posting threads.
- Platform-specific titles are not optional. One title does not fit all platforms.
- Two campaigns in one hour is fine. More than that dilutes both — algorithm rewards engagement depth not volume.
- X: @PermissionPrtcl keys at ~/.openclaw/secrets/x-api-pp.json
- HN: rodchalski, creds in 1Password
