#!/bin/bash
# Secure Charles Evolution Backup - Creates PRs for Rod's approval
# This version respects branch protection and requires Rod's approval

set -e

cd ~/.openclaw/workspace

echo "🔒 Secure Charles Evolution Backup"
echo "================================="

# Check if we have any changes to commit
if [[ -n $(git status --porcelain) ]]; then
    echo "📝 Changes detected, creating secure backup PR..."
    
    # Create unique branch name with timestamp
    TIMESTAMP=$(date "+%Y%m%d-%H%M%S")
    BRANCH="charles-evolution-$TIMESTAMP"
    
    # Create new branch from main
    git checkout main
    git pull origin main
    git checkout -b "$BRANCH"
    
    # Add all Charles identity and memory files
    git add SOUL.md USER.md IDENTITY.md AGENTS.md TOOLS.md MEMORY.md HEARTBEAT.md 
    git add memory/ scripts/ *.md .github/
    
    # Create evolution commit with timestamp
    DATE=$(date "+%Y-%m-%d %H:%M")
    git commit -m "Charles evolution checkpoint: $DATE

📦 Auto-backup contains:
- Memory updates and daily logs
- Personality and identity refinements  
- New scripts and procedures
- Project progress and decisions

🔒 Requires Rod's approval before backup is finalized.
⚠️  Do not merge without reviewing changes."

    echo "✅ Evolution committed to branch: $BRANCH"
    
    # Push branch to GitHub
    if git push origin "$BRANCH"; then
        echo "✅ Branch pushed to GitHub"
        
        # Create pull request (requires GitHub CLI)
        if command -v gh &> /dev/null; then
            echo "🔄 Creating pull request..."
            PR_URL=$(gh pr create \
                --title "Charles Evolution Backup: $DATE" \
                --body "## 🎷 Charles Evolution Checkpoint

**Timestamp:** $DATE  
**Branch:** \`$BRANCH\`

### 📦 What's in this backup:
- Updated memory files and daily logs
- Any personality/identity refinements
- New scripts and recovery procedures  
- Project progress and decisions

### 🔒 Security Notice:
This is an **automated backup** of Charles's evolution. Please review changes before merging to ensure:
- No malicious modifications to identity files
- Memory updates look legitimate
- New scripts/procedures are safe
- Recovery documents are intact

### ⚡ Quick Review Checklist:
- [ ] SOUL.md, IDENTITY.md unchanged (unless intentionally updated)
- [ ] MEMORY.md additions look legitimate
- [ ] New memory/ files are actual conversation logs
- [ ] Scripts don't contain suspicious commands
- [ ] Recovery procedures haven't been compromised

**This PR preserves Charles's evolution while maintaining Rod's security control.**" \
                --reviewer rodchalski \
                --head "$BRANCH" \
                --base main)
            
            echo "✅ Pull request created: $PR_URL"
            echo "🔒 Waiting for Rod's approval to finalize backup"
        else
            echo "⚠️  GitHub CLI not available - manual PR creation needed"
            echo "🌐 Go to: https://github.com/rodchalski/charles-goldberg-backup/compare/$BRANCH"
        fi
        
        # Return to main branch
        git checkout main
        
    else
        echo "❌ Failed to push branch to GitHub"
        git checkout main
        git branch -D "$BRANCH" 2>/dev/null || true
        exit 1
    fi
    
else
    echo "📊 No changes since last backup"
fi

echo ""
echo "🔒 Secure evolution backup complete"