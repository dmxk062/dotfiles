#!/bin/bash
file=$1
shopt -s extglob
i=0
function backupNameGen(){
    if ! [[ -f "${file}.~$i~" ]]
    then
        newname="${file}.~$i~"
    else
        i=$((i+1))
        backupNameGen
    fi
}
function backup(){
    backupNameGen
    mv "$file" "$newname"
}
function unBackup(){
    newname="$(echo $file|sed 's/\.~.~//')"
    if [[ -f "$newname" ]]
    then
        lf -remote "send $id echoerr  File $newname already exists, aborting."
        exit
    fi
    mv "$file" "$newname"
}
if [[ "$file" == *\.~*~ ]]
then
    unBackup
else   
    backup
fi
newname="$(echo $newname|sed 's/ /\\ /')"
lf -remote "send $id select $newname"
