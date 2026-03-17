#!/bin/bash
# scripts/rebase-factory-prs.sh
# Rebases all open feat/ branches against main to avoid Conflict Cascades.
# Usage: ./scripts/rebase-factory-prs.sh [repo-path]

REPO_PATH=${1:-.}
cd "$REPO_PATH" || exit 1

echo "Checking for open feat/ branches in $(pwd)..."

# Fetch latest main
git checkout main
git pull origin main

# Get list of open feat/ branches (local)
BRANCHES=$(git branch --list 'feat/*' | sed 's/* //')

for BRANCH in $BRANCHES; do
    echo "Rebasing $BRANCH against main..."
    git checkout "$BRANCH"
    if git rebase main; then
        echo "Successfully rebased $BRANCH. Pushing..."
        git push origin "$BRANCH" --force-with-lease
    else
        echo "Conflict detected on $BRANCH. Aborting rebase."
        git rebase --abort
    fi
done

git checkout main
echo "Done."
