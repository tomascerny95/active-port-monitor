# Nginx Active Port Monitor (Default Site Config)

This repository contains a replacement configuration file for the default Nginx server block (`/etc/nginx/sites-enabled/default`). Using an integrated Lua block, it dynamically monitors and lists active services running on your server.

When accessing your server's IP address on port 80, the script scans for open TCP ports and displays them in a clean, responsive dark-themed dashboard with direct connection links.

## Prerequisites

For the Lua script inside the Nginx configuration to work, you need Nginx with Lua support and several standard system tools.

### 1. Nginx with Lua Support
On Debian/Ubuntu systems, you can install the necessary Lua modules by installing the `nginx-extras` package:
```bash
sudo apt update
sudo apt install nginx-extras
```
*(Alternatively, you can use OpenResty, which includes Lua support by default).*

### 2. System Tools
The script executes a shell pipeline to detect listening ports. The following utilities must be available in the system path:
* `ss`, `grep`, `awk`, `cut`, `sort`

## Installation and Setup

You can use the provided Python script to generate and write the configuration directly, or perform the steps manually.

### Option A: Using the Python Script
Run the helper script to replace the default Nginx configuration:
```bash
sudo python3 generate_config.py
```
If run without `sudo`, the script will safely generate a local file named `default` in your current directory, which you can copy manually.

### Option B: Manual Installation
1. **Back up your existing default configuration:**
   ```bash
   sudo cp /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default.bak
   ```
2. **Replace the content:**
   Open `/etc/nginx/sites-enabled/default` with your preferred editor and paste the configuration.
3. **Verify and restart Nginx:**
   ```bash
   sudo nginx -t
   sudo systemctl restart nginx
   ```

## Customization

You can customize service names and connection protocols directly in the configuration file under the `service_map` block:

```lua
local service_map = {
    ["22"]    = { name = "SSH Access",            protocol = "ssh://" },
    ["80"]    = { name = "Active Port Monitor",   protocol = "http://" },
    -- Add your custom ports here
}
```

If a port is active but not listed in the mapping, it defaults to `"Service on port <port>"` using `http://`.

## Security Considerations

* **Port Exposure:** Since this configuration listens on port 80 with `server_name _`, any visitor accessing your server's public IP address will see the list of active ports.
* **Restricting Access:** To protect this data, consider securing the location block with Basic Authentication, or restrict access to your local network/trusted IP addresses:
  ```nginx
  allow 192.168.1.0/24; # Allow local network
  deny all;             # Block everyone else
  ```
