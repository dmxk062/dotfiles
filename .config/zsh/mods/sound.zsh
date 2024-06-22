#!/bin/false
# vim: ft=zsh

# some common pulseaudio stuff

if [[ "$1" == "load" ]] {

# return a list of sink inputs that match a str
function pagrep {
    local search_term="${@}"
    local line id str res
    local current=()
    pactl list sink-inputs|while read -r line; do
        if [[ "$line" == "Sink Input"* ]] {
            read -r _ _ id <<< "$line"
            current=("${id:1}") # remove leading `#`
        } elif [[ "$line" == "application.name"* ]] {
            IFS='=' read -r _ str <<< "$line"
            current+=("$str")
        } elif [[ "$line" == "media.name"* ]] {
            IFS='=' read -r _ str <<< "$line"
            current+=("$str")
            print -- $current
        }
    done|grep -i "$search_term" \
        |while read -rA res; do print -- ${res[1]}; done
}

# toggle mute
function tmute {
    local search_terms="$@"
    local -a ids 
    local id
    if [[ "$@" =~ ^[0-9]*$ ]] {
        ids=("$@")
    } else {
        ids=($(pagrep "$search_terms"))
    }
    for id in "${ids[@]}"; do
        pactl set-sink-input-mute "$id" toggle
    done
}


} elif [[ "$1" == "unload" ]] {

    unfunction pagrep tmute

}
