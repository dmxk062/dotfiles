#!/bin/bash

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
    ~/.config/sway/eww/shell/bin/center_popup.sh audio out
else
    ~/.config/sway/eww/shell/bin/center_popup.sh audio in
fi
