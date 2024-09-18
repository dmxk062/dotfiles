#!/bin/bash

POPUP_ID=1766
ID_FILE="/run/user/1000/hypr/$HYPRLAND_INSTANCE_SIGNATURE/popup"

read -r _ _ _ cur_bright _ < <(ddcutil -d 1 getvcp 10 -t --lazy-sleep --disable-dynamic-sleep --sleep-multiplier 0.1)
if [[ "$1" == "raise" ]]; then
    change=10
else
    change=-10
fi
new_bright=$((cur_bright + change))
new_bright=$((new_bright >= 100 ? 100 : (new_bright <= 0 ? 0 : new_bright)))

if [[ -f "$ID_FILE" ]]; then
    read -r id <"$ID_FILE"
    rm "$ID_FILE"
fi
id=${id:-$POPUP_ID}

notify-send -r "$id" --transient --print-id -t 1000 \
    "Display Brightness: $new_bright%" "May take some time to apply" -i "display" --hint=int:value:$new_bright >"$ID_FILE"

for ((d = 1; d <= $(hyprctl -j monitors | jq length); d++)); do
    ddcutil setvcp 10 -d $d $new_bright --lazy-sleep --disable-dynamic-sleep --sleep-multiplier 0.1 >/dev/null 2>&1 &
done
wait
