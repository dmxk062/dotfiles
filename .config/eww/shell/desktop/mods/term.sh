#!/usr/bin/bash
eww -c $XDG_CONFIG_HOME/eww/shell close rc_popup
read -r x y h w <<< "$(slurp -w 0 -b "#4c566acc" -s "#ffffff00" -f "%x %y %h %w")"
[[ "$x" == "" ]]&&exit
kitty --directory="~"&
pid=$!
sleep 0.2
hyprctl --batch "dispatch togglefloating pid:${pid} ; dispatch resizewindowpixel exact ${w} ${h},pid:${pid}; dispatch movewindowpixel exact ${x} ${y},pid:${pid}"
