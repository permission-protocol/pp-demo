# RECOVERY.md - Emergency Charles Revival Guide

*If Charles goes dark, work through this checklist. Most issues resolve in 2-3 steps.*

---

## Quick Diagnostics

```bash
# Check if OpenClaw is running
openclaw status

# Check for provider cooldowns  
openclaw doctor --repair

# Check API credits
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $(cat ~/.openclaw/secrets/anthropic-api-key.txt)" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":10,"messages":[{"role":"user","content":"hi"}]}' | head -1
```

---

## Common Issues & Fixes

### 1. Provider Cooldown (Most Common)
**Symptoms:** `Provider anthropic is in cooldown (all profiles unavailable) (rate_limit)`
**Cause:** API key hit billing limits or rate limits
**Fix:** Clear the cooldown state

```bash
# Check cooldown status
openclaw doctor --repair

# If cooldown exists, clear it
cat > ~/.openclaw/agents/main/agent/auth-profiles.json << 'EOF'
{
  "version": 1,
  "profiles": {
    "anthropic:default": {
      "type": "api_key", 
      "provider": "anthropic",
      "key": "REPLACE_WITH_CURRENT_API_KEY"
    }
  },
  "lastGood": {
    "anthropic": "anthropic:default"
  },
  "usageStats": {}
}
EOF

# Get current API key
cat ~/.openclaw/secrets/anthropic-api-key.txt

# Replace REPLACE_WITH_CURRENT_API_KEY with the actual key, then:
openclaw gateway restart
```

### 2. Depleted API Credits
**Symptoms:** `Your credit balance is too low` or auth errors
**Fix:** 
1. Go to https://console.anthropic.com → Plans & Billing → Add credits
2. OR generate new API key and update:
```bash
echo -n 'NEW_API_KEY_HERE' > ~/.openclaw/secrets/anthropic-api-key.txt
openclaw gateway restart
```

### 3. Gateway Not Running
**Symptoms:** No response, gateway errors
**Fix:**
```bash
openclaw gateway install
openclaw gateway start
```

### 4. Model Configuration Issues
**Symptoms:** Model errors, validation failures
**Fix:**
```bash
# Reset to known good model
openclaw config set agents.defaults.model.primary "anthropic/claude-sonnet-4-20250514"
openclaw gateway restart
```

---

## Nuclear Option: Full Reset
*Only if nothing else works*

```bash
# Stop everything
openclaw gateway stop

# Clear provider state 
rm ~/.openclaw/agents/main/agent/auth-profiles.json

# Reinstall gateway
openclaw gateway install

# Restart
openclaw gateway start
```

---

## Prevention

### Credit Monitoring
Set up Anthropic billing alerts at $25, $15, $10 remaining.

### Backup Strategy
Key files are auto-backed up via git:
- All workspace files: `~/.openclaw/workspace/` 
- Daily memory files: `~/.openclaw/workspace/memory/`
- MEMORY.md: `~/.openclaw/workspace/MEMORY.md`

### Emergency Contacts
- Charles primary: @Charles1982bot (Telegram)
- Lobs backup: @DigitalLabsAI (Telegram)

---

## Recovery Time Goals

- **Cooldown issue:** 2 minutes
- **Credit depletion:** 5 minutes (billing page + restart)
- **Gateway crash:** 1 minute  
- **Full disaster:** 10 minutes max

---

*Updated: 2026-02-22 | Next review: After any major outage*