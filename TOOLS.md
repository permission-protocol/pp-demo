# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

---

## GitHub Projects

**PAT for Projects API:** `~/.openclaw/secrets/github-pat-projects.txt`
**Scopes:** `project`, `read:project`, `repo`

**Boards:**
- [PP Marketing](https://github.com/orgs/Roca-Ventures/projects/1) — content, SEO, outreach
- [PP Product](https://github.com/orgs/permission-protocol/projects/1) — core product, deploy gates, features
  - Project Node ID: `PVT_kwDOD2Ims84BRQBA`
  - Status Field: `PVTSSF_lADOD2Ims84BRQBAzg_IfZ8`
  - Options: Backlog=`f75ad846`, Ready=`61e4505c`, In progress=`47fc9ee4`, In review=`df73e18b`, Done=`98236657`

**⚠️ RULE: Every issue created on permission-protocol/* repos MUST be added to the PP Product board.**
After `gh issue create`, always:
1. Get the issue node_id from the URL/API
2. Add to board via `addProjectV2ItemById` mutation
3. Set status (default: Ready, unless specified otherwise)

**Usage:**
```bash
GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt) gh project list --owner Roca-Ventures
```

---

## 1Password Integration

**Service Account configured** — Token stored at `~/.openclaw/secrets/op-token`

**Vault:** `Xdares / OpenClaw`

**Available credentials:**
- `Wordpress - Xdares` — blog.xdares.com admin
- `Kickofflabs` — waitlist management
- `10Web` — WordPress hosting
- `postmark` — transactional email
- `Gmail` — cgoldber82@gmail.com
- `GitHub` — cgoldber82@gmail.com
- `Telegram Bot Token` — @Charles1982bot
- `Telegram` — Rod's account
- `Identity` — Charles Goldberg identity
- `BetaList` — cgoldber82 (startup directory)
- `product hunt` — cgoldber82 (product launches) — **Xdares draft exists, Charles invited as collaborator**
- `indie hackers` — cgoldber82 (indie community)
- `Quora` — cgoldber82@gmail.com (verified 2026-02-06)
- `Reddit` — xDaresOfficial (verified 2026-02-06)
- `X` — @xdares_ (verified 2026-02-06) — **API enabled** (credentials at ~/.openclaw/secrets/x-api.json)
- `Facebook` — rod@xdares.com / facebook.com/join.xdares (verified 2026-02-06)
- `YouTube` — cgoldber82 (Google/Gmail login)

**Usage:**
```bash
export OP_SERVICE_ACCOUNT_TOKEN=$(cat ~/.openclaw/secrets/op-token)
op item get "ITEM_NAME" --vault "Xdares / OpenClaw" --reveal
```

---

## Coding Agents

**Available agents:**
- **Codex CLI** — GPT-5.3 Codex via ChatGPT Pro (unlimited, free). Auth: `codex login status`
- **Claude Code** — Anthropic API. Key: `~/.openclaw/secrets/anthropic-api-key.txt`

**When to use which:**

| Scenario | Use |
|---|---|
| Default for most coding tasks | Codex (free) |
| Feature builds, refactors, boilerplate | Codex |
| Parallel batch work (5+ simultaneous) | Codex (zero cost concern) |
| PR reviews | Codex |
| Complex architecture / system design | Claude Code (better reasoning) |
| Codex gets stuck or quality is subpar | Claude Code (escalation) |
| Nuanced writing (outreach, RFI) | Claude Code |
| Big features with independent subtasks | Both in parallel |
| Cross-validation of critical PRs | Both (compare notes) |
| Time-critical, max throughput | Both |

**Rule:** Start Codex. Escalate to Claude Code if quality > speed. Use both when time matters most.

**Usage:**
```bash
# Codex (one-shot, needs git repo)
codex exec --full-auto "Your prompt"

# Claude Code
ANTHROPIC_API_KEY=$(cat ~/.openclaw/secrets/anthropic-api-key.txt) claude -p "Your prompt"

# Background with PTY (required for both)
# Use exec tool with pty:true, background:true, workdir:/path/to/repo
```

---

## DGX Spark (Ollama)

**Tailscale IP:** 100.111.31.56
**Ollama endpoint:** http://100.111.31.56:11434
**Available model:** llama3.1:8b
**Status:** Works via direct API, OpenClaw routing not working yet

**Usage:**
```bash
curl http://100.111.31.56:11434/api/generate -d '{"model":"llama3.1:8b", "prompt":"..."}'
```

---

## Telegram

**Bot:** @Charles1982bot
**Rod's chat ID:** 6091356144

---

## Coding Agent Workflow

**Always use this flow for coding tasks:**

### 1. Launch with codex-run.sh (not raw codex)
```bash
bash pty:true background:true workdir:/tmp/pp-XXX command:"bash ~/.openclaw/workspace/scripts/codex-run.sh <issue> /tmp/pp-XXX '<prompt>'"
```

### 2. Monitor with agent-status.sh
```bash
bash scripts/agent-status.sh          # all agents
bash scripts/agent-status.sh 216      # specific issue
```
Status file at `/tmp/agent-status-<issue>.json` shows phase + detail + files changed.

### 3. Pre-merge visual review (BEFORE merging)
```bash
bash scripts/pre-merge-review.sh permission-protocol/site 42
```
Then screenshot with browser tool:
- Desktop viewport of each changed page
- Check nav, colors, responsiveness
- **Only merge after visual confirmation**

### Rules
- **Codex first, always.** Claude Code only for single complex tasks where Codex fails.
- **Screenshot before merge**, not after.
- **Never move to Done** — executor moves to QA Review, pipeline verifies.
- **Environment Parity**: Check for the "Environment Badge" on the dashboard (introduced 2026-03-15) to ensure the current deployment matches the expected environment.
- **Factory Archive**: Auto-archive factory threads in Discord once a task is merged to keep #factory-wip clean.

---

## Caddy / HTTPS Setup Runbook

When setting up HTTPS on a new server (Caddy + Let's Encrypt), avoid these pitfalls:

**1. Cloudflare must be DNS-only (grey cloud), NOT proxied (orange cloud)**
- Orange cloud = Cloudflare proxies traffic = Let's Encrypt can't verify domain ownership via HTTP-01
- Set to grey cloud BEFORE running `caddy start` or requesting a cert
- You can switch back to orange cloud after cert is issued (but Caddy auto-renews, so keep it grey or use DNS-01 challenge)

**2. Port 80 must be open for HTTP-01 ACME challenge**
```bash
ufw allow 80/tcp
```
- Even if your app only serves HTTPS, Caddy needs port 80 for the ACME challenge
- Without it: cert request hangs or fails silently

**3. nip.io wildcard DNS is unreliable with Let's Encrypt**
- Rate limits + wildcard verification issues — don't use for prod HTTPS
- Use a real domain (e.g., hooks.permissionprotocol.com)

**4. Caddyfile minimal working config:**
```
hooks.permissionprotocol.com {
    reverse_proxy localhost:3100
}
```
- Caddy auto-provisions cert + handles HTTP→HTTPS redirect

**5. Test before declaring done:**
```bash
curl https://hooks.permissionprotocol.com/health
```

---

## Expandi Outreach Rules

**Placeholder limit: 300 chars. Expandi silently drops anything longer (no error thrown).**

Always validate before injecting leads:
```bash
node pp-os/outreach/scripts/validate-messages.js leads.json
```

**Campaign API inject URL:** `~/.openclaw/secrets/expandi-api.json`

**Webhook server:** `https://hooks.permissionprotocol.com` (Fastify on pp-scout-sfo2)
- Health check: `curl https://hooks.permissionprotocol.com/health`
- Droplet SSH: `ssh -i ~/.ssh/github_ed25519 root@64.23.210.36`
- Tailscale IP: `100.122.174.112`

### GitHub App Auth Reference
- **App JWT**: Created using App ID + Private Key. Used for global App-level API calls (e.g., `GET /app/installations`).
- **Installation Token**: Created via `POST /app/installations/{id}/access_tokens`. Used for repo-level API calls (e.g., `GET /installation/repositories`, `POST /repos/{owner}/{repo}/statuses`).
- **Rule**: If you get a 401/403 on a repo-level call while using a JWT, you probably need an Installation Token.

---

## Sentry / Monitoring

**DSN configured on Render** — Token stored at `~/.openclaw/secrets/sentry-auth-token`

**Usage:**
```bash
factory/scripts/error-sensor.sh
```
- Automatically pulls real-world crashes into the Factory pipeline.
- Deterministic policy-gate will prioritize these as high-signal work.

---

## Visual QA & Screenshots

When performing visual reviews on modern frontends (Framer Motion, animations):
1. **Navigate manually** with the `browser` tool (don't trust default tab state).
2. **Inject CSS** to force element visibility for scroll-triggered components (Evidentiary UX):
```javascript
// Example via browser act:evaluate
Array.from(document.querySelectorAll("*")).forEach(el => {
  el.style.opacity = "1";
  el.style.transition = "none";
  el.style.animation = "none";
});
```
3. **Capture** with `fullPage: true` but be aware of viewport height constraints.
4. **Evidentiary Verification**: Ensure all risk signals (Signer identity, Verification status, Policy Context) are visible in the screenshot. If missing, it's a regression in "Evidentiary UX."

---

## Deployment & Cache Troubleshooting

### Render Stale JS Bundles
Render/Vercel sometimes serve stale JS chunks from build cache, leading to "ReferenceError" or "Not Found" errors even after a fix is pushed.
- **Symptom:** Code looks correct in `main`, but browser devtools show old file contents or variable names.
- **Fix:** Trigger a "Manual Deploy" with **Clear Build Cache** enabled in the Render dashboard (or via API).
- **Verification:** Check the build log to ensure it says "Clearing build cache" at the start.

---

## PullMatch Workspace

**Standalone Repo:** `pullmatch/app` (private)
**Vercel Project:** `pullmatch`
**Neon Database:** `pullmatch-db`

**Architecture:**
- Decoupled from Permission Protocol (standalone branding).
- Uses the same core Auth primitives as PP.
- Workspace directory: `~/pullmatch` (symlinked or separate).

---

## Blog Publishing (via Tor)

**Server IP blocked** from blog.xdares.com — use Tor proxy for all WordPress operations.

**Script:** `goals/xdares-seo-growth/scripts/publish_post.py`

**Features:**
- Publishes via WordPress REST API through Tor
- Auto-generates AI images (Imagen 4.0)
- Compresses images to <100KB
- Extracts metadata from HTML files

**Usage:**
```bash
python3 goals/xdares-seo-growth/scripts/publish_post.py content/post-file.html
python3 goals/xdares-seo-growth/scripts/publish_post.py content/post-file.html --draft
```

**Credentials:**
- WordPress: 1Password "Wordpress - Xdares" (Application Password)
- Gemini: `~/.openclaw/secrets/gemini-api.json`

**Tor must be running:** `brew services start tor`
