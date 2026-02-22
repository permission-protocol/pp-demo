# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

---

## GitHub Projects

**PAT for Projects API:** `~/.openclaw/secrets/github-pat-projects.txt`
**Scopes:** `project`, `read:project`, `repo`

**Boards:**
- [PP Marketing](https://github.com/orgs/Roca-Ventures/projects/1) — content, SEO, outreach
- [PP Product](https://github.com/orgs/Roca-Ventures/projects/2) — core product, deploy gates, features

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

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

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
