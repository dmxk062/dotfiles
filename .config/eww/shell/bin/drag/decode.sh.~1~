#!/usr/bin/env bash

URI="$1"
update(){
    eww -c $XDG_CONFIG_HOME/eww/shell update "$@"
}
open_for_mime(){
    path="$1"
    case $(file --mime-type -b --dereference -- "$path" ) in
        image/*)
            eog --name=popup "$URI" & disown
            ;;
        text/*|application/json|inode/x-empty|application/x-subrip|application/javascript|application/x-elc) 
            kitty --class="nvim" nvim "$path" & disown
            ;;
        application/x-iso9660-image)
            $XDG_CONFIG_HOME/eww/settings/bin/loop.sh add_path "$path"
            eww_settings.sh storage & disown
            ;;

        *)
            xdg-open "$URI" & disown
            ;;


    esac
}
yad_wrapper(){
    yad --html --name="web_preview popup" \
        --uri="$1" \
        --geometry=800x600+0+0 \
        --button="Open in Web Browser":0 \
        --button="Cancel":1
}
open_for_web(){
    url="$1"
    if yad_wrapper "$url" ; then
        firefox "$url" & disown
    fi
    
}

    update dragndrop_value='{"type":"web", "url":"$url", "icon":"󰖟"}'
case $URI in
    file://*)
        url="${URI//file:\/\//}"
        url="${url//\%/\\x}"
        path="$(echo -e "$url")"

        if [ -d "$path" ]; then
            nemo --name=popup "$URI" & disown
        elif [ -f "$path" ]; then
            open_for_mime "$path"
        fi
        ;;
    http://*|https://*)
        open_for_web "$URI"
        ;;
    *)
        ;;
esac
