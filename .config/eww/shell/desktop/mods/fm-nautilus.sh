#!/usr/bin/bash
eww -c $XDG_CONFIG_HOME/eww/shell close rc_popup
read -r x y h w <<< "$(slurp -w 0 -b "#4c566acc" -s "#ffffff00" -f "%x %y %h %w")"
[[ "$x" == "" ]]&&exit
gsettings set org.gnome.nautilus.window-state initial-size "(${w}, ${h})"
nautilus -w & disown
sleep 0.3
hyprctl dispatch movewindowpixel exact ${x} ${y},address:$(hyprctl -j activewindow|jq -r ".address")
