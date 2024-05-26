#!/usr/bin/env bash

rofi -show window\
    -modes "window:$XDG_CONFIG_HOME/rofi/applets/window/window_search.sh"\
    -theme "$XDG_CONFIG_HOME/rofi/applets/window/theme.rasi"\
    -config "$XDG_CONFIG_HOME/rofi/applets/window/config.rasi"
