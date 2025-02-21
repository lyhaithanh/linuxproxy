#!/bin/bash

# Hỏi người dùng nhập thông tin proxy
read -p "Nhập địa chỉ proxy (định dạng IP:PORT:USERNAME:PASSWORD): " proxy_input

# Tách các thành phần của proxy
IFS=':' read -r ip port username password <<< "$proxy_input"

# Kiểm tra xem các giá trị có hợp lệ không
if [[ -z "$ip" || -z "$port" || -z "$username" || -z "$password" ]]; then
  echo "Định dạng proxy không hợp lệ. Vui lòng nhập lại."
  exit 1
fi

# Cấu hình proxy cho toàn bộ hệ thống
export http_proxy="http://$username:$password@$ip:$port"
export https_proxy="http://$username:$password@$ip:$port"
export ftp_proxy="http://$username:$password@$ip:$port"
export socks_proxy="http://$username:$password@$ip:$port"

# Cấu hình proxy cho apt (nếu có)
if [ -f /etc/apt/apt.conf ]; then
  echo "Acquire::http::Proxy \"http://$username:$password@$ip:$port\";" | sudo tee -a /etc/apt/apt.conf > /dev/null
  echo "Acquire::https::Proxy \"http://$username:$password@$ip:$port\";" | sudo tee -a /etc/apt/apt.conf > /dev/null
fi

# Cấu hình proxy cho môi trường shell
echo "export http_proxy=\"http://$username:$password@$ip:$port\"" | sudo tee -a /etc/environment > /dev/null
echo "export https_proxy=\"http://$username:$password@$ip:$port\"" | sudo tee -a /etc/environment > /dev/null
echo "export ftp_proxy=\"http://$username:$password@$ip:$port\"" | sudo tee -a /etc/environment > /dev/null
echo "export socks_proxy=\"http://$username:$password@$ip:$port\"" | sudo tee -a /etc/environment > /dev/null

# Thông báo thành công
echo "Proxy đã được cấu hình thành công cho toàn bộ hệ thống."
