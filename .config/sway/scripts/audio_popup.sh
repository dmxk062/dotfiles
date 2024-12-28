#!/bin/bash

POPUP_ID=1766
ID_FILE="/run/user/1000/.popup"

case "$2" in
raise)
    wpctl set-volume @"$1"@ "${3}%+" -l 1 &
    ;;
lower)
    wpctl set-volume @"$1"@ "${3}%-" -l 1 &
    ;;
mute)
    wpctl set-mute @"$1"@ "toggle" &
    ;;
set)
    wpctl set-volume @"$1"@ "$3" -l 1 &
    ;;
esac

if [[ "$1" == "DEFAULT_SINK" ]]; then
    icon="audio-headphones"
    name="Output"
    devname="$(pactl --format=json list sinks|jq --arg active "$(pactl get-default-sink)" '.[]|select(.name == $active)|.properties."device.description"' -r)"
    volume="$(pamixer --get-volume)"
    muted="$(pamixer --get-mute)"
else
    icon="audio-input-microphone"
    name="Input"
    devname="$(pactl --format=json list sources|jq --arg active "$(pactl get-default-source)" '.[]|select(.name == $active)|.properties."device.description"' -r)"
    volume="$(pamixer --get-volume --default-source)"
    muted="$(pamixer --get-mute --default-source)"
fi

if [[ -f "$ID_FILE" ]]; then
    read -r id <"$ID_FILE"
    rm "$ID_FILE"
fi

id=${id:-$POPUP_ID}
display_volume="$volume"
if [[ "$muted" == "true" ]]; then
    volume="0"
fi
notify-send -r "$id" --transient --print-id -t 1000 \
    "Audio $name: $display_volume%" "$devname" -i "$icon" --hint=int:value:$volume > "$ID_FILE"
