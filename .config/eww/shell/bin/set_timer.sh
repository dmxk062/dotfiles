#!/usr/bin/env bash

response="$(zenity --entry --text="[HH:]MM:SS" --title="Create Timer" --entry-text "5:00")"
IFS=: read -ra fields <<<"$response"

time=0
num_fields=${#fields[@]}
if ((num_fields == 1)); then
    time=${fields[0]}
elif ((num_fields == 2)); then
    time=$((fields[0] * 60 + fields[1]))
else
    time=$((fields[0] * 3600 + fields[1] * 60 + fields[2]))
fi

if ((time <= 0)); then
    exit
fi

eww -c "$XDG_CONFIG_HOME/eww/shell" update timer-start=$EPOCHSECONDS timer-time=$((EPOCHSECONDS + time))

sleep "$time"
eww -c "$XDG_CONFIG_HOME/eww/shell" update timer-start=0 timer-time=0

mpv --loop=yes /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga &
pid=$!
notify-send "Timer Done" -w --icon=alarm-symbolic
kill $pid
