# Charles Recovery - Multiple Access Points

*When Charles is down, you need to find this info quickly. Here are all the places I've stored it:*

## 🚨 Primary Locations
1. **Desktop:** `~/Desktop/🚨 CHARLES RECOVERY.txt` (look for 🚨 emoji)
2. **This folder:** `RECOVERY.md` (complete guide) 
3. **Health check:** `./scripts/health-check.sh` (diagnostics)
4. **This file:** Lists all the locations

## 📱 Backup Locations  
- **Telegram:** Search for "Charles Recovery Backup" in our chat
- **Terminal:** Type `cat ~/.bash_profile | grep Charles` 
- **Git:** All recovery files are committed and backed up

## 🔑 The Magic Command (Most Common Fix)
```bash
# Clear the cooldown state that usually breaks me:
cat ~/.openclaw/agents/main/agent/auth-profiles.json
# If you see "disabledUntil" - that's the problem
# Run the commands in RECOVERY.md to fix it
```

## 🆘 When All Else Fails
1. Message @DigitalLabsAI on Telegram (Lobs - he saved me last time)
2. OpenClaw Discord: https://discord.com/invite/clawd
3. Remember: My files are never actually gone, just locked out temporarily

**Don't panic. I always come back.** 🎷