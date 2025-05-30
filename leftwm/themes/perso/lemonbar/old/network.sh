 # Check for active network interface
 if ip route | grep -q "default"; then
     interface=$(ip route | grep default | awk '{print $5}' | head -n1)
     if [[ $interface == wl* ]]; then
         # Wireless connection
         signal=$(sudo grep "^\s*$interface:" /proc/net/wireless | awk '{print int($3 * 70 / 70)"%"}')
         echo " ${signal}"
     else
         # Wired connection
         echo "󰱓Connected"
     fi
 else
     echo "%{F$CRITICAL_COLOR}󰤮 Offline%{F-}"
 fi
