#!/usr/bin/env bash

killall eww
sleep 1
eww -c "$XDG_CONFIG_HOME/sway/eww/shell/" daemon
eww -c "$XDG_CONFIG_HOME/sway/eww/shell/" open bar
eww -c "$XDG_CONFIG_HOME/sway/eww/shell/" open qmenu-edge
