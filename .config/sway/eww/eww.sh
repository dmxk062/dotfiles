#!/usr/bin/env bash

killall eww
eww -c "$XDG_CONFIG_HOME/sway/eww/bar/" daemon
eww -c "$XDG_CONFIG_HOME/sway/eww/bar" open bar
