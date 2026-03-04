# TOOLS.md — Local Notes

## Blog Publishing (via Tor)

**Script:** `goals/xdares-seo-growth/scripts/publish_post.py`
- Publishes via WordPress REST API through Tor
- Auto-generates AI images (Imagen 4.0)
- Compresses images to <100KB

**Usage:**
```bash
python3 goals/xdares-seo-growth/scripts/publish_post.py content/post-file.html
python3 goals/xdares-seo-growth/scripts/publish_post.py content/post-file.html --draft
```

**Tor must be running:** `service tor start`

## DGX Spark (Ollama)

**Endpoint:** http://100.111.31.56:11434
**Models:** deepseek-r1:70b, llama3.1:8b
**Use for:** QA judgments, content review, reasoning tasks (free)

## Metrics Pipeline

```bash
bash scripts/xdares-metrics-collect.sh        # Collect metrics
bash scripts/xdares-strategy-recommend.sh     # Generate recommendations
bash scripts/xdares-goal-auto-update.sh       # Inject tasks into goal executor
```

## Goal Executor

**State:** `goals/xdares-seo-growth/state.json`
**Status:** Stale since Feb 10, 126 tasks queued, needs restart

## Credentials

WordPress and other credentials will be configured via 1Password or environment variables.
Details TBD after workspace migration.

## Telegram

**Bot:** @maria_docean_bot
**Rod's chat ID:** 6091356144
