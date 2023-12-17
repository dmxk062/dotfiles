#!/usr/bin/env bash

case $1 in
    check)
        [ -f /tmp/.eww_osk_overlay ]
        ;;
    toggle)
        if [ -f /tmp/.eww_osk_overlay ]; then
            if eww -c $XDG_CONFIG_HOME/eww/shell close kbd_window_overlay; then
                eww -c $XDG_CONFIG_HOME/eww/shell open kbd_window
            fi

            rm /tmp/.eww_osk_overlay
            eww -c $XDG_CONFIG_HOME/eww/settings update input_osk_overlay=false
        else
            touch /tmp/.eww_osk_overlay
            if eww -c $XDG_CONFIG_HOME/eww/shell close kbd_window; then
                eww -c $XDG_CONFIG_HOME/eww/shell open kbd_window_overlay
            fi
            eww -c $XDG_CONFIG_HOME/eww/settings update input_osk_overlay=true

        fi
        ;;
esac
