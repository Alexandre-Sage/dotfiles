#!/bin/bash

# Emergency Network Startup Script
# Place this in /etc/rc.local or run at startup if systemd doesn't work

echo "Starting emergency network configuration..."

# Find the network interface
INTERFACE=$(ip link show | grep -E "ens|eth|enp" | head -n1 | cut -d: -f2 | tr -d ' ')

if [ -n "$INTERFACE" ]; then
    echo "Bringing up interface: $INTERFACE"
    
    # Bring interface up
    ip link set $INTERFACE up
    
    # Start DHCP client
    dhcpcd $INTERFACE &
    
    # Alternative: use dhclient if dhcpcd not available
    # dhclient $INTERFACE &
    
    echo "Network startup initiated for $INTERFACE"
else
    echo "No network interface found!"
fi