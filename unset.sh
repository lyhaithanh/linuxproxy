#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "This script needs to be run as root (sudo)"
    exit 1
fi

# Function to remove proxy settings
remove_proxy_settings() {
    # Remove proxy settings from /etc/environment
    sed -i '/^.*_proxy/d' /etc/environment
    sed -i '/^.*_PROXY/d' /etc/environment

    # Remove apt proxy configuration
    rm -f /etc/apt/apt.conf.d/proxy.conf

    # Remove system-wide proxy settings
    rm -f /etc/profile.d/proxy.sh

    # Remove proxy settings from current user's .bashrc
    sed -i '/^.*_proxy/d' $HOME/.bashrc
    sed -i '/^.*_PROXY/d' $HOME/.bashrc

    # Unset current session proxy variables
    unset http_proxy https_proxy ftp_proxy no_proxy
    unset HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY

    echo "All proxy settings have been removed successfully."
}

# Main program
echo "Removing all proxy settings..."
remove_proxy_settings

echo "Applying changes..."

# Apply changes using different methods
bash
source /etc/environment
. /etc/environment
. ~/.bashrc

echo -e "\nVerifying current proxy settings:"
env | grep -i proxy

echo -e "\nProxy settings have been reset to default (direct connection)."
