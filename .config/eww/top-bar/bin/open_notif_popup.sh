#!/bin/bash

eww="eww -c $HOME/.config/eww/top-bar"

if ! $eww close notifcenter 
then
    $eww open notifcenter
fi


