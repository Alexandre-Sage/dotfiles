#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
BG="#CC434a49"
# BG="#CC0f0f23"
FG="#ffffff"
BRIGHT_BLUE="#00d4ff"    # Very bright cyan-blue
# BRIGHT_GREEN="#ebf5f3"   # Very bright green  
BRIGHT_GREEN="#00ff88"   # Very bright green  
BRIGHT_ORANGE="#ff8800"  # Very bright orange
BRIGHT_PURPLE="#dd88ff"  # Very bright purple/magenta
BRIGHT_RED="#ff4444"     # Very bright red
BRIGHT_YELLOW="#ffdd00"  # Very bright yellow

# Lemonbar configuration script
# This script sets up and runs lemonbar with common options

# Color definitions
BG_COLOR=$BG        # Background color
FG_COLOR=$BRIGHT_BLUE           # Foreground (text) color
ACCENT_COLOR="#00ff00"       # Accent color for highlights
WARNING_COLOR="#ffaa00"      # Warning color (orange)
CRITICAL_COLOR="#ff0000"     # Critical color (red)

# Font settings
# FONT_MAIN="Adwaita Mono:size=10"
FONT_MAIN="Hack Nerd Font:style=Regular:size=10"
FONT_ICON="Hack Nerd Font:style=Regular:size=10"

# Bar dimensions and positioning
BAR_HEIGHT=24
BAR_WIDTH=1900              # Set to your screen width, or leave empty for full width
BAR_X_OFFSET=10              # X position offset
BAR_Y_OFFSET=7              # Y position offset (0 for top, -0 for bottom)

# Module update intervals (in seconds)
TIME_INTERVAL=0.5
BATTERY_INTERVAL=30
NETWORK_INTERVAL=5
VOLUME_INTERVAL=1

# Function to get current time
get_time() {
    date "+%H:%M:%S %d/%m/%Y"
}

# Function to get battery status
get_battery() {
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
}

# Function to get network status
get_network() {
    # Check for active network interface
    if ip route | grep -q "default"; then
        interface=$(ip route | grep default | awk '{print $5}' | head -n1)
        if [[ $interface == wl* ]]; then
            # Wireless connection
            signal=$(grep "^\s*$interface:" /proc/net/wireless | awk '{print int($3 * 70 / 70)"%"}')
            echo "📶 ${signal}"
        else
            # Wired connection
            echo "󰱓Connected"
        fi
    else
        echo "%{F$CRITICAL_COLOR}❌ Offline%{F-}"
    fi
}

# Function to get volume
get_volume() {
    if command -v amixer >/dev/null 2>&1; then
        volume=$(amixer get Master | grep -o '[0-9]*%' | head -n1)
        muted=$(amixer get Master | grep -o '\[off\]')
        
        if [ "$muted" ]; then
            echo "%{F$WARNING_COLOR}🔇 Muted%{F-}"
        else
            echo "🔊 ${volume}"
        fi
    else
        echo "󰖁 N/A"
    fi
}

# Function to get CPU usage
get_cpu() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
    echo " ${cpu_usage}"
}

# Function to get memory usage
get_memory() {
    memory_usage=$(free | grep Mem | awk '{printf("%.1f%%", $3/$2 * 100.0)}')
    echo " ${memory_usage}"
}

get_layout() {
    layout=$(leftwm-state -w 0 -s '{{ workspace.layout }}' -q) 
    echo "$layout"
}

get_worksapce() {
	workspace=$(leftwm-state -w 0 -t $SCRIPTPATH/template.liquid -q)
	echo "$workspace"
}

# Main function to generate bar content
generate_bar() {
    while true; do
        # Left side - workspace info
        left="%{l}%{F$BRIGHT_GREEN} $(get_layout) %{F-} | "
        left="${left}$(get_worksapce)"
	left="${left} |"
        # Center - time
        center="%{c}%{F$FG_COLOR}$(get_time)%{F-}"
        
        # Right side - system info
        right="%{r}"
        right="${right}$(get_cpu) | "
        right="${right}$(get_memory) | "
        right="${right}$(get_volume) | "
        right="${right}$(get_network) | "
        right="${right}$(get_battery) "
        
        # Combine all parts
        echo "${left}${center}${right}"
        
        sleep $TIME_INTERVAL
    done
}

# Lemonbar command with options
LEMONBAR_CMD=(
    lemonbar
    -p                          # Make bar persistent
    # -d                          # Dock the bar (reserve space)
    -B "$BG_COLOR"             # Background color
    -F "$FG_COLOR"             # Foreground color
    -f "$FONT_MAIN"            # Primary font
    -f "$FONT_ICON"            # Icon font
    -f 'Font Awesome 6 Free' 
    -f 'Font Awesome 6 Brands' 
    -f 'Font Awesome 6 Free Solid'
    # -g "${BAR_WIDTH}x${BAR_HEIGHT}+${BAR_X_OFFSET}+${BAR_Y_OFFSET}"  # Geometry
    -g "${BAR_WIDTH}x${BAR_HEIGHT}+${BAR_X_OFFSET}+${BAR_Y_OFFSET}"  # Geometry
    -n "lemonbar"              # Window name
    -a 32                      # Number of clickable areas
)

# Additional options you might want to uncomment:
# -u 2                        # Underline height
# -U "$ACCENT_COLOR"          # Underline color
# -o -2                       # Vertical font offset
# -R "$ACCENT_COLOR"          # Right border color
# -r 2                        # Right border width

# Run the bar
generate_bar | "${LEMONBAR_CMD[@]}"
