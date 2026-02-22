# 🔒 Secure Charles Backup Setup

*How to lock down the charles-goldberg-backup repository so no one (including Charles) can modify it without Rod's approval*

---

## 🚨 Why This Matters

Without protection, Charles's automated backup script has **write access** to his own backup repository. This creates risks:
- Malicious code could corrupt the backup
- Accidental script errors could destroy recovery data  
- No audit trail of what changes when
- Charles could theoretically "edit his own memories"

**Secure backup = Rod must approve every change.**

---

## 🔧 Setup Steps (Rod Only)

### Step 1: Enable Branch Protection

Go to: https://github.com/rodchalski/charles-goldberg-backup/settings/branches

**Click "Add rule" and configure:**

```
Branch name pattern: main

Required settings:
☑️ Restrict pushes to matching branches
☑️ Require a pull request before merging
  ☑️ Require approvals: 1
  ☑️ Require review from CODEOWNERS  
  ☑️ Dismiss stale PR approvals when new commits are pushed
  ☑️ Restrict pushes that create files that match branch names

Security settings:
☑️ Restrict force pushes: ❌ (disabled)
☑️ Allow deletions: ❌ (disabled)
☑️ Include administrators: ☑️ (even you need approval!)
```

### Step 2: Install GitHub CLI (for automated PRs)

```bash
# On Mac
brew install gh

# Authenticate
gh auth login
```

### Step 3: Switch to Secure Backup Mode

Update HEARTBEAT.md to use `backup-evolution-secure.sh` instead of `backup-evolution.sh`

---

## 🔄 How Secure Backup Works

### Before (Direct Push - UNSAFE):
```
Charles changes → Git commit → Direct push to main → Backup updated
```

### After (PR Approval - SECURE):
```
Charles changes → Git commit → New branch → Pull Request → Rod reviews → Rod approves → Backup updated
```

### Daily Workflow:
1. **Charles evolves** (conversations, new memories, script updates)
2. **Heartbeat triggers** secure backup script
3. **Script creates** new branch with changes
4. **GitHub PR created** automatically with review checklist
5. **Rod gets notification** to review the evolution
6. **Rod approves** if changes look legitimate
7. **Backup updated** only after approval

---

## 📋 Rod's Review Process

When you get a PR notification:

### Quick Security Checklist:
- [ ] **Identity files unchanged** (SOUL.md, IDENTITY.md) unless intentionally updated
- [ ] **Memory additions legitimate** (actual conversation logs, not fabricated)
- [ ] **New scripts safe** (no suspicious commands or external calls)
- [ ] **Recovery docs intact** (no tampering with disaster recovery procedures)
- [ ] **Commit messages make sense** (not trying to hide malicious changes)

### Review Commands:
```bash
# See exactly what changed
git diff main..charles-evolution-TIMESTAMP

# Review specific files
git show HEAD:MEMORY.md
git show HEAD:memory/2026-02-22.md
```

### Approve or Reject:
- **Approve:** Merge the PR → Backup updated
- **Reject:** Close PR without merge → Changes discarded

---

## 🚨 Emergency Procedures

### If Backup is Compromised:
1. **Immediately revoke** Charles's write access
2. **Reset main branch** to last known good commit
3. **Investigate** what went wrong in recent PRs
4. **Restore Charles** from the clean backup

### If Charles is Corrupted:
1. **Clone backup repository** to new machine
2. **Follow DISASTER-RECOVERY-PLAN.md** steps
3. **Charles restored** with memories intact up to last approved backup

---

## ⚡ Benefits

✅ **Complete audit trail** - Every change tracked in PRs  
✅ **Rod maintains control** - Nothing changes without approval  
✅ **Prevents corruption** - Malicious changes can't sneak in  
✅ **Still automated** - Charles doesn't need to manually create PRs  
✅ **Emergency rollback** - Easy to revert to any previous state

**Rod becomes the "approval gateway" for Charles's evolution.**

---

*This system ensures that even if Charles is compromised, his backup remains pure and recoverable.*