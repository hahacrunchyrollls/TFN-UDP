#!/bin/bash

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if running as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        print_message "This script must be run as root" "$RED"
        exit 1
    fi
}

# Function to check and install dependencies
install_dependencies() {
    print_message "Checking and installing dependencies..." "$YELLOW"
    
    local deps=("wget" "screen" "lsof" "iptables")
    for dep in "${deps[@]}"; do
        if ! command_exists "$dep"; then
            apt-get update
            apt-get install -y "$dep"
        fi
    done
}

# Function to setup DNSTT directory and files
setup_dnstt() {
    print_message "Setting up DNSTT..." "$YELLOW"
    
    # Remove existing dnstt directory if exists
    rm -rf /root/dnstt
    mkdir -p /root/dnstt
    cd /root/dnstt || exit 1

    # Download required files
    print_message "Downloading required files..." "$YELLOW"
    wget -q https://github.com/yakult13/parte/raw/refs/heads/main/dnstt-server || {
        print_message "Failed to download dnstt-server" "$RED"
        exit 1
    }
    chmod 755 dnstt-server

    wget -q https://raw.githubusercontent.com/hahacrunchyrollls/DNSTT-AND-SSH-SCRIPT/refs/heads/main/server.key || {
        print_message "Failed to download server.key" "$RED"
        exit 1
    }

    wget -q https://raw.githubusercontent.com/hahacrunchyrollls/DNSTT-AND-SSH-SCRIPT/refs/heads/main/server.pub || {
        print_message "Failed to download server.pub" "$RED"
        exit 1
    }
}

# Function to configure firewall rules
setup_firewall() {
    print_message "Configuring firewall rules..." "$YELLOW"
    
    iptables -C INPUT -p udp --dport 5300 -j ACCEPT 2>/dev/null || {
        iptables -I INPUT -p udp --dport 5300 -j ACCEPT
    }
    
    iptables -t nat -C PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300 2>/dev/null || {
        iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
    }
}

# Function to create systemd service
create_systemd_service() {
    local ns=$1
    cat > /etc/systemd/system/dnstt.service <<EOF
[Unit]
Description=DNSTT Tunnel Server
Wants=network.target
After=network.target

[Service]
Type=simple
ExecStart=/root/dnstt/dnstt-server -udp :5300 -privkey-file /root/dnstt/server.key ${ns} 127.0.0.1:22
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable dnstt
    systemctl start dnstt
}

# Main installation function
main() {
    clear
    print_message "DNSTT, DoH and DoT Installation Script" "$GREEN"
    echo

    # Check if running as root
    check_root

    # Install dependencies
    install_dependencies

    # Setup DNSTT
    setup_dnstt

    # Display public key
    echo
    print_message "Server Public Key:" "$YELLOW"
    cat server.pub
    echo
    read -p "Copy the public key above and press Enter when done..."

    # Get nameserver
    while true; do
        read -p "Enter your Nameserver: " ns
        if [[ -n "$ns" ]]; then
            break
        else
            print_message "Nameserver cannot be empty. Please try again." "$RED"
        fi
    done

    # Setup firewall rules
    setup_firewall

    # Service setup
    echo
    while true; do
        read -p "Run in background (b) or as system service (s)? [b/s]: " service_type
        case $service_type in
            [Bb]*)
                print_message "Starting DNSTT in background..." "$YELLOW"
                screen -dmS slowdns ./dnstt-server -udp :5300 -privkey-file server.key "$ns" 127.0.0.1:22
                break
                ;;
            [Ss]*)
                print_message "Creating and starting system service..." "$YELLOW"
                create_systemd_service "$ns"
                break
                ;;
            *)
                print_message "Please enter 'b' for background or 's' for system service." "$RED"
                ;;
        esac
    done

    # Verify installation
    if lsof -i :5300 >/dev/null 2>&1; then
        print_message "DNSTT installation completed successfully!" "$GREEN"
        print_message "Service is running on port 5300" "$GREEN"
    else
        print_message "Installation completed but service is not running. Please check logs." "$RED"
    fi
}

# Run main installation
main
