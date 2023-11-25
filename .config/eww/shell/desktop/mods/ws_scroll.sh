#!/usr/bin/env bash

case $1 in 
    up)
        hyprctl dispatch workspace +1
        ;;
    down)
        hyprctl dispatch workspace -1
        ;;
esac
