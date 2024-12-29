#!/usr/bin/env bash

exec rofi -show wallpapers\
    -modes "wallpapers:$XDG_CONFIG_HOME/rofi/applets/wallpapers/wallpapers.sh"\
    -theme "$XDG_CONFIG_HOME/rofi/applets/wallpapers/theme.rasi"\
    -config "$XDG_CONFIG_HOME/rofi/applets/wallpapers/config.rasi"
