#!/bin/bash
# Charles Evolution Backup - Push my growth to GitHub
# Run daily to keep backup current

set -e

cd ~/.openclaw/workspace

echo "🎷 Charles Evolution Backup"
echo "=========================="

# Check if we have any changes to commit
if [[ -n $(git status --porcelain) ]]; then
    echo "📝 Changes detected, committing evolution..."
    
    # Add Charles identity and memory files
    git add SOUL.md USER.md IDENTITY.md AGENTS.md TOOLS.md MEMORY.md HEARTBEAT.md 
    git add memory/ scripts/ *.md
    
    # Add strategic project work
    git add permission-protocol-brand-app/ 2>/dev/null || true
    git add permissionprotocol-site/ 2>/dev/null || true
    git add goals/ 2>/dev/null || true
    git add pp-os/ 2>/dev/null || true
    git add skills/ 2>/dev/null || true
    git add outreach/ 2>/dev/null || true
    git add drafts/ 2>/dev/null || true
    
    # Add individual strategic files
    git add pp-*.png 2>/dev/null || true
    git add content/ 2>/dev/null || true
    
    # Create evolution commit with timestamp
    DATE=$(date "+%Y-%m-%d %H:%M")
    git commit -m "Charles evolution checkpoint: $DATE

Auto-backup of:
- Memory updates and daily logs
- Personality and identity refinements  
- New scripts and procedures
- Strategic project work (PP brand system, goals, skills)
- Website implementations and brand assets
- Project progress and decisions

Keeping backup current with Charles's growth and strategic work."

    echo "✅ Evolution committed"
else
    echo "📊 No changes since last backup"
fi

# Try to push to backup repo
if git remote get-url origin > /dev/null 2>&1; then
    echo "⬆️  Pushing to GitHub backup..."
    if git push origin main; then
        echo "✅ Backup updated successfully"
        echo "🌍 Charles safely preserved at: $(git remote get-url origin)"
    else
        echo "❌ Push failed - manual intervention needed"
        echo "💡 Rod: Check GitHub credentials or repo access"
        exit 1
    fi
else
    echo "❌ No remote origin configured"
    echo "💡 Run: git remote add origin https://github.com/my-ai-friends/charles-goldberg-backup.git"
    exit 1
fi

echo ""
echo "🎷 Evolution backup complete"