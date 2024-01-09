#!/usr/bin/env bash


case $1 in
    off)
        req="dispatch submap reset; keyword general:border_size 0" 
        if hyprctl workspaces | grep -q "OVERVIEW"; then
            req="dispatch hycov:toggleoverview; ${req}"
        fi
        hyprctl --batch "$req"
        ;;
    *)
        if hyprctl workspaces | grep -q "OVERVIEW"; then
            hyprctl --batch "dispatch hycov:toggleoverview; dispatch submap reset; keyword general:border_size 0" 
        else
            # we dont want special workspaces 
            if [[ "$(hyprctl clients -j|jq --argjson active "$(hyprctl monitors -j|jq '.[]|select(.focused)|.id')" '[.
                []|select(.monitor == $active 
                    and .mapped 
                    and (.workspace.name | startswith("special:") | not ) 
                )
                ]|length')" -gt 0 ]]; then
                hyprctl --batch "dispatch hycov:toggleoverview; dispatch submap overview; keyword general:border_size 2" 
            fi
        fi;;
esac

if [[ "$1" == "alttab" ]]; then
    hyprctl dispatch cyclenext
fi
