#!/usr/bin/env bash
# PP post-deploy smoke test
# Usage: bash scripts/pp-smoke-test.sh [base_url]
set -euo pipefail

BASE="${1:-https://www.permissionprotocol.com}"
PASS=0
FAIL=0
RESULTS=""

check() {
  local name="$1" url="$2" expect="${3:-200}"
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" "$url" --max-time 10 2>/dev/null || echo "000")
  if [ "$code" = "$expect" ]; then
    RESULTS+="  ✅ $name ($code)\n"
    PASS=$((PASS + 1))
  else
    RESULTS+="  ❌ $name (got $code, expected $expect)\n"
    FAIL=$((FAIL + 1))
  fi
}

echo "🧪 PP Smoke Test — $BASE"
echo ""

# Core pages
check "Homepage" "$BASE/"
check "Review dashboard" "$BASE/review"
check "How it works" "$BASE/how-it-works"
check "Developers" "$BASE/developers" "307"
check "Pricing" "$BASE/pricing"

# API endpoints
check "Reviews API" "$BASE/api/reviews"
check "Review by ID (known)" "$BASE/api/review/cmmfhgf8z000ybnyzqqg2fosv"
check "Review 404" "$BASE/api/review/nonexistent" "404"

# Review page
check "Review page" "$BASE/review/cmmfhgf8z000ybnyzqqg2fosv"

echo -e "$RESULTS"
echo ""
if [ "$FAIL" -gt 0 ]; then
  echo "❌ $FAIL/$((PASS+FAIL)) checks FAILED"
  exit 1
else
  echo "✅ All $PASS checks passed"
fi
