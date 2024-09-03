#!/bin/false
# vim: ft=zsh

if [[ "$1" == "load" ]] {

function lschg {
    local dir="${1:-.}"
    local all=0
    local hide="${2}"
    local ignored=no
    if [[ "$hide" == "-a" ]] || [[ "$hide" == "--all" ]]; then
        all=1
        ignored="traditional"
    fi
    local line mode file prefix
    while read -r type line; do
        if [[ $type == 1 ]] {
            read -r mode _ _ _ _ _ _ file <<< "$line";
            case $mode in 
                \.M) prefix="%F{magenta}";;
                M\.) prefix="%F{magenta}";;
                MM)  prefix="%B%F{magenta}";;
                A\.) prefix="%F{green}";;
                \.A) prefix="%F{greem}";;
                AA) prefix="%B%F{green}";;
                D\.) prefix="%F{red}";;
                \.D) prefix="%F{red}";;
                DD) prefix="%B%F{red}";;
            esac

            print -P -- "$prefix$mode $file%f%b"
        } elif [[ "$type" == '?' || "$type" == "!" ]] && ((all)) {
            print -P -- "\e[90m$type  $line%f"
        }
    done < <(git status --porcelain=v2 --ignored="$ignored" "$dir")
}

alias lgit="lsd -l --config-file $HOME/.config/lsd/brief.yaml" \
    sparse_clone="git clone --filter=blob:none --sparse"


} elif [[ "$1" == "unload" ]] {

unfunction lschg
unalias lgit sparse_clone

}

