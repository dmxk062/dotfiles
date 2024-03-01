#!/usr/bin/env bash

urldecode() {
    local i="${*//+/ }"
    i="${i//"file://"/}"
    echo -e "${i//%/\\x}" 
}


function get_meta(){
    if [[ $1 == "" ]]
    then
        echo '{"player":null,"active":false,"title":null}'
    else
        echo "$line"|sed -e 's/&quot;/\\"/g' -e 's/playing/true/' -e 's/paused/false/' -e 's/stopped/false/' -e "s/&apos;/\\'/g" -e "s/\&amp;/\&/g"
    fi
}

function listen(){
    playerctl -F metadata -f '{ "player":"{{playerName}}","active":"{{lc(status)}}","title":"{{markup_escape(title)}}" }'|while read -r line
do
    get_meta "$line"
done
}


function metadata(){
    img_path="$(urldecode "$(playerctl metadata 'mpris:artUrl')")"
    if ! [[ -f "$img_path" ]]
    then
        img_path="null"
    else
        img_path=\"$img_path\"
    fi
    artist=$(playerctl metadata 'xesam:artist'|sed 's/"/\\"/g')
    album=$(playerctl metadata 'album'|sed 's/"/\\"/g')

    loop=\"$(playerctl loop)\"||loop="null"
    printf '{"img":%s,"artist":"%s","album":"%s","loop":%s}\n' "$img_path" "$artist" "$album" "$loop" 

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
upd(){
    val="$(playerctl metadata -f '{ "player":"{{playerName}}","active":"{{lc(status)}}","title":"{{markup_escape(title)}}" }')"
    eww -c $XDG_CONFIG_HOME/eww/shell update mpris="$(get_meta "$val")" #mpris_meta="$(metadata)"
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
    upd)
        upd;;
esac
