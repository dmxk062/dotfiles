#!/bin/false
# vim: ft=zsh

if [[ "$1" == "unload" ]]; then

    unfunction fupload \
        urlenc urldec \
        makeqr \
        ip-local \
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

function ip-local {
    ip route | awk '$1 == "default" { print $5" "$9}'
}

function makeqr {
    qrencode --size=2 --margin=2 --type=ANSIUTF8 --output=- 
}

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
