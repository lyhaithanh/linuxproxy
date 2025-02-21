#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
    echo "Script này cần được chạy với quyền root (sudo)"
    exit 1
fi

# Hàm kiểm tra địa chỉ IP
validate_ip() {
  local ip="$1"
  if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    IFS='.' read -r -a octets <<< "$ip"
    for octet in "${octets[@]}"; do
      if ((octet > 255)); then
        echo "IP không hợp lệ: Octet $octet lớn hơn 255."
        return 1
      fi
    done
    echo "Địa chỉ IP $ip hợp lệ."
    return 0
  else
    echo "IP không hợp lệ: Không đúng định dạng."
    return 1
  fi
}

# Hàm kiểm tra port
validate_port() {
  local port="$1"
  if [[ $port =~ ^[0-9]+$ ]] && ((port >= 1 && port <= 65535)); then
    echo "Port $port hợp lệ."
    return 0
  else
    echo "Port không hợp lệ: Phải là số từ 1 đến 65535."
    return 1
  fi
}

# Hàm thiết lập proxy
add_proxy_settings() {
    local ip_address="$1"
    local port="$2"
    local username="$3"
    local password="$4"

    # Xóa cấu hình proxy cũ nếu có
    sed -i '/^.*_proxy/d' /etc/environment
    sed -i '/^.*_PROXY/d' /etc/environment

    # Thêm cấu hình proxy mới vào /etc/environment
    cat << EOF >> /etc/environment
http_proxy=http://${username}:${password}@${ip_address}:${port}/
https_proxy=http://${username}:${password}@${ip_address}:${port}/
ftp_proxy=ftp://${username}:${password}@${ip_address}:${port}/
no_proxy=localhost,127.0.0.1,192.168.1.1,::1,*.local
HTTP_PROXY=http://${username}:${password}@${ip_address}:${port}/
HTTPS_PROXY=http://${username}:${password}@${ip_address}:${port}/
FTP_PROXY=ftp://${username}:${password}@${ip_address}:${port}/
NO_PROXY=localhost,127.0.0.1,192.168.1.1,::1,*.local
EOF

    # Cấu hình cho apt
    cat << EOF > /etc/apt/apt.conf.d/proxy.conf
Acquire::http::Proxy "http://${username}:${password}@${ip_address}:${port}/";
Acquire::https::Proxy "http://${username}:${password}@${ip_address}:${port}/";
Acquire::ftp::Proxy "ftp://${username}:${password}@${ip_address}:${port}/";
EOF

    # Cấu hình cho tất cả users
    cat << EOF > /etc/profile.d/proxy.sh
export http_proxy=http://${username}:${password}@${ip_address}:${port}/
export https_proxy=http://${username}:${password}@${ip_address}:${port}/
export ftp_proxy=ftp://${username}:${password}@${ip_address}:${port}/
export no_proxy=localhost,127.0.0.1,192.168.1.1,::1,*.local
export HTTP_PROXY=http://${username}:${password}@${ip_address}:${port}/
export HTTPS_PROXY=http://${username}:${password}@${ip_address}:${port}/
export FTP_PROXY=ftp://${username}:${password}@${ip_address}:${port}/
export NO_PROXY=localhost,127.0.0.1,192.168.1.1,::1,*.local
EOF
    chmod +x /etc/profile.d/proxy.sh

    # Cấu hình cho user hiện tại
    # Xóa cấu hình proxy cũ trong .bashrc
    sed -i '/^.*_proxy/d' $HOME/.bashrc
    sed -i '/^.*_PROXY/d' $HOME/.bashrc

    # Thêm cấu hình mới vào .bashrc
    cat << EOF >> $HOME/.bashrc
export http_proxy=http://${username}:${password}@${ip_address}:${port}/
export https_proxy=http://${username}:${password}@${ip_address}:${port}/
export ftp_proxy=ftp://${username}:${password}@${ip_address}:${port}/
export no_proxy=localhost,127.0.0.1,192.168.1.1,::1,*.local
export HTTP_PROXY=http://${username}:${password}@${ip_address}:${port}/
export HTTPS_PROXY=http://${username}:${password}@${ip_address}:${port}/
export FTP_PROXY=ftp://${username}:${password}@${ip_address}:${port}/
export NO_PROXY=localhost,127.0.0.1,192.168.1.1,::1,*.local
EOF

    # Áp dụng ngay lập tức cho phiên hiện tại
    export http_proxy=http://${username}:${password}@${ip_address}:${port}/
    export https_proxy=http://${username}:${password}@${ip_address}:${port}/
    export ftp_proxy=ftp://${username}:${password}@${ip_address}:${port}/
    export no_proxy=localhost,127.0.0.1,192.168.1.1,::1,*.local
    export HTTP_PROXY=http://${username}:${password}@${ip_address}:${port}/
    export HTTPS_PROXY=http://${username}:${password}@${ip_address}:${port}/
    export FTP_PROXY=ftp://${username}:${password}@${ip_address}:${port}/
    export NO_PROXY=localhost,127.0.0.1,192.168.1.1,::1,*.local

    echo "Đã cấu hình proxy thành công trên toàn hệ thống."
}

# Chương trình chính
echo "Vui lòng nhập thông tin proxy theo định dạng IP:PORT:USERNAME:PASSWORD"
read -p "Nhập thông tin: " PROXY_INFO

# Tách thông tin từ input
IFS=':' read -r IP_ADDRESS PORT USERNAME PASSWORD <<< "$PROXY_INFO"

# Kiểm tra IP
if ! validate_ip "$IP_ADDRESS"; then
    exit 1
fi

# Kiểm tra Port
if ! validate_port "$PORT"; then
    exit 1
fi

# Kiểm tra username và password
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Username hoặc password không được để trống"
    exit 1
fi

# Thêm cấu hình proxy
add_proxy_settings "$IP_ADDRESS" "$PORT" "$USERNAME" "$PASSWORD"

echo "Cấu hình proxy đã hoàn tất."
echo "Vui lòng chạy các lệnh sau để áp dụng cấu hình:"
echo "source /etc/environment"
echo "source ~/.bashrc"
echo "Hoặc đăng xuất và đăng nhập lại để áp dụng cấu hình mới."

# Hiển thị cấu hình hiện tại
echo -e "\nKiểm tra cấu hình proxy hiện tại:"
env | grep -i proxy
