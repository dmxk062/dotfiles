#!/bin/false
# vim: ft=zsh

# general purpose data transformation functions
# formats:
# table: a list of newline delimitted entries with fixed, delimiter based fields
# hash: a built in zsh hashtable
# json: arbitrary json arrays or maps

if [[ "$1" == "load" ]]; then

# read the json map on stdin into a hashtable variable
# dont expand child elements
# $1: tablename
function json2hash {
    local array_name="$1"
    declare -gA "$array_name"
    local json_object key value

    jq -rMc 'to_entries|map("\(.key)\t\(.value)")|.[]'\
        | while IFS=$'\t' read -r key value; do
            eval "$array_name"'[$key]="$value"'
        done
}

# $1: tablename
function hash2json {
    local array_name="$1" key value
    for key value in "${(@kv)${(P)array_name}}"; do
        printf "%s\t%s\n" "$key" "$value"
    done|jq -RMs 'split("\n")[:-1]|map(split("\t"))|map({(.[0]): .[1]})|add'
}

# $1: separator, empty string for IFS
# $@:2: names for columns, if not given first row of stream will be used
function table2json {
    local sep="$1"
    local separate=0
    shift

    if [[ "$sep" != "" ]]; then
        separate=1
    fi

    local -a columns

    if (($# <= 1)); then
        IFS="$sep" read -rA columns
    else 
        columns=("$@")
    fi

    if ((separate)); then
        column -tJ --table-columns="${(j:,:)columns}" -s "$sep"|jq -cM '.table'
    else
        column -tJ|jq -cM '.table'
    fi
}

elif [[ "$1" == "unload" ]]; then
    unfunction json2hash hash2json \
        table2json
fi
