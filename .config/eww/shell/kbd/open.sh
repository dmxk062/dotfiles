#!/usr/bin/env bash

eww -c $XDG_CONFIG_HOME/eww/shell update kbd_layout="$(< $XDG_CONFIG_HOME/eww/shell/kbd/layout.json)"
if eww -c $XDG_CONFIG_HOME/eww/shell close kbd_window; then
    eww -c $XDG_CONFIG_HOME/eww/shell update input_osk=false
    eww -c $XDG_CONFIG_HOME/eww/settings/ update input_osk=false
else
    eww -c $XDG_CONFIG_HOME/eww/shell update input_osk=true
    eww -c $XDG_CONFIG_HOME/eww/settings/ update input_osk=true
    eww -c $XDG_CONFIG_HOME/eww/shell open kbd_window
fi
