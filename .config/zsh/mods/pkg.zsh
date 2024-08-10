#!/bin/false
# vim: ft=zsh

if [[ "$1" == "load" ]]; then

# check which package a file belongs to, first tries to find it in $PATH
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
    if [[ "$files" == "" ]]; then
        return 1
    fi
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



elif [[ "$1" == "unload" ]]; then


unfunction which_pkg flat lspkg

fi
