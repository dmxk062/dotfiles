#!/bin/bash
eww="eww -c $HOME/.config/eww/top-bar"

notify(){
    notify-send "$1" -i "$2" -c "screenshot"
}
close() {
    $eww close screenshot_popup
}
open() {
    $eww open screenshot_popup --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')
}
choose_region() {
    sleep 0.1
    area=$(slurp -w 0 -b "#4c566acc" -s "#ffffff00")
    sleep 0.5
    echo "$area"
}
update() {
   $eww update "${1}=${2}" 
}
create_temp() {
    mkdir -p /tmp/eww/cache/clip
    timestamp="$(date +'%d.%m_%Y_%H:%M:%S_grim')"
    echo "/tmp/eww/cache/clip/${timestamp}.png"
}
create_file() {
    dir="$(xdg-user-dir PICTURES)/Screenshots"
    timestamp="$(date +'%d.%m_%Y_%H:%M:%S_grim')"
    echo "${dir}/${timestamp}.png"
}
screen_clip() {
    file="$(create_temp)"
    close
    sleep 0.5
    if ! grim -o "$1" "$file"
    then
        exit
    fi
    wl-copy < "$file"& disown
    notify "Copied Image to Clipboard" "$file"
    open
}
section_clip() {
    file="$(create_temp)"
    close
    region="$(choose_region)"
    if [[ "$region" == "" ]]
    then
        open
        exit
    fi
    if ! grim -g "$region" "$file"
    then
        exit
    fi
    wl-copy < "$file"& disown
    notify "Copied Image to Clipboard" "$file"
    open
}
screen_file() {
    file="$(create_file)"
    close
    sleep 0.5
    if ! grim -o "$1" "$file"
    then
        exit
    fi
    notify "Took Screenshot: $(basename $file)" "$file"
    open
}
section_file() {
    file="$(create_file)"
    close
    region="$(choose_region)"
    if [[ "$region" == "" ]]
    then
        open
        exit
    fi
    if ! grim -g "$region" "$file"
    then
        exit
    fi
    notify "Took Screenshot: $(basename $file)" "$file"
    open

}

case $1 in 
    toggle)
        if ! close
        then
            open
            update "screenshot_screens" "$(hyprctl -j monitors |jq 'sort_by(.x)')" 
        fi;;
    list_monitors)
        update "screenshot_screens" "$(hyprctl -j monitors |jq 'sort_by(.x)')";;
    screen)
        case $2 in
            clip)
                screen_clip "$3";;
            disk)
                screen_file "$3";;
        esac;;
    region)
        case $2 in
            clip)
                section_clip;;
            disk)
                section_file;;
        esac;;
esac


