#!/usr/bin/env bash
addr="$1"
read -r pos size <<< "$(slurp -w 0 -b "#4c566acc" -s "#ffffff00")"
x=${pos%%,*} 
y=${pos#*,}
w=${size%%x*} 
h=${size#*x}
hyprctl --batch "dispatch resizewindowpixel exact ${w} ${h},address:${addr}; dispatch movewindowpixel exact ${x} ${y},address:${addr}"

