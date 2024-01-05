#!/bin/sh

eww="eww -c $XDG_CONFIG_HOME/eww/shell"
workspace_order='{
"web":1,
"web2":2,
"web3":3,
"web4":4,
"main":10,
"1":11,
"2":12,
"3":13,
"4":14,
"5":15,
"6":16,
"7":17,
"8":18,
"9":19,
"10":20,
"11":21,
"12":22,
"13":23,
"14":24,
"15":25,
"16":26,
"17":27,
"18":28,
"19":29,
"20":30,
"21":31,
"22":32,
"23":33,
"24":34,
"games":300,
"vm":350,
"external":370,
"special:1":400,
"special:2":401,
"special:3":402,
"special:4":403
}'

update(){
    hyprctl -j clients|jq --argjson order "$workspace_order" 'map(. + {pos:$order[.workspace.name],
})|sort_by(.pos)'
}

case $1 in
    upd)
        $eww update windows="$(update)";;
    *)
        if $eww active-windows | grep "window_list"; then
            sleep 0.2
            $eww close window_list
        else
            $eww update windows="$(update)"
            $eww open window_list
        fi;;
esac
