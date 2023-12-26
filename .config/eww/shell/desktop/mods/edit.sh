#!/usr/bin/env bash
eww -c $XDG_CONFIG_HOME/eww/shell close rc_popup
cd

file="$(zenity --file-selection --title="File Picker")"

if [[ "$file" != "" ]]
then
    read -r x y h w <<< "$(slurp -w 0 -b "#4c566acc" -s "#ffffff00" -f "%x %y %h %w")"
    [[ "$x" == "" ]]&&exit
    kitty --class="nvim" nvim "$file" -O& disown
    pid=$!
    sleep 0.2
    hyprctl --batch "dispatch togglefloating pid:${pid} ; dispatch resizewindowpixel exact ${w} ${h},pid:${pid}; dispatch movewindowpixel exact ${x} ${y},pid:${pid}"
fi



