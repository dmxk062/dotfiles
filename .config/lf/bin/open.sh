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
        kitten icat --no-trailing-newline -- "$img"
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
text/* | application/json | inode/x-empty | application/javascript|application/x-wine-extension-ini)
    nvim -b -- $fx
    ;;
application/x-archive|application/x-cpio|application/x-tar|application/x-bzip2|application/gzip|application/x-lzip|application/x-lzma|application/x-xz|application/x-7z-compressed|application/vnd.android.package-archive|application/vnd.debian.binary-package|application/java-archive|application/x-gtar|application/zip|application/vnd.rar|application/x-iso9660-image)
    exit
    ;;
*)
    for file in $fx; do
        xdg-open "$file" &
        disown
    done
    ;;
esac
