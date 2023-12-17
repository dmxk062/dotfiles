#!/usr/bin/env bash

[ -f /tmp/.eww_osk_overlay ]&&winsuffix="_overlay"||winsuffix=""
echo "$winsuffix"
if eww -c $XDG_CONFIG_HOME/eww/shell close kbd_window${winsuffix}; then
    eww -c $XDG_CONFIG_HOME/eww/shell update input_osk=false
    eww -c $XDG_CONFIG_HOME/eww/settings/ update input_osk=false
else
    eww -c $XDG_CONFIG_HOME/eww/shell update input_osk=true kbd_layout="$(< $XDG_CONFIG_HOME/eww/shell/kbd/layout.json)"
    eww -c $XDG_CONFIG_HOME/eww/settings/ update input_osk=true
    eww -c $XDG_CONFIG_HOME/eww/shell open kbd_window${winsuffix}
fi
