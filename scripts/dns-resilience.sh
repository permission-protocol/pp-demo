#!/bin/bash
# scripts/dns-resilience.sh - Check and log DNS health for key services.
# Used to diagnose failures in Hotline Scans and Signal Capture.

LOG_FILE="/Users/moltbot/.openclaw/workspace/memory/connectivity-diagnostics.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

DOMAINS=("google.com" "github.com" "x.com" "news.ycombinator.com" "app.posthog.com")

echo "--- DNS Health Check: $TIMESTAMP ---" >> "$LOG_FILE"

FAILED=0
for domain in "${DOMAINS[@]}"; do
  if ! host "$domain" > /dev/null 2>&1; then
    echo "[FAIL] DNS resolution for $domain" >> "$LOG_FILE"
    FAILED=$((FAILED + 1))
  else
    echo "[OK] DNS resolution for $domain" >> "$LOG_FILE"
  fi
done

if [ $FAILED -gt 0 ]; then
  echo "[ADVISORY] $FAILED DNS resolutions failed. Suggestion: sudo killall -HUP mDNSResponder" >> "$LOG_FILE"
  # Note: Can't run sudo automatically without Rod, so we just log the recommendation.
fi

echo "Done." >> "$LOG_FILE"
