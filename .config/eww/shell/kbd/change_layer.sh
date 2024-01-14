#!/usr/bin/env bash

LOCKFILE="/tmp/eww/state/osk_tile"

case $1 in
    check)
        [ -f "$LOCKFILE" ]
        ;;
    toggle)
        if [ -f "$LOCKFILE" ]; then
            if eww -c $XDG_CONFIG_HOME/eww/shell close kbd_window_overlay; then
                eww -c $XDG_CONFIG_HOME/eww/shell open kbd_window
            fi

            rm "$LOCKFILE"
            eww -c $XDG_CONFIG_HOME/eww/settings update input_osk_overlay=false
        else
            touch "$LOCKFILE"
            if eww -c $XDG_CONFIG_HOME/eww/shell close kbd_window; then
                eww -c $XDG_CONFIG_HOME/eww/shell open kbd_window_overlay
            fi
            eww -c $XDG_CONFIG_HOME/eww/settings update input_osk_overlay=true

        fi
        ;;
esac
