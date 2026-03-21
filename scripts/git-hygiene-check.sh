#!/bin/bash
# scripts/git-hygiene-check.sh
# Simple check to prevent junk files from being committed.

# 1. Check for sensitive/junk patterns in staged files
STAGED_FILES=$(git diff --cached --name-only)

JUNK_PATTERNS=("node_modules" ".env" ".DS_Store" "npm-debug.log" "yarn-error.log" "package-lock.json" "yarn.lock")

echo "🔍 Running Git Hygiene Check..."

for file in $STAGED_FILES; do
  for pattern in "${JUNK_PATTERNS[@]}"; do
    if [[ "$file" == *"$pattern"* ]]; then
      echo "❌ ERROR: Staged junk file detected: $file"
      echo "Please unstage this file and use 'git add <specific files>' instead of 'git add .'"
      exit 1
    fi
  done
done

# 2. Check for potential secrets (basic entropy check or common prefixes)
if git diff --cached | grep -qE "sk-|ghp_|OP_"; then
  echo "❌ ERROR: Potential API key or secret detected in staged changes!"
  exit 1
fi

echo "✅ Git Hygiene Check passed."
exit 0
