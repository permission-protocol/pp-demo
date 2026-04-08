# Tools Reference — On-Demand

*Read this file when you need specific IPs, credentials, runbooks, or service details. Not for every conversation.*

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

## Troubleshooting

### Discord Provider Stuck
**Symptoms:** `Unsupported channel: discord` errors in cron jobs or `awaiting gateway readiness` in logs.
- **Run Health Check:** `bash scripts/discord-health-check.sh`
- **Fix:** If the provider is stuck or not registered, restart the gateway:
  ```bash
  openclaw gateway restart
  ```
- **Check Intents:** Verify "Message Content Intent" is enabled in Discord Developer Portal.

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
- Default for most coding tasks → Codex (free)
- Feature builds, refactors, boilerplate → Codex
- Parallel batch work (5+ simultaneous) → Codex (zero cost concern)
- PR reviews → Codex
- Complex architecture / system design → Claude Code (better reasoning)
- Codex gets stuck or quality is subpar → Claude Code (escalation)
- Nuanced writing (outreach, RFI) → Claude Code
- Big features with independent subtasks → Both in parallel
- Time-critical, max throughput → Both

**Rule:** Start Codex. Escalate to Claude Code if quality > speed. Use both when time matters most.

**Usage:**
```bash
# Codex (one-shot, needs git repo)
codex exec --full-auto "Your prompt"

# Claude Code
ANTHROPIC_API_KEY=$(cat ~/.openclaw/secrets/anthropic-api-key.txt) claude -p "Your prompt"
```

---

## DGX Spark (Ollama)

**Tailscale IP:** 100.111.31.56
**Ollama endpoint:** http://100.111.31.56:11434
**Available model:** llama3.1:8b

---

## Telegram

**Bot:** @Charles1982bot
**Rod's chat ID:** 6091356144

---

## Coding Agent Workflow

### 1. Launch with codex-run.sh (not raw codex)
```bash
bash pty:true background:true workdir:~/pp-agent-work/pp-XXX command:"bash ~/.openclaw/workspace/scripts/codex-run.sh <issue> ~/pp-agent-work/pp-XXX '<prompt>'"
```

### 2. Monitor with agent-status.sh
```bash
bash scripts/agent-status.sh          # all agents
bash scripts/agent-status.sh 216      # specific issue
```

### 3. Pre-merge visual review (BEFORE merging)
```bash
bash scripts/pre-merge-review.sh permission-protocol/site 42
```

---

## Caddy / HTTPS Setup Runbook

**1. Cloudflare must be DNS-only (grey cloud), NOT proxied (orange cloud)** for HTTP-01 ACME.
**2. Port 80 must be open:** `ufw allow 80/tcp`
**3. Don't use nip.io** for prod HTTPS.
**4. Minimal Caddyfile:**
```
hooks.permissionprotocol.com {
    reverse_proxy localhost:3100
}
```
**5. Test:** `curl https://hooks.permissionprotocol.com/health`

---

## Infrastructure References

**Webhook server:** `https://hooks.permissionprotocol.com` (Fastify on pp-scout-sfo2)
- Droplet SSH: `ssh -i ~/.ssh/github_ed25519 root@64.23.210.36`
- Tailscale IP: `100.122.174.112`

**Sentry:** Token at `~/.openclaw/secrets/sentry-auth-token`. Script: `factory/scripts/error-sensor.sh`

**Expandi:** Placeholder limit: 300 chars (silently drops longer). Validate: `node pp-os/outreach/scripts/validate-messages.js leads.json`

**PullMatch:** Repo `pullmatch/app`, Vercel project `pullmatch`, Neon DB `pullmatch-db`.

---

## Blog Publishing (via Tor)

**Server IP blocked** from blog.xdares.com — use Tor proxy.
**Script:** `goals/xdares-seo-growth/scripts/publish_post.py`
**Tor must be running:** `brew services start tor`

---

## GitHub App Auth Reference
- **App JWT**: App ID + Private Key → global App-level calls.
- **Installation Token**: `POST /app/installations/{id}/access_tokens` → repo-level calls.
- **Rule**: 401/403 on repo-level call with JWT → you need an Installation Token.

---

## Prompt Cache Auditing
**Rule:** Run `scripts/prefix-telemetry.sh` to check for prefix hash drift.
**Cache-Control Boundary:** OpenClaw injects `cache_control: { type: "ephemeral" }` at end of system prompt. Dynamic content above this point kills cache.

---

## Render Stale JS Bundles
- **Symptom:** Code correct in `main`, browser shows old content.
- **Fix:** Manual Deploy with **Clear Build Cache** in Render dashboard.
