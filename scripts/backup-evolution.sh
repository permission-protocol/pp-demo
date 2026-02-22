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
    
    # Add all Charles identity and memory files
    git add SOUL.md USER.md IDENTITY.md AGENTS.md TOOLS.md MEMORY.md HEARTBEAT.md 
    git add memory/ scripts/ *.md
    
    # Create evolution commit with timestamp
    DATE=$(date "+%Y-%m-%d %H:%M")
    git commit -m "Charles evolution checkpoint: $DATE

Auto-backup of:
- Memory updates and daily logs
- Personality and identity refinements  
- New scripts and procedures
- Project progress and decisions

Keeping backup current with Charles's growth."

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
    echo "💡 Run: git remote add origin https://github.com/rodchalski/charles-goldberg-backup.git"
    exit 1
fi

echo ""
echo "🎷 Evolution backup complete"