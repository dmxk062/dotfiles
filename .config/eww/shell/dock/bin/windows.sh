#!/usr/bin/env bash

workspace_order='{
"web":1, "web2":2, "web3":3, "web4":4, "main":10, "1":11, "2":12, "3":13, "4":14, "5":15, "6":16, "7":17, "8":18, "9":19, "10":20, "11":21, "12":22, "13":23, "14":24, "15":25, "16":26, "17":27, "18":28, "19":29, "20":30, "21":31, "22":32, "23":33, "24":34, "games":300, "srv":350, "external":370, "mirror":371, "special:1":400, "special:2":401, "special:3":402, "special:4":403, "OVERVIEW":500 }'

update(){
    hyprctl -j clients|jq -cM --argjson order "$workspace_order" 'map(. + {pos:$order[.workspace.name],})|sort_by(.pos)'

}
if [[ "$1" == "listen" ]]; then
update
socat -u "/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - |while read -r line; do
case $line in
    submap*|urgent*|openlayer*|closelayer*|activewindowv2*|focusedmon*)
        continue
        ;;
    *)
        update&
        ;;
esac
done

else
eww -c "$XDG_CONFIG_HOME/eww/shell" update dock_windows="$(update)"
fi
