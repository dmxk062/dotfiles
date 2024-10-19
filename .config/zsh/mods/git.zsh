#!/bin/false
# vim: ft=zsh

if [[ "$1" == "load" ]] {

function lschg {
    local all=0
    local -a dirs
    local ignored=no
    for arg in "$@"; do
        if [[ "$arg" == "-a" || "$arg" == "--all" ]]; then
            all=1
            ignored=traditional
        else 
            dirs+=("$arg")
        fi
    done

    function list_changes {
        local line mode file prefix
        while read -r type line; do
            if [[ $type == 1 ]]; then
                read -r mode _ _ _ _ _ _ file <<< "$line";
                case $mode in 
                    \.M) prefix="%F{magenta}";;
                    M\.) prefix="%B%F{magenta}";;
                    MM)  prefix="%B%F{magenta}";;
                    A\.) prefix="%B%F{green}";;
                    \.A) prefix="%F{greem}";;
                    AA) prefix="%B%F{green}";;
                    D\.) prefix="%B%F{red}";;
                    \.D) prefix="%F{red}";;
                    DD) prefix="%B%F{red}";;
                esac
                print -P -- "$prefix$mode $file%f%b"
            elif [[ "$type" == '?' || "$type" == "!" ]] && ((all)); then
                print -P -- "\e[90m$type  $line%f"
            fi
            # HACK: cd so we can work with *any* git repo
        done < <(cd -- "$1"; git status --porcelain=v2 --ignored="$ignored" ".")
    }

    if (($#dirs == 0)); then
        list_changes "."
    elif (($#dirs == 1)); then
        list_changes "${dirs[1]}"
    else
        for dir in "${dirs[@]}"; do
            print -- "$dir:"
            list_changes "$dir"
        done
    fi

}

alias lgit="lsd -l --config-file $HOME/.config/lsd/brief.yaml" \
    sparse_clone="git clone --filter=blob:none --sparse"


} elif [[ "$1" == "unload" ]] {

unfunction lschg
unalias lgit sparse_clone

}

