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

counter=0
for file in "${@}"
do
    basename="$(basename $file)"
    ((counter+1))
    case $file in
        *.zip)
        unzip "$file"
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
        *.tar.*|*.tar|*.gz|*.deb|*.xz)
            tar xf "$file"
            ;;
        *)
        error "File $basename is not supported"
        ;;
    esac
done
if [[ $counter -gt 1 ]]
then
    notify "Successfully extracted $counter archives"
fi
