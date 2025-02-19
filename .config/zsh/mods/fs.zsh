#!/bin/false
# vim: ft=zsh

# make filesystem naviation/file handling easier

if [[ "$1" == "unload" ]]; then

    unfunction rgf mcd rp bn rcd \
        pwf \
        r .. \
        root

    unalias md ft bft zcp zln

    zmodload -u zsh/mapfile

    unfunction zmv

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

function lr {
    command lsd --tree --depth 3 --hyperlink=always "$@" | less -rFi
}

# like pwd but takes into account all the shell magic
function pwf {
    print -P -- "%~"
}

# go up n levels; in a subshell, return the absolute path to the directory n levels above
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

# cd to a directory containing a file
function rcd {
    cd "$(root "$1")"
}

autoload -Uz zmv
alias zcp="zmv -C" zln="zmv -p 'ln -s'"
