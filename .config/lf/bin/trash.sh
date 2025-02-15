#!/usr/bin/env bash

function notify {
    lf -remote "send $id echomsg $1"
}

function add {
    gio trash "$@"  
    notify "Trashed: $# Files"
}

function restore {
    for file in "$@"; do
        basename="${file##*/}"
        gio trash --restore trash:///"$basename"
    done
    sleep .1
    notify "Restored: $# Files"
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
