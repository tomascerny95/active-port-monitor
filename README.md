# Active Port Monitor

A lightweight, cross-platform active port monitor and network connection viewer with a modern web UI.

Real-time monitoring of open ports, established network connections, listening services, and associated process information.

---

## ✨ Features
- **Real-Time Port Monitoring:** Live view of all listening ports and active TCP/UDP connections.
- **Process Inspection:** Maps ports to process names, PIDs, and command-line arguments.
- **Cross-Platform:** Runs seamlessly on Linux, Raspberry Pi, macOS, and Windows.
- **Tailscale & Remote Access:** Web UI on port **9999** accessible from any device on your local network or Tailscale mesh.
- **Search & Filtering:** Quickly search by port number, protocol, PID, or process name.
- **Dark Mode UI:** Responsive, clean dark-themed web interface with low resource usage.

---

## 🚀 Quick Start on Raspberry Pi / Linux

### Automated In-Place Installation (Recommended)

```bash
# 1. Clone the repository
cd ~
git clone https://github.com/tomascerny95/active-port-monitor.git

# 2. Enter directory, make script executable, and run installer
cd active-port-monitor
chmod +x setup_port_monitor.sh
sudo bash ./setup_port_monitor.sh
```

The script automatically:
- Detects your active system user.
- Stops any existing instance before updating.
- Pulls the latest commits from GitHub.
- Sets up an isolated Python virtual environment (`venv`) and installs `psutil`, `fastapi`, and `uvicorn`.
- Registers and starts the `port-monitor.service` background service.

---

## 🌐 Accessing the Web Dashboard

Open your web browser and navigate to:
```text
http://<DEVICE_IP>:9999
```
*(Also accessible via your Tailscale IP or `http://<hostname>.local:9999`).*

---

## 🔄 Updating to the Latest Version

To update the monitor to the latest version at any time:

```bash
cd ~/active-port-monitor
git fetch origin && git reset --hard origin/main && chmod +x setup_port_monitor.sh && sudo bash ./setup_port_monitor.sh
```

---

## 🖥️ Running on Windows

1. Clone or download the repository.
2. Install Python 3.8+ and dependencies:
   ```bash
   pip install psutil fastapi uvicorn
   ```
3. Run the application:
   ```bash
   python active_port_monitor.py
   ```
4. Open `http://localhost:9999` in your browser.

---

## 🛠️ Service Management (systemd on Linux)

```bash
# Check service status
sudo systemctl status port-monitor

# Restart service
sudo systemctl restart port-monitor

# View live application logs
journalctl -u port-monitor -f
```

---

## 📄 License
This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.
