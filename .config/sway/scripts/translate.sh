#!/bin/sh

TEXT="$(wl-paste $1 | translate)"
response="$(notify-send -i config-language "Translated" "$TEXT" \
    --action=copy="Copy" \
    --action=view="View")"
case "$response" in
copy) echo "$TEXT" | wl-copy ;;
view)
    tmpfile="$(mktemp)"
    echo "$TEXT" > "$tmpfile"
    xdg-open  "$tmpfile"
    ;;
esac
