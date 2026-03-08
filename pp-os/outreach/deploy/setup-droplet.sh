#!/usr/bin/env bash
# PP Scout Droplet Setup Script
# Run on fresh Ubuntu 24.04 droplet via SSH
# Usage: ssh root@<tailscale-ip> 'bash -s' < setup-droplet.sh

set -euo pipefail

echo "=== PP Scout Droplet Setup ==="

# --- System updates ---
echo "[1/8] System updates..."
apt-get update -qq && apt-get upgrade -y -qq
apt-get install -y -qq curl git sqlite3 ufw caddy

# --- Node.js 22 ---
echo "[2/8] Installing Node.js 22..."
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y -qq nodejs

# --- Firewall ---
echo "[3/8] Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow from 100.64.0.0/10 to any  # Tailscale subnet
ufw allow 443/tcp                      # HTTPS for webhook receiver
ufw --force enable

# --- Create directories ---
echo "[4/8] Creating directory structure..."
mkdir -p /opt/pp-scout/workspace
mkdir -p /opt/pp-outreach/{webhook-server,db,data/analysis,scripts}
mkdir -p /opt/pp-shared/{config,backups}

# --- Create pp user ---
echo "[5/8] Creating pp user..."
useradd -r -m -d /opt/pp-scout -s /bin/bash pp || true
chown -R pp:pp /opt/pp-scout /opt/pp-outreach /opt/pp-shared

# --- Deploy webhook server ---
echo "[6/8] Setting up webhook server..."
# Files should be copied here by deployment script
# For now, create placeholder systemd service

cat > /etc/systemd/system/pp-webhooks.service <<EOF
[Unit]
Description=PP Outreach Webhook Receiver
After=network.target

[Service]
Type=simple
User=pp
WorkingDirectory=/opt/pp-outreach/webhook-server
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=5
Environment=PORT=3100
Environment=DB_PATH=/opt/pp-outreach/db/outreach.sqlite
EnvironmentFile=-/opt/pp-shared/config/env

[Install]
WantedBy=multi-user.target
EOF

# --- Caddy reverse proxy ---
echo "[7/8] Configuring Caddy..."
cat > /etc/caddy/Caddyfile <<EOF
# PP Scout webhook receiver
# Uses Caddy's automatic HTTPS with Let's Encrypt
# Replace YOUR_DOMAIN with actual domain or use Tailscale HTTPS

:443 {
  reverse_proxy localhost:3100
}

# Also listen on :80 for health checks
:80 {
  respond /health "ok" 200
  redir / https://{host}{uri} permanent
}
EOF

# --- SQLite DB ---
echo "[8/8] Initializing database..."
if [ -f /opt/pp-outreach/db/schema.sql ]; then
  sqlite3 /opt/pp-outreach/db/outreach.sqlite < /opt/pp-outreach/db/schema.sql
  chown pp:pp /opt/pp-outreach/db/outreach.sqlite
  echo "Database initialized."
else
  echo "WARNING: schema.sql not found. Copy it to /opt/pp-outreach/db/ and run:"
  echo "  sqlite3 /opt/pp-outreach/db/outreach.sqlite < /opt/pp-outreach/db/schema.sql"
fi

# --- Daily backup cron ---
cat > /etc/cron.d/pp-backup <<EOF
# Daily SQLite backup at 2 AM
0 2 * * * pp sqlite3 /opt/pp-outreach/db/outreach.sqlite ".backup '/opt/pp-shared/backups/outreach-\$(date +\%Y\%m\%d).sqlite'" && find /opt/pp-shared/backups -name "outreach-*.sqlite" -mtime +7 -delete
EOF

echo ""
echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Copy webhook-server files to /opt/pp-outreach/webhook-server/"
echo "  2. Copy schema.sql to /opt/pp-outreach/db/"
echo "  3. Copy env file to /opt/pp-shared/config/env"
echo "  4. Run: cd /opt/pp-outreach/webhook-server && npm install"
echo "  5. Run: sqlite3 /opt/pp-outreach/db/outreach.sqlite < /opt/pp-outreach/db/schema.sql"
echo "  6. Run: systemctl enable --now pp-webhooks"
echo "  7. Run: systemctl restart caddy"
echo "  8. Install Docker for OpenClaw Scout agent"
echo ""
echo "Test: curl http://localhost:3100/health"
