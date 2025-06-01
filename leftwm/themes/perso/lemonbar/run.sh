#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

source $SCRIPTPATH/style

ACCENT_COLOR="#00ff00"       # Accent color for highlights

# FONT_MAIN="Hack Nerd Font:style=Regular:size=10"
# FONT_ICON="Hack Nerd Font:style=Regular:size=10"

BAR_HEIGHT=24
BAR_Y_OFFSET=7              # Y position offset (0 for top, -0 for bottom)
# source $SCRIPTPATH/dimension.sh

workspace_idx_modules=0

get_volume() {
    if command -v amixer >/dev/null 2>&1; then
        volume=$(amixer get Master | grep -o '[0-9]*%' | head -n1)
        muted=$(amixer get Master | grep -o '\[off\]')
        
        if [ "$muted" ]; then
            echo "%{F$WARNING_COLOR}🔇 Muted%{F-}"
        else
            echo " ${volume}"
        fi
    else
        echo "󰖁 N/A"
    fi
}

main_bar() {

  # Named pipe setup
  pipe="/tmp/lemonbar-fifo"
  [[ -p "$pipe" ]] || mkfifo "$pipe"

  # Send status text into named pipe
  leftwm-state -w "$workspace_idx_modules" \
   -t "$SCRIPTPATH/template.liquid" > "$pipe" &
  "$SCRIPTPATH/clock-module" > "$pipe" &
  "$SCRIPTPATH/cpu-module" > "$pipe" &
  "$SCRIPTPATH/memory-module" > $pipe &
  "$SCRIPTPATH/network-module" > "$pipe" &
  "$SCRIPTPATH/battery-module" > "$pipe" &
  "$SCRIPTPATH/volume-module" > "$pipe" &
  printf 'K%s\n' "$(uname -sr)" > "$pipe" &

  # Process named pipe and give the status text to lemonbar
  # Sorted based on their first letter
  while read -r; do
      case "$REPLY" in
	  "$RAM_USAGE_ICON"*) local memory_usage=${REPLY} ;;
	  CPU*) local  cpu_usage=${REPLY:3} ;;
          K*) local kernel="${REPLY#?}" ;;
          C*) local clock="${REPLY#?}" ;;
	  N*) local network="${REPLY:1}" ;;
	  B*) local battery="${REPLY:1}" ;;
	  V*) local volume="${REPLY:1}" ;;
          *) local wm="${REPLY}" ;;
      esac

      printf '%s\n' "%{l}$wm%{c}$clock%{r}$cpu_usage %{F#6e6c7e}|%{F-} $memory_usage %{F#6e6c7e}|%{F-} $network %{F#6e6c7e}|%{F-} $battery %{F#6e6c7e}|%{F-} $volume %{F#6e6c7e}|%{F-} $kernel "
  done < "$pipe" | lemonbar -p \
	  -g "$1"  \
	  -B "$BG_COLOR" \
          -F "$FG_COLOR" \
	  -f "$FONT_MAIN" \
	  -f "$FONT_ICON" \
	  -f 'Font Awesome 6 Free' \
	  -f "Material Design Icons:style=Regular" \
	  -f "Material Design Icons Desktop:style=Regular" \
	  | sh

}

# Note: if you only use one workspace the remaining code can be pared down,
#       can be replaced with: main_bar "$your_size" &

# Workspace size(s)
sizes=( $(leftwm-state -qn -t "$SCRIPTPATH/sizes.liquid" | sed -r '/^\s*$/d') )

idx=0
for size in "${sizes[@]}"; do
  if [[ "$idx" -eq "$workspace_idx_modules" ]]; then
    main_bar "$size" &
  else
    # Instance(s) without modules
    leftwm-state -w "$idx" -t "$SCRIPTPATH/template.liquid" | lemonbar -p \
     -g "$size" -B "$background_color" | sh &
  fi

  (( idx++ ))
done
