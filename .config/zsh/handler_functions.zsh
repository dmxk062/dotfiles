function command_not_found_handler() {
    printf 'zsh: command not found: %s\n' "$1" > /dev/stderr
    if [[ ! -t 0 ]]||[[ ! -t 1 ]]; then # early return if we are not in a tty
        return 127
    fi
    local file="$1"
    if [[ -f "./$file" ]]
    then
        printf 'zsh: file %s found. Open it in %s? [y/N] ' "$file" "$EDITOR"
        read -k 1 answer
        if [[ "$answer" == "y" || "$answer" == "Y" ]]
        then 
            $EDITOR "$file"
        fi
    else 
        local entries=(${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$file")"})
        if (( ${#entries[@]} ))
        then
            print "zsh: but it is available in the following package(s):"
            local pkg
            for entry in "${entries[@]}"
            do
                local fields=(${(0)entry})
                if [[ "$pkg" != "${fields[2]}" ]]
                then
                    print -P "%B%F{magenta}${fields[1]}%f/${fields[2]}%b"
                fi
                pkg="${fields[2]}"
            done
        else
            printf "zsh: could not find a package that provides /usr/bin/%s in the repos. search the AUR? [y/N] " "$file"
            read -k 1 answer
            if [[ "$answer" == "y" || "$answer" == "Y" ]]
            then
                printf "\n"
                yay -Ssa "$file"
            fi
        fi
    fi
    return 127
}


function __readnullcommand {
    local fpath="$(realpath /proc/self/fd/0)"
    if [[ -f "$fpath" ]]; then
        \bat --color=always -Pp "$fpath"
    elif [[ -d "$fpath" ]]; then
        \lsd "$fpath"
    fi
}

READNULLCMD=__readnullcommand
