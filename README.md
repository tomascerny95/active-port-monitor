# Active Port Monitor

An ultra-lightweight, dynamic service portal and active port dashboard built directly into **Nginx** using the embedded **Lua engine** (`libnginx-mod-http-lua`).

Runs on default HTTP port **80** with **zero background Python processes and zero extra RAM overhead**.

---

## ✨ Features
- **⚡ Zero Extra RAM Overhead:** No heavy Python, Node.js, or Docker daemons running in the background. Nginx serves the dashboard directly using an ultra-fast in-memory Lua script.
- **🔄 Real-Time Dynamic Scanning:** Queries active listening ports on the host system (`ss -tnl`) on every page load. Start or stop any service on your server, hit refresh (`F5`), and it immediately updates!
- **🌐 Central Server Hub (Port 80):** Operates on standard port 80—simply type `http://<IP>/` or `http://<hostname>.local/` without typing port numbers.
- **🏷️ Smart Service Mapping:** Automatically resolves detected port numbers to human-readable names and correct connection protocols (`http://`, `ssh://`, `vnc://`).
- **🔒 Tailscale & VPN Friendly:** Works seamlessly over local network (LAN), mDNS (`.local`), or Tailscale VPN.
- **🎨 Modern Dark Web UI:** Clean, minimalist dark teal interface matching modern server dashboards.

---

## 🚀 Quick Start on Raspberry Pi / Linux

### Automated In-Place Installation

```bash
# 1. Clone the repository
cd ~
git clone https://github.com/tomascerny95/active-port-monitor.git

# 2. Enter folder, make script executable, and run installer
cd active-port-monitor
chmod +x setup_port_monitor.sh
sudo bash ./setup_port_monitor.sh
```

The script will automatically:
- Pull the latest commits from GitHub.
- Install `nginx` and `libnginx-mod-http-lua`.
- Configure the Nginx default site configuration with the dynamic Lua handler.
- Validate configuration syntax and restart Nginx.

---

## 🌐 Accessing the Dashboard

Open your web browser and navigate to:
```text
http://<DEVICE_IP>/
```
*(Also accessible via your Tailscale IP or `http://<hostname>.local/`).*

---

## 🛠️ Customizing Services & Ports

To add, edit, or rename mapped services, edit the `service_map` table inside the `default` configuration file:

```lua
local service_map = {
    ["22"]    = { name = "SSH Access",              protocol = "ssh://" },
    ["80"]    = { name = "Active Port Monitor",     protocol = "http://" },
    ["631"]   = { name = "Print Server (CUPS)",     protocol = "http://" },
    ["1111"]  = { name = "HDMI Server",             protocol = "http://" },
    ["2222"]  = { name = "Universal WoL Hub",       protocol = "http://" },
    ["5000"]  = { name = "TC-Media Video Player",   protocol = "http://" },
    ["5900"]  = { name = "VNC Remote Desktop",      protocol = "vnc://" },
    ["8080"]  = { name = "qBittorrent WebUI",       protocol = "http://" },
    ["8484"]  = { name = "Elegoo CC Family Hub",    protocol = "http://" },
    ["9999"]  = { name = "Televize",                protocol = "http://" },
}
```

After editing `default`, apply changes by re-running the installer:
```bash
sudo bash ./setup_port_monitor.sh
```

---

## 🔄 Updating to the Latest Version

To fetch updates and re-apply Nginx configuration:

```bash
cd ~/active-port-monitor
git fetch origin && git reset --hard origin/main && chmod +x setup_port_monitor.sh && sudo bash ./setup_port_monitor.sh
```

---

## 🔧 Service Management (Nginx)

```bash
# Check Nginx status
sudo systemctl status nginx

# Test configuration syntax
sudo nginx -t

# Reload configuration without dropping connections
sudo systemctl reload nginx

# View Nginx access & error logs
sudo tail -f /var/log/nginx/error.log
```

---

## 📄 License
This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.
