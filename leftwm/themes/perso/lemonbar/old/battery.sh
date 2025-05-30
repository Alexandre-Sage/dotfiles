if [ -f /sys/class/power_supply/BAT0/capacity ]; then
    battery_level=$(cat /sys/class/power_supply/BAT0/capacity)
    battery_status=$(cat /sys/class/power_supply/BAT0/status)
    
    if [ "$battery_status" = "Charging" ]; then
        echo " ${battery_level}%"
    elif [ "$battery_level" -lt 20 ]; then
        echo "%{F$CRITICAL_COLOR} ${battery_level}%%{F-}"
    elif [ "$battery_level" -lt 50 ]; then
        echo "%{F$WARNING_COLOR} ${battery_level}%%{F-}"
    else
        echo " ${battery_level}%"
    fi
else
    echo " AC"
fi
