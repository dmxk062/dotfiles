#!/usr/bin/env bash


case $1 in
    off)
        hyprctl --batch "dispatch hycov:toggleoverview; dispatch submap reset; keyword general:border_size 0" 
        ;;
    *)
        if hyprctl workspaces | grep -q "OVERVIEW"; then
            hyprctl --batch "dispatch hycov:toggleoverview; dispatch submap reset; keyword general:border_size 0" 
        else
            hyprctl --batch "dispatch hycov:toggleoverview; dispatch submap overview; keyword general:border_size 2" 
        fi;;
esac

