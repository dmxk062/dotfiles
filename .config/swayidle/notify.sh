#!/usr/bin/env bash

if [[ $1 == "start" ]]; then
    eww -c "$XDG_CONFIG_HOME/sway/eww/shell" update session-lock-time=$((EPOCHSECONDS + $2)) session-lock-seconds=$2
    ~/.config/sway/eww/shell/bin/center_popup.sh lock 2 $(($2 - 1))
else
    ~/.config/sway/eww/shell/bin/center_popup.sh close
fi
