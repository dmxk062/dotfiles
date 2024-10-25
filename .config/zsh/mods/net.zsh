#!/bin/false
# vim: ft=zsh

if [[ "$1" == "unload" ]]; then

    unfunction fupload \
        urlenc urldec \
        makeqr \
        deepl_request translate \
        ncsend ncrecv ncsenddir ncrecvdir

    unalias req 

    zmodload -u zsh/net/socket

    return
fi

NC_PORT=60246

# a bunch of network dependant stuff, such as different network services

alias req="noglob curl -s"

zmodload zsh/net/socket

function fupload {
    curl -sF file="@$1" "${2:-"https://0x0.st"}"
}

function urlenc {
    local arg
    for arg in "$@"; do
        local urlpath="$arg"
        local prefix=""
        if [[ ! "$urlpath" =~ ^.*://.*$ ]]; then
            # resolve the path and use the correct schema
            prefix="file://"
            urlpath="${urlpath:A}"
        fi

        print -n "$prefix"
        print -n -- "$urlpath"|jq -sRr @uri|sed 's/%2F/\//g'
    done
}

function urldec {
    local url
    for url in "$@"; do
        if [[ "$url" != "file://"* ]]; then
            # ignore other urls
            print -- "$url"
            continue
        fi

        local file="${url//file:\/\//}"
        file="${file//\%/\\x}"
        print -- "$file"
    done
}

function deepl_request {
    local request="$1"
    local auth_key="$( < "$XDG_DATA_HOME/keys/deepl" )"
    if [[ "$auth_key" == "" ]]; then
        print -P -- "%F{red}Please make sure your auth key is placed at $XDG_DATA_HOME/keys/deepl%f" > /dev/stderr
        return 1
    fi
    curl -s --request POST --header "Authorization: DeepL-Auth-Key $auth_key" \
        --header "Content-Type: application/json" \
        --data "$request" \
        'https://api-free.deepl.com/v2/translate'
}

function makeqr {
    qrencode --size=2 --margin=2 --type=ANSIUTF8 --output=- 
}

function translate {
    local target="${1:-EN}"
    local -a buffer
    local line
    while read -r line; do
        buffer+=("$line")
    done
    local request_body
    if [[ -n "$2" ]]; then
        request_body="{\"text\":[\"${(j:\n:)buffer[@]}\"],\"target_lang\":\"$target\", \"source_lang\": \"$2\"}"
    else
        request_body="{\"text\":[\"${(j:\n:)buffer[@]}\"],\"target_lang\":\"$target\"}"
    fi
    deepl_request "$request_body"|jq '.translations.[0].text' -r
}

autoload -Uz _translate
compdef _translate translate

function ncsend {
    cat | nc "$1" $NC_PORT
}

function ncrecv {
    nc -d -q 1 -l -p $NC_PORT
}

function ncsenddir {
    tar cvf - "$2" | nc "$1" $NC_PORT
}

function ncrecvdir {
    mkdir -p -- "$1"
    nc -l -p $NC_PORT | tar xvf - -C "$1"
}
