#!/bin/false
# vim: ft=zsh

# simple math things i use farely often

if [[ "$1" == "load" ]]; then

which_pkg(){
    local progpath
    if [[ -f "$1" ]]; then
        progpath="$1"
    else
        progpath="$(which "$1")"
        if [[ "$progpath" == *"aliased"* ]]; then
            progpath="/usr/bin/${1}"
        fi
        if ! [[ -e "$progpath" ]]; then
            print "File does not exist: ${progpath}"
            return 1
        fi
    fi
    pacman -Qo "$progpath"
}


# list all files belonging to a package
# options:
# -x: only executables
# -m: only manpages
lspkg(){
    local searchtype
    if [[ "$1" == "-x" ]]; then
        searchtype="exe"
        shift
    elif [[ "$1" == "-m" ]]; then
        searchtype="man"
        shift
    fi

    local package="$1"
    local files=($(pacman -Qql "$package"))
    local file
    for file in $files; do
        case $searchtype in
            exe)
                if [[ -x "$file" ]]&&[[ -f "$file" ]]; then
                    print "$file"
                fi
                ;;
            man)
                if [[ -f "$file" ]]&&[[ "$file" == "/usr/share/man/"* ]]; then
                    print "$file"
                fi
                ;;
            *)
                print "$file"
                ;;
        esac
    done
}

# flatpak wrapper for ease of use
flat(){
    local command="${1:-upd}"
    local action
    local search(){
        local name desc id ver branch repo
        flatpak search "$@"|sed 's/\t/;/g'| while read -r line; do
            IFS=";" read -r name desc id ver branch repo <<< "$line"
            # local url="$(printf '\e]8;;%s/%s\e\\%s\e]8;;\e\\\n' "https://flathub.org/apps" "$id" "$id")"
            print -Pf '%s/%s %s\n    %s\n' "%B%F{magenta}${repo}%f"  "$name" "%F{green}${ver}%f%b" "$desc"
        done
    }
    case $command in
        '-Syu'|upd*)
            flatpak update
            ;;
        '-S'|in*)
            shift
            flatpak install "$@"
            ;;
        '-R'|rm|rem*)
            shift
            flatpak remove "$@"
            ;;
        '-Ss'|search)
            shift
            search "$@"
            ;;
        *)
            search "$@"
            ;;
    esac

}



elif [[ "$1" == "unload" ]]; then


unfunction which_pkg flat lspkg

fi