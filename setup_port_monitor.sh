#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure root privileges
if [ "$EUID" -ne 0 ]; then
  echo "[!] Please run this script with root privileges: sudo bash ./setup_port_monitor.sh"
  exit 1
fi

# Detect regular user
TARGET_USER="${SUDO_USER:-$(awk -F: '$3 >= 1000 && $3 < 60000 {print $1; exit}' /etc/passwd)}"

echo "=========================================================="
echo "  Active Port Monitor Setup & Auto-Updater"
echo "  Running in-place from : $REPO_DIR"
echo "=========================================================="

echo "=== [1/4] Pulling latest code from Git ==="
if [ -d "$REPO_DIR/.git" ]; then
    echo "-> Checking for updates on GitHub..."
    sudo -u "$TARGET_USER" git -C "$REPO_DIR" pull || echo "-> Note: Local changes present or already up to date."
fi

echo "=== [2/4] Installing Nginx & Lua module ==="
apt update
apt install -y nginx libnginx-mod-http-lua

echo "=== [3/4] Configuring Nginx site ==="
if [ ! -f "$REPO_DIR/default" ]; then
    echo "[!] Error: 'default' configuration file not found in $REPO_DIR!"
    exit 1
fi

cp "$REPO_DIR/default" /etc/nginx/sites-available/default
ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Test configuration syntax
nginx -t

echo "=== [4/4] Restarting Nginx ==="
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
