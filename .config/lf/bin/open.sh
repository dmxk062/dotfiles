#!/bin/bash -e
IFS=$'\n'

# just let neovim deal with everything
if [[ -n "$NVIM" ]]; then
    exec nvr "$fx"
fi

ARCHIVEDIR="$HOME/Tmp/arc"
ARCLIST="$ARCHIVEDIR/open.list"
[[ ! -d "$ARCHIVEDIR" ]] && mkdir -p "$ARCHIVEDIR"

function create_arccache {
    local id="$(stat -c "%m.%i.%Y" -- "$1")"
    id="${id//\//@}"
    REPLY="$ARCHIVEDIR/$id$2"
    [[ ! -e "$REPLY" ]]
}

function escape {
    sed -z 's/\\/\\\\/g;s/"/\\"/g;s/\n/\\n/g;s/^/"/;s/$/"/'
}

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


    name="${f##*/}#x"
    if create_arccache "$f" "#x"; then
        # create 
        mkdir "$REPLY" 
        case "$MIMETYPE" in
            *)
                bsdtar -C "$REPLY" -x -f "$f"
                ;;
        esac
        
        printf "%s\0%s\0%s\n" "$f" "${f%/*}/$name" "$REPLY" >> "$ARCLIST"

        err=""
        [[ -L "$f#x" ]] && unlink "$f#x"
        if ! ln -s "$REPLY" "$f#x"; then
            err="$(chmod +w "${f%/*}" 2>&1 || true)"
            if [[ -n "$err" ]]; then
                lf -remote "send $id echoerr \\#arc: Could not symlink: $err"
                exit 1
            else
                ln -s "$REPLY" "$f#x" 2>&1
            fi
        fi
    fi
    if [[ -d "$name" ]]; then
        lf -remote "send $id cd $(printf '%s' "$name" | escape)"
    elif [[ -d "$REPLY" ]]; then
        lf -remote "send $id cd $(printf '%s' "$REPLY" | escape)"
    fi

    ;;
*)
    for file in $fx; do
        xdg-open "$file" &
        disown
    done
    ;;
esac
