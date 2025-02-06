#!/usr/bin/env bash

CITY="$(eww -c "$XDG_CONFIG_HOME/sway/eww/shell" get weather-city)"
KEY=$(< "$XDG_DATA_HOME/keys/openweather")

curl -sf "http://api.openweathermap.org/data/2.5/weather?appid=${KEY}&q=${CITY}&units=metric"
