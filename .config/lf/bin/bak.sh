#!/usr/bin/env bash

file=$1
shopt -s extglob

i=0
function get_backup_name(){
    if ! [[ -e "${file}.~$i~" ]]
    then
        newname="${file}.~$i~"
    else
        i=$((i+1))
        get_backup_name
    fi
}

function backup(){
    get_backup_name
    mv "$file" "$newname"
}
function un_backup(){
    newname="${file//.~[0-9]~/}"
    if [[ -e "$newname" ]]
    then
        lf -remote "send $id echoerr $newname: File already exists"
        exit
    fi
    mv "$file" "$newname"
}
if [[ "$file" == *\.~*~ ]]
then
    un_backup
else   
    backup
fi
lf -remote "send $id select \"$newname\""
