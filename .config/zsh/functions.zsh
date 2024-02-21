# fancy command not found that opens files

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



function enable_git(){
     # eval "$(ssh-agent -s)" >/dev/null 2>&1
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
function mcd(){
    mkdir "$1"
    cd "$1"
}



function qi(){
    echo "Calculator"
    printf "\033]0;qalc\007"
    qalc
}

ft(){
    file --dereference --mime-type "$@"
}

url(){
    file="${*//+/ }"
    file="${file//file:\/\//}"
    file="${file//\%/\\x}"
    file="$(echo -e "$file")"
    if [[ -d "$file" ]]; then
        cd "$file"
    elif [[ -f "$file" ]]; then
        case "$(file --dereference --mime-type --brief "$file")" in
            text/*)
                nvim "$file"
                ;;
        esac
    fi
}


-root(){
    if [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
        pkexec "$@"
    else
        sudo "$@"
    fi
}

# open(){
# # fancy openener
#
# local files_edit=()
#
# if [[ "$1" == "-g" ]] || [[ "$1" == "--gui" ]]; then
#     local gui=true
#     shift
# fi
#
# local files=("$@")
# if [[ "$files" == "" ]]; then
#     print "zsh: open: exepected at least 1 argument"
#     return 1
# fi
#
# for file in "${files[@]}"; do
#     local mimetype="$(file --dereference --brief --mime-type "$file")"
#     case $mimetype in 
#         text/*|application/json|inode/x-empty|application/x-subrip|application/javascript|application/x-elc)
#         files_edit+=("$file")
#             ;;
#     esac
# done
#
# if [[ "${#files_edit}" -gt 0 ]]; then
#     if $gui; then
#         for file in ${files_edit[@]}; do
#             print -n "Opening ${file}: "
#             xdg-open "$file" & disown
#         done
#     else
#         $VISUAL -O ${files_edit[@]}
#     fi
# fi
# }
#
# faster than the clear binary, yes 
c(){
    print -n "[H[2J"
}

# some process management stuff
procmem(){
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        echo "Please specify a list of process ids, not process names" > /dev/stderr
        return 127
    fi

    (for pid in "$@"; do
        read -r _ value _ <<< $(grep "VmRSS" /proc/$pid/status)
        ((total+=value))
        print -n "$pid: "
        numfmt --to=iec --from-unit=Ki "$value"
    done
    print -n "total: "
    numfmt --to=iec --from-unit=Ki "$total")|column -t
}

source $ZDOTDIR/dash_functions.sh

