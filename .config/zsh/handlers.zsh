function command_not_found_handler() {
    printf 'zsh: command not found: %s\n' "$1" > /dev/stderr
    # early return if not in tty
    if [[ ! -t 0 || ! -t 1 ]] && return 127

    local file="$1"
    local entries=(${(f)"$(pkgfile -b -- "$file")"})
    if (( ${#entries[@]} )); then
        print "zsh: but it is available in the following package(s):"
        local entry
        for entry in "${entries[@]}"; do
            local fields=(${(s:/:)entry})
            print -P "%B%F{magenta}${fields[1]}%f/${fields[2]}%b"
        done
    fi
    return 127
}


function __readnullcommand {
    local realpath="/proc/self/fd/0"
    realpath="${realpath:A}"
    if [[ -f "$realpath" ]] {
        command bat --color=always -Pp "$realpath"
    } elif [[ -d "$realpath" ]] {
    command lsd "$realpath"
}
}

READNULLCMD=__readnullcommand

# abuse for the clipboard, can contain any data, not just a dir
function _clipboard_directory_name {
    if [[ "$1" == "d" ]]; then
        return 1
    fi

    if [[ "$1" == "n" ]]; then
        if [[ "$2" != "clip"* ]] && [[ "$2" != "sel"* ]]; then
            return 1
        fi

        local cmd="wl-paste"
        local content err type mime use_mime
        if [[ "$2" == *":"* ]]; then
            IFS=":" read -r type mime <<< "$2"
            use_mime=1
        else
            type="$2"
        fi

        if [[ "$type" == "clip" ]]; then
            if ((use_mime)); then
                local -a mime_types=($(wl-paste -l 2>/dev/null))
                if ! (($mime_types[(Ie)$mime])); then
                    return 1
                fi
                content="$(wl-paste --type "$mime" 2>/dev/null)"
                err=$?
            else
                content="$(wl-paste 2>/dev/null)"
                err=$?
            fi
        elif [[ "$type" == "sel" ]]; then
            if ((use_mime)); then
                local -a mime_types=($(wl-paste --primary -l 2>/dev/null))
                if ! (($mime_types[(Ie)$mime])); then
                    return 1
                fi
                content="$(wl-paste --primary --type "$mime" 2>/dev/null)"
                err=$?
            else
                content="$(wl-paste --primary 2>/dev/null)"
                err=$?
            fi
        fi

        if ((err > 0)) || [[ -z "$content" ]]; then
            return 1
        fi

        typeset -ga reply
        reply=("$content")
        return 0
    fi

    if [[ "$1" == "c" ]]; then
        local primary_types secondary_types primary_err secondary_err
        primary_types=($(wl-paste --primary -l 2>/dev/null))
        primary_err=$?
        secondary_types=($(wl-paste -l 2>/dev/null))
        secondary_err=$?

        local -a compls
        if ! ((primary_err)); then
            compls+=("sel")
            compls+=("${(@)primary_types/#/"sel:"}")
        fi

        if ! ((secondary_err)); then
            compls+=("clip")
            compls+=("${(@)secondary_types/#/"clip:"}")
        fi

        _wanted dynamic-dirs expl 'clipboards' compadd -S\] -a compls
        return
    fi
}

zsh_directory_name_functions+=(_clipboard_directory_name)
