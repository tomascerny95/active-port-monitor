#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure root privileges
if [ "$EUID" -ne 0 ]; then
  echo "[!] Please run this script with root privileges: sudo bash ./setup_port_monitor.sh"
  exit 1
fi

echo "=========================================================="
echo "  Active Port Monitor Setup (Nginx + Lua Dashboard)"
echo "=========================================================="

echo "=== [1/3] Installing Nginx & Lua module ==="
apt update
apt install -y nginx libnginx-mod-http-lua

echo "=== [2/3] Configuring Nginx site ==="
if [ ! -f "$REPO_DIR/default" ]; then
    echo "[!] Error: 'default' configuration file not found in $REPO_DIR!"
    exit 1
fi

cp "$REPO_DIR/default" /etc/nginx/sites-available/default
ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Test configuration
nginx -t

echo "=== [3/3] Restarting Nginx ==="
systemctl enable nginx
systemctl restart nginx

IP_ADDR=$(hostname -I | awk '{print $1}')

echo ""
echo "=========================================================="
echo " Setup complete! Port Monitor Dashboard is ONLINE."
echo "=========================================================="
echo " Access URL : http://${IP_ADDR}/"
echo " (Also accessible via http://<hostname>.local/ or Tailscale)"
echo "=========================================================="
