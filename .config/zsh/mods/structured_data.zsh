#!/bin/false
# vim: ft=zsh

if [[ "$1" == "unload" ]]; then
    unfunction json2hash hash2json \
        json2table table2json \
        proplist2table table2proplist \
        filter_table \
        hash2props props2hash

    return
fi

# general purpose data transformation and conversion functions for formats useful in a shell
# so no binary or even more complex structured data formats
# just generalized forms of structured data
# json is here due to its widespread use in networking, that's it
# 
# compared to other data format handling in e.g. fancy object oriented shells,
# this keeps with the *stream* as the primary datatype of a shell.
# fields in that format are newline or delimiter separated, not adhering to some standard
# this means that regular shell utilities (grep, awk, sed, cut) can still be used with them
#
# formats:
#
# table:
#   a list of newline delimited entries with fixed, delimiter based fields
#   it may optionally have a header line giving the names of the fields
#   csv is a type of "table", but a table may not contain *any* occurrence of their separators, 
#   with no escaping of separators to simplify handling so smth like \t or \0 should be used
#   e.g. /etc/passwd
#
# hash: 
#   a built in zsh hashtable, mainly used as the final step in a pipeline
#   meant to be used to examine data in more detail
#
# json: 
#   arbitrary json arrays or maps. json is mainly used for maps however
#
# proplist: 
#   a series of "blocks", delimitted by blank lines. lines match a key: value pattern
#   the delimiter is ":" by default, but may be anything in reality
#   this format is comparable to a table, however fields can contain ordered sub fields using a second delimiter
#   e.g. /proc/cpuinfo


# read the json map on stdin into a hash variable
# don't expand child elements
# $1: tablename
# e.g. `curl ipinfo.io | json2hash val; print $val[ip]`
function json2hash {
    local array_name="$1"
    declare -gA "$array_name"
    local json_object key value

    jq -rMc 'to_entries|map("\(.key)\t\(.value)")|.[]'\
        | while IFS=$'\t' read -r key value; do
            eval "$array_name"'[$key]="$value"'
        done
}

# print json representation of hash
# $1: tablename
function hash2json {
    local array_name="$1" key value
    for key value in "${(@kv)${(P)array_name}}"; do
        printf "%s\t%s\n" "$key" "$value"
    done | jq -RMs 'split("\n")[:-1]|map(split("\t"))|map({(.[0]): .[1]})|add'
}

# read a table, with or without header into json
# $1: separator, empty string for IFS
# $@:2: names for columns, if not given first row of stream will be used
function table2json {
    local sep="${1:-"	"}"
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

# convert json into a table, no expansion of sub-elements
# $1: output separator
function json2table {
    local line
    local sep="${1:-"	"}"

    local -a columns
    local jsonObj=""

    while read -r line; do
        jsonObj+="$line"
    done

    IFS=$'\t' read -rA columns < <(print -- "$jsonObj"| jq -r '.[0]|keys_unsorted|join("\t")')
    print -- "${(pj[$sep])columns}"
    print -- "$jsonObj"|jq --arg sep "$sep" -r '.[]|[.[]]|join($sep)'
}

# convert a property list into table
# $1: key-value separator
# $2: output separator
function proplist2table {
    local insep="${1:-":"}"
    local outsep="${2:-"	"}"
    local -a keys current
    local had_keys=0

    local line key rest value=""
    while IFS="$insep" read -r key rest; do 
        if [[ "$key" == "" ]]; then
            if ((!had_keys)); then
                print -- "${(pj[$outsep])keys}"
            fi
            print -- "${(pj[$outsep])current}"
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

# convert a table into a property list
# $1: output separator
function table2proplist {
    local outsep="${1:=": "}"
    read -rA header
    
    local fields i
    while read -rA fields; do
        for ((i = 1; i <= $#fields; i++)); do
            print -- "${header[i]}$outsep${fields[i]}"
        done
        print
    done
}

# index the named columns of a table, the first line is assumed to be the header, separated by IFS
# columns not in the table are silently ignored
# $@: columns to index
# -s: output separator
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

    print -- "${(pj[$sep])found_in_table[@]}"

    local line cur
    while read -rA line; do
        cur=()
        for i in "${indices[@]}"; do
            cur+=("${line[$i]}")
        done
        print -- "${(pj[$sep])cur[@]}"
    done
}

# convert a hashmap to a list of key: val lines
# $1: name of hash
# $2: output separator
function hash2props {
    local array_name="$1"
    local outsep="${2:-": "}"

    local k v
    for k v in "${(@kv)${(P)array_name}}"; do
        print -- "$k$outsep$v"
    done
}

function props2hash {
    local array_name="$1"
    local sep="${2:-:}"
    declare -gA "$array_name"

    local key value
    while IFS="$sep" read -r key val; do
        if [[ -z "$fsep" ]]; then
            eval "$array_name"'[$key]="$val"'
        fi
    done
}
