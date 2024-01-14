#!/usr/bin/env bash
LOCKFILE="/tmp/eww/state/osk_tile"
[ -f "$LOCKFILE" ]&&winsuffix=""||winsuffix="_overlay"
echo "$winsuffix"
if eww -c $XDG_CONFIG_HOME/eww/shell close kbd_window${winsuffix}; then
    eww -c $XDG_CONFIG_HOME/eww/shell update input_osk=false
    eww -c $XDG_CONFIG_HOME/eww/settings/ update input_osk=false
else
    eww -c $XDG_CONFIG_HOME/eww/shell update input_osk=true kbd_layout="$(< $XDG_CONFIG_HOME/eww/shell/kbd/layout.compact.json)"
    eww -c $XDG_CONFIG_HOME/eww/settings/ update input_osk=true
    eww -c $XDG_CONFIG_HOME/eww/shell open kbd_window${winsuffix}
fi
