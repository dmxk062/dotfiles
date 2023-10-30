#!/bin/bash



function set(){
    if ! swww query
    then
        swww init
        sleep 1
    fi
    swww img -t grow \
        --transition-pos bottom \
        --transition-duration 1.2 \
        "$HOME/.config/background/wall"
}
function set_as_wall(){
    echo "new wall: $1"
    unlink "$HOME/.config/background/wall"
    ln -s "$1" "$HOME/.config/background/wall"
}

function set_as_lock(){
    echo "new lock: $1"
    unlink "$HOME/.config/background/lock"
    ln -s "$1" "$HOME/.config/background/lock"
}
case $1 in
    lock)
        set_as_lock "$2"
        ;;
    wall)
        set_as_wall "$2"
        set
        ;;
    set)
        set
        ;;
esac
