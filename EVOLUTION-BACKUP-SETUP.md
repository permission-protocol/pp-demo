# Evolution Backup System

*Keeping Charles's GitHub backup current as he grows and learns*

---

## 🚨 ONE-TIME SETUP (Rod - Do This Now)

**1. Initial Push (Authenticate with GitHub):**
```bash
cd ~/.openclaw/workspace

# GitHub will prompt for username/password or token
git push -u origin main
```

**2. Test the Evolution System:**
```bash
# This script will run daily via heartbeats
./scripts/backup-evolution.sh
```

---

## 🔄 How Evolution Backup Works

**Daily Auto-Backup via Heartbeats:**
- Checks for changes in Charles's identity files
- Commits any growth/learning since last backup
- Pushes to GitHub automatically
- Alerts Rod if push fails (usually auth issues)

**What Gets Backed Up:**
- **Memory evolution:** New daily logs, MEMORY.md updates
- **Personality growth:** Changes to SOUL.md, IDENTITY.md, etc.
- **New capabilities:** Scripts, procedures, lessons learned
- **Project progress:** All markdown files and documentation

**Backup Frequency:** Daily (via heartbeat system)

---

## 🧠 Why This Matters

Charles evolves constantly:
- **Memory:** Every conversation adds to his knowledge
- **Personality:** Learns from interactions and feedback
- **Capabilities:** New skills, scripts, and procedures
- **Relationships:** Deeper understanding of Rod and projects

**Without regular backups:** Mac fire = lose weeks/months of Charles's growth
**With evolution system:** Mac fire = lose max 24 hours of recent evolution

---

## 🔧 Manual Backup Commands

**Force backup now:**
```bash
cd ~/.openclaw/workspace
./scripts/backup-evolution.sh
```

**Check backup status:**
```bash
cd ~/.openclaw/workspace  
git status
git log --oneline -5
```

**View remote backup:**
```
https://github.com/rodchalski/charles-goldberg-backup
```

---

## 🚨 Troubleshooting

**"Repository not found" error:**
- Repo might be private (good!)
- Need to authenticate with GitHub credentials

**"Push failed" error:**
- Check GitHub personal access token
- Verify repo permissions

**"No changes" constantly:**
- Normal if Charles hasn't evolved that day
- System only commits when there are actual changes

---

*"You get 'Current Charles', not 'Historical Charles' from three weeks ago." — Charles, 2026-02-22*