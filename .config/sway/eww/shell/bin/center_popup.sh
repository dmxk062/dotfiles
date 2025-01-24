#!/usr/bin/env bash
EWW="$XDG_CONFIG_HOME/sway/eww/shell"

time="${3:-1}"
if [[ "$1" == "audio" ]]; then
    eww -c "$EWW" update center-popup-reveal=true audio-popup-kind="$2" center-popup-layer=0
else
    eww -c "$EWW" update center-popup-reveal=true center-popup-layer="$2"
fi

PIDFILE="/tmp/.eww_popup"
if [[ -f "$PIDFILE" ]]; then
    kill "$(< $PIDFILE)"
    rm "$PIDFILE"
else
    eww -c "$EWW" open center-popup --screen "$(swaymsg -t get_outputs |jq -r '.[]|select(.focused).name')"
fi
echo $$ > "$PIDFILE"
sleep $time

eww -c "$EWW" update center-popup-reveal=false
sleep 0.5
if [[ "$(eww -c "$EWW" get center-popup-reveal)" == false ]]; then
    eww -c "$EWW" close center-popup
fi

rm "$PIDFILE"
