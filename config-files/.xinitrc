#!/bin/sh

setxkbmap fr
if xrandr | grep "HDMI-1 connected"; then
    xrandr --output HDMI-1 --primary --auto
    # Optional: disable laptop screen if you only want HDMI
    xrandr --output eDP-1 --off
fi
xrdb ~/.Xresources
feh --bg-scale ~/.local/wallpaper/arc_wp1.jpg &
exec leftwm
