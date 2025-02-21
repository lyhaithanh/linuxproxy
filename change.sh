#!/bin/bash

# Function to validate IP address
validate_ip() {
  local ip="$1"
  if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    IFS='.' read -r -a octets <<< "$ip"
    for octet in "${octets[@]}"; do
      if ((octet > 255)); then
        return 1
      fi
    done
    return 0
  else
    return 1
  fi
}

# Function to validate port
validate_port() {
  local port="$1"
  if [[ $port =~ ^[0-9]+$ ]] && ((port >= 1 && port <= 65535)); then
    return 0
  else
    return 1
  fi
}

# Function to add proxy settings
add_proxy_settings() {
  local ip_address="$1"
  local port="$2"
  local username="$3"
  local password="$4"

  local proxy_settings="
export http_proxy=\"http://${username}:${password}@${ip_address}:${port}/\"
export https_proxy=\"http://${username}:${password}@${ip_address}:${port}/\"
export ftp_proxy=\"ftp://${username}:${password}@${ip_address}:${port}/\"
export rsync_proxy=\"rsync://${username}:${password}@${ip_address}:${port}/\"
export no_proxy=\"localhost,127.0.0.1,192.168.1.1,::1,*.local\"
export HTTP_PROXY=\"http://${username}:${password}@${ip_address}:${port}/\"
export HTTPS_PROXY=\"http://${username}:${password}@${ip_address}:${port}/\"
export FTP_PROXY=\"ftp://${username}:${password}@${ip_address}:${port}/\"
export RSYNC_PROXY=\"rsync://${username}:${password}@${ip_address}:${port}/\"
export NO_PROXY=\"localhost,127.0.0.1,192.168.1.1,::1,*.local\"
"

  # Backup existing /etc/environment
  sudo cp /etc/environment /etc/environment.bak

  # Append proxy settings to /etc/environment
  echo "$proxy_settings" | sudo tee -a /etc/environment

  echo "Proxy settings applied successfully!"
}

# Main script
clear
echo "Welcome to the Proxy Setup Script"

# Prompt user for proxy details in the format IP:PORT:USERNAME:PASSWORD
while true; do
  read -p "Nhập địa chỉ proxy (định dạng IP:PORT:USERNAME:PASSWORD): " proxy_input
  IFS=':' read -r ip_address port username password <<< "$proxy_input"

  if validate_ip "$ip_address" && validate_port "$port" && [[ -n "$username" && -n "$password" ]]; then
    break
  else
    echo "Định dạng không hợp lệ. Vui lòng nhập đúng định dạng IP:PORT:USERNAME:PASSWORD."
  fi
done

# Add proxy settings
add_proxy_settings "$ip_address" "$port" "$username" "$password"

echo "Proxy đã được cấu hình thành công. Vui lòng khởi động lại hệ thống hoặc đăng xuất và đăng nhập lại để áp dụng thay đổi."
