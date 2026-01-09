#!/bin/bash

# Install VM Network Service Script
# Run this inside your VM to install the systemd service

echo "Installing VM Network Service..."

# Copy startup script to system location
sudo cp vm-startup-network.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/vm-startup-network.sh

# Copy service file to systemd
sudo cp vm-network.service /etc/systemd/system/

# Reload systemd and enable service
sudo systemctl daemon-reload
sudo systemctl enable vm-network.service

echo "VM Network Service installed!"
echo "The network will now start automatically on boot."
echo ""
echo "To test the service:"
echo "  sudo systemctl start vm-network.service"
echo "  sudo systemctl status vm-network.service"