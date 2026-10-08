#!/usr/bin/env bash
set -e

# Resolve absolute path to the git repository directory
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$REPO_DIR/active_port_monitor.py"

# Ensure script is executed with root/sudo privileges
if [ "$EUID" -ne 0 ]; then
  echo "[!] Please run this script with root privileges: sudo bash ./setup_port_monitor.sh"
  exit 1
fi

# Fully automatic detection of regular system user (UID >= 1000)
TARGET_USER="${SUDO_USER:-$(awk -F: '$3 >= 1000 && $3 < 60000 {print $1; exit}' /etc/passwd)}"

if [ -z "$TARGET_USER" ]; then
  echo "[!] Error: Failed to detect a valid system user!"
  exit 1
fi

echo "=========================================================="
echo "  Active Port Monitor Setup & Auto-Updater"
echo "  Running in-place from : $REPO_DIR"
echo "  Target User           : $TARGET_USER"
echo "=========================================================="

echo "=== [1/5] Stopping existing service (Safe Update) ==="
if systemctl is-active --quiet port-monitor.service 2>/dev/null; then
    echo "-> Stopping port-monitor.service..."
    systemctl stop port-monitor.service
fi

echo "=== [2/5] Pulling latest code from Git ==="
if [ -d "$REPO_DIR/.git" ]; then
    echo "-> Checking for updates on GitHub..."
    sudo -u "$TARGET_USER" git -C "$REPO_DIR" pull || echo "-> Note: Local changes present or already up to date."
fi

# Verify main python script presence
if [ ! -f "$PYTHON_SCRIPT" ]; then
  echo "[!] Error: active_port_monitor.py not found in $REPO_DIR!"
  exit 1
fi

echo "=== [3/5] Installing dependencies & virtual environment ==="
apt update
apt install -y python3 python3-pip python3-venv git curl

# Setup a clean Python venv inside the repo (PEP 668 compliant)
VENV_DIR="$REPO_DIR/venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "-> Creating Python virtual environment in $VENV_DIR..."
    sudo -u "$TARGET_USER" python3 -m venv "$VENV_DIR"
fi

echo "-> Installing / updating required Python libraries (psutil, fastapi, uvicorn)..."
sudo -u "$TARGET_USER" "$VENV_DIR/bin/pip" install --upgrade psutil fastapi uvicorn

# Ensure repository ownership for TARGET_USER
chmod +x "$PYTHON_SCRIPT"
chown -R "${TARGET_USER}:${TARGET_USER}" "$REPO_DIR"

echo "=== [4/5] Configuring systemd service ==="
cat << EOF > /etc/systemd/system/port-monitor.service
[Unit]
Description=Active Port Monitor ($TARGET_USER)
After=network.target

[Service]
Type=simple
User=$TARGET_USER
Group=$TARGET_USER
WorkingDirectory=$REPO_DIR
ExecStart=$VENV_DIR/bin/python $PYTHON_SCRIPT
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

echo "=== [5/5] Enabling and starting service ==="
systemctl daemon-reload
systemctl enable port-monitor.service
systemctl restart port-monitor.service

IP_ADDR=$(hostname -I | awk '{print $1}')

echo ""
echo "=========================================================="
echo " Setup complete! Active Port Monitor is ONLINE."
echo "=========================================================="
echo " Web Dashboard : http://${IP_ADDR}:9999"
echo " (Also accessible via Tailscale IP or <hostname>.local:9999)"
echo " Service Status: sudo systemctl status port-monitor"
echo " View Logs     : journalctl -u port-monitor -f"
echo "=========================================================="
