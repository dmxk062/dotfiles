#!/usr/bin/env bash

eww="eww -c $XDG_CONFIG_HOME/eww/top-bar"

function update(){
    hyprctl -j clients|jq 'map({
title:.title,
floating:.floating,
class:.class,
pid:.pid,
legacy:.xwayland,
workspace:.workspace,
size:.size,
position:.at,
address:.address
})|sort_by(.workspace.id)'
}

case $1 in
    upd)
        $eww update windows="$(update)";;
    *)
        if ! $eww close window_list
        then
            $eww update windows="$(update)"
            $eww open window_list
        fi;;
esac
