#!/bin/bash -eu
IFS=$'\n' 

icon="󰛫"

notify() {
    msg="$1"
    lf -remote "send $id echomsg $icon $msg"
}
error() {
    msg="$1"
    lf -remote "send $id echoerr $msg"
}
mkdir_error(){
    dir="$1"
    if [[ -e "$dir" ]]
    then
        error "Directory ${basename%%.*} already exists, aborting."
        return 1
    else
        mkdir "$dir"
        return 0
    fi
}
counter=0
for file in "${@}"
do
    basename="$(basename $file)"
    dirname="${file%%.*}"
    ((counter+1))
    case $file in
        *.bz|*.bz2|*.tbz|*.tbz2)
        if ! mkdir_error "$dirname"
        then
            exit
        fi
        tar xjf "$file" -C "$dirname"
        notify "Finished extracting $basename"
        ;;
        *.gz|*.tgz|*.deb)
        if ! mkdir_error "$dirname"
        then
            exit
        fi
        tar xzf "$file" -C "$dirname"
        notify "Finished extracting $basename"
        ;;
        *.xz|*.txz)
        if ! mkdir_error "$dirname"
        then
            exit
        fi
        tar xJf "$file" -C "$dirname"
        notify "Finished extracting $basename"
        ;;
        *.zip)
        if ! mkdir_error "$dirname"
        then
            exit
        fi
        unzip "$file" -d "$dirname"
        notify "Finished extracting $basename"
        ;;
        *.rar)
        unrar x "$file"
        notify "Finished extracting $basename"
        ;;
        *.7z)   
        7z x "$file"
        notify "Finished extracting $basename"
        ;;
        *)
        error "File $basename is not supported"
        ((counter+1))
        ;;
    esac
done
if [[ $counter -gt 1 ]]
then
    notify "Successfully extracted $counter archives"
fi
