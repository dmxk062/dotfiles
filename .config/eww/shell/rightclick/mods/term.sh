#!/usr/bin/bash
eww -c $XDG_CONFIG_HOME/eww/shell close rc_popup
read -r pos size <<< "$(slurp -w 0 -b "#4c566acc" -s "#ffffff00")"
x=${pos%%,*} 
y=${pos#*,}
w=${size%%x*} 
h=${size#*x}
kitty --directory="~"&
pid=$!
sleep 0.2
hyprctl --batch "dispatch togglefloating pid:${pid} ; dispatch resizewindowpixel exact ${w} ${h},pid:${pid}; dispatch movewindowpixel exact ${x} ${y},pid:${pid}"
