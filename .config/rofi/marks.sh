#!/usr/bin/env bash

# Bookmark file format {{{
# Each line is a |-separated list of fields which are as follows:
#   - type: single character describing what type it is
#    - optionally followed by :icon-name
#       - f: file
#       - d: directory
#       - u: url to open
#       - U: url with format parameter
#       - F: files matching a fd query
#   - name: short name
#   - desc: description
#   - value: the value, for U it should contain a single %s
# }}}

function run_in_background {
    ("$@" >/dev/null 2>&1) &
    disown
}

BOOKMARKS_FILE="$XDG_CONFIG_HOME/rofi/bookmarks.psv"

if ((ROFI_RETV == 0)); then
    echo -en "\0delim\x1f\t\n"
    sort "$BOOKMARKS_FILE" | while IFS="|" read -r type name desc value; do
        IFS=":" read -r type icon <<<"$type"
        if [[ -z "$icon" ]]; then
            case "$type" in
            d) icon="file-manager" ;;
            f) icon="application-text" ;;
            U | u) icon="internet-web-browser" ;;
            esac
        fi
        printf "%s\n%s\0icon\x1f%s\x1finfo\x1f%s:%s\t" "$name" "$desc" "$icon" "$type" "$value"
    done
else
    if [[ -n "$ROFI_DATA" ]]; then
        IFS=":" read -r type value <<<"$ROFI_DATA"
        case "$type" in
        U)
            printf -v url "$value" "$*"
            run_in_background firefox "$url"
            ;;
        esac
    else
        IFS=":" read -r type value <<<"$ROFI_INFO"
        value="${value//\~/$HOME}"
        case "$type" in
        d) run_in_background kitty --directory "$value" ;;
        f) run_in_background xdg-open "$value" ;;
        u) run_in_background firefox "$value" ;;
        U) printf "\0data\x1f%s:%s\t%s\0icon\x1ffsearch\x1fnonselectable\x1ftrue\t" "$type" "$value" "$1" ;;
        esac
    fi
fi
