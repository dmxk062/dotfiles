#!/usr/bin/env zsh


CACHEDIR="$XDG_CACHE_HOME/lf"
if ! [[ -d "$CACHEDIR" ]] { mkdir -p "$CACHEDIR" }

MAX_IMAGE_SIZE=20971520

FILE=$1
W=$2
H=$3
X=$4
Y=$5
LINES="$H"
COLUMNS="$W"






function display_image {
    kitten icat --silent --stdin no --transfer-mode memory --place "${W}x${H}@${X}x${Y}" "$1" < /dev/null > /dev/tty
}

function create_cache {
    local basen="${1:t}"
    print -- "$CACHEDIR/$basen${RANDOM}${2}"
}


if ! [[ -r "$FILE" ]] {
    read -r owner group perms <<< $(stat -c "%U %G %A" "$FILE")
    print -P "%B%F{red}Permission Denied%b%F{white}

Owner: %F{magenta}$owner%F{white}
Group: %F{cyan}$group%F{white}
Perms: %F{yellow}$perms%F{white}"
    exit 0
    
}

MIMETYPE="$(file --dereference --brief --mime-type -- "$FILE")"

case "$MIMETYPE" in
    application/pdf) 
        tmpfile="$(create_cache "${FILE}" ".ppm")"
        if ! [[ -f "$tmpfile" ]] {
            pdftoppm -f 1 -l 1 "$FILE" >> "$tmpfile"
        }
        display_image "$tmpfile"
        exit 1
        ;;

    image/*)
        size=$(stat -c %s "$FILE")
        if ((size > MAX_IMAGE_SIZE)) {
            print -P -- "%F{blue}󰋽 Image is greater than 20mb"
        } else {
            identify -format 'Format: %m\nSize: %wx%h\nColor Depth: %z Bits per Pixel\n' "$FILE"
            H=$[H-4]
            Y=$[Y+4]
            display_image "$FILE"
        }
        exit 1
        ;;

    video/*)
        tmpfile="$(create_cache "${FILE}" ".png")"
        if ! [[ -f "$tmpfile" ]] {
            ffmpegthumbnailer -s 0 -m -i "$FILE" -o "$tmpfile"
        }
        display_image "$tmpfile"
        exit 1
        ;;


    *x-iso9660-image)
        iso-info --no-header "$FILE" -f|tail -n+10|while read -r num file; do
            print -- "$file"
        done
        exit 1
        ;;

    *opendocument*)
        odt2txt --width="$W" "$FILE"
        exit 1
        ;;

    text/* | */xml | application/javascript)
        COLORTERM=truecolor bat -pf --wrap=character --terminal-width=$((W-4)) -f --number "$FILE"
        exit 1
        ;;

    application/json)
        jq -C < "$FILE"
        exit 1
        ;;

    *octet-stream)
        print -P "%SBinary\e[0m"
        xxd -R always -c $[(COLUMNS / 6) + 1] -u -l $[( (COLUMNS / 6) + 1) * LINES] "$FILE"
        exit 1
        ;;

    inode/x-empty|application/x-empty)
        print -P "%SEmpty\e[0m"
        exit 1

esac

