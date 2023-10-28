#!/usr/bin/env bash

rofi -show power\
    -modes "power:$XDG_CONFIG_HOME/rofi/applets/power/powermenu.sh"\
    -theme "$XDG_CONFIG_HOME/rofi/applets/power/theme.rasi"\
    -config "$XDG_CONFIG_HOME/rofi/applets/power/config.rasi"
