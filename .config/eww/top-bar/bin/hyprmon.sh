#!/bin/bash

function update(){
    eww -c "$HOME/.config/eww/top-bar/" update "$@"
}


#
# Windows
#


# window_icons='{
# "kitty":"󰄛",
# "firefox":"",
# "nemo":"",
# "zenity":"󰙵",
# "steam":"󰓓",
# "gamescope":"󰊴",
# "org.prismlauncher.PrismLauncher":"󰍳",
# "Tor Browser":"󰖟",
# "mpv":"󱜅",
# "gnome-boxes":"",
# "gnome-disks":"󰋊",
# "org.gnome.clocks":"󰥔",
# "eog":"󰋩",
# "libreoffice-startcenter":"󰈙",
# "libreoffice-writer":"󰼭",
# "libreoffice-calc":"󱖦",
# "org.pwmt.zathura":"",
# "thunderbird":"󰺻",
# "Zotero":"󱫆",
# "com.transmissionbt.transmission_39_364746":"",
# "vinagre":"󰢹",
# "Timeshift-gtk":"󰁯",
# "valent":"",
# "pavucontrol":"",
# "virt-manager":"",
# "polkit-gnome-authentication-agent-1":"󰟵",
# "io.elementary.desktop.agent-polkit":"󰟵",
# "com.obsproject.Studio":"",
# "hyprland-share-picker":"󰩨",
# "Vial":"󰌌",
# "cava":"",
# "simple-scan":"󰚫",
# "com.github.flxzt.rnote":"󱦹",
# "blueman-manager":"",
# "blueman-sendto":"",
# "nm-connection-editor":"󰖟",
# "yuzu":"󰟡",
# "soffice":"󰼭",
# "seahorse":"󰌆",
# "com.github.neithern.g4music":"󰁧",
# "discord":"󰙯",
# "fractal":"󰍩",
# "io.github.celluloid_player.Celluloid":"󱜏"
# }'

function get_active_window_info(){
    win="$(hyprctl activewindow -j)"
    echo "$win" |jq -Mc '[.]|map({
        id:.address,
        pid:.pid,
        class:.class,
        title:.title,
        wsname:.workspace.name,
        shown:.mapped,
        hidden:.hidden,
        float:.floating,
        pin:.pinned,
        legacy:.xwayland,
        fullscreen:.fullscreen,
        mode:.fullscreenMode
    })'
}


# 
# Workspaces:
#

workspace_icons='{
"main":"󰣇",
"1":"1",
"2":"2",
"3":"3",
"4":"4",
"5":"5",
"6":"6",
"7":"7",
"8":"8",
"9":"9",
"10":"10",
"11":"11",
"12":"12",
"13":"13",
"14":"14",
"15":"15",
"16":"16",
"17":"17",
"18":"18",
"19":"19",
"20":"20",
"22":"22",
"23":"23",
"24":"24",
"games":"󰊴",
"web":"󰖟  1",
"web2":"󰖟  2",
"web3":"󰖟  3",
"web4":"󰖟  4",
"external":"󰍹  ext",
"special:1":"󱓥  1",
"special:2":"󱓥  2",
"special:3":"󱜏",
"special:4":"󰥔",
"vm":"󰒋"
}'

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

function get_active_workspace_id(){
    hyprctl activeworkspace -j|jq  '.id'
}

function list_workspaces(){
        active=$(get_active_workspace_id)
        hyprctl workspaces -j|jq --argjson order "$workspace_order" --argjson icons "$workspace_icons" --argjson activeid "$active" 'map({
            id:.id,
            name:.name,
            display:.monitor,
            count:.windows,
            title:.lastwindowtitle,
            fullscreen:.hasfullscreen,
            icon:$icons[.name],
            pos:$order[.name],
            special:(if .name | test("special:.*") then true else false end),
            active:(if .id == $activeid then true else false end)
        })'|jq -Mc 'sort_by(.pos)'

}
function refresh(){
    update window="$(get_active_window_info)"
    update workspaces="$(list_workspaces)"
}

function monitor_changes(){
    refresh
    socat -u "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - |while read -r line;
    do
        refresh
    done
}
function display_changes(){
    get_active_window_info
    socat -u "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - |while read -r line;
    do
    get_active_window_info
    done
}
function switch_to_workspace(){
    id=$1
    name=$2
    workspaces="$(list_workspaces)"
    echo "$workspaces"|jq
    if echo "$workspaces"|jq -e --argjson id "$id" '.[]|select(.id == $id)|.active'
    then
        true
    else
        hyprctl dispatch workspace "$name"
    fi

}


case $1 in 
    monitor)
        monitor_changes;;
    switch)
        switch_to_workspace "$2" "$3";;
    display)
        display_changes;;

esac
