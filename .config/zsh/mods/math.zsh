#!/bin/false
# vim: ft=zsh

# simple math things i use farely often


if [[ "$1" == "load" ]]; then

zmodload zsh/mathfunc

function conv {
    local from="$1"
    local to="$2"
    local res
    # -t is for result only, -c0 disables color, -s "fractions 0" always makes it return a decimal,
    # the - before $to disables mixed units
    res="$(qalc -t -c0 -s "fractions 0" -s "precision 100" "$from to -$to")"
    print "${res//$to/}"
}

function _math {
    local pi=3.1415926535897932384
    local e=2.71828182845904523536
    print -- "$[ $@ ]"

}

alias math="noglob _math"
alias '#'="noglob _math"

function sum {
    local accumulator=0
    local value

    if (($# == 0)); then
        while read -r value; do
            ((accumulator+=value))
        done
    else
        for value in $@; do
            ((accumulator+=value))
        done
    fi
    print -- $accumulator
}

function avg {
    local accumulator=0
    local count=0.0 value

    if (($# == 0)); then
        while read -r value; do
            ((accumulator+=value))
            ((count++))
        done
    else
        for value in $@; do
            ((accumulator+=value))
            ((count++))
        done
    fi
    print -- $((accumulator / count))
}

function ucov {
    local from="${1:-K}"
    local to="${2:-M}"
    local round="${3:-16}"
    local -A units=(
        ["b"]=$((1/8.0))
        ["B"]=1
        ["K"]=1024.0
        ["M"]=$((1024**2)).0
        ["G"]=$((1024**3)).0
        ["T"]=$((1024**4)).0
    )
    local value in out
    while read -r value; do
        in=$((units[$from] * value))
        out=$((in / units[$to]))
        printf "%.${round}g\n" "$out"
    done
}

# qalculate interactive
function qi {
    print -n -- "\e]0;qalc\a"
    qalc
}

elif [[ "$1" == "unload" ]]; then

unfunction conv ucov _math  sum avg qi

unalias math '#'

zmodload -u zsh/mathfunc

fi