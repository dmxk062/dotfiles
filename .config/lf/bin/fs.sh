#!/bin/bash -eu
icon=""

notify() {
    msg="$1"
    lf -remote "send $id echomsg $msg"
}
error() {
    msg="$1"
    lf -remote "send $id echoerr $msg"
}


function mount_disk(){
    if ! udisksctl mount -b "$1"
    then
        error "󱊞 Failed to mount device $1"
    else
        notify "󱊞 Mounted device $1"
    fi
}

function unmount_disk(){
    if ! udisksctl unmount -b "$1"
    then
        error "󱊟 Failed to unmount device $1"
    else
        notify "󱊟 Unmounted device $1"
    fi
}

function decrypt(){
    
}
