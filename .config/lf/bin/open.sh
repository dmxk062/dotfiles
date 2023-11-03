#!/bin/bash -eu
IFS=$'\n' 
f="$1"
file="$f"
if ! [[ -r "$f" ]]
then
    lf -remote "send $id echoerr  You don't have read permissions for the file $f.'"
fi
case $(file --mime-type -b --dereference -- "$f" ) in
#use kitty for pictures
    image/*) 
        for img in $fx 
        do
            clear
            kitten icat $img
            read
        done
        ;;
#use mpv for video
    video/*)
        setsid -f mpv --hwdec=auto $f -quiet >/dev/null 2>&1
        ;;
#same for audio
    audio/*)
    shortname=$(basename $f|head -c 16)
    kitty @ launch --title="mpv: ${shortname}~" --type=tab mpv --no-audio-display -- $fx
        ;;
#use zathura for pdf
    application/pdf)
        setsid -f zathura "$fx" >/dev/null 2>&1
        ;;
#libreoffice
    application/vnd.openxmlformats-officedocument.wordprocessingml.document|application/vnd.oasis.opendocument.text|application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|application/octet-stream|application/vnd.oasis.opendocument.spreadsheet|application/vnd.oasis.opendocument.spreadsheet-template|application/vnd.openxmlformats-officedocument.presentationml.presentation|application/vnd.oasis.opendocument.presentation-template|application/vnd.oasis.opendocument.presentation|application/vnd.ms-powerpoint|application/vnd.oasis.opendocument.graphics|application/vnd.oasis.opendocument.graphics-template|application/vnd.oasis.opendocument.formula|application/vnd.oasis.opendocument.database)
    for file in $fx
    do
        setsid -f libreoffice "$file" >/dev/null 2>&1 
    done
        ;;
#text using nvim, opens all files in vertical splits
    text/*|application/json|inode/x-empty|application/x-subrip|application/javascript|application/x-elc) 
        nvim $fx -O
        ;;
#shows the content of iso images
    application/x-iso9660-image)
        iso-info "$f" -l
        ;;
#fallback to xdg-open
    *) 
        for file in $fx
        do 
            setsid -f xdg-open $file >/dev/null 2>&1 
        done
        ;;
esac
