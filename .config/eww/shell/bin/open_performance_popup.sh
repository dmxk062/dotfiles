#!/bin/sh

eww="eww -c $HOME/.config/eww/shell"

if ! $eww close performance_popup
then
    $eww open performance_popup
fi
