#!/usr/bin/env bash

CITY="$(eww -c "$XDG_CONFIG_HOME/eww/shell" get weather-city)"

curl -sf "wttr.in/$CITY?format=j1"
