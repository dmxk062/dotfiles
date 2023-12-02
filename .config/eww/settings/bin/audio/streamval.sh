#!/bin/bash

pactl set-sink-input-volume "$1" "${2}%"
~/.config/eww/settings/bin/mixer.sh
