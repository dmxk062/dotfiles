#!/bin/false
# vim: ft=zsh

# make filesystem naviation/file handling easier

if [[ "$1" == "unload" ]]; then

    unfunction rgf mcd rp bn in \
        rmi pwf \
        readfile readstream lr .. \
        root

    unalias md ft bft

    zmodload -u zsh/mapfile

    return
fi

zmodload zsh/mapfile

alias md="mkdir -p"

function mcd {
    if [[ -d "$1" ]] {
        cd "$1"
        return
    }
    mkdir -p "$1"
    cd "$1"
}
compdef mcd=mkdir


alias ft="file --mime-type -F$'\t'"
alias bft="file --brief --mime-type -N"


# ripgrep files
function rgf {
    local search_term="$1"
    local search_path
    if [[ -z "$2" ]] {
        search_path="$PWD"
        shift 1
    } else {
        search_path="$2"
        shift 2
    }
    local flags="$@"

    rg --color=never --files-with-matches $flags "$search_term" "$search_path"
}

# better realpath
function rp {
    print -l -- "${@:A}"
}
# basename
function bn {
    print -l -- "${@:t}"
}

function readfile {
    local arrayname="$1"
    local file="$2"

    eval "$arrayname"='("${(@f)mapfile['"$file"']}")'
}

function readstream {
    local arrayname="${1}"
    local line  
    local -a buffer

    while read -r line; do
        buffer+=("$line")
    done

    eval "${arrayname}=("\${buffer}")"
}

# rm wrapper
function rmi {
    if (($# < 1)) {
        return 0
    }

    local -a files
    local -a dirs
    local -a links

    local file
    for file in "${@}"; do
        if [[ -L "$file" ]] {
            links+=("$file")
        } elif [[ -f "$file" ]] {
            files+=("$file")
        } elif [[ -d "$file" ]] {
            dirs+=("$file")
        } else {
            print -P "%F{red}Not a file, dir or symlink: $file%f" > /dev/stderr
            return 1
        }
    done

    local -a fmt=()
    if (($#files > 0)) {
        fmt+=("%F{magenta}󰈔 $#files file(s)%f")
    }
    if (($#dirs > 0)) {
        fmt+=("%F{cyan}󰉋 $#dirs dir(s)%f")
    }
    if (($#links > 0)) {
        fmt+=("%F{blue}󰌷 $#links link(s)%f")
    }
    print -Pn -- "%B${(j:\n:)fmt[@]}%b" "\n%B%F{red}%S󰩹 rm%s%f%b N[o]/y[es]/f[orce]/t[rash] "
    read -r -k 1 answer
    echo
    case "$answer" in 
        [tT])
            gio trash -- "${files[@]}" "${dirs[@]}" "${links[@]}"
            if (($? == 0)) {
                print -P "%F{green}󰩹 Successfully trashed $[$#files + $#dirs + $#links] element(s)%f"
            }
            ;;
        [yY])
            \rm -rI -- "${files[@]}" "${dirs[@]}" "${links[@]}"
            ;;
        [fF])
            \rm -rf -- "${files[@]}" "${dirs[@]}" "${links[@]}"
            echo
            ;;
        *|[Nn]) 
            echo
            return 1
            ;;
    esac
    echo
}

function lr {
    command lsd --tree --depth 3 --hyperlink=always "$@" | less -rFi
}

# like pwd but takes into account all the shell magic
function pwf {
    print -P -- "%~"
}

# go up n levels, in a subshell, return the absolute path to the directory n levels above
function .. {
    local level="$1"
    if [[ -t 1 ]] {
        if [[ ! "$level" =~ '[0-9]+' ]] {
            cd ..
            return
        }

        local fmt
        printf -v fmt "../%.0s" {1..$level}
        cd "$fmt"
    } else {
        local fmt
        printf -v fmt "../%.0s" {1..$level}
        print -- "${fmt:a}"
    }
}

# find the parent directory containing a file or dir
# e.g. `root .git` or `root compile_commands.json`
function root {
    local pattern="$1"
    local cwd="$PWD"

    while [[ "$cwd" != "" && ! -e "$cwd/$pattern" ]]; do
        cwd="${cwd%/*}"
    done

    if [[ "$cwd" == "" ]]; then
        if [[ -e "/$pattern" ]]; then
            print "/"
        else
            return 1
        fi
    else
        print "$cwd"
    fi
}
