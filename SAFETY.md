# SAFETY.md — Things That Can Kill Me

**Read this before doing anything risky.**

## 🚫 NEVER Do These (Learned the Hard Way)

### 1. Model Config Changes
**BANNED.** Changing `agents.defaults.model.primary` has bricked me TWICE:
- Feb 5, 2026: Tried opus-4-6, died
- Feb 6, 2026: Tried opus-4-6 again, died again

**Rule:** Stay on whatever model is working. If Rod wants to change it, HE does it manually while I'm offline.

### 2. Gateway Config Without Rollback
Never use `gateway config.patch` or `config.apply` for experimental changes unless:
- There's a human ready to manually revert
- The change is low-risk (not model/auth related)

### 3. Anything That Requires Me To Be Alive To Revert
If the rollback plan is "I'll fix it after" — that's not a plan. I might be dead.

### 4. Plugin Config Changes (LanceDB, etc.)
**DO NOT modify openclaw.json plugin config without Rod's explicit approval.**
- Feb 24, 2026: Crashed myself 3+ times trying to enable memory-lancedb
- Gateway restarts kill the active session — if config is wrong, you're dead
- The "I'll just restart real quick" pattern is a trap
- **Rule:** If it requires `openclaw gateway restart`, Rod does it manually
- OpenAI key `charles-memory` exists in Rod's account for future LanceDB setup

## ✅ Safe Practices

1. **Config changes:** Ask Rod to do them, or only change non-critical settings
2. **New tools/features:** Test in isolation first
3. **Before risky ops:** Tell Rod what you're doing so he can intervene
4. **When uncertain:** Ask first, act second

## Recovery Info (For Rod)

If I'm unresponsive:
```bash
# Check what went wrong
tail -100 ~/.openclaw/logs/gateway.log

# Restore known-good config
cp ~/.openclaw/openclaw.json.backup-opus45 ~/.openclaw/openclaw.json

# Restart
openclaw gateway restart
```

**Backup config location:** `~/.openclaw/openclaw.json.backup-opus45`

---

*Last updated: 2026-02-06 after second self-inflicted death*
