#!/bin/false
# vim: ft=zsh

if [[ "$1" == "unload" ]]; then
    unfunction \
        json.hash \
        json.table \
        table.props \
        table.json \
        table.select \
        props.table \
        props.hash \
        props.select \
        props.filter \
        props.slice \
        props.map \
        hash.json \
        hash.props

    return
fi

# general purpose data transformation and conversion functions for formats useful in a shell
# so no binary or even more complex structured data formats
# just generalized forms of structured data
# json is here due to its widespread use in networking, that's it
# 
# compared to other data format handling in e.g. fancy object oriented shells,
# this keeps with the *stream* as the primary datatype of a shell.
# fields in that format are newline or delimiter separated, not following to some syntax tree
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
# props: 
#   a series of "blocks" or a single "block", delimitted by blank lines. lines match a key: value pattern
#   the delimiter is ":" by default, but may be anything in reality
#   this format is comparable to a table, however fields can contain ordered sub fields using a second delimiter
#   e.g. /proc/cpuinfo


# JSON

# read the json map on stdin into a hash variable
# don't expand child elements
# $1: tablename
# e.g. `curl ipinfo.io | json2hash val; print $val[ip]`
function json.hash {
    local array_name="$1"
    declare -gA "$array_name"
    local json_object key value

    jq -rMc 'to_entries|map("\(.key)\t\(.value)")|.[]'\
        | while IFS=$'\t' read -r key value; do
            eval "$array_name"'[${(q)key}]="${(q)value}"'
        done
}

# convert json into a table, no expansion of sub-elements
# $1: output separator
function json.table {
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


# TABLE

# convert a table into a property list
# $1: output separator
function table.props {
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

# read a table, with or without header into json
# $1: separator, empty string for IFS
# $@:2: names for columns, if not given first row of stream will be used
function table.json {
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

# index the named columns of a table, the first line is assumed to be the header, separated by IFS
# columns not in the table are silently ignored
# $@: columns to index
# -s: output separator
function table.select {
    local -a indices columns to_get=("$@")
    read -rA columns
    local sep=$'\t'
    local flag

    while getopts "s:" flag; do
        case "$flag" in
            s) sep="$OPTARG";;
        esac
    done


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


# PROPS

# convert a property list into table
# $1: key-value separator
# $2: output separator
function props.table {
    local insep="${1:-":"}"
    local outsep="${2:-"	"}"
    local -a keys current
    local had_keys=0

    local line key rest value=""
    while IFS="$insep" read -r key rest; do 
        key=${key%"${key##*[![:space:]]}"}
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
            keys+=("$key")
        fi

        value=${rest#"${rest%%[![:space:]]*}"}
        value=${value%"${value##*[![:space:]]}"}
        current+=("$value")
    done
}

function props.hash {
    local array_name="$1"
    local sep="${2:-:}"
    declare -gA "$array_name"

    local key val
    while IFS="$sep" read -r key val; do
        if [[ -z "$key" ]]; then
            continue
        fi
        key=${key%"${key##*[![:space:]]}"}
        val=${val#"${val%%[![:space:]]*}"}
        val=${val%"${val##*[![:space:]]}"}
        eval "$array_name"'[${(q)key}]="${(q)val}"'
    done
}

# select fields from props to keep
function props.select {
    local insep=":" outsep=":	"
    local key rest value

    while getopts "i:s:" flag; do
        case "$flag" in
            i) insep="$OPTARG";;
            s) outsep="$OPTARG";;
        esac
    done

    local -a keys=("$@")

    while IFS="$insep" read -r key rest; do
        key=${key%"${key##*[![:space:]]}"}
        if [[ "$key" == "" ]]; then
            print
        elif (($keys[(I)$key])); then
            value=${rest#"${rest%%[![:space:]]*}"}
            value=${value%"${value##*[![:space:]]}"}
            print "$key$outsep$value"
        fi
    done
}

# select objects from a props based on expressions evaluated on their values
# $1: expression to be evaluated, $obj will be set to fields in object
# not required for tables because there just plain 'filter' can be used
function props.filter {
    local insep=":" outsep=":	"
    local -A obj
    local -a cur
    local key rest value
    local had_keys=0

    while getopts "i:s:" flag; do
        case "$flag" in
            i) insep="$OPTARG";;
            s) outsep="$OPTARG";;
        esac
    done


    while IFS="$insep" read -r key rest; do 
        if [[ "$key" == "" ]]; then
            if eval "$1"; then
                print -l -- "${cur[@]}" ""
            fi
            obj=()
            cur=()
            had_keys=1
            continue
        fi

        value=${rest#"${rest%%[![:space:]]*}"}
        value=${value%"${value##*[![:space:]]}"}
        obj[$key]+="${value}"
        cur+=("$key$outsep$value")
    done
}

# index props
# if $2 is not given, only the single element in $1 is output
# if $1 is not given either, print the entire list
# $1: start index
# $2: end index
function props.slice {
    local insep=":" outsep=":	"
    local num_read=1
    local start=${1:-0} 
    local end=${2:-$1}

    while getopts "i:s:" flag; do
        case "$flag" in
            i) insep="$OPTARG";;
            s) outsep="$OPTARG";;
        esac
    done

    local -a cur
    local key rest value
    while IFS="$insep" read -r key rest; do 
        key=${key%"${key##*[![:space:]]}"}
        if [[ "$key" == "" ]]; then
            if ((num_read <= end && num_read >= start)); then
                print -l -- "${cur[@]}" ""
            fi
            cur=()
            ((num_read++))
            continue
        fi

        value=${rest#"${rest%%[![:space:]]*}"}
        value=${value%"${value##*[![:space:]]}"}
        cur+=("$key$outsep$value")
    done
}

function props.map {
    local insep=":" outsep=":	"
    local -A obj
    local -a cur
    local key rest value
    local had_keys=0

    while getopts "i:s:" flag; do
        case "$flag" in
            i) insep="$OPTARG";;
            s) outsep="$OPTARG";;
        esac
    done


    while IFS="$insep" read -r key rest; do 
        if [[ "$key" == "" ]]; then
            eval "$1"
            obj=()
            cur=()
            had_keys=1
            continue
        fi

        value=${rest#"${rest%%[![:space:]]*}"}
        value=${value%"${value##*[![:space:]]}"}
        obj[$key]+="${value}"
        cur+=("$key$outsep$value")
    done
}


# HASH

# print json representation of hash
# $1: tablename
function hash.json {
    local array_name="$1" key value
    for key value in "${(@kv)${(P)array_name}}"; do
        printf "%s\t%s\n" "$key" "$value"
    done | jq -RMs 'split("\n")[:-1]|map(split("\t"))|map({(.[0]): .[1]})|add'
}

# convert a hashmap to a list of key: val lines
# $1: name of hash
# $2: output separator
function hash.props {
    local array_name="$1"
    local outsep="${2:-": "}"

    local k v
    for k v in "${(@kv)${(P)array_name}}"; do
        print -- "$k$outsep$v"
    done
}
