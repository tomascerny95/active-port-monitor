#!/usr/bin/env python3
import os
import sys

# The Nginx/Lua configuration content
NGINX_CONFIG = """server {
    listen 80;
    server_name _;

    location / {
        default_type text/html;
        content_by_lua_block {
            -- Service mapping configuration
            local service_map = {
["22"]    = { name = "SSH Access",            protocol = "ssh://" },
["80"]    = { name = "Active Port Monitor",   protocol = "http://" },
["631"]   = { name = "Print Server (CUPS)",   protocol = "http://" },
["5900"]  = { name = "VNC",                   protocol = "vnc://" },
["1111"]  = { name = "HDMI Server",           protocol = "http://" },
["8484"]  = { name = "Elegoo CC Family Hub",  protocol = "http://" },
["8888"]  = { name = "Televize Legacy",       protocol = "http://" },
["9999"]  = { name = "Televize",              protocol = "http://" },
            }

            -- Retrieve list of listening ports
            local handle = io.popen("ss -tnl | grep LISTEN | awk '{print $4}' | cut -d: -f2 | sort -nu")
            local output = handle:read("*a")
            handle:close()

            local host = ngx.var.http_host

            -- HTML/CSS Output
            ngx.say("<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'>")
            ngx.say("<style>body{background-color:#030712; color:#f3f4f6; font-family:sans-serif; padding:2rem;}")
            ngx.say(".container{max-width:36rem; margin:0 auto;} .card{background:#111827; padding:1.5rem; border-radius:0.75rem; border:1px solid #1f2937; margin-bottom:1.5rem;}")
            ngx.say(".item{background:#030712; padding:1rem; border-radius:0.5rem; border:1px solid #1f2937; display:flex; justify-content:space-between; align-items:center; margin-bottom:0.75rem;}")
            ngx.say("h1{color:#2dd4bf; text-align:center; margin-bottom:0.5rem;} .desc{text-align:center; color:#6b7280; margin-bottom:1.5rem; font-size:0.9rem;}")
            ngx.say("a{color:#2dd4bf; text-decoration:none; font-weight:bold; background:#111827; padding:0.5rem 1rem; border:1px solid #2dd4bf; border-radius:0.4rem;}")
            ngx.say("a:hover{background:#2dd4bf; color:#030712;}</style></head><body>")
            
            ngx.say("<div class='container'><h1>Active Port Monitor</h1>")
            ngx.say("<p class='desc'>A dynamic overview of active services and ports running on your server.</p>")
            ngx.say("<div class='card'>")

            -- Process detected ports
            for port in string.gmatch(output, "([^\n]+)") do
                local sock = ngx.socket.tcp()
                sock:settimeout(100)
                local ok = sock:connect("127.0.0.1", port)
                
                if ok then
                    local service = service_map[port]
                    local name = service and service.name or ("Service on port " .. port)
                    local protocol = service and service.protocol or "http://"
                    
                    ngx.say("<div class='item'><div><h3 style='margin:0;'>" .. name .. "</h3>")
                    ngx.say("<p style='color:#6b7280; font-size:0.75rem; margin:0;'>Port: " .. port .. "</p></div>")
                    ngx.say("<a href='" .. protocol .. host .. ":" .. port .. "' target='_blank'>Connect</a></div>")
                    sock:close()
                end
            end

            ngx.say("</div></div></body></html>")
        }
    }
}
"""

TARGET_PATH = "/etc/nginx/sites-enabled/default"

def main():
    print("Nginx Active Port Monitor Config Generator")
    print("==========================================")
    
    try:
        # Attempt to write directly to Nginx configuration folder
        with open(TARGET_PATH, "w", encoding="utf-8") as f:
            f.write(NGINX_CONFIG)
        print(f"[SUCCESS] Successfully updated Nginx configuration at: {TARGET_PATH}")
        print("Please test and reload Nginx:")
        print("  sudo nginx -t")
        print("  sudo systemctl reload nginx")
        
    except PermissionError:
        print("[WARNING] Permission denied. Elevated privileges (sudo) are required to write directly to /etc/nginx.")
        print("Writing configuration to local file 'default' instead...")
        
        local_path = "default"
        with open(local_path, "w", encoding="utf-8") as f:
            f.write(NGINX_CONFIG)
            
        print(f"[SUCCESS] Local file '{local_path}' created.")
        print("\nTo apply this configuration, run:")
        print(f"  sudo cp {local_path} {TARGET_PATH}")
        print("  sudo nginx -t")
        print("  sudo systemctl reload nginx")
        
    except Exception as e:
        print(f"[ERROR] An unexpected error occurred: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
