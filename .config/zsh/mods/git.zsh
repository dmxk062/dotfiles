#!/bin/false
# vim: ft=zsh

if [[ "$1" == "unload" ]]; then

    unfunction lschg
    unalias lgit sparse_clone unstage

    return
fi

# show changes in current git tree
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
        local dir="$1"
        if [[ ! -d "$dir" || ! -x "$dir" ]]; then
            print "Can't access directory: $dir" >&2
            return 1
        fi

        local line mode file prefix head=""
        while read -r type line; do
            if [[ $type == 1 ]]; then
                read -r mode _ _ _ _ _ _ file <<< "$line";
                case $mode in 
                    M\.|MM) prefix="%B%F{yellow}";;
                    \.M) prefix="%F{yellow}";;
                    A\.|AA) prefix="%B%F{green}";;
                    \.A) prefix="%F{greem}";;
                    D\.|DD) prefix="%B%F{red}";;
                    \.D) prefix="%F{red}";;
                esac
                print -P -- "$prefix$mode%f%b $file"
            elif [[ "$type" == '?' || "$type" == "!" ]] && ((all)); then
                print -P -- "\e[90m$type  $line%f"
            fi
            # HACK: cd so we can work with *any* git repo, not just the current
        done < <(cd -- "$dir"; git status --porcelain=v2 --ignored="$ignored" ".")
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
    sparse_clone="git clone --filter=blob:none --sparse" \
    unstage="git restore --staged -- "
