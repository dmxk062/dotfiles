#!/usr/bin/env bash

CITY="graz"
KEY=$(< "$XDG_DATA_HOME/keys/openweather")

upd() {
    eww -c "$XDG_CONFIG_HOME/sway/eww/shell/" update "$@"
}

if (( $1 > 300 )); then
    weather="$(curl -sf "http://api.openweathermap.org/data/2.5/weather?appid=${KEY}&q=${CITY}&units=metric")"
    upd weather="$weather"
    upd weather-last="$(date +%s)"
fi
