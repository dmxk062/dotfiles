#!/usr/bin/env bash


case $1 in
    off)
        hyprctl --batch "dispatch submap reset; dispatch hycov:leaveoverview; keyword general:border_size 0" 
        ;;
    enter)
        # work around bug that idk how to fix
        hyprctl --batch "dispatch submap overview; keyword general:border_size 2"
        ;;
    *)
        if hyprctl workspaces | grep -q "OVERVIEW"; then
            hyprctl --batch "dispatch hycov:toggleoverview; dispatch submap reset" 
        else
            # we dont want special workspaces 
            if [[ "$(hyprctl clients -j|jq --argjson active "$(hyprctl monitors -j|jq '.[]|select(.focused)|.id')" '[.
                []|select(.monitor == $active 
                    and .mapped 
                    and (.workspace.name | startswith("special:") | not ) 
                )
                ]|length')" -gt 0 ]]; then
                hyprctl --batch "dispatch hycov:toggleoverview" 
            fi
        fi
        if [[ "$1" == "alttab" ]]; then
            hyprctl dispatch cyclenext
        fi
        ;;
esac
