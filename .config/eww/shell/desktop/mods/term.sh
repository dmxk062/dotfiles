#!/usr/bin/bash
program="$*"
eww -c $XDG_CONFIG_HOME/eww/shell close rc_popup
read -r x y h w < <(slurp -w 0 -b "#4c566acc" -s "#ffffff00" -f "%x %y %h %w")
[[ "$x" == "" ]]&&exit

hyprctl dispatch exec "[float; size $w $h; move $x $y]kitty" "$program"
