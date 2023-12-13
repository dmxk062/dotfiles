#!/usr/bin/bash
eww -c $XDG_CONFIG_HOME/eww/shell close rc_popup
read -r pos size <<< "$(slurp -w 0 -b "#4c566acc" -s "#ffffff00")"
x=${pos%%,*} 
y=${pos#*,}
w=${size%%x*} 
h=${size#*x}
nemo --geometry=${w}x${h}+0+0 --name=popup& disown
sleep 0.2
hyprctl dispatch movewindowpixel exact ${x} ${y},address:$(hyprctl -j activewindow|jq -r ".address")
