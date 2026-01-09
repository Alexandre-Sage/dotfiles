#!/bin/bash

# VM Network Persistence Setup Script
# This script creates the necessary files to make network configuration persistent
# Run this script INSIDE your VM to set up persistent networking

echo "=== VM Network Persistence Setup ==="
echo "This script will configure your VM for persistent networking"
echo "Choose your Linux distribution:"
echo "1) Ubuntu/Debian (systemd)"
echo "2) Arch Linux (systemd)"
echo "3) CentOS/RHEL/Fedora (NetworkManager)"
echo "4) Generic systemd setup"
read -p "Enter choice (1-4): " choice

# Detect network interface
INTERFACE=$(ip link show | grep -E "ens|eth|enp" | head -n1 | cut -d: -f2 | tr -d ' ')
if [ -z "$INTERFACE" ]; then
    echo "Warning: Could not detect network interface automatically"
    echo "Available interfaces:"
    ip link show
    read -p "Enter interface name (e.g., ens3, eth0): " INTERFACE
fi

echo "Using interface: $INTERFACE"

case $choice in
    1|2|4) # Ubuntu/Debian/Arch/Generic systemd
        echo "Creating systemd network configuration..."
        
        # Create systemd network file
        sudo tee /etc/systemd/network/50-dhcp.network > /dev/null << EOF
[Match]
Name=$INTERFACE

[Network]
DHCP=yes
IPv6AcceptRA=yes

[DHCP]
UseDNS=yes
UseNTP=yes
EOF

        # Enable systemd-networkd
        sudo systemctl enable systemd-networkd
        sudo systemctl enable systemd-resolved
        
        # Start services
        sudo systemctl start systemd-networkd
        sudo systemctl start systemd-resolved
        
        echo "Systemd network configuration created!"
        ;;
        
    3) # CentOS/RHEL/Fedora
        echo "Creating NetworkManager configuration..."
        
        # Create NetworkManager connection
        sudo nmcli con add type ethernet con-name "VM-Network" ifname $INTERFACE
        sudo nmcli con mod "VM-Network" connection.autoconnect yes
        sudo nmcli con mod "VM-Network" ipv4.method auto
        sudo nmcli con up "VM-Network"
        
        echo "NetworkManager configuration created!"
        ;;
esac

echo ""
echo "=== Network Status ==="
ip addr show $INTERFACE
echo ""
echo "=== Testing Connectivity ==="
ping -c 3 8.8.8.8
echo ""
echo "Setup complete! Network should now be persistent across reboots."