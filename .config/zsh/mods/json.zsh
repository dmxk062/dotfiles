#!/bin/false
# vim: ft=zsh


# a lot of general json and other data structure functions

if [[ "$1" == "load" ]]; then

# two table handling functions
# a "table" is a list of newline separated values representing objects
# they may be preceded by a header containing the field names
# the separator between the fields is taken as a space " " by default
# both this and json2table below take an option sep="str" as the first argument for setting a **single** character separator
# only simple string/int/null values are supported, no nested arrays/objects
# example:
# table2json sep=: login password userid groupid username home shell < /etc/passwd
# to get all the users as json, here we need to name the fields ourselves
function table2json {
    local sep=" "
    local separate=0
    if [[ "$1" == "sep="* ]] {
        IFS='=' read -r _ sep <<< "$1"
        separate=1
        shift
    }
    local -a columns

    if (($# == 0)) {
        if ((separate == 1)){
            IFS="$sep" read -rA columns
        } else {
            read -rA columns
        }

    } else {
        columns=("$@")
    }
    if ((separate == 1)){
        column -tJ --table-columns="${(j:,:)columns}" -s "$sep" \
            |jq -cM '.table'

    } else {
        column -tJ --table-columns="${(j:,:)columns}" \
            |jq -cM '.table'
    }
}

function json2table {
    local line 
    local sep=" "
    if [[ "$1" == "sep="* ]] {
        IFS='=' read -r _ sep <<< "$1"
        shift
    }
    local -a columns 

    local jsonObj="" 

    while read -r line; do
        jsonObj+="$line"
    done

    if (($# == 0)) {
        columns=($(echo "$jsonObj" | jq -r '.[0]|keys_unsorted[]'))
    } else {
        columns=("$@")    
    }
    eval "print -- \${(j(${sep}))columns[@]}"
    echo "$jsonObj" \
        |jq --arg sep "$sep" -r '.[]|[.[] ]|join($sep)'
    
}

# how to use:
# json2hash myArray <<< "$(curl ipinfo.io)"
# print $myArray[ip]
# spaces from keys will be stripped
function json2hash {
    local arrayName="${1}"
    declare -gA "$arrayName"
    local jsonObj key value

    jq -rMc 'to_entries| map("\(.key)\t\(.value)")| .[]' \
        |while IFS=$'\t' read -r key value; do
        eval $arrayName'[$key]="$value"'
    done
}

function json2array {
    local arrayName="${1}"
    declare -ga "$arrayName"
    local line jsonObj value

    while read -r line; do
        jsonObj+="$line"
    done

    echo "$jsonObj"|jq -rMc '.[]' \
        |while read -r value; do
        eval $arrayName'+="$value"'
    done
}

# nice way to deserialize too
function list2hash {
    local arrayName="${1}"
    declare -gA "$arrayName"
    local line value

    while read -r key value; do
        eval $arrayName'[$key]="$value"'
    done
}


# returns all the assigned lists' names in the first parameter
function table2lists {
    local -a columns
    local output_name="$1"; shift
    local num_columns column line
    

    if (($# == 0)) {
        read -rA columns
    } else {
        columns=("$@")
    }
    num_columns=$#columns 

    for column in "${columns[@]}"; do
        declare -ga "$column"
    done

    while read -rA line; do
        for ((i=1; i<=num_columns; i++)) {
            eval ${columns[i]}+='${line[i]}'
        }
    done
    declare -ga "$output_name"
    eval "$output_name"='("${columns[@]}")'
}

# index a named array, very useful with the above
# e.g. IFS=: table2lists etc_passwd login passwd uid gid name home shell < /etc/passwd
# iindex etc_passwd 1,5 users
function iindex {
    local arrayName="$1"
    local index="$2"

    if (($# == 3)){
        eval "$3"="(\"\$${arrayName}[$index]\")"
    } else {
        eval "print -- \"\$${arrayName}[$index]\""
    }
}

alias jsoniter="jq -Mc '.[]'"

elif [[ "$1" == "unload" ]]; then

unfunction table2json json2table \ 
    json2hash json2array \
    list2hash \
    iindex

unalias jsoniter


fi
