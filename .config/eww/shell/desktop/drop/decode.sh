#!/usr/bin/env bash

URI="$1"
update(){
    eww -c $XDG_CONFIG_HOME/eww/shell update dragndrop_value="$*"
}
case $URI in
    file://*)
        url="${URI//file:\/\//}"
        url="${url//\%/\\x}"
        path="$(echo -e "$url")"

        if [ -d "$path" ]; then
            type="directory"
        elif [ -f "$path" ]; then
            case $(file --mime-type -b --dereference -- "$path" ) in
                image/*)
                    type="image"
                    ;;
                text/*|application/json|inode/x-empty|application/x-subrip|application/javascript|application/x-elc) 
                    type="text"
                    ;;
                application/x-iso9660-image)
                    type="disk_image"
                    ;;

                *)
                    type="file"
                    ;;
            esac
        fi
        update "$(printf '{"url":"%s","type":"%s","path":"%s"}' "$URI" "$type" "$path")"
        ;;
    http://*|https://*)
        update "$(printf '{"url":"%s","type":"web"}' "$URI")"
        ;;
    *)
        update "$(printf '{"url":"%s","type":"plaintext"}' "$URI")"
        ;;
esac

eww -c $XDG_CONFIG_HOME/eww/shell open dragndrop_popup
