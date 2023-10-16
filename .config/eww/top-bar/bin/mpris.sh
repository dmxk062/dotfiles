#!/usr/bin/env bash

function listen(){
    playerctl -F metadata -f '{ "player":"{{playerName}}","active":"{{lc(status)}}","title":"{{markup_escape(title)}}" }'|while read -r line
do
    if [[ $line == "" ]]
    then
        echo '{"player":null,"active":false,"title":null}'
    else
        echo "$line"|sed -e 's/&quot;/\\"/g' -e 's/playing/true/' -e 's/paused/false/' -e 's/stopped/false/' -e "s/&apos;/\\'/g" -e "s/\&amp;/\&/g"
    fi
done
}


function metadata(){
    img_path="$(playerctl metadata 'mpris:artUrl'|sed 's/file:\/\///')"
    if ! [[ -f "$img_path" ]]
    then
        img_path="null"
    else
        img_path=\"$img_path\"
    fi
    artist=$(playerctl metadata 'xesam:artist'|sed 's/"/\\"/g')
    length=$(playerctl metadata 'mpris:length')||length="null"
    position=$(playerctl metadata --format '{{position}}')||position="null"
    if [[ $length == "null" ]]||[[ $position == "null" ]]
    then
        prog=false
    else
        prog=true
    fi

    loop=\"$(playerctl loop)\"||loop="null"
    printf '{"img":%s,"artist":"%s","pos":%s,"len":%s, "loop":%s, "avail":%s}\n' "$img_path" "$artist" "$position" "$length" "$loop" "$prog"

}

function loop(){
    echo "null"
    playerctl -F loop|while read -r line
    do
        case $line in
            Track)
                echo "track"
                ;;
            Playlist)
                echo "list"
                ;;
            None)
                echo "none"
                ;;
            *)
                echo "null"
        esac
    done

}

function jump(){
    playerctl position "$(echo "$1*$2/100"|bc)"
    
}
case $1 in 
    listen)
        echo '{"player":null,"active":false,"title":null}'
        listen
        ;;
    meta)
        metadata
        ;;
    loop)
        loop
        ;;
    jump)
        jump $2 $3;;
esac
