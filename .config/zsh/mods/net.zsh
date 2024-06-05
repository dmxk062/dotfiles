#!/bin/false
# vim: ft=zsh



NC_PORT=60246

# a bunch of network dependant stuff, such as different network services

if [[ "$1" == "load" ]]; then

alias req="noglob curl -s"

zmodload zsh/net/socket

function fupload {
    curl -F file=@"$1" "${2:-"https://0x0.st"}"
}

function ncsend {
    nc -l  -p "${1:-$NC_PORT}"
}

function ncrecv {
    nc -dq 0 "$1" "${2:-$NC_PORT}"
}


function _jreq {
    local url="$1"
    shift
    local jqopts="${(j:,:)@}"
    curl -s "$url"|jq -r "${jqopts:-.}"
}

alias jreq="noglob _jreq"

function urlenc {
    local fpath
    fpath="${1:A}"
    if [[ "$fpath" == "/run/user/$UID/gvfs/sftp"* ]]; then
        local sftppath="${fpath/"\/run\/user\/$UID\/gvfs\/sftp:"/}"
        local host="${sftppath/host=/}"
        host="${host/"\/"*/}"
        local remote_path="${sftppath#*/}"
        print "sftp://${host}/${remote_path}"
        return 0
    fi
    print -n "file://"
    printf '%s' "$fpath"|jq -sRr @uri|sed 's/%2F/\//g'
}


function urldec {
    local url="$1"
    local file
    if ! [[ "$url" == "file://"* ]]; then
        return
    fi
    file="${url//file:\/\//}"
    file="${file//\%/\\x}"
    print -- "$file"
}


function local_ip {
    local -a line
    ip route | while read -rA line; do
        if [[ "$line[1]" == "default" ]] {
            print "$line[9]"
        }
    done
}


alias public_ip="req ifconfig.es"

# not necessarily a network thing
# params: $1: text to encode
#         $@:2 flags for qrencode
function qrgen {
    qrencode "$1" --margin=2 --output=- --size=2 --type=ANSIUTF8 "${@:2}" 
}

function deepl_request {
    local request="$1"
    local auth_key="$( < "$XDG_DATA_HOME/keys/deepl" )"
    if [[ "$auth_key" == "" ]] {
        print -P -- "%F{red}Please make sure your auth key is placed at $XDG_DATA_HOME/keys/deepl%f" > /dev/stderr
        return 1
    }
    curl -s --request POST --header "Authorization: DeepL-Auth-Key $auth_key" \
        --header "Content-Type: application/json" \
        --data "$request" \
        'https://api-free.deepl.com/v2/translate'
}

function translate {
    local target="${1}"; shift
    local -a buffer
    if (($# == 0)) {
        local line
        while read -r line; do
            buffer+=("$line")
        done
    } else {
        buffer="${argv[@]}"
    }
    deepl_request "{\"text\":[\"${(j:\n:)buffer[@]}\"],\"target_lang\":\"$target\"}"|jq -r '.translations.[].text'

}

function ncdir {
    local mode="$1"
    local arg="$2"
    local port="${3:-$NC_PORT}"

    case $mode in 
        send)
            local dir="$arg"
            if ! [[ -d "$dir" ]] {
                print -- "Not a directory: $dir"
                return 1
            }
            tar czp "$dir"|nc -l -p "$port"
            ;;
        recv|*)
            local host="$arg"
            nc -dq 0 "$host" "$port"|tar zxv
            ;;
    esac
}
autoload -Uz _translate
compdef _translate translate




elif [[ "$1" == "unload" ]]; then

unfunction fupload _jreq \
    urlenc urldec \
    ncsend ncrecv ncdir \
    local_ip \
    qrgen \
    deepl_request translate 

unalias req jreq public_ip

zmodload -u zsh/net/socket

fi
