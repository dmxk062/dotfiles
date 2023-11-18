#!/usr/bin/env bash

eww -c $XDG_CONFIG_HOME/eww/shell close rc_popup
sleep 0.5

create_temp() {
    mkdir -p /tmp/eww/cache/clip
    timestamp="$(date +'%Y_%m.%d_%H:%M:%S_sc')"
    echo "/tmp/eww/cache/clip/${timestamp}.png"
}
create_file() {
    dir="$(xdg-user-dir PICTURES)/Screenshots"
    timestamp="$(date +'%Y_%m.%d_%H:%M:%S_sc')"
    echo "${dir}/${timestamp}.png"
}
notify(){
    notify-send "$1" -i "$2" -c "screenshot"
}

case $1 in
    clip)
        file="$(create_temp)"
        clip=true;;
    disk)
        file="$(create_file)"
        clip=false;;
esac

active_window="$(hyprctl -j activewindow)"
geometry="$(echo "$active_window"|jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')"
grim -g "$geometry" "$file"
if $clip
then
    wl-copy < "$file" & disown
    notify "Copied Image to Clipboard" "$file"
else
    notify "Took Screenshot: $(basename "$file")" "$file"
fi
eww -c $XDG_CONFIG_HOME/eww/shell update rc_win_area=0
