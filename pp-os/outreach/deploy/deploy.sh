#!/usr/bin/env bash
# Deploy/update PP Outreach Engine to droplet
# Usage: ./deploy.sh <tailscale-ip>
# Example: ./deploy.sh 100.x.x.x

set -euo pipefail

DROPLET_IP="${1:?Usage: ./deploy.sh <tailscale-ip>}"
DROPLET_USER="root"  # Switch to pp user after initial setup
LOCAL_BASE="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Deploying PP Outreach Engine to $DROPLET_IP ==="

# --- Copy webhook server ---
echo "[1/4] Deploying webhook server..."
rsync -avz --delete \
  "$LOCAL_BASE/webhook-server/" \
  "$DROPLET_USER@$DROPLET_IP:/opt/pp-outreach/webhook-server/"

# --- Copy schema ---
echo "[2/4] Deploying database schema..."
rsync -avz \
  "$LOCAL_BASE/db/schema.sql" \
  "$DROPLET_USER@$DROPLET_IP:/opt/pp-outreach/db/"

# --- Copy scripts ---
echo "[3/4] Deploying scripts..."
rsync -avz \
  "$LOCAL_BASE/scripts/" \
  "$DROPLET_USER@$DROPLET_IP:/opt/pp-outreach/scripts/"

# --- Copy playbook ---
echo "[4/4] Deploying playbook..."
rsync -avz \
  "$LOCAL_BASE/playbook.json" \
  "$DROPLET_USER@$DROPLET_IP:/opt/pp-outreach/"

# --- Install deps + restart ---
echo "Installing dependencies and restarting..."
ssh "$DROPLET_USER@$DROPLET_IP" bash <<'REMOTE'
  cd /opt/pp-outreach/webhook-server
  npm install --production
  
  # Init DB if not exists
  if [ ! -f /opt/pp-outreach/db/outreach.sqlite ]; then
    sqlite3 /opt/pp-outreach/db/outreach.sqlite < /opt/pp-outreach/db/schema.sql
    chown pp:pp /opt/pp-outreach/db/outreach.sqlite
    echo "Database initialized."
  fi
  
  chown -R pp:pp /opt/pp-outreach
  systemctl restart pp-webhooks
  
  echo "Health check:"
  sleep 2
  curl -s http://localhost:3100/health || echo "WARNING: Health check failed"
REMOTE

echo ""
echo "=== Deploy complete ==="
echo "Webhook receiver: https://$DROPLET_IP:443/hooks/expandi"
echo "Health: https://$DROPLET_IP:443/health"
