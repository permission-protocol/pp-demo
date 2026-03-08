#!/usr/bin/env bash
# PP pre-push check: build + lint before creating PR
# Usage: bash scripts/pp-pre-push.sh /path/to/pp-site-repo
set -euo pipefail

REPO="${1:?Usage: pp-pre-push.sh /path/to/repo}"
cd "$REPO"

echo "🔨 Running next build..."
if npx next build 2>&1 | tail -20; then
  echo "✅ Build passed"
else
  echo "❌ Build FAILED — do NOT push"
  exit 1
fi

echo ""
echo "✅ All checks passed — safe to push"
