#!/bin/sh

if [ "$1" = "-p" ]; then
    title="Selection"
else
    title="Clipboard"
fi

action=$(notify-send "$title" "$(wl-paste $1)")
