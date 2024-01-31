#!/usr/bin/env bash
pid="$1"
answer="$(notify-send "Are you sure?" \
    "Any unsaved data might be lost. More than one window might be closed" \
    --action="cancel"="Cancel" --action="confirm"="Confirm" -i system-error)"

case $answer in 
    confirm)
        kill $1;;
    cancel)
        exit;;
esac
