#!/usr/bin/env bash

CITY="$(eww get weather-city)"

curl -sf "wttr.in/$CITY?format=j1"
