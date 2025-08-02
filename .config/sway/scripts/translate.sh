#!/bin/sh

TEXT="$(wl-paste $1 | translate -p)"
response="$(notify-send -i config-language \
    "Translated $(echo "$TEXT" | head -n 1)" \
    "$(echo "$TEXT" | tail -n +3)" \
    --action=copy="Copy" \
    --action=view="View")"
case "$response" in
copy) echo "$TEXT" | wl-copy ;;
view)
    tmpfile="$(mktemp)"
    echo "$TEXT" >"$tmpfile"
    xdg-open "$tmpfile"
    ;;
esac
