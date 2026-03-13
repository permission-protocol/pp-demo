#!/bin/bash
# PP-001 PR Creation Gate — Authority C enforcement boundary
#
# This script MUST be called before any `gh pr create` in the PP-001 board executor.
# It is the enforcement boundary between intent (analyzing/planning) and execution
# (actual git push / PR create — the external/public action).
#
# Usage: pp-001-pr-gate.sh --draft-file <path>
#
# Where <path> is a file containing the PR description / plan for what is being created.
# The gate checks for a valid approval token whose content_hash matches this file.
#
# Exit 0 = GATE OPEN — proceed with PR creation
# Exit 1 = GATE CLOSED — do NOT create PR; create draft PR or move to Blocked
#
# Fail-closed: absent, expired, or hash-mismatched tokens → denied.
#
# ── Why this gate exists ───────────────────────────────────────────────────────
# PP-001 is Authority C (creates public PRs on permission-protocol/app).
# Without this gate, an agent could create PRs without explicit human approval.
# This gate enforces that a human (Rod, Telegram ID 6091356144) explicitly reviewed
# the draft and minted an approval token via mint-approval-token.sh.
#
# ── Indirect escalation path ──────────────────────────────────────────────────
# PP-002 (daily planner, Authority B) writes board state — it can add items to Backlog.
# PP-001 executes items from Ready. Rod is the bridge: only Rod moves Backlog → Ready.
# Even if PP-002 were compromised, it cannot move items to Ready directly.
# This gate adds a second checkpoint: even items in Ready require an approval token
# before PP-001 can create a PR. Two independent gates must both pass:
#   1. Rod manually moved the item to Ready (board state)
#   2. Rod minted an approval token matching the PR draft (this gate)
#
# ── How to get a token ─────────────────────────────────────────────────────────
# 1. PP-001 writes its draft to a file (e.g., /tmp/pp001-draft-<task>.md)
# 2. PP-001 hits this gate, which fails (no token yet)
# 3. PP-001 moves the board item to Blocked, notifies Rod via Telegram
# 4. Rod reviews the draft, then runs:
#    mint-approval-token.sh --process-id PP-001 --draft-file <path> --sender-id 6091356144
# 5. Next PP-001 run: gate passes, PR is created

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUDIT_LOG="${WORKSPACE:-$HOME/.openclaw/workspace}/company-os/governance/approval-log.jsonl"

DRAFT_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --draft-file) DRAFT_FILE="$2"; shift 2 ;;
    *) echo "ERROR: Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$DRAFT_FILE" ]; then
  echo "GATE_ERROR: --draft-file is required" >&2
  echo "  Provide the path to the PR description draft file." >&2
  exit 1
fi

if [ ! -f "$DRAFT_FILE" ]; then
  echo "GATE_ERROR: Draft file not found: $DRAFT_FILE" >&2
  exit 1
fi

# Compute hash of the draft file (same algorithm as mint-approval-token.sh)
CONTENT_HASH=$(sha256sum "$DRAFT_FILE" 2>/dev/null | awk '{print $1}' \
  || shasum -a 256 "$DRAFT_FILE" | awk '{print $1}')

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Call verify-approval.sh
VERIFY_RESULT=$("$SCRIPT_DIR/verify-approval.sh" PP-001 "$CONTENT_HASH" 2>&1) && VERIFY_EXIT=0 || VERIFY_EXIT=$?

if [ $VERIFY_EXIT -eq 0 ]; then
  echo "GATE_OPEN: $VERIFY_RESULT"
  # Log gate open event
  echo "{\"event\":\"PP001_GATE_OPEN\",\"draft_file\":\"$DRAFT_FILE\",\"content_hash\":\"$CONTENT_HASH\",\"timestamp\":\"$TIMESTAMP\"}" >> "$AUDIT_LOG" 2>/dev/null || true
  exit 0
else
  echo "GATE_CLOSED: $VERIFY_RESULT"
  echo ""
  echo "ACTION REQUIRED:"
  echo "  1. Move board item to Blocked (Human Input Required)"
  echo "  2. Notify Rod: draft hash = $CONTENT_HASH"
  echo "  3. Rod runs:"
  echo "     mint-approval-token.sh --process-id PP-001 --draft-file $DRAFT_FILE --sender-id 6091356144"
  echo "  4. Re-queue the item for next PP-001 run"
  # Log gate closed event
  echo "{\"event\":\"PP001_GATE_CLOSED\",\"draft_file\":\"$DRAFT_FILE\",\"content_hash\":\"$CONTENT_HASH\",\"reason\":\"$(echo "$VERIFY_RESULT" | head -1)\",\"timestamp\":\"$TIMESTAMP\"}" >> "$AUDIT_LOG" 2>/dev/null || true
  exit 1
fi
