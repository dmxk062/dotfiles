#!/usr/bin/env bash

PORT="1234"
update(){
    eww -c "$XDG_CONFIG_HOME/eww/shell" update "$@"
}

listen_to_server(){
nesting=0
killall festival
festival --server | while read -r client day month time year _ _ event;
do
    if [[ "$event" == "disconnected" ]]; then
        ((nesting--))
    elif [[ "$event" == "accepted from localhost" ]]; then
        ((nesting++))
    fi
    if ((nesting == 0 )); then
        update tts_active=false
    elif ((nesting > 0 )); then
        update tts_active=true
    fi
done
}

case $1 in 
    server)
        listen_to_server
        ;;
    toggle)
        if killall festival; then
            update tts_running=false tts_active=false tts_state='{}'
        else
            update tts_running=true
            listen_to_server
        fi
        ;;
    say)
        shift
        printf '(SayText "%s")\n' "$@"|festival_client
        ;;

esac
