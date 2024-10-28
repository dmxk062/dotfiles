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

        local mode file old_perm new_perm prefix suffix head=""
        local type line
        while read -r type line; do
            if [[ $type == 1 ]]; then
                read -r mode _ _ old_perm new_perm _ _ file extra <<< "$line";
                case $mode in 
                    M\.|MM) prefix="%B%F{yellow}";;
                    \.M) prefix="%F{yellow}";;
                    A\.|AA) prefix="%B%F{green}";;
                    \.A) prefix="%F{green}";;
                    D\.|DD) prefix="%B%F{red}";;
                    \.D) prefix="%F{red}";;
                esac
                suffix=""
                if [[ "$old_perm" != "$new_perm" ]]; then
                    local bits_old="${old_perm:2}"
                    local bits_new="${new_perm:2}"
                    suffix=" %F{red}$bits_old%f -> %F{green}$bits_new%f"
                fi
                print -P -- "$prefix$mode%f%b $file$suffix"
            elif [[ "$type" == '?' || "$type" == "!" ]] && ((all)); then
                print -P -- "\e[90m$type  $line%f"
            elif [[ "$type" == 2 ]]; then
                local old_path new_path
                read -r mode _ _ old_perm new_perm _ _ _ files <<< "$line"
                IFS=$'\t' read -r new_path old_path <<< "$files"

                suffix=""
                if [[ "$old_perm" != "$new_perm" ]]; then
                    local bits_old="${old_perm:2}"
                    local bits_new="${new_perm:2}"
                    suffix="; %F{red}$bits_old%f -> %F{green}$bits_new%f"
                fi
                if [[ "$mode" == "RM" ]]; then
                    print -P -- "%B%F{red}R%F{yellow}M%b %F{red}$old_path%f -> %F{yellow}$new_path%f$suffix"
                fi
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
