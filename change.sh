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

# Main script execution
echo "Please enter the proxy details:"

# Prompt for IP address
while true; do
  read -p "IP Address: " IP_ADDRESS
  if validate_ip "$IP_ADDRESS"; then
    break
  else
    echo "Please enter a valid IP address."
  fi
done

# Prompt for Port
while true; do
  read -p "Port: " PORT
  if validate_port "$PORT"; then
    break
  else
    echo "Please enter a valid port number (1-65535)."
  fi
done

# Prompt for Username
read -p "Username: " USERNAME

# Prompt for Password
read -sp "Password: " PASSWORD
echo

# Add proxy settings
add_proxy_settings "$IP_ADDRESS" "$PORT" "$USERNAME" "$PASSWORD"

echo "Proxy settings have been successfully configured."
