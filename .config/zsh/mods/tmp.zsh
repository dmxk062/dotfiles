#!/usr/bin/false
# vim: ft=zsh

if [[ "$1" == "unload" ]]; then
    return
fi

# tools for working with temporary files and data

# return fresh directories inside ~/Tmp
# automagically create them when they do not exist yet
function _tmp_directory_name {
    if [[ "$1" == "d" ]]; then
        local -a match
        if [[ "$2" =~ ^\($HOME/Tmp/\([^/]+\)\) ]]; then
            typeset -ga reply
            reply=(t:$match[2] $[ ${#match[1]} ])
        else
            return 1
        fi
    fi

    if [[ "$1" == "n" ]]; then
        local prefix rest
        IFS=":" read -r prefix rest <<< "$2"
        if [[ "$prefix" != "t" ]]; then
            return 1
        fi
        if [[ -z "$rest" ]]; then
            typeset -ga reply
            reply=("$HOME/Tmp")
        else
            local dir="$HOME/Tmp/$rest"
            if [[ ! -e "$dir" ]]; then
                mkdir -p "$dir"
            fi
            typeset -ga reply
            reply=("$dir")
        fi
    fi

    if [[ "$1" == "c" ]]; then
        local tmps=("$HOME/Tmp/"*)
        local tmps_prefix=("${tmps[@]/#$HOME\/Tmp\//t:}")
        tmps_prefix=("${(@)tmps_prefix:#t:cache}")
        _wanted dynamic-dirs expl 'tmp' compadd -S\] -a tmps_prefix
    fi
}

zsh_directory_name_functions+=(_tmp_directory_name)

TMPDIR="~/Tmp"
