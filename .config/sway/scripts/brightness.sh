#!/usr/bin/env bash

function has_internal {
    [[ "$(ls /sys/class/backlight/* 2>/dev/null)" != "" ]] && command -v light 2>/dev/null
    return $?
}

case "$1" in
get)
    if has_internal; then
        light -G
    else
        ddcutil -d 1 getvcp 10 --lazy-sleep --sleep-multiplier 0.1 -t | cut -d" " -f4 | grep -v "Retrying"
    fi
    ;;
set)
    delta="$2"
    if has_internal; then
        if ((delta < 0)); then
            ((delta = -delta))
            light -U "$delta"
        else
            light -A "$delta"
        fi
        new_current=$(light -G)
        "$XDG_CONFIG_HOME/sway/eww/shell/bin/center_popup.sh" bright 2
        eww -c "$XDG_CONFIG_HOME/sway/eww/shell" update brightness="$new_current"
    else
        read -r _ _ _ current _ < <(ddcutil -d 1 getvcp 10 -t --lazy-sleep --sleep-multiplier 0.1)
        ((new = current + delta))
        ((new = new >= 100 ? 100 : (new <= 0 ? 0 : new)))
        for ((d = 1; d <= $(swaymsg -t get_outputs | jq 'length'); d++)); do
            ddcutil setvcp 10 -d $d $new --lazy-sleep --disable-dynamic-sleep --sleep-multiplier 0.1 >/dev/null
        done&
        eww -c "$XDG_CONFIG_HOME/sway/eww/shell" update brightness="$new"
        "$XDG_CONFIG_HOME/sway/eww/shell/bin/center_popup.sh" bright 2
        wait
    fi
    ;;
rawset)
    new="$2"
    if has_internal;  then
        light -S "$new"
    else
        for ((d = 1; d <= $(swaymsg -t get_outputs | jq 'length'); d++)); do
            ddcutil setvcp 10 -d $d $new --lazy-sleep --disable-dynamic-sleep --sleep-multiplier 0.1 >/dev/null 2>&1
        done
    fi
    eww -c "$XDG_CONFIG_HOME/sway/eww/shell" update brightness="$new"
esac
