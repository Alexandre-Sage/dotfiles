get_screen_info() {
    if command -v xrandr >/dev/null 2>&1; then
        # Get primary monitor dimensions using xrandr
        SCREEN_WIDTH=$(xrandr --query | grep ' connected primary' | grep -o '[0-9]*x[0-9]*' | cut -d'x' -f1)
        if [ -z "$SCREEN_WIDTH" ]; then
            # Fallback: get first connected monitor
            SCREEN_WIDTH=$(xrandr --query | grep ' connected' | head -n1 | grep -o '[0-9]*x[0-9]*' | cut -d'x' -f1)
        fi
    elif command -v xdpyinfo >/dev/null 2>&1; then
        # Alternative method using xdpyinfo
        SCREEN_WIDTH=$(xdpyinfo | grep dimensions | awk '{print $2}' | cut -d'x' -f1)
    else
        # Default fallback
        SCREEN_WIDTH=1920
        echo "Warning: Could not detect screen width, using default: $SCREEN_WIDTH"
    fi
    
    # Ensure we have a valid width
    if [ -z "$SCREEN_WIDTH" ] || [ "$SCREEN_WIDTH" -eq 0 ]; then
        SCREEN_WIDTH=1920
        echo "Warning: Invalid screen width detected, using default: $SCREEN_WIDTH"
    fi
}

# Calculate bar dimensions based on screen size
calculate_bar_dimensions() {
    get_screen_info
    
    # Calculate bar width (screen width - 20px)
    BAR_WIDTH=$((SCREEN_WIDTH - 20))
    
    # Calculate X offset to center the bar
    # (screen width - bar width) / 2
    BAR_X_OFFSET=$(((SCREEN_WIDTH - BAR_WIDTH) / 2))
    
    echo "Screen width: ${SCREEN_WIDTH}px"
    echo "Bar width: ${BAR_WIDTH}px"
    echo "X offset: ${BAR_X_OFFSET}px"
}

# Call the function to set dimensions
calculate_bar_dimensions
