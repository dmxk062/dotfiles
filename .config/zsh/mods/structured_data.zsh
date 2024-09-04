#!/bin/false
# vim: ft=zsh

# general purpose data transformation functions
# formats:
# table: a list of newline delimitted entries with fixed, delimiter based fields
# hash: a built in zsh hashtable
# json: arbitrary json arrays or maps
# proplist: a series of "blocks", delimitted by blank lines. lines match a key: value pattern

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

function proplist2table {
    local outsep="${1:-"	"}"
    local -a keys current
    local had_keys=0

    local line key rest value=""
    while IFS=":" read -r key rest; do 
        if [[ "$key" == "" ]]; then
            if ((!had_keys)); then
                eval print -- "\${(j[$outsep])keys}"
            fi
            eval print -- "\${(j[$outsep])current}"
            current=()
            had_keys=1
            continue
        fi
        if ((!had_keys)); then
            key=${key%"${key##*[![:space:]]}"}
            keys+=("$key")
        fi

        value=${rest#"${rest%%[![:space:]]*}"}
        value=${value%"${value##*[![:space:]]}"}
        current+=("$value")
    done
}

# index the named columns of a table, the first line is assumed to be the header, separated by IFS
function filter_table {
    local -a indices columns to_get=("$@")
    read -rA columns
    local sep=$'\t'

    if [[ "$1" == "-s" ]]; then
        sep="$2"
    elif [[ "$1" == "-s"* ]]; then
        sep="${1:2}"
    fi


    local field col i
    local -a found_in_table

    for field in "${to_get[@]}"; do
        i=1
        for ((i=1; i <= "${#columns}"; i++)); do
            if [[ "${columns[i]}" == "$field" ]]; then
                indices+=($i)
                found_in_table+=("$field")
                break
            fi
        done
    done

    eval print -- "\${(j[$sep])found_in_table[@]}"

    local line cur
    while read -rA line; do
        cur=()
        for i in "${indices[@]}"; do
            cur+=("${line[$i]}")
        done
        eval print -- "\${(j[$sep])cur[@]}"
    done
}

elif [[ "$1" == "unload" ]]; then
    unfunction json2hash hash2json \
        table2json \
        proplist2table \
        filter_table
fi
