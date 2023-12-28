#!/usr/bin/env bash
PIDFILE=/tmp/.swayidle_timeout_pid
if [[ $1 == "start" ]]; then
    $XDG_CONFIG_HOME/swayidle/idle.sh notify & disown
else
    kill $(< $PIDFILE)
    rm $PIDFILE
fi
