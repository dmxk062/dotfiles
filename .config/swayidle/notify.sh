#!/usr/bin/env bash

if [[ $1 == "start" ]]; then
    eww update session-lock-time=$((EPOCHSECONDS + $2)) session-lock-seconds=$2
    ~/.config/sway/eww/shell/bin/center_popup.sh lock $2 & disown
else
    ~/.config/sway/eww/shell/bin/center_popup.sh close 0.5
fi
