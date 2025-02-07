#!/usr/bin/env bash

CITY="Graz"
KEY=$(< "$XDG_DATA_HOME/keys/openweather")

curl -sf "http://api.openweathermap.org/data/2.5/weather?appid=${KEY}&q=${CITY}&units=metric"
echo
