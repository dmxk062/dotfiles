#!/usr/bin/zsh

function notify {
    lf -remote "send $id echomsg $1"
}

function add {
    gio trash "$@"  
    if (($# == 1)) {
        name=file
    } else {
        name=files
    }
    notify "󰩹 Moved $# ${name} to trash"
}

function restore {
    if (($# == 1)) {
        name=file
    } else {
        name=files
    }
    for file in "$@"; do
        basename="${file:t}"
        gio trash --restore trash:///"$basename"
    done
    sleep .1
    notify "󰩹 Restored $# ${name} from trash"
}

case "$1" in
    add)
        shift
        add "$@"
        ;;
    restore)
        shift
        restore "$@"
        ;;
esac
