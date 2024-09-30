#!/bin/bash

POPUP_ID=1766
ID_FILE="/run/user/1000/hypr/$HYPRLAND_INSTANCE_SIGNATURE/popup"

if [[ "$1" == "raise" ]]; then
    light -A 3
else
    light -U 3
fi
new_bright=$(light -G)

if [[ -f "$ID_FILE" ]]; then
    read -r id <"$ID_FILE"
    rm "$ID_FILE"
fi
id=${id:-$POPUP_ID}

notify-send -r "$id" --transient --print-id -t 1000 \
    "Display Brightness: ${new_bright%.*}%" "Internal Laptop Screen" -i "laptop" --hint=int:value:$new_bright >"$ID_FILE"

