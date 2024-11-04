#!/bin/false
# vim: ft=zsh


if [[ "$1" == "unload" ]]; then
    unfunction which_pkg lspkg

    return
fi
# check which package a file belongs to, first tries to find it in $PATH
which_pkg(){
    local file progpath
    local -a paths
    for file in "$@"; do
        if [[ -f "$file" ]]; then
            paths+=("$file")
        else
            progpath="$(which "$file")"
            if [[ "$progpath" == *"aliased"* ]]; then
                progpath="/usr/bin/${file}"
            fi
            if ! [[ -e "$progpath" ]]; then
                print "No such program in \$PATH, file or directory: $file" >&2
                continue
            fi
            paths+=("$progpath")
        fi
    done
    if ((${#paths} > 0)); then
        pacman -Qqo "${paths[@]}"
    else
        return 1
    fi
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
                if [[ -x "$file" && -f "$file" ]]; then
                    print "$file"
                fi
                ;;
            man)
                if [[ -f "$file" && "$file" == "/usr/share/man/"* ]]; then
                    print "$file"
                fi
                ;;
            *)
                print "$file"
                ;;
        esac
    done
}
