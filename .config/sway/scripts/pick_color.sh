#!/usr/bin/bash


CACHEFILE="$XDG_CACHE_HOME/.color_$EPOCHSECONDS.png"

read -r r g b < <(hyprpicker -r -f rgb)
if [[ -z "$r" ]]; then
    exit
fi

printf -v hex "%02x%02x%02x" $r $g $b

magick -size 90x90 xc:none \
    -fill "#$hex" -draw "circle 40,40 40,0" \
    "$CACHEFILE"

reply="$(notify-send "#$hex" -i "$CACHEFILE" \
    --action=rgb="rgb($r, $g, $b)" \
    --action=hex="#$hex")"

case "$reply" in
    rgb) wl-copy "rgb($r, $g, $b)";;
    hex) wl-copy "#$hex";;
esac

wl-copy -p "#$hex"
