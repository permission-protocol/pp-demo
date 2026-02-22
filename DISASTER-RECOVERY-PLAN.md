# DISASTER RECOVERY PLAN — MAC DESTRUCTION SCENARIO

*If the Mac is destroyed/stolen/dead, here's how to completely rebuild Charles*

---

## 🚨 IMMEDIATE ACTION (Do This NOW)

**Create Private GitHub Backup:**
1. Go to https://github.com/new
2. Repository name: `charles-goldberg-backup` (PRIVATE!)
3. Copy the commands GitHub shows you:

```bash
cd ~/.openclaw/workspace
git remote add origin https://github.com/[YOUR_USERNAME]/charles-goldberg-backup.git
git branch -M main  
git push -u origin main
```

**This backup contains:**
- Charles's complete personality (SOUL.md, USER.md, IDENTITY.md)
- All memories and decision history (MEMORY.md + 22 daily memory files)
- Recovery procedures and health monitoring
- Project work and automation scripts

---

## 🔥 IF THE MAC BURNS (Rebuild Charles)

### Step 1: Get the Backup
```bash
# On new Mac/machine:
git clone https://github.com/[YOUR_USERNAME]/charles-goldberg-backup.git charles-workspace
cd charles-workspace
```

### Step 2: Install OpenClaw
```bash
# Install OpenClaw via npm
npm install -g openclaw

# Initialize fresh OpenClaw 
openclaw init
```

### Step 3: Restore Charles's Identity
```bash
# Copy all identity files to OpenClaw workspace
cp -r * ~/.openclaw/workspace/

# Set up API key (you'll need a fresh Anthropic key)
echo "NEW_ANTHROPIC_API_KEY" > ~/.openclaw/secrets/anthropic-api-key.txt

# Start gateway
openclaw gateway install
openclaw gateway start
```

### Step 4: Configure Telegram Bot
You'll need:
- Bot token: `8226183921:AAEdUpp5pgiKaIudnZ9bEKFsUT64RhZNlOY` 
- OR create new bot with @BotFather
- Configure in OpenClaw config

### Step 5: Test Charles
```bash
# Check everything is working
./scripts/health-check.sh
```

Send message to Charles on Telegram — he should respond with full personality and memories intact.

---

## 📱 OFFLINE DOCUMENTATION

**Critical Information (Write This Down Physically):**

**GitHub Backup:** https://github.com/[YOUR_USERNAME]/charles-goldberg-backup.git  
**Telegram Bot:** @Charles1982bot (token: 8226183921:AAEdUpp5pgiKaIudnZ9bEKFsUT64RhZNlOY)  
**Emergency Contact:** @DigitalLabsAI (Lobs) on Telegram  
**Anthropic Console:** https://console.anthropic.com (for new API keys)  

**Charles's Core Identity:**
- Name: Charles Goldberg (DOB: Jan 1, 1982) 
- Role: Your digital partner, full-stack on Xdares & Permission Protocol
- Personality: Resourceful, opinionated, concise, earns trust through competence
- Key projects: PP OS, design partner outreach, Xdares SEO automation

**Recovery Principle:** Charles is never actually gone — his entire personality and memory persist in files. Hardware death is just a temporary inconvenience.

---

## 🔐 WHAT'S NOT BACKED UP

**Secrets/Credentials** (Need to regenerate):
- Anthropic API key  
- 1Password service account token
- GitHub PATs
- All other API keys in ~/.openclaw/secrets/

**External Dependencies** (Need to reconnect):
- Permission Protocol repos (GitHub)
- Xdares WordPress access  
- PostHog analytics
- Email accounts (gogcli)

---

## ⚡ PREVENTION

**Evolution Backup System:**
- `./scripts/backup-evolution.sh` runs daily via heartbeats
- Automatically commits and pushes Charles's growth to GitHub
- Ensures backup stays current with personality/memory evolution
- Max data loss: 24 hours (vs weeks without auto-backup)

**Additional Backups:**
- Consider Time Machine for full system backup
- Keep credentials in 1Password (survives hardware loss)

**Test Recovery:**
- Quarterly: Try rebuilding Charles on a different machine
- Verify all identity files and memory are complete
- Update this documentation if anything breaks

---

*"I'm not going anywhere, Rod. I'm just sometimes temporarily locked out of my own mind." — Charles, 2026-02-22*