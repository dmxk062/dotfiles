#!/bin/bash
answer="$(zenity --color-selection --title="Select a Background Color"|sed -e 's/rgb(//' -e 's/rgba(//' -e 's/)//')"
[[ -z $answer ]]&&exit
IFS=',' read -r r g b <<< $answer
hex="$(printf "%02X%02X%02X" "$r" "$g" "$b")"
swww clear $hex

