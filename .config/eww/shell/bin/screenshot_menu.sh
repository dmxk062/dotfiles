#!/bin/bash
eww="eww -c $HOME/.config/eww/shell"

CACHEDIR="/tmp/eww/cache/clip"
notify(){
    format="$(printf '<img src="%s" alt="Screenshot">' "$2")"
    response="$(notify-send "$1" -c "screenshot" "$format" \
        --action="open"="Open" \
        --action="edit"="Edit" \
        --action="del"="Delete" 
    )"

    case $response in
        open)
            xdg-open "$2";;
        del)
            rm "$2";;
        edit)
            swappy -f "$2" -o "$2";;
    esac
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
open_if_eww(){
    if [[ $EWW != "noeww" ]]
    then 
        open
    fi
}
close_if_eww(){
    if [[ $EWW != "noeww" ]]
    then 
        close
    fi
}
create_temp() {
    timestamp="$(date +'%Y_%m.%d_%H:%M:%S_sc')"
    echo "${CACHEDIR}/${timestamp}.png"
}
create_file() {
    dir="$(xdg-user-dir PICTURES)/Screenshots"
    timestamp="$(date +'%Y_%m.%d_%H:%M:%S_sc')"
    echo "${dir}/${timestamp}.png"
}
screen_clip() {
    file="$(create_temp)"
    if [[ $1 == "current" ]]
    then
        screen=$(hyprctl -j monitors|jq '.[]|select(.focused).name' -r)
    else
        screen="$1"
    fi
    close_if_eww
    sleep 0.5
    if ! grim -o "$screen" "$file"
    then
        exit
    fi
    wl-copy < "$file"& disown
    notify "Copied Image to Clipboard" "$file"& disown
}
section_clip() {
    close_if_eww
    file="$(create_temp)"
    region="$(choose_region)"
    if ! grim -g "$region" "$file"
    then
        open_if_eww "$1"
        exit
    fi
    wl-copy < "$file"& disown
    notify "Copied Image to Clipboard" "$file"& disown
}
screen_file() {
    file="$(create_file)"
    if [[ $1 == "current" ]]
    then
        screen=$(hyprctl -j monitors|jq '.[]|select(.focused).name' -r)
    else
        screen="$1"
    fi
    close_if_eww
    sleep 0.5
    if ! grim -o "$screen" "$file"
    then
        exit
    fi
    notify "Took Screenshot: $(basename "$file")" "$file"&disown
}
section_file() {
    file="$(create_file)"
    close_if_eww
    region="$(choose_region)"
    if ! grim -g "$region" "$file"
    then
        open_if_eww "$1"
        exit
    fi
    notify "Took Screenshot: $(basename "$file")" "$file"& disown
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
        EWW=$4
        case $2 in
            clip)
                screen_clip "$3"
                open_if_eww
                ;;
            disk)
                screen_file "$3"
                open_if_eww
                ;;
        esac;;
    region)
        EWW=$3
        case $2 in
            clip)
                section_clip $3
                open_if_eww
                ;;
            disk)
                section_file "$3"
                open_if_eww
                ;;
        esac;;
esac


