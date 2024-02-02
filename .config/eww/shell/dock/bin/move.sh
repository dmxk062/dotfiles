#!/usr/bin/env bash

win="$1"
ws="$2"

if [[ "$ws" == "current" ]]; then
    { read -r name; read -r id; } <<< "$(hyprctl -j activeworkspace| jq -r '.name, .id')"
    if ! [[ "$name" == special* || "$name" == "$id" ]]; then
        name="name:$name"
    fi
    hyprctl dispatch movetoworkspacesilent "$name",address:"$win"
else
    hyprctl dispatch movetoworkspacesilent "$ws",address:"$win"
fi
