#!/usr/bin/env bash


case $1 in
    off)
        hyprctl --batch "dispatch hycov:toggleoverview; dispatch submap reset; keyword general:border_size 0" 
        ;;
    *)
        if hyprctl workspaces | grep -q "OVERVIEW"; then
            hyprctl --batch "dispatch hycov:toggleoverview; dispatch submap reset; keyword general:border_size 0" 
        else
            if [[ "$(hyprctl clients -j|jq --argjson active "$(hyprctl monitors -j|jq '.[]|select(.focused)|.id')" '[.[]|select(.monitor == $active)]|length')" -gt 0 ]]; then
                hyprctl --batch "dispatch hycov:toggleoverview; dispatch submap overview; keyword general:border_size 2" 
            fi
        fi;;
esac

