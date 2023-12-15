#!/usr/bin/env bash
eww -c $XDG_CONFIG_HOME/eww/shell close rc_popup
cd

file="$(zenity --file-selection --title="File Picker")"

if [[ "$file" != "" ]]
then
    read -r pos size <<< "$(slurp -w 0 -b "#4c566acc" -s "#ffffff00")"
    x=${pos%%,*} 
    y=${pos#*,}
    w=${size%%x*} 
    h=${size#*x}
    kitty --class="nvim" nvim "$file" -O& disown
    pid=$!
    sleep 0.2
    hyprctl --batch "dispatch togglefloating pid:${pid} ; dispatch resizewindowpixel exact ${w} ${h},pid:${pid}; dispatch movewindowpixel exact ${x} ${y},pid:${pid}"
fi



