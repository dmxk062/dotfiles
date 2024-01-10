#!/usr/bin/env bash

URI="$1"
edit_in_nvim(){
    cd||exit
    read -r x y h w <<< "$(slurp -w 0 -b "#4c566acc" -s "#ffffff00" -f "%x %y %h %w")"
    [[ "$x" == "" ]]&&exit
    kitty --class="nvim" nvim "$1" & disown
    pid=$!
    sleep 0.2
    hyprctl --batch "dispatch togglefloating pid:${pid} ; dispatch resizewindowpixel exact ${w} ${h},pid:${pid}; dispatch movewindowpixel exact ${x} ${y},pid:${pid}"

}
open_in_fm(){
    read -r x y h w <<< "$(slurp -w 0 -b "#4c566acc" -s "#ffffff00" -f "%x %y %h %w")"
    [[ "$x" == "" ]]&&exit
    gsettings set org.gnome.nautilus.window-state initial-size "(${w}, ${h})"
    nautilus -w "$1" & disown
    sleep 0.3
    hyprctl --batch "dispatch togglefloating; dispatch movewindowpixel exact ${x} ${y},address:$(hyprctl -j activewindow|jq -r ".address")"

}
open_for_mime(){
    path="$1"
    case $(file --mime-type -b --dereference -- "$path" ) in
        image/*)
            eog --name=popup "$URI" & disown
            ;;
        text/*|application/json|inode/x-empty|application/x-subrip|application/javascript|application/x-elc) 
            edit_in_nvim "$path"
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
open_for_web(){
    env GTK_THEME=Graphite-teal-Dark-nord firefox --new-window "$1" & disown
    
}

case $URI in
    file://*)
        url="${URI//file:\/\//}"
        url="${url//\%/\\x}"
        path="$(echo -e "$url")"

        if [ -d "$path" ]; then
            open_in_fm "$URI"
        elif [ -f "$path" ]; then
            open_for_mime "$path"
        fi
        ;;
    http://*|https://*)
        open_for_web "$URI"
        ;;
    smb://*)
        open_in_fm "$URI"
        ;;
    *)
        escaped="${URI//\%/\\x}"
        text="$(echo -e "$escaped")"
        wl-copy <<< "$text"
        notify-send -a "eww" \
            -i /usr/share/icons/Tela/scalable/apps/desktop.svg \
            "Copied to clipboard" \
            "$text"
        ;;
esac
