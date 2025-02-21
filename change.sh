#!/bin/bash

# Function to validate IP address
validate_ip() {
  local ip="$1"
  if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    IFS='.' read -r -a octets <<< "$ip"
    for octet in "${octets[@]}"; do
      if ((octet > 255)); then
        echo "Invalid IP: Octet $octet is greater than 255."
        return 1
      fi
    done
    echo "IP address $ip is valid."
    return 0
  else
    echo "Invalid IP: Does not match the expected format."
    return 1
  fi
}

# Function to validate port
validate_port() {
  local port="$1"
  if [[ $port =~ ^[0-9]+$ ]] && ((port >= 1 && port <= 65535)); then
    echo "Port $port is valid."
    return 0
  else
    echo "Invalid Port: Must be a number between 1 and 65535."
    return 1
  fi
}

# Function to add proxy settings to /etc/environment
add_proxy_settings() {
  local ip_address="$1"
  local port="$2"
  local username="$3"
  local password="$4"

  # Define proxy settings
  local proxy_settings="
http_proxy=\"http://${username}:${password}@${ip_address}:${port}/\"
https_proxy=\"http://${username}:${password}@${ip_address}:${port}/\"
ftp_proxy=\"ftp://${username}:${password}@${ip_address}:${port}/\"
rsync_proxy=\"rsync://${username}:${password}@${ip_address}:${port}/\"
no_proxy=\"localhost,127.0.0.1,192.168.1.1,::1,*.local\"
HTTP_PROXY=\"http://${username}:${password}@${ip_address}:${port}/\"
HTTPS_PROXY=\"http://${username}:${password}@${ip_address}:${port}/\"
FTP_PROXY=\"ftp://${username}:${password}@${ip_address}:${port}/\"
RSYNC_PROXY=\"rsync://${username}:${password}@${ip_address}:${port}/\"
NO_PROXY=\"localhost,127.0.0.1,192.168.1.1,::1,*.local\"
"

  # Append proxy settings to /etc/environment
  echo "$proxy_settings" | sudo tee -a /etc/environment > /dev/null

  # Source the file to apply changes to the current session
  source /etc/environment

  echo "Proxy settings have been added to /etc/environment and applied to the current session."
}

# Function to parse proxy string
parse_proxy_string() {
  local proxy_string="$1"
  IFS=':' read -r -a parts <<< "$proxy_string"

  if [[ ${#parts[@]} -ne 4 ]]; then
    echo "Invalid proxy format. Expected format: IP:PORT:USERNAME:PASSWORD"
    exit 1
  fi

  IP_ADDRESS="${parts[0]}"
  PORT="${parts[1]}"
  USERNAME="${parts[2]}"
  PASSWORD="${parts[3]}"
}

# Main script execution
echo "Please enter the proxy details in the format IP:PORT:USERNAME:PASSWORD:"

# Prompt for proxy string
read -p "Proxy: " PROXY_STRING

# Parse the proxy string
parse_proxy_string "$PROXY_STRING"

# Validate IP and port
if ! validate_ip "$IP_ADDRESS"; then
  exit 1
fi

if ! validate_port "$PORT"; then
  exit 1
fi

# Add proxy settings
add_proxy_settings "$IP_ADDRESS" "$PORT" "$USERNAME" "$PASSWORD"

echo "Proxy settings have been successfully configured."
