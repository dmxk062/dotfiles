#!/usr/bin/env bash
command="$1"
class="$2"
cd||exit

read -r x y h w < <(slurp -w 0 -b "#4c566acc" -s "#ffffff00" -f "%x %y %h %w")
[[ "$x" == "" ]]&&exit

($command & disown)
socat "/run/user/$UID/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while IFS=">" read -r event rest; do
    if [[ "$event" == "openwindow" ]]; then
        if [[ "$rest" == *"$class"* ]]; then
            address="${rest:1:12}"
            hyprctl --batch "dispatch setfloating address:0x$address;dispatch resizewindowpixel exact $w $h,address:0x$address;dispatch movewindowpixel exact $x $y,address:0x$address"
            break
        fi
    fi
done
