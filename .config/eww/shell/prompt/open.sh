#!/usr/bin/env bash

eww="eww -c $XDG_CONFIG_HOME/eww/shell"
mode="$1"
if $eww close prompt_window; then
    hyprctl dispatch submap reset
else
    $eww open prompt_window
    hyprctl dispatch submap prompt
    if [[ -n $mode ]]; then
        $eww update prompt_current="$mode"
    fi
fi
