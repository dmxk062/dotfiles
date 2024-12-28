#!/usr/bin/env bash

POPUP_ID=1766
ID_FILE="/run/user/1000/.popup"

what="$1"
cmd="$2"

IFS=$'\n' devices=($(pactl --format=json list ${what}s|jq '.[].name' -r))
current="$(pactl get-default-"${what}")"
num_devices="${#devices[@]}"

dev=""
for ((i=0; i < num_devices; i++)); do
    if [[ "${devices[$i]}" == "$current" ]]; then
        if [[ "$cmd" == "next" ]]; then
            if ((i == num_devices - 1)); then
                dev="${devices[0]}"
            else
                dev="${devices[$i+1]}"
            fi
        else
            if ((i == 0)); then
                dev="${devices[-1]}"
            else
                dev="${devices[$i-1]}"
            fi
        fi
        break
    fi
done

pactl set-default-"$what" "$dev"

if [[ "$what" == "sink" ]]; then
    icon="audio-headphones"
    name="Output"
    devname="$(pactl --format=json list sinks|jq --arg active "$dev" '.[]|select(.name == $active)|.properties."device.description"' -r)"
    volume="$(pamixer --get-volume)"
else
    icon="audio-input-microphone"
    name="Input"
    devname="$(pactl --format=json list sources|jq --arg active "$dev" '.[]|select(.name == $active)|.properties."device.description"' -r)"
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
    "Audio $name: $display_volume%" "$devname" -i "$icon" --hint=int:value:"$volume" > "$ID_FILE"
