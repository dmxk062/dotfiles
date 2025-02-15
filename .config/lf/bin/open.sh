#!/bin/bash -e
IFS=$'\n'

# just let neovim deal with everything
if [[ -n "$NVIM" ]]; then
    exec nvr "$fx"
fi

MIMETYPE="$(file --mime-type --brief --dereference -- "$1")"
case "$MIMETYPE" in
image/*)
    for img in $fx; do
        kitten icat -- "$img"
        read
    done
    ;;
audio/*)
    clear
    mpv --no-audio-display -- $fx
    ;;
application/pdf)
    zathura -- $fx &
    disown
    ;;
text/* | application/json | inode/x-empty | application/javascript)
    nvim -b -- $fx
    ;;
*)
    for file in $fx; do
        xdg-open "$file" &
        disown
    done
    ;;
esac
