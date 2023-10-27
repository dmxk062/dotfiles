# fancy command not found that opens files

function command_not_found_handler {
    printf 'zsh: command not found: %s\n' "$1"
    file="$1"
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



function enable_git(){
     eval "$(ssh-agent -s)" >/dev/null 2>&1
     ssh-add "$HOME/.local/share/keys/git"
}

# function to use a workspace in ~/ws

function ws(){
    [ -z $1 ]&& return
    cd $HOME/ws/$1||return 1
    enable_git
    print -P "%B󰌌%b working on %F{green}%{\x1b[3m%}$1%{\x1b[0m%}"
}

function md(){
    for dir in $@
    do
        mkdir -p $dir
    done
}

function alert(){ #alert function to notify after a command.
    prog=$@
    start=$(date "+%s")
    eval $prog
    exit=$?
    time=$(( $(date +%s) - $start ))
    if [ $exit = 0 ]
    then
        notify-send -i "/usr/share/icons/Tela/scalable/apps/terminal.svg" "Command $prog finished successfully" "Took $(date -d @$time "+%M:%S")"
    else
        notify-send -i "/usr/share/icons/Tela/scalable/apps/gksu-root-terminal.svg" "Command $prog failed with error code: $exit" "Took $(date -d @$time "+%M:%S")"
    fi
}
