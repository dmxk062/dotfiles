#!/bin/false
# vim: ft=zsh

# function patterns in zsh

if [[ "$1" == "load" ]] {


# all of these work pretty much the same:
# argv will be set based on an element in either an array or a line in stdin, split based on IFS
# use "$*" if you want to access it all like one variable


function map {
    local expr="$1"; shift
    local arg

    if (($# == 0)); then
        while read -r arg; do
            argv=(${=arg})
            eval $expr
        done
    else
        for arg in "$@"; do
            argv=(${=arg})
            eval $expr
        done
    fi
}

# first param is a function name
function fmap {
    local func="$1"; shift
    if (($# == 0)); then
        while read -r arg; do
            "$func" "${=arg}"
        done
    else
        for arg in "$@"; do
            "$func" "${=arg}"
        done
    fi
}

# conditional map, basically tfilter|map
function cmap {
    local cmp="[[ $1 ]]" 
    local expr="$2" 
    shift 2
    local arg

    if (($# == 0)); then
        while read -r arg; do
            argv=(${=arg})
            if eval $cmp; then
                eval $expr
            fi

        done
    else
        for arg in "$@"; do
            argv=(${=arg})
            if eval $cmp; then
                eval $expr
            fi
        done
    fi
}

# variable map
# syntax sugar, for e.g ${*:A} for realpath
function vmap {
    local expr="print -- $1"; shift
    map "$expr" "$@"
}

function cvmap {
    local cmp="$1"
    local expr="print -- $2"
    shift 2
    cmap "$cmp" "$expr" "$@"
}

# arithmetic map, useful for e.g. unit conversion
function amap {
    local math="print -- \$[ $1 ]"; shift
    local arg

    if (($# == 0)); then
        while read -r arg; do
            argv=(${=arg})
            eval $math
        done
    else
        for arg in "$@"; do
            argv=(${=arg})
            eval $math
        done
    fi
}

# accumulate the results of math expressions, kinda like amap|sum
function afold {
    local math="print -- \$[ $1 ]"; shift
    local arg
    local result=0
    local _res

    if (($# == 0)); then
        while read -r arg; do
            argv=(${=arg})
            _res=$(eval "$math")
            ((result+=_res))
        done
    else
        for arg in "$@"; do
            argv=(${=arg})
            _res=$(eval "$math")
            ((result+=_res))
        done
    fi
    print -- $result

}

# only return values for with $expr returns 0
function filter {
    local expr="$1"; shift
    local arg

    if (($# == 0)); then
        while read -r arg; do
            argv=(${=arg})
            if eval $expr; then
                print -- $arg
            fi
        done
    else
        for arg in "$@"; do
            argv=(${=arg})
            if eval $expr; then
                print -- $arg
            fi
        done
    fi
}

# takes in a function e.g
# fn isFile { [[ -f "$*" ]]}
# ffilter isFile *
function ffilter {
    local func="$1"; shift
    local arg

    if (($# == 0)); then
        while read -r arg; do
            if "$func" "${=arg}"; then
                print -- "$arg"
            fi
        done
    else
        for arg in "$@"; do
            if "$func" "${=arg}"; then
                print -- "$arg"
            fi
        done
    fi
}

# syntax sugar to use expressions like test or [[ ]]
# e.g. tfilter '-f "$*"' *
function tfilter {
    local expr="[[ $1 ]]"; shift
    local arg

    if (($# == 0)); then
        while read -r arg; do
            argv=(${=arg})
            if eval $expr; then
                print -- $arg
            fi
        done
    else
        for arg in "$@"; do
            argv=(${=arg})
            if eval $expr; then
                print -- $arg
            fi
        done
    fi
}

# count, faster than just afold '1' or amap 1|sum
function cnt {
    if (($# > 0)); then
        print -- $#
        return
    fi

    local counter=0
    while read _; do
        ((counter++))
    done
    print -- "$counter"
}

# join the result of a process to stdout
# e.g.
# pgrep zsh|sjoin pgrep bash
# to get all pids of both
# basically the same as (pgrep zsh; pgrep bash)
function sjoin {
    local expr="$1"
    shift
    local elem
    while read -r elem; do
        print -- "$elem"
    done
    eval $expr "$@"
}

# split nicely, either expanded args or each line
function sep {
    local elem
    local line
    if (($# == 0)); then
        while read -rA line; do
            print -l -- "${line[@]}"
        done
    else
        print -l -- "${@}"
    fi
}

# join $1 lines together with $2
# very useful with e.g. jq to get properties into a more shell-friendly form
function interlace {
    local numcols="${1:-2}"
    local sep="${2:-" "}"
    local line 
    local counter=1
    local -a buf=()
    while read -r line; do
        buf+=("$line")
        if ((counter < numcols)) {
            ((counter++))
        } else {
            counter=1
            # hacky, but we sadly need eval here, otherwise sep wont expand
            eval "print -- \${(j(${sep}))buf}"
            buf=()
        }
    done
}

# separate all of stdin into $1 blocks and then join block1[1] and block2[1] ... blockn[1] to a single line separated by $2
# not that fast
# useful with e.g. sjoin to join two streams into one block
function blockjoin {
    local blocks="${1:-2}"
    local sep="${2:-" "}"
    local -a buf=()
    local num_lines=1
    local line blocklen 
    local -a outline=()

    while read -r line; do
        buf+=("$line")
        ((num_lines++))
    done

    blocklen=$((num_lines / blocks))

    for ((i=1; i<=blocklen; i++)){
        outline=()
        for ((j=0; j<blocks; j++)){
            local offset=$[ (j*blocklen) + i ]
            # print line: $i, block: $j, offset:$offset
            outline+=("${buf[$offset]}")
        }
        # same as above sadly
        eval "print -- \${(j(${sep}))outline}"
    }
}


# nicer to type
alias fn="function" '\\'="function" 'λ'="function"

# mainly for use in functions
alias ret="print --"
alias yield="print -l --"

# not just functions, also aliases and exes

function getdef {
    whence -f -x 4 "$@"|bat --plain --language zsh
}
compdef getdef=whence


function keys {
    local arrayname="${1}"
    print -l -- ${(k)${(P)arrayname}}
}




} elif [[ "$1" == "unload" ]] {

unfunction filter tfilter ffilter \
    afold \
    amap map cmap vmap cvmap fmap \
    cnt sjoin sep \
    interlace blockjoin \
    keys \
    getdef 

unalias fn '\\' 'λ' ret yield

}
