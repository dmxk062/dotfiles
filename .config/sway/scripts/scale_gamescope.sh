#!/usr/bin/env bash

PIDFILE="/run/user/$UID/.game_scaler"
DEFAULT_SCALE=1.4
SCREEN=DP-1
WORKSPACE=10

if [[ -f "$PIDFILE" ]] && [[ -d "/proc/$(< PIDFILE)" ]]; then
    exit
fi

echo "$$" > "$PIDFILE"

trap "rm $PIDFILE" EXIT

swaymsg --monitor -t subscribe '["workspace"]' \
    | jq -r --unbuffered --argjson ws "$WORKSPACE" \
    'select(.change == "focus" and .old.output == .current.output and (.old.num == $ws or .current.num == $ws))
    | (if .current.num == $ws then 1 else 0 end)' \
    | while read -r entered; do
        if ((entered)); then
            swaymsg output $SCREEN scale 1
        else
            swaymsg output $SCREEN scale $DEFAULT_SCALE
        fi
    done
