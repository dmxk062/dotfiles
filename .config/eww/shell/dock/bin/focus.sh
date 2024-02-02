#!/usr/bin/env bash

win="$1"
ws="$2"
if [[ "$ws" == special* ]]; then
    basename="${ws/special:/}"
    hyprctl dispatch togglespecialworkspace "$basename"
else
    oldcursor="$(hyprctl cursorpos)"
    hyprctl --batch  "dispatch focuswindow address:$win; dispatch movecursor ${oldcursor/,/}; dispatch alterzorder top, address:$win"
fi
