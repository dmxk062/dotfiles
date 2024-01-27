#!/usr/bin/env bash

CACHEDIR="/tmp/eww/cache/clip"
notify(){
    format="$(printf '<img src="%s" alt="Screenshot">' "$2")"
    response="$(notify-send "$1" -c "screenshot" "$format" \
        --action="open"="Open" \
        --action="edit"="Edit" \
        --action="del"="Delete" 
    )"

    case $response in
        open)
            xdg-open "$2";;
        del)
            rm "$2";;
        edit)
            swappy -f "$2" -o "$2";;
    esac
}

eww -c $XDG_CONFIG_HOME/eww/shell close rc_popup
sleep 0.5



create_temp() {
    timestamp="$(date +'%Y_%m.%d_%H:%M:%S_sc')"
    echo "${CACHEDIR}/${timestamp}.png"
}
create_file() {
    dir="$(xdg-user-dir PICTURES)/Screenshots"
    timestamp="$(date +'%Y_%m.%d_%H:%M:%S_sc')"
    echo "${dir}/${timestamp}.png"
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
geometry="$(echo "$active_window"|jaq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')"
grim -g "$geometry" "$file"
if $clip
then
    wl-copy < "$file" & disown
    notify "Copied Image to Clipboard" "$file"
else
    notify "Took Screenshot: $(basename "$file")" "$file"
fi
eww -c $XDG_CONFIG_HOME/eww/shell update rc_win_area=0
