#!/bin/false
# vim: ft=zsh

if [[ "$1" == "load" ]] {

function lschg {
    local dir="${1:-.}"
    local hide="${2}"
    local line mode file prefix
    while read -r type line; do
        if [[ $type == 1 ]] {
            read -r mode _ _ _ _ _ _ file <<< "$line";
            case $mode in 
                \.M) prefix="%F{blue}* ";;
                M\.) prefix="%F{yellow}* ";;
                MM)  prefix="%B%F{yellow}* ";;
                A\.) prefix="%F{green}+ ";;
                \.A) prefix="%F{blue}+ ";;
                AA) prefix="%B%F{green}+ ";;
                D\.) prefix="%F{red}- ";;
                \.D) prefix="%F{magenta}- ";;
                DD) prefix="%B%F{red}- ";;
            esac

            print -P -- "$prefix$file%f%b"
        } elif [[ "$type" == '?' && "$hide" == "-a" ]] {
            print -P -- "\e[90m~ $line%f"
        }
    done < <(git status --porcelain=v2 "$dir")
}

alias lgit="lsd -l --config-file $HOME/.config/lsd/brief.yaml" \
    sparse_clone="git clone --filter=blob:none --sparse"


} elif [[ "$1" == "unload" ]] {

unfunction lschg
unalias lgit sparse_clone

}

